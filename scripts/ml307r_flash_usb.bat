@echo off
setlocal EnableDelayedExpansion

REM ============================================================================
REM  ML307R-DC OpenCPU 通用工程 USB 一键烧录脚本 (基于 ASR adownload.exe)
REM  字符编码: GBK (CP936) / CRLF
REM ============================================================================

set "TOOLS_DIR=%~dp0"
for %%I in ("%TOOLS_DIR%..") do set "PROJ_ROOT=%%~fI"
set "FW_ZIP=%PROJ_ROOT%\06_Release\v0.7_Baseline\ML307R-DC_APP.zip"
set "ABOOT_DIR=D:\Project\Software\ml307\aboot-tools-2022.03.01-win-x64"
set "ADOWNLOAD=%ABOOT_DIR%\adownload.exe"

set "NO_PAUSE=0"
set "USE_AT_FALLBACK=0"
for %%A in (%*) do (
    if /i "%%~A"=="--nopause" set "NO_PAUSE=1"
    if /i "%%~A"=="--at" set "USE_AT_FALLBACK=1"
    if not "%%~A"=="--nopause" if not "%%~A"=="--at" (
        if exist "%%~fA" set "FW_ZIP=%%~fA"
    )
)

echo ============================================================================
echo   ML307R-DC OpenCPU 通用工程 USB 一键烧录工具 (adownload)
echo ============================================================================
echo [烧录工具] %ADOWNLOAD%
echo [烧录包]   %FW_ZIP%
echo.

if not exist "%ADOWNLOAD%" (
    echo [错误] 未找到 adownload.exe: %ADOWNLOAD%
    goto :FAIL
)

if not exist "%FW_ZIP%" (
    echo [错误] 未找到烧录包: %FW_ZIP%
    echo [提示] 请先双击运行 build_and_pack.bat 生成固件!
    goto :FAIL
)

echo [操作提示]
echo   1. 请确认已安装 ASR USB 驱动 (DrvInstaller_x64.exe).
echo   2. 严禁开启生产模式 (-m), 本脚本默认使用安全升级模式 (保留 IMEI 与校准).
echo   3. 烧录引擎启动后, 请按一下板载 RST 复位键 (或重新上电) 触发烧录.
echo   4. 烧录完成后模组将自动重启进入正常模式.
echo ============================================================================
echo.

pushd "%ABOOT_DIR%"
if "%USE_AT_FALLBACK%"=="1" (
    echo [执行] adownload.exe -q -u -a -f -r -s 115200 "%FW_ZIP%"
    "%ADOWNLOAD%" -q -u -a -f -r -s 115200 "%FW_ZIP%"
) else (
    echo [执行] adownload.exe -q -u -a -r -s 115200 "%FW_ZIP%"
    "%ADOWNLOAD%" -q -u -a -r -s 115200 "%FW_ZIP%"
)
set "RET=%ERRORLEVEL%"
popd

if not "%RET%"=="0" (
    echo.
    echo [错误] 烧录失败或被中断, 返回码: %RET%
    goto :FAIL
)

echo.
echo ============================================================================
echo   [烧录成功] 固件已写入模组并触发自动重启!
echo ============================================================================
if "%NO_PAUSE%"=="0" pause
exit /b 0

:FAIL
echo.
echo ============================================================================
echo   [烧录未完成] 请检查 USB 接线、ASR 驱动或模组复位状态!
echo ============================================================================
if "%NO_PAUSE%"=="0" pause
exit /b 1