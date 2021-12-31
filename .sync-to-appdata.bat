:: Name:     sync-to-repo
:: Purpose:  syncs configuration files from an application to this repository
::
@ECHO off
SETLOCAL EnableExtensions EnableDelayedExpansion

:: ERROR CODES
SET /A err_none=0
SET /A err_nondescript_failure=1

:: GLOBALS
SET me=%~n0
SET parent=%~dp0

:: PROGRAM BEGINS
SET $project_root=%parent%

CALL :jq .REMOTE "%project_root%/%1/vars.json"
SET source=%r%

CALL :jq .LOCAL "%project_root%/%1/vars.json"
SET destination=%r%

:: Copy everything from the source to the destination, removing destination files and
:: directories that no longer exist in the source.
::
:: /s ........ copies subdirectories, excluding empty directories.
:: /mir ...... MIRrors a directory tree (equivalent to /e plus /purge).
ROBOCOPY "%source%" "%destination%" * /s /mir
EXIT /B %err_none%

:: SUBROUTINES / FUNCTIONS

:jq
:: jq is a lightweight and flexible command-line JSON processor.
::
:: PARAMETERS
:: %1  , filter - jq filter to use when processing json data
:: %2  , file   - json file to process
::
:: RETURNS
:: %r% , the return variable to use, since batch files suck at subroutines :~(
SET filter=%1
SET file=%2

FOR /F "delims=" %%_ in ('%parent%/.vendor/jq.exe --raw-output %filter% %file%') DO SET r=%%_

:: log the error
IF %ERRORLEVEL% NEQ 0 (
  ECHO %me%: jq returned with an error = %ERRORLEVEL%
  GOTO :EOF
)
