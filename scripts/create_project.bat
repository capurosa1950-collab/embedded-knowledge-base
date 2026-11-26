@echo off
chcp 65001 >nul
echo ============================================================
echo        嵌入式标准化工程脚手架生成工具 (Embedded Project Generator)
echo ============================================================
echo.
set /p PROJ_NAME="请输入新工程名称 (建议英文/拼音，如 Gateway_H7): "
if "%PROJ_NAME%"=="" (
    echo [错误] 工程名称不能为空！
    pause
    exit /b
)

if exist "%PROJ_NAME%" (
    echo [错误] 目录 %PROJ_NAME% 已经存在，防止覆盖已退出！
    pause
    exit /b
)

echo.
echo [1/4] 正在创建标准目录架构...
mkdir "%PROJ_NAME%\00_Docs\Reference"
mkdir "%PROJ_NAME%\01_Hardware\Schematic_PCB"
mkdir "%PROJ_NAME%\01_Hardware\Gerbers"
mkdir "%PROJ_NAME%\01_Hardware\BOM"
mkdir "%PROJ_NAME%\02_Firmware\Drivers"
mkdir "%PROJ_NAME%\02_Firmware\Middlewares"
mkdir "%PROJ_NAME%\02_Firmware\App"
mkdir "%PROJ_NAME%\03_Software"
mkdir "%PROJ_NAME%\04_Mechanical"
mkdir "%PROJ_NAME%\05_Tools"
mkdir "%PROJ_NAME%\06_Release"

echo [2/4] 正在生成嵌入式防坑 .gitignore...
(
echo # Keil MDK 编译生成物
echo *.o
echo *.obj
echo *.d
echo *.crf
echo *.axf
echo *.build_log.htm
echo *.dep
echo *.lnp
echo *.sct
echo Listings/
echo Objects/
echo *.uvgui.*
echo *.uvopt
echo *.uvoptx
echo.
echo # IAR 编译物
echo *.pbi
echo *.pbd
echo *.out
echo Debug/
echo Release/
echo.
echo # VSCode / CMake
echo .vscode/
echo build/
echo CMakeSettings.json
echo.
echo # 系统与临时文件
echo *.tmp
echo .DS_Store
echo Thumbs.db
) > "%PROJ_NAME%\.gitignore"

echo [3/4] 正在生成核心文档与出货清单规范...
(
echo # %PROJ_NAME%
echo.
echo ## 1. 项目简介
echo - 项目代号: %PROJ_NAME%
echo - 核心 MCU: 待填入
echo - 创建日期: %date%
echo - 负责人: 
echo.
echo ## 2. 当前研发进度
echo - [ ] 硬件原理图设计
echo - [ ] PCB 布局与打样
echo - [ ] 底层 BSP 驱动适配
echo - [ ] 业务功能逻辑联调
echo - [ ] 初版固件量产发布
) > "%PROJ_NAME%\README.md"

(
echo # 引脚与外设映射表 (Pinout Table)
echo.
echo ^| 引脚编号 ^| 引脚名称 ^| 外设功能 ^| 外部连接器件 ^| 初始电气属性 ^| 备注说明 ^|
echo ^| :--- ^| :--- ^| :--- ^| :--- ^| :--- ^| :--- ^|
echo ^| PA9  ^| USART1_TX ^| 调试串口 TX ^| CH340 / 外部调试口 ^| 上拉输出 ^| 115200 8N1 ^|
echo ^| PA10 ^| USART1_RX ^| 调试串口 RX ^| CH340 / 外部调试口 ^| 浮空输入 ^| 115200 8N1 ^|
echo ^| PB6  ^| I2C1_SCL  ^| 传感器总线 ^| SHT30 / EEPROM     ^| 开漏上拉 ^| 硬件外置 4.7K 上拉 ^|
echo ^| PB7  ^| I2C1_SDA  ^| 传感器总线 ^| SHT30 / EEPROM     ^| 开漏上拉 ^| 硬件外置 4.7K 上拉 ^|
) > "%PROJ_NAME%\00_Docs\Pinout.md"

(
echo # 需求与规格说明书 (Specs)
echo.
echo ## 1. 供电与电气特性
echo - 输入电压范围: DC 9V ~ 36V
echo - 典型工作功耗: 
echo - 工作温度环境: 工业级 -40℃ ~ +85℃
echo.
echo ## 2. 关键通信接口
echo - RS485 / CAN / 以太网 / 4G 模组
) > "%PROJ_NAME%\00_Docs\Specs.md"

(
echo # 标准量产交付与出货清单规范 (Packing ^& Delivery Spec)
echo.
echo ^> 注意：本文件是**研发交付物与出厂标配基线**，非日常快递发货流水。
echo.
echo ## 1. 交付固件基线 (Firmware Release)
echo - 固件版本号: v1.0.0
echo - 二进制文件名: %PROJ_NAME%_Firmware_v1.0.0.bin
echo - MD5 校验和: 
echo - 烧录基地址: 0x08000000
echo.
echo ## 2. 硬件交付版本 (Hardware Baseline)
echo - PCB 版本号: Rev 1.0
echo - BOM 清单代号: BOM_%PROJ_NAME%_V1.0
echo.
echo ## 3. 整机出货包装与配件清单 (Box Contents)
echo ^| 序号 ^| 物品名称 ^| 规格型号 ^| 标配数量 ^| 单位 ^| 检验要求 ^|
echo ^| :--- ^| :--- ^| :--- ^| :--- ^| :--- ^| :--- ^|
echo ^| 1 ^| PCBA / 整机主机 ^| %PROJ_NAME% ^| 1 ^| 台 ^| 已贴 QC PASS 标与 SN 码 ^|
echo ^| 2 ^| 供电适配器 ^| 12V / 1.5A DC5.5 ^| 1 ^| 只 ^| 3C 认证 ^|
echo ^| 3 ^| 通信排线/端子 ^| 3.81mm 4Pin 绿色端子 ^| 2 ^| 只 ^| 无毛刺 ^|
echo ^| 4 ^| 简易操作说明书 ^| A4 折页纸质 ^| 1 ^| 份 ^| 包含默认 IP/波特率说明 ^|
echo ^| 5 ^| 干燥剂与防静电袋 ^| 工业标准 ^| 1 ^| 套 ^| 密封包装 ^|
) > "%PROJ_NAME%\06_Release\Packing_Spec.md"

echo.
echo ============================================================
echo [成功] 工程 [%PROJ_NAME%] 已按照大厂精简标准初始化完成！
echo 目录位置: %cd%\%PROJ_NAME%
echo ============================================================
pause
