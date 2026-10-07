"""
Browser init for flash Harbor tasks.

Chromium binds to 127.0.0.1:19222 (default).
nginx proxies 0.0.0.0:9222 → 127.0.0.1:19222, rewriting Host: localhost so
Chromium's DNS-rebinding check passes. nginx also handles WebSocket upgrades,
so agents can connect via connect_over_cdp("http://browser:9222").

When INJECT_BUG=true, merges bug.js into the bug_injector.js runner template
and registers it as a Playwright init script so it fires on every navigation.

SETUP_FUNCTION selects which app login to run before the browser is handed off.

"""

from __future__ import annotations

import os
import re
import signal
import subprocess
import sys
import time
import urllib.request
from pathlib import Path

from playwright.sync_api import Page, sync_playwright

APP_URL = os.environ.get("APP_URL", "http://localhost:80")
INJECT_BUG = os.environ.get("INJECT_BUG", "false").lower() == "true"
SETUP_FUNCTION = os.environ.get("SETUP_FUNCTION", "")
BUG_JS = Path("/bug.js")
BUG_INJECTOR = Path("/bug_injector.js")

CDP_PORT = 9222  # nginx public port
CDP_INTERNAL_PORT = 19222  # Chromium's actual port (127.0.0.1 only)

NGINX_CONF = f"""\
events {{}}
http {{
    map $http_upgrade $connection_upgrade {{
        default upgrade;
        ''      close;
    }}
    server {{
        listen {CDP_PORT};
        gzip off;

        location / {{
            proxy_pass         http://127.0.0.1:{CDP_INTERNAL_PORT};
            proxy_set_header   Host "localhost:{CDP_INTERNAL_PORT}";
            proxy_http_version 1.1;
            proxy_set_header   Upgrade         $http_upgrade;
            proxy_set_header   Connection      $connection_upgrade;
            proxy_set_header   Accept-Encoding "";

            # CDP websockets can sit idle for minutes during a single LLM-driven
            # action; nginx's 60s default proxy_read_timeout/proxy_send_timeout
            # would otherwise drop the connection mid-action.
            proxy_read_timeout 3600s;
            proxy_send_timeout 3600s;

            # Rewrite ws:// URLs in JSON responses so agents can reach
            # Chromium via the Docker service name (browser:9222).
            sub_filter         '"ws://localhost:{CDP_INTERNAL_PORT}/' '"ws://browser:{CDP_PORT}/';
            sub_filter         '"ws://127.0.0.1:{CDP_INTERNAL_PORT}/' '"ws://browser:{CDP_PORT}/';
            sub_filter_once    off;
            sub_filter_types   application/json;
        }}
    }}
}}
"""


# ---------------------------------------------------------------------------
# App setup (login) functions
# ---------------------------------------------------------------------------


def _setup_bookstack(page: Page) -> None:
    page.goto(f"{APP_URL}/login", wait_until="domcontentloaded", timeout=30_000)
    page.get_by_role("textbox", name="Email").fill("admin@admin.com")
    page.get_by_role("textbox", name="Password").fill("password")
    page.get_by_role("button", name="Log In").click()
    page.wait_for_load_state("domcontentloaded")
    page.wait_for_function(
        "() => !window.location.pathname.includes('/login')",
        timeout=30_000,
    )


def _setup_indico(page: Page) -> None:
    page.goto(f"{APP_URL}/login/", wait_until="domcontentloaded", timeout=30_000)
    page.get_by_role("textbox", name="Username or email").fill("admin@admin.com")
    page.get_by_role("textbox", name="Password").fill("webtestpilot")
    page.get_by_role("button", name="Login with Indico").click()
    page.wait_for_load_state("domcontentloaded")
    heading = page.get_by_role("heading", name="February 2025")
    show = page.get_by_role("link", name="Show").first
    for _ in range(50):
        if heading.is_visible():
            break
        if show.is_visible():
            show.click()
        page.wait_for_timeout(200)
    else:
        raise TimeoutError("February 2025 heading never appeared")


def _setup_invoiceninja(page: Page) -> None:
    page.goto(f"{APP_URL}/login", wait_until="domcontentloaded", timeout=30_000)
    page.locator('input[name="email"]').fill("admin@admin.com")
    page.get_by_role("textbox", name="Password").fill("password")
    page.get_by_role("button", name="Login").click()
    page.get_by_role("button", name="Save").click()
    page.wait_for_load_state("domcontentloaded")


def _setup_prestashop_seller(page: Page) -> None:
    page.goto(f"{APP_URL}/webtestpilot/", wait_until="domcontentloaded", timeout=30_000)
    page.get_by_role("textbox", name="Email address").fill("admin@admin.com")
    page.get_by_role("textbox", name="Password").fill("admin12345")
    page.get_by_role("button", name="Log in").click()
    page.get_by_role("heading", name="Dashboard").wait_for(state="visible", timeout=30_000)


def _setup_prestashop_buyer(page: Page) -> None:
    page.goto(APP_URL, wait_until="domcontentloaded", timeout=30_000)
    page.get_by_role("link", name=" Sign in").click()
    page.get_by_role("textbox", name="Email").fill("auto.customer@example.com")
    page.get_by_role("textbox", name="Password input").fill("mypassword")
    page.get_by_role("button", name="Sign in").click()
    page.wait_for_load_state("domcontentloaded")


_SETUP_FUNCTIONS: dict[str, object] = {
    "login_to_bookstack": _setup_bookstack,
    "login_to_indico": _setup_indico,
    "login_to_invoiceninja": _setup_invoiceninja,
    "login_to_prestashop_as_seller": _setup_prestashop_seller,
    "login_to_prestashop_as_buyer": _setup_prestashop_buyer,
}


# ---------------------------------------------------------------------------


def prepare_bug_script(bug_js: str, template: str, kind: str) -> str:
    """Merge one bug definition into the browser injector template."""
    is_cond = re.findall(
        r"// BEGIN isConditionMet\s*(.*?)\s*// END isConditionMet", bug_js, re.DOTALL
    )
    on_cond = re.findall(
        r"// BEGIN onConditionMet\s*(.*?)\s*// END onConditionMet", bug_js, re.DOTALL
    )
    script = template.replace("const isConditionMet = () => {};", is_cond[-1])
    script = script.replace("const onConditionMet = () => {};", on_cond[-1])
    script = script.replace("{{INJECTOR_KIND}}", kind)
    return script


def main() -> None:
    with sync_playwright() as p:
        chromium_proc = subprocess.Popen(
            [
                p.chromium.executable_path,
                "--headless",
                "--no-sandbox",
                "--disable-dev-shm-usage",
                "--disable-gpu",
                f"--remote-debugging-port={CDP_INTERNAL_PORT}",
                "--remote-allow-origins=*",
                "--no-first-run",
                "--no-default-browser-check",
                # Prevent Chrome from showing HTTPS-upgrade interstitials for HTTP app URLs.
                "--disable-features=HttpsFirstBalancedMode,HttpsUpgrades,HttpsFirstModeIncognito,HttpsFirstModeV2ForTypicallySecureUsers",
                f"--unsafely-treat-insecure-origin-as-secure={APP_URL}",
                "--ignore-certificate-errors",
                "--allow-running-insecure-content",
            ]
        )

        # Wait for Chromium's internal CDP endpoint
        deadline = time.time() + 30
        while time.time() < deadline:
            try:
                urllib.request.urlopen(
                    f"http://127.0.0.1:{CDP_INTERNAL_PORT}/json/version", timeout=1
                )
                break
            except Exception:
                time.sleep(0.5)
        else:
            chromium_proc.terminate()
            print("[init] Chromium CDP not ready after 30s", file=sys.stderr)
            sys.exit(1)

        browser = p.chromium.connect_over_cdp(f"http://127.0.0.1:{CDP_INTERNAL_PORT}")
        context = browser.contexts[0] if browser.contexts else browser.new_context()

        # Register the bug script before navigation. It waits for the
        # post-setup flag before applying a mutation.
        if INJECT_BUG and BUG_JS.exists():
            script = prepare_bug_script(BUG_JS.read_text(), BUG_INJECTOR.read_text(), "bug")
            context.add_init_script(script)
            print("[init] Bug script injected (INJECT_BUG=true)")
        else:
            print(f"[init] No bug injection (INJECT_BUG={os.environ.get('INJECT_BUG', 'false')})")

        page = context.pages[0] if context.pages else context.new_page()
        page.set_viewport_size({"width": 1280, "height": 720})

        setup_fn = _SETUP_FUNCTIONS.get(SETUP_FUNCTION)
        if setup_fn:
            try:
                setup_fn(page)
                print(f"[init] Setup complete ({SETUP_FUNCTION})")
            except Exception as e:
                print(f"[init] Setup failed ({SETUP_FUNCTION}): {e}", file=sys.stderr)
                browser.close()
                chromium_proc.terminate()
                sys.exit(1)
        else:
            try:
                page.goto(APP_URL, wait_until="domcontentloaded", timeout=30_000)
            except Exception as e:
                print(f"[init] Navigation warning: {e}")

        # Activate the bug script after setup and reload the current page.
        if INJECT_BUG and BUG_JS.exists():
            page.evaluate("sessionStorage.setItem('__flash_ui_active__', 'true')")
            try:
                page.reload(wait_until="domcontentloaded", timeout=30_000)
            except Exception as e:
                print(f"[init] Reload warning: {e}")

        # Hand over a fully loaded start page: apps keep rendering after
        # DOMContentLoaded (e.g. Indico loads its event months by XHR), and bugs
        # that count page visits must see the start page as the first one.
        try:
            page.wait_for_load_state("networkidle", timeout=30_000)
        except Exception as e:
            print(f"[init] Start page did not reach network idle: {e}")

        # Expose CDP only after setup has finished so agents cannot attach mid-login.
        nginx_conf_path = Path("/tmp/cdp-nginx.conf")
        nginx_conf_path.write_text(NGINX_CONF)
        nginx_proc = subprocess.Popen(
            [
                "nginx",
                "-c",
                str(nginx_conf_path),
                "-g",
                "daemon off;",
            ]
        )
        # Give nginx a moment to bind the port
        time.sleep(1)

        print(f"[init] Ready: nginx 0.0.0.0:{CDP_PORT} → Chromium 127.0.0.1:{CDP_INTERNAL_PORT}")

        def _shutdown(sig, _frame):
            nginx_proc.terminate()
            chromium_proc.terminate()
            sys.exit(0)

        signal.signal(signal.SIGTERM, _shutdown)
        signal.signal(signal.SIGINT, _shutdown)

        while True:
            if chromium_proc.poll() is not None:
                print(f"[init] Chromium exited (code {chromium_proc.returncode})", file=sys.stderr)
                nginx_proc.terminate()
                sys.exit(1)
            if nginx_proc.poll() is not None:
                print("[init] nginx exited unexpectedly", file=sys.stderr)
                chromium_proc.terminate()
                sys.exit(1)
            time.sleep(5)


if __name__ == "__main__":
    main()
