# Range generator

[![Continuous Integration](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml/badge.svg)](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml)

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

## Supported environments and examples

This info is available only [here](https://console-utils.github.io/).
