@echo off
setlocal EnableDelayedExpansion

REM ============================================================================
REM  ML307R-DC OpenCPU 通用工程 一键同步源码、编译固件并生成 FOTA 升级包脚本
REM  字符编码: GBK (CP936) / CRLF
REM ============================================================================

set "TOOLS_DIR=%~dp0"
for %%I in ("%TOOLS_DIR%..") do set "PROJ_ROOT=%%~fI"
set "FW_DIR=%PROJ_ROOT%\02_Firmware"
set "RELEASE_DIR=%PROJ_ROOT%\06_Release\v0.7_Baseline"
set "SDK_DIR=D:\Project\Software\ml307\ml307r-opencpu-master_07\ml307r-opencpu-master_07"
set "PY_DIR=C:\Users\WEI\AppData\Local\Programs\Python\Python312"

set "DO_CLEAN=0"
set "NO_PAUSE=0"
for %%A in (%*) do (
    if /i "%%~A"=="--clean" set "DO_CLEAN=1"
    if /i "%%~A"=="--nopause" set "NO_PAUSE=1"
)

if exist "%PY_DIR%\python.exe" (
    set "PATH=%PY_DIR%;%PY_DIR%\Scripts;%PATH%"
)

echo ============================================================================
echo   ML307R-DC OpenCPU 通用工程 固件编译与 FOTA 升级包一键构建工具
echo ============================================================================
echo [信息] 工程根目录: %PROJ_ROOT%
echo [信息] SDK 编译目录: %SDK_DIR%
echo.

if not exist "%SDK_DIR%\SConstruct" (
    echo [错误] 未找到 SDK 编译目录或 SConstruct: %SDK_DIR%
    goto :FAIL
)

where python >nul 2>nul
if errorlevel 1 (
    echo [错误] 未检测到可用的 python 环境!
    goto :FAIL
)

where scons >nul 2>nul
if errorlevel 1 (
    echo [错误] 未检测到 scons 命令, 请先运行 pip install scons
    goto :FAIL
)

echo [1/4] 正在同步 02_Firmware 源码至 SDK 目录...
call :SYNC_DIR "%FW_DIR%\App\inc" "%SDK_DIR%\app_demo\app_demo_custom\inc"
if errorlevel 1 goto :FAIL
call :SYNC_DIR "%FW_DIR%\App\src" "%SDK_DIR%\app_demo\app_demo_custom\src"
if errorlevel 1 goto :FAIL
copy /y "%FW_DIR%\App\SConscript" "%SDK_DIR%\app_demo\SConscript" >nul
if errorlevel 1 goto :FAIL

call :SYNC_DIR "%FW_DIR%\Middlewares\inc" "%SDK_DIR%\app_demo\app_demo_custom\app_demo_midware\inc"
if errorlevel 1 goto :FAIL
call :SYNC_DIR "%FW_DIR%\Middlewares\src" "%SDK_DIR%\app_demo\app_demo_custom\app_demo_midware\src"
if errorlevel 1 goto :FAIL

call :SYNC_DIR "%FW_DIR%\Drivers\cm_lib" "%SDK_DIR%\src\cm_lib"
if errorlevel 1 goto :FAIL
call :SYNC_DIR "%FW_DIR%\Drivers\cm_sim" "%SDK_DIR%\src\cm_sim"
if errorlevel 1 goto :FAIL
call :SYNC_DIR "%FW_DIR%\Drivers\modem" "%SDK_DIR%\src\modem"
if errorlevel 1 goto :FAIL
copy /y "%FW_DIR%\Drivers\SConscript" "%SDK_DIR%\src\SConscript" >nul
if errorlevel 1 goto :FAIL
call :SYNC_DIR "%FW_DIR%\Drivers\cJSON" "%SDK_DIR%\third-party\cJSONFiles\cJSON"
if errorlevel 1 goto :FAIL
echo [完成] 源码同步成功.
echo.

echo [2/4] 正在执行 SCons 编译 (scons app_demo=y)...
pushd "%SDK_DIR%"
if "%DO_CLEAN%"=="1" (
    echo [信息] 正在清理旧编译产物...
    call scons app_demo=y -c
    if errorlevel 1 (
        popd
        echo [错误] SCons 清理失败!
        goto :FAIL
    )
)
call scons app_demo=y
if errorlevel 1 (
    popd
    echo [错误] SCons 编译失败, 请检查上方编译器报错!
    goto :FAIL
)
popd

set "APP_BIN=%SDK_DIR%\out\image\DC\ML307R-DC_APP.bin"
set "APP_ZIP=%SDK_DIR%\out\image\DC\ML307R-DC_APP.zip"
if not exist "%APP_BIN%" (
    echo [错误] 编译未生成 %APP_BIN%
    goto :FAIL
)
echo [完成] 固件编译成功.
echo.

echo [3/4] 正在制作 APP 整包 FOTA 升级包 (system_patch.bin)...
set "FOTA_DIR=%SDK_DIR%\tools\fota_tool"
if not exist "%FOTA_DIR%\a" mkdir "%FOTA_DIR%\a"
copy /y "%APP_BIN%" "%FOTA_DIR%\a\user_app.bin" >nul
if errorlevel 1 (
    echo [错误] 拷贝 user_app.bin 到 fota_tool\a 失败!
    goto :FAIL
)

pushd "%FOTA_DIR%"
if exist "system_patch.bin" del /f /q "system_patch.bin"
FBFMake_CF_V1.6-150.exe -o system_patch.bin -f config_app -a a -b a
if errorlevel 1 (
    popd
    echo [错误] FBFMake_CF_V1.6-150.exe 生成升级包失败!
    goto :FAIL
)
popd

set "PATCH_BIN=%FOTA_DIR%\system_patch.bin"
if not exist "%PATCH_BIN%" (
    echo [错误] 未生成 %PATCH_BIN%
    goto :FAIL
)
echo [完成] FOTA 升级包生成成功.
echo.

echo [4/4] 正在归档产物至 06_Release\v0.7_Baseline...
if not exist "%RELEASE_DIR%" mkdir "%RELEASE_DIR%"
copy /y "%APP_BIN%" "%RELEASE_DIR%\ML307R-DC_APP.bin" >nul
if errorlevel 1 goto :FAIL
copy /y "%APP_ZIP%" "%RELEASE_DIR%\ML307R-DC_APP.zip" >nul
if errorlevel 1 goto :FAIL
copy /y "%PATCH_BIN%" "%RELEASE_DIR%\system_patch.bin" >nul
if errorlevel 1 goto :FAIL

echo.
echo ============================================================================
echo   全部构建与打包已完成!
echo   输出目录: %RELEASE_DIR%
echo   SDK原始打包路径: %PATCH_BIN%
echo ============================================================================
call :PRINT_ITEM "%RELEASE_DIR%\ML307R-DC_APP.bin" "裸APP(仅打包用)"
call :PRINT_ITEM "%RELEASE_DIR%\ML307R-DC_APP.zip" "烧录包(USB线刷)"
call :PRINT_ITEM "%RELEASE_DIR%\system_patch.bin" "升级包(FOTA Mode=1)"
echo ============================================================================
goto :END_OK

:PRINT_ITEM
echo [%~2] %~f1  [%~z1 字节]
for /f "delims=" %%H in ('certutil -hashfile "%~f1" MD5 ^| findstr /r /c:"^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]"') do echo        MD5: %%H
exit /b 0

:SYNC_DIR
robocopy "%~1" "%~2" /E /NFL /NDL /NJH /NJS /NC /NS >nul
if errorlevel 8 (
    echo [错误] 同步目录失败: %~1 -^> %~2
    exit /b 1
)
exit /b 0

:FAIL
echo.
echo ============================================================================
echo   [构建失败] 请根据上方提示排查问题!
echo ============================================================================
if "%NO_PAUSE%"=="0" pause
exit /b 1

:END_OK
if "%NO_PAUSE%"=="0" pause
exit /b 0