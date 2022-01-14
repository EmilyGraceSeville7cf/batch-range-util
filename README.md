# Range generator

[![Continuous Integration](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml/badge.svg)](https://github.com/Console-Utils/batch-range-util/actions/workflows/ci.yml)

## Description

Tool to generate ranges and print them into stdout.

## Syntax

```bat
range -h|--help -v|--version ( -nw|--not-wine -l|--limit:number \
  -i|--interactive )
range ( -l|--limit:number <from>..<to>..[<step>] )
```

| Short option |   Long option   | Default | Description                       |
| :----------: | :-------------: | :-----: | :-------------------------------- |
|     `-h`     |    `--help`     |    -    | Print help                        |
|     `-v`     |   `--version`   |    -    | Print version                     |
|     `-l`     |    `--limit`    |   100   | Specify random number range limit |
|    `-nw`     |  `--not-wine`   |    -    | treat environment as not Wine     |
|     `-i`     | `--interactive` |    -    | Start an interactive session      |

## Return codes

| Return code | Description                              |
| :---------: | :--------------------------------------- |
|     `0`     | Success                                  |
|     `2`     | Missing value for -l&#124;--limit found  |
|     `2`     | Unsupported option used                  |
|     `2`     | Missing range                            |
|     `2`     | Trailing argument after first range used |
|     `2`     | Redundant -nw&#124;--not-wine option     |
|     `2`     | No previous command found                |
|     `2`     | Negative step used                       |
|     `2`     | Wrong char used                          |
|     `2`     | Not enough characters used               |

## Supported environments and examples

This info is available only [here](https://console-utils.github.io/).
