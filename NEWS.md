# wikimapR 0.1.2 (2023-05-14)

## New features

- Added `set_wikimapia_api_key()` to make API keys available for all Wikimapia API
calls in a session so you don't have to keep specifying the wm_api_key argument
each time

## Breaking changes

- `wm_get_by_id()` changed the main argument from `x` to `ids`. This is more intuitive, since the function accepts vectors of length > 1. It is also easier to debug the code now. Help section fixed accordingly

## Minor improvements and fixes

- Fixed issue/bug #1 (errors due to deprecation of `dplyr::progress_estimated()` )
- Removed unneeded dependencies (`lwgeom`, `rlist`), add `progress` dependency due to deprecation of `dplyr::progress_estimated()`


# wikimapR 0.1.1 (2018-12-17)

- Initial public release



