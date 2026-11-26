# 引脚与外设映射模板 (Pinout & Peripherals Template)

> 提示：新硬件开板或新固件立项时，最先填写的必须是本表。AI 会严格依照此表生成引脚初始化代码。

---

## 1. 核心芯片信息
* 芯片型号：`STM32H743VIT6` (示例)
* 封装：`LQFP-100`
* 外部主晶振：`25.000 MHz` (HSE)
* 32.768kHz 外部低速晶振：`是` (LSE)

---

## 2. GPIO 与外设分配总表

| 序号 | 引脚名称 | 硬件网络标号 (Net) | 外设映射 (Peripheral) | 电气特性 (Mode/Pull/Speed) | 外部连接器件 | 备注说明 / 避坑提示 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | PA9 | UART1_TX | USART1_TX | 复用推挽 / 无上下拉 / Very High | CH340C / 调试串口 | 波特率 115200 8-N-1 |
| 2 | PA10 | UART1_RX | USART1_RX | 复用输入 / 内部上拉 / Very High | CH340C / 调试串口 | 接收中断 |
| 3 | PB6 | I2C1_SCL | I2C1_SCL | 复用开漏 / 外部 4.7K 上拉 | SHT30 / EEPROM | 严禁配置为推挽输出 |
| 4 | PB7 | I2C1_SDA | I2C1_SDA | 复用开漏 / 外部 4.7K 上拉 | SHT30 / EEPROM | 总线速率 100kHz |
| 5 | PC13 | LED_SYS | GPIO_Output | 推挽输出 / 无上下拉 / Low | 系统心跳指示灯 | 低电平点亮 |
| 6 | PA0 | KEY_BOOT | GPIO_Input | 下拉输入 / Very High | 功能按键 (WKUP) | 高电平有效，外部硬件去抖 |
| 7 | PB12 | SPI2_NSS | GPIO_Output | 推挽输出 / 内部上拉 / Very High | W25Q64 Flash 片选 | 软件控制 CS 引脚 |
| 8 | PB13 | SPI2_SCK | SPI2_SCK | 复用推挽 / 内部下拉 / Very High | W25Q64 Flash 时钟 | Mode 0 (CPOL=0, CPHA=0) |
| 9 | PB14 | SPI2_MISO | SPI2_MISO | 复用输入 / 内部上拉 / Very High | W25Q64 Flash 主入从出 | |
| 10 | PB15 | SPI2_MOSI | SPI2_MOSI | 复用推挽 / 无上下拉 / Very High | W25Q64 Flash 主出从入 | |

---

## 3. 中断优先级规划（NVIC Priority Group 4: 4位抢占，0位响应）

| 中断名称 | 抢占优先级 (Preempt) | 响应优先级 (Sub) | 用途说明 |
| :--- | :--- | :--- | :--- |
| `SysTick_IRQn` | 0 (最高) | 0 | RTOS 调度时基滴答 |
| `USART1_IRQn` | 5 | 0 | 命令行与上位机通讯 |
| `EXTI0_IRQn` | 6 | 0 | 按键外部中断 |
| `DMA1_Stream0_IRQn` | 3 | 0 | 高速 ADC / SPI 采集传输完成 |
