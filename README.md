# WebTestPilot benchmark for FLASH

This repository contains the benchmark source consumed by the FLASH adapter.
It is based on the [original WebTestPilot benchmark](https://github.com/code-philia/WebTestPilot/tree/main/benchmark), with the current FLASH test case and expected result revisions. The `change_*` UI experiments have been removed.

The four app directories contain 100 YAML test cases and their matching bug scripts. `template.yaml` and `template.js` provide source examples.

FLASH pins this repository as the `adapter/source` submodule. After cloning FLASH, run `just setup-benchmark` (or `just setup`) before `just build-benchmark`.
