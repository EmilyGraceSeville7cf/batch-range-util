@echo off
setlocal

call :init

:main_loop
    set "option=%~1"
    set "value=%~2"

    set /a "is_help=%false%"
    if "%option%" == "-h" set /a "is_help=%true%"
    if "%option%" == "--help" set /a "is_help=%true%"

    if "%is_help%" == "%true%" (
        call :help
        exit /b %ec_success%
    )

    set /a "is_version=%false%"
    if "%option%" == "-v" set /a "is_version=%true%"
    if "%option%" == "--version" set /a "is_version=%true%"

    if "%is_version%" == "%true%" (
        call :version
        exit /b %ec_success%
    )

    set /a "is_interactive=%false%"
    if "%option%" == "-i" set /a "is_interactive=%true%"
    if "%option%" == "--interactive" set /a "is_interactive=%true%"

    if "%is_interactive%" == "%true%" (
        call :interactive
        exit /b %ec_success%
    )

    set "range=%option%"
    set "next_argument=%value%"

    call :try_expand_range range "%range%"
    set /a "temp_errorlevel=%errorlevel%"
    if %temp_errorlevel% equ 0 (
        if not "%next_argument%" == "" (
            echo %em_too_many_arguments% >&2
            exit /b %ec_too_many_arguments%
        )
        echo %range%
    )
    exit /b %temp_errorlevel%

:init
    set /a "ec_success=0"

    set /a "ec_too_many_arguments=10"
    set /a "ec_first_number_expected=20"
    set /a "ec_second_number_expected=21"
    set /a "ec_step_number_expected=22"
    set /a "ec_wrong_range_syntax=23"
    set /a "ec_nonzero_step_number_expected=24"

    set "em_too_many_arguments=Only one range in accepted."
    set "em_first_number_expected=First range border is not specified."
    set "em_second_number_expected=Second range border is not specified."
    set "em_step_number_expected=Range step is not specified."
    set "em_wrong_range_syntax=Range syntax expected low..high[..step]."
    set "em_nonzero_step_number_expected=Range step must be nonzero."

    set /a "true=0"
    set /a "false=1"

    set "delimiter= "
    set "prompt=>>> "

    call :set_esc
exit /b %ec_success%

:help
    echo Prints number range.
    echo.
    echo Syntax:
    echo    range [options] first..second[..step]
    echo.
    echo Options:
    echo    -h^|--help - writes help and exits
    echo    -v^|--version - writes version and exits
    echo    -i^|--interactive - fall in interactive mode
    echo.
    echo If range is specified before some option then it is ignored.
    echo If more than one range is specified only first one is written.
    echo.
    echo Interactive mode commands:
    echo    q^|quit - exits
    echo    c^|clear - clears screen
    echo    h^|help - writes help
    echo.
    echo Examples:
    echo    - range --help
    echo    - range 0..10
    echo    - range 0..10..2
    echo    - range 0..10 --help (--help option is ignored)
exit /b %ec_success%

:version
    echo 1.0 ^(c^) 2021 year
exit /b %ec_success%

:interactive
    set /a "i_last_errorlevel=0"

    :interactive_loop
        set /a "i_color_code=32"
        if not %i_last_errorlevel% == 0 set /a "i_color_code=31"
        set /p "i_command=%esc%[%i_color_code%m%i_last_errorlevel% %prompt%%esc%[0m"

        if "%i_command%" == "" goto interactive_loop
        
        set "i_comment_regex=^#.*$"
        echo %i_command%| findstr /R "%i_comment_regex%" 2> nul > nul && goto interactive_loop

        set "i_command=%i_command: =%"
        call set "i_command=%%i_command:!!=%i_previous_command%%%"

        set /a "i_is_quit=%false%"
        if "%i_command%" == "q" set /a "i_is_quit=%true%"
        if "%i_command%" == "quit" set /a "i_is_quit=%true%"

        if "%i_is_quit%" == "%true%" exit /b %ec_success%
    
        set /a "i_is_clear=%false%"
        if "%i_command%" == "c" set /a "i_is_clear=%true%"
        if "%i_command%" == "clear" set /a "i_is_clear=%true%"

        if "%i_is_clear%" == "%true%" (
            cls
            goto interactive_loop
        )

        set /a "i_is_help=%false%"
        if "%i_command%" == "h" set /a "i_is_help=%true%"
        if "%i_command%" == "help" set /a "i_is_help=%true%"

        if "%i_is_help%" == "%true%" (
            call :help
            goto interactive_loop
        )

        set "i_previous_command=%i_command%"
        call :try_expand_range i_command "%i_command%"
        set /a "i_last_errorlevel=%errorlevel%"
        if %i_last_errorlevel% equ 0 echo %i_command%
        goto interactive_loop
exit /b %ec_success%

:try_expand_range
    set "ter_variable_name=%~1"
    set "ter_range_expression=%~2"

    set "ter_simple_range_regex=^[0-9][0-9]*\.\.[0-9][0-9]*$ ^-[0-9][0-9]*\.\.[0-9][0-9]*$ ^[0-9][0-9]*\.\.-[0-9][0-9]*$ ^-[0-9][0-9]*\.\.-[0-9][0-9]*$"
    set "ter_stepped_range_regex=^[0-9][0-9]*\.\.[0-9][0-9]*\.\.[0-9][0-9]*$ ^-[0-9][0-9]*\.\.[0-9][0-9]*\.\.[0-9][0-9]*$ ^[0-9][0-9]*\.\.-[0-9][0-9]*\.\.[0-9][0-9]*$ ^-[0-9][0-9]*\.\.-[0-9][0-9]*\.\.[0-9][0-9]*$"

    set "ter_missing_first_number_regex=^\.\.[0-9][0-9]*$ ^\.\.-[0-9][0-9]*$"
    set "ter_missing_second_number_regex=^[0-9][0-9]*$ ^-[0-9][0-9]*$ ^[0-9][0-9]*\.\.$ ^-[0-9][0-9]*\.\.$"
    set "ter_missing_step_regex=^[0-9][0-9]*\.\.[0-9][0-9]*\.\.$ ^-[0-9][0-9]*\.\.[0-9][0-9]*\.\.$ ^[0-9][0-9]*\.\.-[0-9][0-9]*\.\.$ ^-[0-9][0-9]*\.\.-[0-9][0-9]*\.\.$"

    echo %ter_range_expression%| findstr /R "%ter_simple_range_regex%" 2> nul > nul && (
        set "ter_range_expression=%ter_range_expression%..1"
    ) || (
        echo %ter_range_expression%| findstr /R "%ter_stepped_range_regex%" 2> nul > nul || (
            echo %ter_range_expression%| findstr /R "%ter_missing_first_number_regex%" 2> nul > nul && (
                echo %em_first_number_expected% >&2
                exit /b %ec_first_number_expected%
            )

            echo %ter_range_expression%| findstr /R "%ter_missing_second_number_regex%" 2> nul > nul && (
                echo %em_second_number_expected% >&2
                exit /b %ec_second_number_expected%
            )

            echo %ter_range_expression%| findstr /R "%ter_missing_step_regex%" 2> nul > nul && (
                echo %em_step_number_expected% >&2
                exit /b %ec_step_number_expected%
            )

            echo %em_wrong_range_syntax% >&2
            exit /b %ec_wrong_range_syntax%
        )
    )

    set "ter_first_number="
    set "ter_second_number="
    set "ter_step="

    set /a "i=-1"
    :ter_get_first_number_range
        set /a "i+=1"
        call set "ter_char=%%ter_range_expression:~%i%,1%%"
        if not "%ter_char%" == "." (
            set "ter_first_number=%ter_first_number%%ter_char%"
            goto :ter_get_first_number_range
        )
    
    set /a "i+=1"

    :ter_get_second_number_range
        set /a "i+=1"
        call set "ter_char=%%ter_range_expression:~%i%,1%%"
        if not "%ter_char%" == "." (
            set "ter_second_number=%ter_second_number%%ter_char%"
            goto :ter_get_second_number_range
        )

    set /a "i+=1"

    :ter_get_step_range
        set /a "i+=1"
        call set "ter_char=%%ter_range_expression:~%i%,1%%"
        if defined ter_char (
            set "ter_step=%ter_step%%ter_char%"
            goto :ter_get_step_range
        )

    if "%ter_step%" == "0" (
        echo %em_nonzero_step_number_expected% >&2
        exit /b %ec_nonzero_step_number_expected%
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

:set_esc
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "esc=%%b"
        exit /b 0
    )
exit /b %ec_success%
