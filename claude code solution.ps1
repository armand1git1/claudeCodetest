@echo off
setlocal enabledelayedexpansion

echo Script started: Deleting Python files not modified in last 30 days
echo Excluding files in 'core' directory and files with 'db_connector' in name
echo.

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

echo Files that will be checked:
echo.

:: Find and process Python files
for /r %%F in (*.py) do (
    set "filepath=%%F"
    set "filename=%%~nxF"
    
    :: Check if file contains db_connector in the name
    echo !filename! | findstr /i "db_connector" > nul
    if !errorlevel! equ 0 (
        echo SKIPPING: "!filepath!" - contains 'db_connector' in filename
    ) else (
        :: Check if file is in core directory
        echo !filepath! | findstr /i "\core\\" > nul
        if !errorlevel! equ 0 (
            echo SKIPPING: "!filepath!" - located in 'core' directory
        ) else (
            :: Get file modification date
            for /f "tokens=1-5" %%a in ('dir /tc "!filepath!" ^| findstr /i "!filename!"') do (
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
            set file_modified_days_ago=0
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
                echo MARKED FOR DELETION: "!filepath!" - not modified in last 30 days
            ) else (
                echo SKIPPING: "!filepath!" - recently modified
            )
        )
    )
)

echo.
echo Do you want to proceed with deletion? (Y/N)
set /p confirm=

if /i "%confirm%"=="Y" (
    echo.
    echo Deleting files...
    
    for /r %%F in (*.py) do (
        set "filepath=%%F"
        set "filename=%%~nxF"
        
        :: Check if file contains db_connector in the name
        echo !filename! | findstr /i "db_connector" > nul
        if !errorlevel! equ 0 (
            echo Keeping: "!filepath!"
        ) else (
            :: Check if file is in core directory
            echo !filepath! | findstr /i "\core\\" > nul
            if !errorlevel! equ 0 (
                echo Keeping: "!filepath!"
            ) else (
                :: Get file modification date
                for /f "tokens=1-5" %%a in ('dir /tc "!filepath!" ^| findstr /i "!filename!"') do (
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
                set file_modified_days_ago=0
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
                    echo Deleted: "!filepath!"
                ) else (
                    echo Keeping: "!filepath!"
                )
            )
        )
    )
    
    echo.
    echo Deletion complete.
) else (
    echo.
    echo Operation cancelled. No files were deleted.
)

endlocal