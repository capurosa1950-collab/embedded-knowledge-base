# 硬件板级画像：一路485 智能电表采集网关 (ML307R-DC)

* **项目代号**：`一路485`
* **主控模组**：中移物联 `ML307R-DC`（4G Cat.1 OpenCPU，ARM Cortex-R5）
* **PCB 版本**：`V1.0`（图纸：`SCH_485及输出部分`）

---

## 1. 供电架构
* **主电源输入**：`AC 220V`（`P3`）→ `F2 (1A/250V)` + `R12 (6.8Ω)` + `L1 (2mH)` → 金升阳 **`LS10-13B12R3`**（`U3`）→ **`VCC12` (12V)**
* **板载低压供电**：
  * `VCC12` → **`SY8113BADC`**（`U4`）→ **`3V6` (3.6V)**（模组 `VBAT`、LED、数字侧供电）
  * `VCC12` → **`AMS1117-5.0`**（`U6`）→ **`VCC5` (5V)** → **`B0505S-1WR3`**（`U1`）→ 隔离 **`+5V_RS485` / `GND_RS485`**
  * 模组 `Pin 24 (VDD_EXT)` → **`+1.8V`**（`UART0` 电平转换与 `TXS0108EPWR` 参考电压）

---

## 2. 外设与引脚映射
* **`UART0` (`Pin 17 RX / Pin 18 TX`, `CM_UART_DEV_0`)**：隔离 RS-485（`P1: 485_A/B`），经 `Q1/Q5 (CJ3420)` 做 1.8V↔3.6V 电平转换，`Q2 (S8050)` 实现**硬件自动收发切换**（无需软件 DE/RE 脚），总线配 `GBLC24C` TVS 与 `120Ω` 终端电阻。
* **`GPIO4` (`Pin 16`, `CM_GPIO_NUM_4`)**：`RELAY` → `Q8 (S8050)` → `SRD-12VDC-SL-C`（`RELAY1`，高电平吸合，输出至 `U5 KF301-5.0-3P`）。
* **`GPIO5` (`Pin 25`, `CM_GPIO_NUM_5`)**：`VCC_EN` → `Q4 (DTC043ZEBTL)` → `Q3 (ASM6115)` P-MOS → `F1 (24V 2A)` → `VCC12OUT1`（`P2` 可控 12V 输出）。
* **`GPIO20` (`Pin 49`) / `GPIO21` (`Pin 50`)**：`LED1_IO20`（网络/OTA 状态灯）、`LED2_IO21`（电源灯，高电平亮）。
* **`J1` (USB Type-A 复用口)**：`USB D+/D-/VBUS` + `DBG_TX/DBG_RX`（`Pin 38/39`）+ `RST`（`Pin 15`），全线配 `GBLC05C` TVS。
* **`U7 (RFM68LC)` (预留)**：经 `U9 (TXS0108EPWR)` 接 `UART1/PCM/GPIO13/Pin26`（注意 `RFA_DIO1` 接 `Pin 26 RSV` 无 GPIO 映射）。

---

## 3. 配套固件特征
* 融合 5 种电表规约：`aibosen` / `hangzhou` / `shangtong` / `zhengtai`（Modbus RTU `0x03`）+ `dlt645_2007`（DLT645-2007 `0x11`），默认串口 `9600-8E1`，支持 MQTT `func=8` 在线修改。
* 持久化文件：`mqtt_config.cfg`（JSON）、`emeter_data.bin`（最大 32 台电表）。
