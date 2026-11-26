# 沁恒 CH32V307 开发与 OTA 双分区架构规范

* **内核**：青稞 V4F 32位 RISC-V（支持硬件 FPU，主频 144MHz）
* **开发工具**：MounRiver Studio (MRS2 / MRS3) + RISC-V Embedded GCC + OpenOCD

---

## 1. OTA 双分区 Flash 地址规划
* **Bootloader 分区**：`0x08000000 ~ 0x08004FFF`（预留 20KB）
* **APP 业务运行区**：`0x08005000` 起始（链接脚本 `.ld` 中 `FLASH (rx) : ORIGIN = 0x08005000`）
* **固件合并烧录**：开发阶段使用工具脚本将 `Bootloader.hex` 与 `FreeRTOS.hex`（APP）合并生成 `FreeRTOS_Combined.hex` 一次性烧录，日常调试可单独烧录 APP（`0x5000`）。

---

## 2. 编码与调试注意要点
* **HardFault 排查**：CH32V307 发生硬件异常时，重点检查 FreeRTOS 任务栈溢出（`uxTaskGetStackHighWaterMark`）、非对齐内存访问以及中断服务函数内耗时操作。
* **多工程协同**：当主机 MCU 与从机 GPIO 检测 MCU 协同开发时，在脚本中显式管理两个工程的编译与 OpenOCD 烧录配置，避免误刷固件。
