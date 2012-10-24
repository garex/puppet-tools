@ECHO OFF

REM Set UTF-8
CHCP 65001 >NUL

REM Base vars
SET modulePath=./puppet

REM Getting settings
SET settingsPath=%1
CALL %settingsPath%
SET appSsh="%puttyPath%plink"
SET appScp="%puttyPath%pscp"

REM Puppet color default
IF ""=="%puppetColor%" (
  SET puppetColor=false
)

IF ""=="%userName%" (
  SET userName=puppet
)

IF ""=="%remoteLogRoot%" (
  SET remoteLogRoot=/var/log/puppet
)

REM Packing puppet
SET packRoot=%TEMP%\puppet-tools-pack-%RANDOM%.tmp
SET packDirectory=%packRoot%\directory
SET packFile=%packRoot%\file
MKDIR %packDirectory%
IF NOT ERRORLEVEL 0 GOTO Finally

FOR %%M IN (%modules%) DO (
  XCOPY %%M %packDirectory%\%%~nM /E /C /I /Q /H /K /Y >NUL
  RD /S /Q %packDirectory%\%%~nM\.git
  IF NOT ERRORLEVEL 0 GOTO Finally
)

"%sevenPath%\7z" a -sccUTF-8 "%packFile%.tar" "%packDirectory%\*" >NUL
"%sevenPath%\7z" a -sccUTF-8 "%packFile%.bz2" "%packFile%.tar" >NUL

echo Uploading puppet
SET cmd=      rm --recursive --force %modulePath%;
SET cmd=%cmd% mkdir --parents %modulePath%;
%appSsh% -ssh -i "%localKey%" %userName%@%hostName% "%cmd%"

%appScp% -C -i "%localKey%" -q "%packFile%.bz2" %userName%@%hostName%:%modulePath%/file.bz2

echo Applying puppet
SET cmd=      tar --extract --bzip2 --touch --file %modulePath%/file.bz2 --directory %modulePath%;
SET cmd=%cmd% sudo puppet apply --verbose --color %puppetColor% --logdest console --logdest "%remoteLogRoot%/$(date --rfc-3339=seconds).log" --modulepath %modulePath% %modulePath%/%entryPoint%;
SET cmd=%cmd% rm --recursive --force %modulePath%;
%appSsh% -ssh -i "%localKey%" %userName%@%hostName% "%cmd%"

:Finally
RD /S /Q %packRoot%

echo Done
