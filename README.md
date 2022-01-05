# Range generator

## Description

Tool to generate ranges and print them into stdout.

## Syntax

```bat
range [{ -h | --help }] [{ -v | --version }] { -i | --interactive }
range <from>..<to>[..<step>]
```

| Short option |   Long option   | Description                  |
| :----------: | :-------------: | :--------------------------- |
|     `-h`     |    `--help`     | Print help                   |
|     `-v`     |   `--version`   | Print version                |
|     `-i`     | `--interactive` | Start an interactive session |

## Return codes

| Return code | Description                                                            |
| :---------: | :--------------------------------------------------------------------- |
|     `0`     | Success                                                                |
|    `10`     | Other options or ranges are not allowed after first range construction |
|    `20`     | Positive step number expected                                          |
|    `30`     | Unexpected char found instead of range operator (..)                   |
|    `31`     | Unexpected end of string found instead of range operator (..)          |
|    `40`     | Unexpected char found instead of digit or number sign                  |
|    `41`     | Unexpected end of string found instead of digit or number sign         |

## Examples

Prints help:

```batch
range --help
```

Generates 1 2 3 4 5 6 7 8 9 10 sequence:

```batch
range 1..10
```

Generates 1 3 5 7 9 sequence:

```batch
range 1..10..2
```

Generates 10 9 8 7 6 5 4 3 2 1 sequence:

```batch
range 10..1
```

Generates 10 8 6 4 2 sequence:

```batch
range 10..1..-2
```
