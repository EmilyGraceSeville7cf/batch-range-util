# Range

## Description

Prints number range.

## Syntax
```bat
range [options] first..second[..step]
```

## Options

- `-h`|`--help` - writes help and exits
- `-v`|`--version` - writes version and exits
- `-i`|`--interactive` - fall in interactive mode

### Interactive

Interactive mode commands:
- `q`|`quit` - exits
- `c`|`clear` - clears screen
- `h`|`help` - writes help

## Return codes
- `0` - Success
- `10` - Other options or ranges are not allowed after first range construction.
- `20` - Positive step number expected.
- `30` - Unexpected char found instead of range operator (..).
- `31` - Unexpected end of string found instead of range operator (..).
- `40` - Unexpected char found instead of digit or number sign.
- `41` - Unexpected end of string found instead of digit or number sign.

## Notes

If range is specified before some option then it is ignored.
If more than one range is specified only first one is written.

## Examples
```bat
range --help
```
```bat
range 0..10
```
```bat
range 0..10..2
```
```bat
range 0..10 --help
```
