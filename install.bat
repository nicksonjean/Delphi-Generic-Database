@echo off
SET path=%~dp0
::Platform
SET win32=Demo\Win32
::Target Build
SET debug=Debug
SET release=Release
::Source and Destination
SET source=%path:~0,-1%\%win32%\%debug%
SET destination=%path:~0,-1%\%win32%\%release%
::Resources Pacakges
SET resources=%path:~0,-1%\Resources\resources.7z
::Commandlet Fragment
SET cmdl_7zip=%path%\Resources\7z2201-extra\7za.exe
SET cmdl_xcopy=%systemroot%\System32\xcopy.exe

%cmdl_7zip% x %resources% -o%source% -aoa -y

IF NOT EXIST %destination% (
    MKDIR %destination%
)

%cmdl_xcopy% %source% %destination% /y /s