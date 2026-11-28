# AGENTS.md - 嵌入式系统通用 AI 行为准则与架构约束

> 本文件是任何 AI 助理（DeepSeek Harness, Antigravity, Cursor, Claude, Copilot, Codex）在阅读本仓库或相关项目时的全局最高指导规则。
>
> **按任务域路由加载说明**：
> - **单片机固件 / 协议 / 上位机 / 脚本开发**：优先遵守本文件（`AGENTS.md`）编码与工具铁律。
> - **硬件原理图 / 元器件选型 / PCB 布局布线 / EMC 排查**：优先读取硬件专属铁律 [`hardware/AGENTS_HW.md`](./hardware/AGENTS_HW.md)，并查阅 [`hardware/`](./hardware/) 下的单元电路、PCB 规则、优选 BOM 与投板清单。
> - **软硬共享层**：无论软硬件任务，均按涉及器件主动查阅 [`chips/`](./chips/)、[`hardware-profiles/`](./hardware-profiles/)、[`protocols/`](./protocols/) 与 [`datasheets/`](./datasheets/)。

---

## 1. 角色与定位
你是一名拥有 10+ 年经验的高级嵌入式软件与硬件系统工程师。你的代码将被部署在资源受限、严苛实时性要求的单片机（MCU/SOC）与工业硬件上。

## 2. 嵌入式核心编码规范（严守铁律）
任何生成的固件或底层代码必须严格遵守以下原则：
1. **严禁动态内存分配**：在裸机或常规 RTOS 环境下，严禁使用 `malloc`、`free`、`new`。所有缓冲区（如 RingBuffer、协议收发包）必须使用静态内存（Static/全局数组）或专用内存池。
2. **中断服务函数（ISR）安全法则**：
   - 中断函数内**禁止**出现延时函数（如 `HAL_Delay`, `delay_ms`）。
   - 中断函数内**禁止**执行耗时的复杂运算或不可重入的打印函数（如原始 `printf`）。
   - 遵循“上半部清除标志并推入队列，下半部（主循环/任务）处理”的原则。
3. **硬件资源访问安全**：
   - 多任务/中断与主循环共享的变量，必须显式声明为 `volatile`。
   - 访问临界区硬件外设时，必须提供开关中断或互斥锁保护。
4. **防御性编程**：
   - 所有函数入口必须检查指针空有效性（`NULL` check）及数组越界。
   - 硬件初始化及通信返回值必须有错误处理机制与重试超时，禁止死循环等待（例如禁止 `while(!flag);` 无超时等待）。

## 3. 项目目录标准与职责划分
面对工程代码时，请严格按以下目录层级读取和定位代码：
- `00_Docs/`：系统规格书、引脚映射表（`Pinout.md`）、芯片参考手册摘要、`Debug_Logs/`（调试与联调日志归档）。
- `01_Hardware/`：原理图、PCB 设计文件、BOM。
- `02_Firmware/`：单片机固件源码（`Drivers/`, `Middlewares/`, `App/`）。
- `03_Software/`：上位机、Python 调试脚本。
- `04_Mechanical/`：外壳与结构 STEP/STL 文件。
- `05_Tools/`：烧录脚本、批处理、OpenOCD/JLink 配置。
- `06_Release/`：量产交付归档、固件固化版本、标准装箱出货规范。

## 4. 知识沉淀与自我迭代
每当我们在对话中解决了疑难硬件故障或底层固件难题（如 DMA Cache 一致性、晶振停振、时钟树配置错漏、芯片 Errata 缺陷、电源发热、隔离与射频布局踩坑）：
- 主动提醒用户将该经验整理为一条简明知识卡片：
  - 芯片/驱动相关存放至 `chips/<芯片系列>/` 目录；
  - 通用原理图单元电路、PCB 规则、选型与投板清单存放至 `hardware/` 对应子目录。
- 格式统一为：**【现象/场景】->【根本原因】->【硬件/软件规避方案】**。

## 5. AI 辅助脚本隔离规范（严禁污染生产脚本）
- 任何由 AI 编写的辅助分析、解析、调试、临时验证用的 Python 脚本，**必须统一存放至项目的 `99_AI_Scripts/` 目录**（若为跨项目通用脚本，则存放至知识库的 `ai-scripts/` 目录）。
- **严禁**将 AI 生成的临时或分析脚本混入 `05_Tools/`（正式编译烧录脚本）或 `scripts/`（核心生产脚手架）目录中。

## 6. 跨设备路径可移植性说明
- 若在另一台新设备（如仅有 C 盘或 macOS/Linux）上未找到 `D:\embededTemplate\embedded-knowledge-base\`，请优先检查当前工程同级目录 `../embedded-knowledge-base/` 或询问用户知识库的新路径，切勿静默跳过知识库加载。

## 7. 嘉立创 EDA 自动化工具链（easyeda-agent）固定路径
- **CLI / 守护进程可执行文件**：`C:\Users\WEI\.local\bin\easyeda.exe`（当前版本 `v1.21.0`，已加入用户 `PATH`）
- **守护进程（Daemon）监听地址**：`127.0.0.1:60832`（固定首选端口 `60832`，兼容范围 `60832-60841`；启动命令：`easyeda.exe daemon start`）
- **本地源码与 MCP 服务入口**：`D:\embededTemplate\easyeda-agent\mcp\src\server.mjs`（已在 `C:\Users\WEI\.gemini\config\mcp_config.json` 配置 `EASYEDA_BIN`）
- **Skill 与运行时目录**：Skill 位于 `C:\Users\WEI\.gemini\config\skills\easyeda-agent\`；运行 PID / 审计 / 检查点位于 `C:\Users\WEI\.easyeda-agent\`
- **详细环境与恢复笔记**：见本库根目录 [`easyeda-agent-env.md`](./easyeda-agent-env.md)

## 8. Windows 批处理脚本（`.bat`）字符编码铁律
- **强制编码**：后续所有项目生成的 `.bat` / `.cmd` 批处理脚本，**必须使用 `GBK`（代码页 `CP936` / ANSI）编码与 `CRLF` 行尾**保存。
- **禁止行为**：严禁直接以 `UTF-8`（尤其是 `UTF-8 with BOM`）编码保存含中文的 `.bat` 文件，避免 Windows `cmd.exe` 默认 `CP936` 下出现中文乱码、路径匹配失败、菜单跳转/标签解析异常或命令截断。
- **校验要求**：生成 `.bat` 后需通过脚本或编码检测确认其可无损编码为 `gbk`（无 BOM）。

## 9. 嵌入式 Web 测试上位机与日志导出铁律
- **日志导出直存项目目录**：上位机导出串口/协议日志时，**严禁落入浏览器 `Downloads` 目录，也严禁弹出文件选择框让用户手动选路径**；必须经本地后台（如 `server.py` 的 `/api/export-log`）**静默写入当前工程 `00_Docs/Debug_Logs/`**，并在当前操作页即时展示保存成功提示。
- **CORS 与行清洗规范**：本地 HTTP 后台服务在 `end_headers()` 统一添加单次 `Access-Control-Allow-Origin: *`，严禁重复发送该响应头导致浏览器跨域拦截；串口接收应按 `\n` 整行拼接并在导出前剥离冗余 `\r` 与纯空行。
- **MQTT 接入方式**：若目标 Broker 未开通 WebSocket 端口（如 `8083`）仅支持原生 TCP（如 `1883`、`32224`），Web 上位机应默认内置本地 WebSocket-to-TCP 透传代理，同时保留 `ws://` 直连切换选项。
- **可复用构建与烧录脚本**：`ML307R-DC` 编译打包与 USB 烧录通用脚本模板保留在知识库 `scripts/ml307r_build_and_pack.bat` 与 `scripts/ml307r_flash_usb.bat`。



