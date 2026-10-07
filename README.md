# WebTestPilot Benchmark

This repository contains GUI test cases, bug injection scripts, and reproducible environments for four web applications. It is derived from the [original WebTestPilot benchmark](https://github.com/code-philia/WebTestPilot/tree/b0659bd9908f11c7957602a9372fc100dda50e40/benchmark), with revised test steps and expected results. The `change_*` UI experiments are no longer part of this benchmark.

## Repository structure

```text
<app>/
  test_cases/<task>.yaml   # ordered test steps and expected results
  bugs/<task>.js           # optional bug injection script for the same task
  environment/             # Compose, seed data, app images, and app configuration
runtime/                   # shared browser, login, and bug injection files
app_config.json            # app URLs, copied assets, and account reference data
template.yaml              # YAML example
template.js                # bug script example
```

There are 100 test cases across BookStack, Indico, Invoice Ninja, and PrestaShop. The YAML filename identifies the task; a bug script with the same filename stem is used when that task is run with bug injection enabled. Each app's `environment/` contains its Compose stack and seed assets. Shared browser startup, login setup, and bug injection live in `runtime/`. A runner assembles these inputs into isolated task environments.

## Test case format

Each YAML file describes one task. `steps` is an ordered list: `action` tells the tester what to do and `expectation` states the expected visible result. The remaining step fields are ground truth that only the benchmark's oracle sees: `solution` performs the action, `url` and `action_check` judge whether the action reached the right state.

```yaml
name: Comment
setup_function: login_to_bookstack
steps:
- action: From the dashboard click 'Page Template' link
  expectation: Page contains title 'Page Template'
  action_check: |
    expect(page.locator("#bkmrk-page-title")).to_match_aria_snapshot("- heading \"Page Template\" [level=1]")
  url: /books/book/page/page-template
  solution: |
    page.locator("#recently-viewed").get_by_role("link", name="Page Template").click()
```

| Field | Meaning |
| --- | --- |
| `name` | Human-readable task name. |
| `setup_function` | Optional runner setup or login function to call before the task. |
| `description` | Optional description of the task. |
| `steps[].action` | Action to perform in the browser. |
| `steps[].expectation` | Expected result in natural language. |
| `steps[].action_check` | Optional Playwright Python assertion that the action reached the right state. It must only read the page, and it must pass whether or not the task's bug is injected: it judges the action, not the app. |
| `steps[].url` | Optional page path expected after the action, checked before `action_check`. |
| `steps[].solution` | Required Playwright code that performs the action on `page`. |
| `assertion_check` | Optional task-level Playwright assertion on the final page, written as static values from the seed (patterns for times and today's dates). It must pass when the task runs without its bug and fail with the bug injected, proving the bug is observable. Only the reference solution's replay runs it; agents are never scored on it. |

The filename stem is the stable task identifier. Use a unique stem within each app, and keep a matching bug script under `bugs/` when testing bug detection. A bug script contains `isConditionMet` and `onConditionMet` blocks delimited by the markers shown in [`template.js`](template.js).

## Web applications and accounts

These are the application image versions and **web login** accounts defined by this repository's environment files and login setup; database credentials are separate. The PrestaShop 8.2.8 Apache image is pinned by digest in its app Dockerfile.

| Web app | Application version / image | Login | Password | Notes |
| --- | --- | --- | --- | --- |
| BookStack | `solidnerd/bookstack:25.2.1` | `admin@admin.com` | `password` | Admin account |
| Indico | `3.3.6` (`pip install indico==3.3.6`) | `admin@admin.com` | `webtestpilot` | Admin account |
| Invoice Ninja | `invoiceninja/invoiceninja-debian:5.11.61-d` | `admin@admin.com` | `password` | Admin account |
| PrestaShop | `prestashop/prestashop:8.2.8-apache` | `admin@admin.com` | `admin12345` | Seller; admin path `/webtestpilot/` |
| PrestaShop | `prestashop/prestashop:8.2.8-apache` | `auto.customer@example.com` | `mypassword` | Buyer account |

## Adding a new task

1. Add `<app>/test_cases/<task>.yaml` using [`template.yaml`](template.yaml) and an existing test case as examples. Give each step an action and a specific expectation; add `action_check` assertions where they can check the action's result directly. Every step must have a `solution`: the ground-truth Playwright code that performs the action on `page` (with `expect` and `re` available). Replays run much faster than a person, so end a solution with an `expect` wait when the app updates its state late, for example an editor syncing into a hidden form field. The adapter refuses to generate the benchmark while any step lacks one, and it builds each task's `solution/solve.sh` for Harbor's oracle agent from them. Optionally give each step a `url`, the page path expected after the action (`/books`, `/search?term=`, or a `^...$` regex over the path), which the oracle checks before `action_check`.
2. Set `setup_function` when the task needs a particular logged-in session. The supported functions are registered in [`runtime/init.py`](runtime/init.py).
3. If the task has an injected bug, add `<app>/bugs/<task>.js` using [`template.js`](template.js). Keep the `// BEGIN` and `// END` markers around both functions.
4. Run the task through the intended runner to check the setup, each step, and the bug condition. `just exp oracle-task <task>` replays the solution on the generated task and should score `task_completed` 1.

## Adding a new app

1. Create `<app>/test_cases/`, `<app>/environment/`, and, if the app has injected bugs, `<app>/bugs/`. Add YAML cases and matching bug scripts using the existing naming convention.
2. Add the app's `docker-compose.yaml`, `seed.sql`, and `seed-loader.sh` under `<app>/environment/`. Put app-specific Dockerfiles, config files, and optional `baseline.sql` there too. See [`runtime/BASELINE.md`](runtime/BASELINE.md) for baseline semantics.
3. Add an entry to [`app_config.json`](app_config.json) with `app_url`, `extra_files`, and `extra_dirs` for app-specific assets copied into each task. Its `credentials` field is reference documentation; the login code reads its own values from `runtime/init.py`.
4. Implement any new `setup_function` in [`runtime/init.py`](runtime/init.py), register it in `_SETUP_FUNCTIONS`, and update the version and test account table above.
5. Generate and run the app's tasks with a consumer of this benchmark to verify its environment and steps.
