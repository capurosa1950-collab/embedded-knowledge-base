# 中移物联 ML307R-DC OpenCPU 开发与踩坑笔记

* **适用模组**：中移物联 `ML307R-DC`（ARM Cortex-R5，OpenCPU 架构）
* **编译工具链**：`Python 3.12` + `SCons` + `arm-none-eabi-gcc`（SDK 自带于 `tools/toolchain/`）
* **核心资源上限**（`prebuild/ld/DC/app_dc.ld`）：
  * APP Flash：`512 KB`（起始 `0x802CE000`，烧录偏移 `0x002CE000`）
  * APP RAM：`256 KB`（起始 `0x7E1D2000`）
  * RTOS Tick：**`5 ms` / tick**（所有 `osDelay(ms / 5)`、`osTimerStart(..., ms / 5)`、`osKernelGetTickCount() * 5` 均基于 5ms 时基）

---

## 1. Windows 编译环境避坑：`WindowsApps\python.exe` 拦截导致编译失败
* **【现象】**：本机已安装 Python 3.12，但在命令行或 SCons 构建（`os.system("python unzip.py ...")`）时提示 `Python was not found; run without arguments to install from the Microsoft Store`。
* **【根本原因】**：Windows 系统 `Machine PATH` 中包含 `C:\Users\<User>\AppData\Local\Microsoft\WindowsApps`，且优先级高于 `User PATH` 中的真实 Python 目录，导致 `python` 命中的是微软商店占位符。
* **【规避方案】**：
  1. 删除/关闭 `%LOCALAPPDATA%\Microsoft\WindowsApps\python.exe` 与 `python3.exe`（应用执行别名）；
  2. 执行 `pip install scons` 安装 SCons（实测 `SCons 4.11.1` + `Python 3.12.10` 可直接编译 `scons app_demo=y`）。

---

## 2. SDK 工程结构与固件编译/FOTA 打包要点
* **编译命令**：
  * 编译正式业务（`app_demo/SConscript`）：`scons app_demo=y`（注意默认无参 `scons` 编译的是空桩 `custom/`！）
  * 产物位置：`out/image/DC/ML307R-DC_APP.bin`（APP 二进制）与 `out/image/DC/ML307R-DC_APP.zip`（烧录整包）。
  * **原则**：除非必须改音频外设方案，不要执行 `kernel_build.bat` 改动内核，保持系统侧 `system.img` 稳定，后续迭代才能做 APP 整包 FOTA。
* **APP 整包 FOTA 制作（`Mode=1`）**：
  1. 将 `ML307R-DC_APP.bin` 重命名为 `user_app.bin` 放入 `tools\fota_tool\a\`；
  2. 确认 `tools\fota_tool\config_app` 中 `1_Image_Flash_Entry_Address = 0x002CE000`；
  3. 在 `tools\fota_tool\` 执行：`FBFMake_CF_V1.6-150.exe -o system_patch.bin -f config_app -a a -b a`。
* **最小系统差分包（`Mode=0`）**：`adiff.exe system_old.img system_new.img system_patch.bin -a1 user_app user_app.bin -m`。
* **USB 一键烧录安全原则（`adownload.exe`）**：
  * 使用 `adownload.exe -q -u -a -r -s 115200 <ML307R-DC_APP.zip>` 进行安全升级模式烧录（**严禁开启 `-m` 生产模式**，防止擦除模组出厂 IMEI 与射频校准参数）。
  * 通用批处理脚手架见知识库：`scripts/ml307r_build_and_pack.bat`（同步源码、SCons 编译、FOTA 打包及 MD5 归档）与 `scripts/ml307r_flash_usb.bat`（USB 安全烧录）。

---

## 3. 外设驱动与底层踩坑经验
1. **`cm_uart_read` 超时参数无效与帧打包机制**（`hal_uart.c`）：
   * SDK 头文件注明 `cm_uart_read(..., timeout)` 的 `timeout` 参数无效（非阻塞读）。
   * 中间件 `hal_uart0_recv_task` 通过 `UART_PAKCET_TIME`（默认 `120ms`）判断一帧结束；主循环若高频轮询多台 485 设备，必须保证请求间隔大于分帧超时时间（如当前 `2000ms`）。
   * FOTA 升级期间，主串口（`UART0`）会吐出升级底层数据，应用层协议解析需做好帧头/CRC 校验过滤。
2. **IOMUX 与 `RSV` 引脚核查**（`cm_iomux.h` / `hal_gpio.c`）：
   * `s_gpio_mapping_table` 仅覆盖 `CM_GPIO_NUM_0 ~ 29`。画原理图复用外设（如挂载 `RFM68LC`）时，**禁止将中断/控制线接到模组 `RSV` 引脚**（例如 `Pin 26` 无 GPIO 映射），否则固件无法直接用 `cm_gpio` 控制。
3. **动态内存风控**（`app_demo_mqtt.c` / `hal_mqtt.c`）：
   * `hal_mqtt_data_t` 结构体单包含 `10KB` payload 缓存，`cJSON` 与队列消息均调用 `cm_malloc`。在 `256KB RAM` 约束下，需严格控制 MQTT 收发队列深度并及时 `cJSON_Delete` / `cm_free`，防止长时间运行堆内存耗尽触发 `HAL_NET_EVENT_MEMORY_LEAK` 重启。
4. **外设默认引脚约定（OpenCPU Demo 中间件）**：
   * `UART0`：`Pin 17 (RX)` / `Pin 18 (TX)`（`CM_IOMUX_FUNC_FUNCTION1`）
   * `UART1`：`Pin 28 (RX)` / `Pin 29 (TX)`（`CM_IOMUX_FUNC_FUNCTION1`）
   * `LED`：`CM_GPIO_NUM_20 (Pin 49)` 网络状态灯、`CM_GPIO_NUM_21 (Pin 50)` 电源灯
   * `RELAY`：`hal_relay.c` 固定使用 `CM_GPIO_NUM_4 (Pin 16)`，高电平吸合
5. **`hal_modem_get_iccid` 缓冲截断与开机不打印问题**（`hal_modem.c` / `app_demo_mqtt.c`）：
   * **【现象】**：OpenCPU Demo 开机只调用 `cm_sys_get_imei` 而不读取打印 ICCID；且原生 `hal_modem_get_iccid` 的 `key_line` 仅 32 字节（`*ICCID: "20位"` 加前缀易逼近上限），且仅支持带双引号格式。
   * **【规避方案】**：将缓冲区扩至 64 字节，兼容 `*ICCID: "..."`、无引号 `*ICCID: ...` 并增加 `AT+CCID` 备选回退；在注网就绪启动业务时显式调用 `hal_modem_get_iccid` 打印 `Device ICCID: ...`。
6. **`hal_mqtt_deinit()` 异步销毁引发幽灵重连与句柄泄漏陷阱**（`hal_mqtt.c`）：
   * **【现象】**：在运行时通过平台指令切换新 MQTT 配置失败回滚、或销毁旧连接重建时，若调用 `hal_mqtt_deinit(s_mqtt_client_id)` 后立即将 `s_mqtt_client_id = NULL` 且不驱动 yield，旧客户端不会被真正释放，失败的连接会在后台持续重连并耗尽 `CM_MQTT_CLIENT_MAX (5)` 名额。
   * **【根本原因】**：`hal_mqtt_deinit()` 只是向 `s_mqtt_msg_queue` 投递 `HAL_MQTT_MSG_DEINIT`，真正销毁与释放槽位必须由 `hal_mqtt_yield(&client)` 消费该消息后将 `*client` 置 `NULL`。
   * **【规避代码】**：
     ```c
     cm_mqtt_client_t *dead_client = s_mqtt_client_id;
     s_mqtt_client_id = NULL;
     hal_mqtt_deinit(dead_client);
     for (int i = 0; i < 20 && dead_client != NULL; i++) {
         hal_mqtt_yield(&dead_client);
         osDelay(100 / 5);
     }
     ```
   * 同时，远程修改 MQTT 配置的指令除 `ip`、`SUB`、`PUB`、`client_id`、`add_imei`、`keepalive`、`report_ms` 外，**务必纳入并持久化 `port`、`username`、`password`**，避免写死默认 `1883` 与空账密。
