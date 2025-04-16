@echo off
setlocal enabledelayedexpansion

:: Set log file path
set "logfile=%~dp0cleanup_log.txt"

:: Start with a fresh log file
echo Script started: %date% %time% > "%logfile%"
echo Script started: %date% %time%

:: Function to echo to both console and log file
call :log "Deleting Python files not modified in last 30 days"
call :log "Excluding files in 'core' directory and files with 'db_connector' in name"
call :log ""

:: Set current date
for /f "tokens=1-3 delims=/" %%a in ('echo %date%') do (
    set day=%%a
    set month=%%b
    set year=%%c
)

:: Calculate date 30 days ago (simplified approach)
set /a days_in_month=30
set /a month_30_days_ago=%month% - 1
set /a year_30_days_ago=%year%

if %month_30_days_ago% leq 0 (
    set /a month_30_days_ago=12
    set /a year_30_days_ago=%year% - 1
)

call :log "Files that will be checked:"
call :log ""

:: Find and process Python files
for /r %%F in (*.py) do (
    set "filepath=%%F"
    set "filename=%%~nxF"
    
    :: Check if file contains db_connector in the name
    echo !filename! | findstr /i "db_connector" > nul
    if !errorlevel! equ 0 (
        call :log "SKIPPING: '!filepath!' - contains 'db_connector' in filename"
    ) else (
        :: Check if file is in core directory
        echo !filepath! | findstr /i "\core\\" > nul
        if !errorlevel! equ 0 (
            call :log "SKIPPING: '!filepath!' - located in 'core' directory"
        ) else (
            :: Get file modification date
            for /f "tokens=1-5 delims= " %%a in ('dir /tc "!filepath!" ^| findstr /i "!filename!"') do (
                set file_date=%%a
                if "!file_date!"=="Directory" (
                    set file_date=%%c
                    set file_time=%%d
                ) else (
                    set file_date=%%a
                    set file_time=%%b
                )
            )

            :: Convert date to days for comparison (simplified)
            for /f "tokens=1-3 delims=/" %%x in ("!file_date!") do (
                set file_day=%%x
                set file_month=%%y
                set file_year=%%z
            )

            :: Simple comparison (assumes we're in same year for simplicity)
            if !file_year! lss %year_30_days_ago% (
                set "older_than_30=yes"
            ) else if !file_year! equ %year_30_days_ago% (
                if !file_month! lss %month_30_days_ago% (
                    set "older_than_30=yes"
                ) else (
                    set "older_than_30=no"
                )
            ) else (
                set "older_than_30=no"
            )

            if "!older_than_30!"=="yes" (
                call :log "MARKED FOR DELETION: '!filepath!' - not modified in last 30 days"
            ) else (
                call :log "SKIPPING: '!filepath!' - recently modified"
            )
        )
    )
)

call :log ""
echo Do you want to proceed with deletion? (Y/N)
set /p confirm=
echo User selected: %confirm% >> "%logfile%"

if /i "%confirm%"=="Y" (
    call :log ""
    call :log "Deleting files..."
    
    for /r %%F in (*.py) do (
        set "filepath=%%F"
        set "filename=%%~nxF"
        
        :: Check if file contains db_connector in the name
        echo !filename! | findstr /i "db_connector" > nul
        if !errorlevel! equ 0 (
            call :log "Keeping: '!filepath!'"
        ) else (
            :: Check if file is in core directory
            echo !filepath! | findstr /i "\core\\" > nul
            if !errorlevel! equ 0 (
                call :log "Keeping: '!filepath!'"
            ) else (
                :: Get file modification date
                for /f "tokens=1-5 delims= " %%a in ('dir /tc "!filepath!" ^| findstr /i "!filename!"') do (
                    set file_date=%%a
                    if "!file_date!"=="Directory" (
                        set file_date=%%c
                        set file_time=%%d
                    ) else (
                        set file_date=%%a
                        set file_time=%%b
                    )
                )

                :: Convert date to days for comparison (simplified)
                for /f "tokens=1-3 delims=/" %%x in ("!file_date!") do (
                    set file_day=%%x
                    set file_month=%%y
                    set file_year=%%z
                )

                :: Simple comparison (assumes we're in same year for simplicity)
                if !file_year! lss %year_30_days_ago% (
                    set "older_than_30=yes"
                ) else if !file_year! equ %year_30_days_ago% (
                    if !file_month! lss %month_30_days_ago% (
                        set "older_than_30=yes"
                    ) else (
                        set "older_than_30=no"
                    )
                ) else (
                    set "older_than_30=no"
                )

                if "!older_than_30!"=="yes" (
                    del "!filepath!"
                    call :log "Deleted: '!filepath!'"
                ) else (
                    call :log "Keeping: '!filepath!'"
                )
            )
        )
    )
    
    call :log ""
    call :log "Deletion complete."
) else (
    call :log ""
    call :log "Operation cancelled. No files were deleted."
)

call :log "Script completed: %date% %time%"
call :log "Log saved to: %logfile%"
goto :eof

:log
echo %~1
echo %~1 >> "%logfile%"
goto :eof

endlocal