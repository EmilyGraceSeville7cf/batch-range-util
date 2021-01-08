# Description

seq alternative for Batch Script. Prints number range.

# Syntax
```bat
range [options] first..second[..step]
```

# Options
- `-h|--help` - writes help and exits
- `-v|--version` - writes version and exits
- `-i|--interactive` - fall in interactive mode

If range is specified before some option then it is ignored.
If more than one range is specified only first one is written.

Interactive mode commands:
- `q|quit` - exits
- `c|clear` - clears screen
- `h|help` - writes help

# Examples
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
