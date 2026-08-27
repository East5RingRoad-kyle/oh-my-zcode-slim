# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.1] - 2026-08-27

### Fixed

- Self-test now pings all nine roles (eight leaf roles in parallel, then
  `council`) instead of only `explorer`, and reports a nine-row PASS/FAIL
  table.
- Hardened the self-test protocol into a fixed nine-dispatch sequence:
  `council` is mandatory as the ninth dispatch, and the report must contain
  exactly nine rows with no early stop.

### Changed

- Expanded "怎么用 / Usage" with a step-by-step orchestration example
  (Simplified Chinese and English).

## [0.1.0] - 2026-08-27

### Added

- Nine native ZCode subagents: `explorer`, `oracle`, `librarian`, `fixer`,
  `designer`, `observer`, `council`, `councillor-alpha`, `councillor-beta`.
- `omzs-dispatch` and `omzs-deepwork` orchestrator skills.
- `install.sh`, `uninstall.sh`, and `check-update.sh`.
- Version tracking via `VERSION` and the install stamp file.
- README in Simplified Chinese and English.

[Unreleased]: https://github.com/East5RingRoad-kyle/oh-my-zcode-slim/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/East5RingRoad-kyle/oh-my-zcode-slim/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/East5RingRoad-kyle/oh-my-zcode-slim/releases/tag/v0.1.0
