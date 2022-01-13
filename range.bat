@echo off
setlocal

call :init
if errorlevel 1 exit /b %ec_unsupported_syntax%

call :clear_arguments args

set /a "i=0"
:copy_options
    set "option=%~1"
    if defined option (
        set "args[%i%]=%option%"
        shift
        set /a "i+=1"
        goto copy_options
    )

set /a "not_wine_used=%false%"

set /a "i=0"
:main_loop
    set /a "j=%i% + 1"
    call set "option=%%args[%i%]%%"
    call set "value=%%args[%j%]%%"

    call :is_option "%option%" -h --help
    if not errorlevel 1 (
        call :help
        exit /b %ec_success%
    )

    call :is_option "%option%" -v --version
    if not errorlevel 1 (
        call :version
        exit /b %ec_success%
    )

    call :is_option "%option%" -i --interactive
    if not errorlevel 1 (
        call :interactive
        exit /b %ec_success%
    )

    call :is_option "%option%" -nw --not-wine
    if not errorlevel 1 (
        set /a "is_wine=%false%"
        set /a "not_wine_used=%true%"
        set /a "i+=1"
        call :init_colors
        goto main_loop
    )

    call :is_option "%option%" -l --limit
    if not errorlevel 1 (
        if not defined value (
            echo Missing value for -l^|--limit found >&2
            exit /b %ec_unsupported_syntax%
        )
        if "%value%" == "0" (
            echo Zero limit used >&2
            exit /b %ec_unsupported_syntax%
        )

        set /a "range_limit=%value%"

        set /a "i+=2"
        goto main_loop
    )

    call :is_match "%option%" "^--"
    if not errorlevel 1 (
        echo Unsupported option "%option%" used >&2
        exit /b %ec_unsupported_syntax%
    )

    set "range=%option%"
    set "next_argument=%value%"

    if not defined range (
        echo Missing range >&2
        exit /b %ec_success%
    )

    if defined next_argument (
        echo Trailing argument "%next_argument%" after first range used >&2
        exit /b %ec_unsupported_syntax%
    )

    if "%not_wine_used%" == "%true%" (
        echo Redundant -nw^|--not-wine option >&2
        exit /b %ec_unsupported_syntax%
    )

    call :try_expand_range range "%range%"
    if errorlevel 1 exit /b %ec_unsupported_syntax%
    echo %range%
    exit /b %ec_success%

:init
    set /a "ec_success=0"
    set /a "ec_unsupported_syntax=2"
    set /a "ec_missing_dependency=2"

    set /a "true=0"
    set /a "false=1"

    gawk --version 2> nul > nul
    if errorlevel 1 (
        echo Missing dependency "gawk" found >&2
        exit /b %ec_missing_dependency%
    )

    set "delimiter= "
    set "prompt=$ "

    set /a "default_range_limit=100"
    set /a "range_limit=%default_range_limit%"

    set /a "is_wine=%false%"
	if defined WINEDEBUG set /a "is_wine=%true%"
exit /b %ec_success%

:init_colors
    call :set_esc

    set "default_color=%esc%[0m"

    if not defined PROMPT_MARKER set "PROMPT_MARKER=%esc%[34m"
    if not defined PROMPT_ERROR_CODE set "PROMPT_ERROR_CODE=%esc%[36m"

    if not defined HELP_HEADER_MARKER set "HELP_HEADER_MARKER=%esc%[36m"
    if not defined HELP_HEADER_ITEM set "HELP_HEADER_ITEM=%esc%[4;96m"
    if not defined HELP_LIST_MARKER set "HELP_LIST_MARKER=%esc%[36m"
    if not defined HELP_LIST_ITEM set "HELP_LIST_ITEM=%esc%[96m"
    if not defined HELP_NOTE_MARKER set "HELP_NOTE_MARKER=%esc%[31m"
    if not defined HELP_NOTE_ITEM set "HELP_NOTE_ITEM=%esc%[91m"

    if not defined SYNTAX_COMMAND_NAME set "SYNTAX_COMMAND_NAME=%esc%[32m"
    if not defined SYNTAX_COMMAND_SWITCH_NAME set "SYNTAX_COMMAND_SWITCH_NAME=%esc%[92m"
    if not defined SYNTAX_COMMAND_SWITCH_TYPE set "SYNTAX_COMMAND_SWITCH_TYPE=%esc%[93m"
exit /b %ec_success%

:help
    setlocal enabledelayedexpansion
    echo Tool to generate ranges and print them into stdout.
    echo.
    echo !HELP_HEADER_MARKER![ !HELP_HEADER_ITEM!Non-interactive mode!default_color! !HELP_HEADER_MARKER!]!default_color!
    echo     !SYNTAX_COMMAND_NAME!range !SYNTAX_COMMAND_SWITCH_NAME!-h!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--help -v!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--version !default_color!^( !SYNTAX_COMMAND_SWITCH_NAME!-nw!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--not-wine !SYNTAX_COMMAND_SWITCH_NAME!-l!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--limit!default_color!:!SYNTAX_COMMAND_SWITCH_TYPE!number !SYNTAX_COMMAND_SWITCH_NAME!-i!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--interactive !default_color!^)
    echo     !SYNTAX_COMMAND_NAME!range !default_color!^( !SYNTAX_COMMAND_SWITCH_NAME!-l!default_color!^|!SYNTAX_COMMAND_SWITCH_NAME!--limit!default_color!:!SYNTAX_COMMAND_SWITCH_TYPE!number !default_color!^<from^>..^<to^>..[^<step^>] ^)
    echo.
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! -h^|--help - Print help!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! -v^|--version - Print version!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! -l^|--limit - Specify random number range limit (default: 100)!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! -nw^|--not-wine - Treat environment as not Wine!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! -i^|--interactive - Start an interactive session!default_color!
	echo.
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 0 - Success!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Missing value for -l^|--limit found!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Unsupported option used!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Missing range!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Trailing argument after first range used!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Redundant -nw^|--not-wine option!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - No previous command found!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Negative step used!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Wrong char used!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! 2 - Not enough characters used!default_color!
    echo.
    echo !HELP_HEADER_MARKER![ !HELP_HEADER_ITEM!Interactive mode!default_color! !HELP_HEADER_MARKER!]!default_color!
	echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! h^|help - Print help!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! v^|version - Print version!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! q^|quit - Exit!default_color!
    echo    !HELP_LIST_MARKER!*!HELP_LIST_ITEM! c^|clear - Clear screen!default_color!
    awk "BEGIN { printf \"   \" }"
    echo.   | set /p "_=!HELP_LIST_MARKER!*!HELP_LIST_ITEM! "
    endlocal
    echo.   | set /p "_=!! - Insert previous command"
    setlocal enabledelayedexpansion
	echo. !default_color!
	echo.
	echo    !HELP_NOTE_MARKER!^> !HELP_NOTE_ITEM!Interactive mode prompt is: ^<return_code^>^>^>^>.!default_color!
    endlocal
exit /b %ec_success%

:version
    echo 2.1 ^(c^) 2022 year
exit /b %ec_success%

:interactive
    set /a "i_last_errorlevel=0"
    set "i_previous_command="

    :i_interactive_loop
        set "i_command="
        
        if "%is_wine%" == "%false%" (
            set /p "i_command=%PROMPT_ERROR_CODE%%i_last_errorlevel% %PROMPT_MARKER%%prompt%%default_color%"
        ) else (
            set /p "i_command=%i_last_errorlevel% %prompt%"
        )

        if not defined i_command goto i_interactive_loop

        set i_command=%i_command:"=%
        if not defined i_command goto i_interactive_loop
        if "%i_command: =%" == "" goto i_interactive_loop
        
        set "i_comment_regex=^#.*$"
        call :is_match "%i_command%" "%i_comment_regex%"
		if not errorlevel 1 goto i_interactive_loop

        set "i_after_remove_exclamation_marks=%i_command:!!=%"

        if defined i_previous_command (
            call set "i_command=%%i_command:!!=%i_previous_command%%%"
        ) else (
            if not "%i_command%" == "%i_after_remove_exclamation_marks%" (
                echo No previous command found
                goto i_interactive_loop
            )
        )

        call :is_option "%i_command%" q quit
        if not errorlevel 1 exit /b %ec_success%
    
        call :is_option "%i_command%" c clear
        if not errorlevel 1 (
            cls
            goto i_interactive_loop
        )

        call :is_option "%i_command%" h help
        if not errorlevel 1 (
            call :help
            goto i_interactive_loop
        )

        call :is_option "%i_command%" v version
        if not errorlevel 1 (
            call :version
            goto i_interactive_loop
        )

        set "i_previous_command=%i_command%"
        call :try_expand_range i_command "%i_command%"
        set /a "i_last_errorlevel=%errorlevel%"
        if %i_last_errorlevel% equ 0 echo %i_command%
        goto i_interactive_loop
exit /b %ec_success%

:try_expand_range
    set /a "ter_ec_positive_step_number_expected=2"

    set "ter_variable_name=%~1"
    set "ter_range_expression=%~2"

    set "ter_first_number="
    set "ter_second_number="
    set "ter_step=1"
    set /a "ter_i=0"

    if "%ter_range_expression%" == "?" set "ter_range_expression=?..?"

    call :skip_spaces ter_i "%ter_range_expression%"
    call :skip_number ter_i ter_first_number "%ter_range_expression%"
    set /a "ter_errorlevel=%errorlevel%"
    if %ter_errorlevel% gtr 0 (
        call :underline_error "%ter_range_expression%" "%ter_i%"
        exit /b %ter_errorlevel%
    )

    call :skip_range_operator ter_i "%ter_range_expression%"
    set /a "ter_errorlevel=%errorlevel%"
    if %ter_errorlevel% gtr 0 (
        call :underline_error "%ter_range_expression%" "%ter_i%"
        exit /b %ter_errorlevel%
    )

    call :skip_number ter_i ter_second_number "%ter_range_expression%"
    set /a "ter_errorlevel=%errorlevel%"
    if %ter_errorlevel% gtr 0 (
        call :underline_error "%ter_range_expression%" "%ter_i%"
        exit /b %ter_errorlevel%
    )

    call set "ter_char=%%ter_range_expression:~%ter_i%,1%%"
    set /a "ter_is_empty_char=%false%"
    if not defined ter_char set /a "ter_is_empty_char=%true%"
    if "%ter_char%" == " " set /a "ter_is_empty_char=%true%"

    if "%ter_is_empty_char%" == "%true%" goto ter_step_evaluation

    call :skip_range_operator ter_i "%ter_range_expression%"
    set /a "ter_errorlevel=%errorlevel%"
    if %ter_errorlevel% gtr 0 (
        call :underline_error "%ter_range_expression%" "%ter_i%"
        exit /b %ter_errorlevel%
    )

    call :skip_number ter_i ter_step "%ter_range_expression%"
    set /a "ter_errorlevel=%errorlevel%"
    if %ter_errorlevel% gtr 0 (
        call :underline_error "%ter_range_expression%" "%ter_i%"
        exit /b %ter_errorlevel%
    )

    :ter_step_evaluation
    if %ter_step% leq 0 (
        echo Negative step "%ter_step%" used >&2
        exit /b %ter_ec_positive_step_number_expected%
    )
    if %ter_first_number% gtr %ter_second_number% set /a "ter_step=-%ter_step%"
    
    set /a "ter_after_first_number=%ter_first_number% + %ter_step%"
    set "ter_range_expression=%ter_first_number%"

    set /a "ter_i=%ter_after_first_number%"
    :ter_range_loop
        if %ter_step% gtr 0 (
            if %ter_i% leq %ter_second_number% (
                set "ter_range_expression=%ter_range_expression%%delimiter%%ter_i%"
                set /a "ter_i+=%ter_step%"
                goto ter_range_loop
            )
        ) else (
            if %ter_i% geq %ter_second_number% (
                set "ter_range_expression=%ter_range_expression%%delimiter%%ter_i%"
                set /a "ter_i+=%ter_step%"
                goto ter_range_loop
            )
        )
    
    set "%ter_variable_name%=%ter_range_expression%"
exit /b %ec_success%

:skip_spaces
    set "ss_index_variable_name=%~1"
    set "ss_string=%~2"

    set /a "ss_i=%ss_index_variable_name%"

    :ss_skip_spaces_loop
        call set "ss_char=%%ss_string:~%ss_i%,1%%"
        if defined ss_char (
            if "%ss_char%" == " " (
                set /a "ss_i+=1"
                goto ss_skip_spaces_loop
            )
        )
    
    set "%ss_index_variable_name%=%ss_i%"
exit /b %ec_success%

:skip_range_operator
    set /a "sro_ec_unexpected_char=2"
    set /a "sro_ec_unexpected_end_of_string=2"

    set "sro_index_variable_name=%~1"
    set "sro_string=%~2"

    set /a "sro_i=%sro_index_variable_name%"
    set /a "sro_skipped_count=0"
    set /a "sro_operator_length=2"

    :sro_skip_range_operator_loop
        call set "sro_char=%%sro_string:~%sro_i%,1%%"
        if %sro_skipped_count% lss %sro_operator_length% (
            if defined sro_char (
                if "%sro_char%" == "." (
                    set /a "sro_skipped_count+=1"
                    set /a "sro_i+=1"
                    goto sro_skip_range_operator_loop
                ) else (
                    echo Wrong char "%sro_char%" used >&2
                    set "%sro_index_variable_name%=%sro_i%"
                    exit /b %sro_ec_unexpected_char%
                )
            ) else (
                echo Not enough characters used >&2
                set "%sro_index_variable_name%=%sro_i%"
                exit /b %sro_ec_unexpected_end_of_string%
            )
        )
    
    set "%sro_index_variable_name%=%sro_i%"
exit /b %ec_success%

:skip_number
    set /a "sn_ec_unexpected_char=2"
    set /a "sn_ec_unexpected_end_of_string=2"

    set "sn_index_variable_name=%~1"
    set "sn_result_number_variable_name=%~2"
    set "sn_string=%~3"
    
    set "sn_result_number="
    set /a "sn_result_number_digit_count=0"
    set /a "sn_i=%sn_index_variable_name%"

    call set "sn_char=%%sn_string:~%sn_i%,1%%"

    if defined sn_char call :sn_internal_if_defined_sn_char

    :sn_skip_number_digits_loop
        call set "sn_char=%%sn_string:~%sn_i%,1%%"
        if not "%sn_char%" == ""  (
            call :is_match "%sn_char%" "[0-9]"
			if errorlevel 1 (
                if "%sn_char%" == "?" (
                    set /a "sn_result_number=%RANDOM% %% %range_limit%"
                    set /a "sn_i+=1"
                ) else (
                    if %sn_result_number_digit_count% equ 0 (
                        set "%sn_index_variable_name%=%sn_i%"
                        echo Wrong char "%sn_char%" used >&2
                        exit /b %sn_ec_unexpected_char%
                    )
                )
            ) else (
                set /a "sn_i+=1"
                set /a "sn_result_number_digit_count+=1"
                set "sn_result_number=%sn_result_number%%sn_char%"
                goto sn_skip_number_digits_loop
            )
        ) else (
            if %sn_result_number_digit_count% equ 0 (
                set "%sn_index_variable_name%=%sn_i%"
                echo Not enough characters used >&2
                exit /b %sn_ec_unexpected_end_of_string%
            )
        )

    set "%sn_index_variable_name%=%sn_i%"
    set /a "%sn_result_number_variable_name%=%sn_result_number%"
exit /b %ec_success%

:sn_internal_if_defined_sn_char
    set /a "sn_is_sign=%false%"
    if "%sn_char%" == "-" set /a "sn_is_sign=%true%"
    if "%sn_char%" == "+" set /a "sn_is_sign=%true%"
    
    if "%sn_is_sign%" == "%true%" (
        set /a "sn_i+=1"
        set "sn_result_number=%sn_char%"
    )
exit /b %ec_success%

:dublicate_string
    set "ds_variable_name=%~1"
    set "ds_string=%~2"
    set /a "ds_count=%~3"

    set "ds_original_string=%ds_string%"
    set "ds_string="

    set /a "ds_i=0"
    :ds_duplicate_loop
        if %ds_i% lss %ds_count% (
            set "ds_string=%ds_string%%ds_original_string%"
            set /a "ds_i+=1"
            goto ds_duplicate_loop
        )

    set "%ds_variable_name%=%ds_string%"
exit /b %ec_success%

:underline_error
    set "ue_string=%~1"
    set "ue_error_position=%~2"

    set "ue_placeholder= "
    call :dublicate_string ue_placeholder "%ue_placeholder%" "%ue_error_position%"

    echo %ue_string%
    echo %ue_placeholder%^^
exit /b %ec_success%

:is_option
    set /a "io_option_is_not_recognized=1"

    set "io_option=%~1"
    set "io_short_option=%~2"
    set "io_long_option=%~3"

    set /a "io_matches=%false%"
    if "%io_option%" == "%io_short_option%" set /a "io_matches=%true%"
    if "%io_option%" == "%io_long_option%" set /a "io_matches=%true%"

    if "%io_matches%" == "%false%" exit /b %io_option_is_not_recognized%
exit /b %ec_success%

:is_match
    set /a "im_match_failed=1"

    set "im_input=%~1"
    set "im_pattern=%~2"

    gawk "BEGIN { exit \"%im_input%\" ~ /%im_pattern%/ }"
    if not errorlevel 1 exit /b %im_match_failed%
exit /b %ec_success%

:clear_arguments
    set "ca_array_name=%~1"

    set /a "ca_i=0"
    :ca_clear_arguments_loop
        call set "ca_argument=%%%ca_array_name%[%ca_i%]%%"
        if defined ca_argument (
            set "%ca_array_name%[%ca_i%]="
            set /a "ca_i+=1"
            goto ca_clear_arguments_loop
        )
exit /b %ec_success%

:set_esc
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "esc=%%b"
        exit /b 0
    )
exit /b %ec_success%
