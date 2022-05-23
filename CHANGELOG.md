# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- an incorrect directory structure was preventing the dub package from building.
- some syntax in this changelog had been left out.

## [2.0.0] - 2022-05-22
### Added
- this changelog! 🎉
- a new range interface - a _random access range with slicing_ - has been added that more closely follows standard practice, replacing the previous implementation that confused ranges with containers.
 - for more information on ranges, see [std.range.primitives](https://dlang.org/phobos/std_range_primitives.html).
- the previously existing unittests have been cleaned up and added to the documentation.

### Changed
- `opIndex()` now returns a range rather than a slice.
 - to compare `foo[]` with an array of elements, use `std.algorithm.comparison.equal` instead of `==`.
- gc using, throwing, inpure, and `@system` - using types are now permitted as element types. note that using such types will make the `FixedString` use those attributes accordingly; you cannot have a `FixedString!(N, SomeClass)` and expect it to work in `@nogc` code.
- the `FixedString!"string"` helper template has been changed to `fixedString!"string"`, so as to conform with the standard D style.

### Removed
- `empty()`, `front()`, and `popFront()` have been removed. use the new range interface instead.
- it is no longer possible to modify out-of-bounds elements with `opIndex`, even if the maximum size of the `FixedString` would allow it. change `length` first before modifying, or use the `~=` operator.

### Fixed
- `opAssign`, `opOpAssign`, `opEquals`, `concat` and `opBinary` all assumed they would only ever be used with the `char` element type. this oversight has been fixed.
- `opSlice` is now bounds checked.
- now compatible with dip1000.

## [1.2.0] - 2022-04-12
### Changed
- when concatenating with the `~` operator, the nearest minimum power of two is used rather than the total size. this helps with template bloat. if you need the old behaviour, use `foo.concat!(foo.size + bar.size)(bar)` instead.

### Fixed
- documentation should now show up correctly in parsers.
- several lint and coverage fixes.

## [1.1.0] - 2022-01-12
### Added
- a shorter syntax (`FixedString!"string"`)
- you can now use fixedstring with any type, not just char. note that non-char types do not have a custom toString implementation
- a small sampling of examples has been added to the readme.

## [1.0.0] - 2022-01-10
- initial release.

[Unreleased]: https://github.com/Moth-Tolias/fixedstring/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/Moth-Tolias/fixedstring/compare/v1.2.0...v2.0.0
[1.2.0]: https://github.com/Moth-Tolias/fixedstring/compare/v1.0.0...v1.2.0
[1.1.0]: https://github.com/Moth-Tolias/fixedstring/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Moth-Tolias/fixedstring/releases/tag/v1.0.0
