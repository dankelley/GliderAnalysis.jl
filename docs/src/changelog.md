# Changes

## Changelog from version 0.2.12 to version 0.2.13

Release notes:

### Changed

- `get_erddap_index()`, `get_tide_gauge_index()`, and
  `get_tide_gauge_metadata()` handle non-responsive URLs better,
  without dumping pages of confusing output from the server.

- BREAKING

### Added

- `interpolate_to_time()`, used by `read_glider()` but also perhaps useful for
  more general purposes, too.


