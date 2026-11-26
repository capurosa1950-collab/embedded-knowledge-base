# 芯片避坑经验卡片：STM32H7 / M7 内核 D-Cache 与 DMA 传输不一致问题

* **适用芯片**：STM32H7 全系列、STM32F7 系列（ARM Cortex-M7 内核）
* **关键词**：`D-Cache`, `DMA`, `数据校验错误`, `MPU 配置`, `SCB_CleanInvalidateDCache`

---

## 1. 现象描述
* **故障现象**：
  * 使用 DMA 发送数据时，对方接收到的数据是旧数据，或者是全零。
  * 使用 DMA 接收数据时，CPU 读出来的内存数组依然是初始化时的脏数据，即使逻辑分析仪抓包确认物理引脚上有正确波形。
  * 降低 CPU 频率或关闭 Cache 后故障立即消失。

---

## 2. 根本原因
* Cortex-M7 引入了 L1 Cache（包括 I-Cache 和 D-Cache）。
* 当 CPU 开启 D-Cache 时，CPU 写入内存的数据可能只停留在了 Cache 里，尚未刷入物理 SRAM（写回策略 Write-Back）。
* **DMA 是直接访问物理 SRAM 的硬件引擎，它不经过 D-Cache**：
  * **DMA 发送**：DMA 从物理 SRAM 搬运数据，此时搬走的是还未来得及从 Cache 刷出来的陈旧数据。
  * **DMA 接收**：DMA 把数据搬到了物理 SRAM，但 CPU 读取该地址时直接命中了 Cache 中的旧数据，根本不知道物理内存已被 DMA 修改。

---

## 3. 规范避坑与代码解决方案

### 方案 A：在 DMA 触发前后手动维护 Cache（推荐轻量级方案）

* **DMA 发送前**（CPU 数据刷入物理内存）：
  ```c
  // 必须对齐到 32 字节（Cache Line 长度）
  SCB_CleanDCache_by_Addr((uint32_t *)tx_buffer, tx_len);
  HAL_UART_Transmit_DMA(&huart1, tx_buffer, tx_len);
  ```

* **DMA 接收完成后**（在中断回调函数中，失效 Cache，强制 CPU 重新从 SRAM 读取）：
  ```c
  void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) {
      if (huart->Instance == USART1) {
          // 使该地址段的 Cache 失效
          SCB_InvalidateDCache_by_Addr((uint32_t *)rx_buffer, rx_len);
          // 此时再去解析 rx_buffer
          Process_Packet(rx_buffer, rx_len);
      }
  }
  ```

### 方案 B：利用 MPU 将专用 DMA 缓冲区配置为 Non-Cacheable（大吞吐量最稳方案）
将 AXI-SRAM 或 SRAM4 的某一段地址（例如 `0x38000000`）配置为 `MPU_TEX_LEVEL0, Bufferable=No, Cacheable=No`，所有 DMA 缓冲区都使用 `__attribute__((section(".dma_buffer")))` 强行定位到该区域，彻底规避 Cache 维护。
