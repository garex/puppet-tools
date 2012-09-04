@ECHO OFF

REM Base vars
SET HERE=%~dp0

ECHO Getting settings
SET settingsPath=%1
CALL %settingsPath%
SET appSsh="%puttyPath%plink"
SET appScp="%puttyPath%pscp"

REM Path to remote install script
SET remoteScriptPath=%HERE%
SET remoteScriptName=install.remote.sh
SET remoteScript=%remoteScriptPath%%remoteScriptName%

ECHO Uploading public key to remote host (could ask your remote root's password)
%appSsh% -ssh -C -i "%localKey%" %rootName%@%hostName% "mkdir -p ~/.ssh && echo %publicKey% > ~/.ssh/authorized_keys"

ECHO Uploading initial install script
%appScp% -C -i "%localKey%" -q "%remoteScript%" %rootName%@%hostName%:.

ECHO Running initial install script
%appSsh% -ssh -C -i "%localKey%" %rootName%@%hostName% "chmod +x ~/%remoteScriptName% && ~/%remoteScriptName% %userName%"

ECHO Done. Now you can use apply.bat to manage remote host.
