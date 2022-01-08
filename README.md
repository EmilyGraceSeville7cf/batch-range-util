# Range generator

[![Continuous Integration](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml/badge.svg)](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml)

## Description

Tool to generate ranges and print them into stdout.

## Syntax

```bat
range { -h | --help } { -v | --version } { -i | --interactive }
range <from>..<to>[..<step>]
```

| Short option |   Long option   | Description                  |
| :----------: | :-------------: | :--------------------------- |
|     `-h`     |    `--help`     | Print help                   |
|     `-v`     |   `--version`   | Print version                |
|     `-i`     | `--interactive` | Start an interactive session |

## Return codes

| Return code | Description                              |
| :---------: | :--------------------------------------- |
|     `0`     | Success                                  |
|     `2`     | Unsupported option used                  |
|     `2`     | Trailing argument after first range used |
|     `2`     | No previous command found                |
|     `2`     | Negative step used                       |
|     `2`     | Wrong char used                          |
|     `2`     | Not enough characters used               |

## Supported environments and examples

This info is available only [here](https://console-utils.github.io/).
