# EasyEDA Pro 自动化工具链与守护进程环境档案

> 用于固定记录本机 `easyeda-agent` 的 CLI、守护进程（Daemon）、MCP 与 Skill 路径，防止跨会话或环境切换后丢失地址。

---

## 1. 核心路径与端口（已实测生效）

| 组件 | 路径 / 地址 | 说明 |
| :--- | :--- | :--- |
| **CLI / Daemon 二进制** | `C:\Users\WEI\.local\bin\easyeda.exe` | 版本 `v1.21.0`，所在目录已写入用户环境变量 `PATH` |
| **Daemon 本地监听地址** | `127.0.0.1:60832` | 默认端口范围 `60832-60841`，连接器固定连接 `60832` |
| **Daemon 运行态目录** | `C:\Users\WEI\.easyeda-agent\` | 包含 `daemon.pid`、`audit/`、`checkpoints/`、`workflow/` |
| **本地源码与 MCP 服务端** | `D:\embededTemplate\easyeda-agent\` | MCP 入口：`D:\embededTemplate\easyeda-agent\mcp\src\server.mjs` |
| **MCP 配置文件** | `C:\Users\WEI\.gemini\config\mcp_config.json` | 已通过环境变量 `EASYEDA_BIN` 显式指向 `easyeda.exe` |
| **Agent Skill 目录** | `C:\Users\WEI\.gemini\config\skills\easyeda-agent\` | 规则与参考文档所在目录 |

---

## 2. 常用启停与排障命令

```powershell
# 1. 启动守护进程（后台或新会话找不到服务时使用）
& "C:\Users\WEI\.local\bin\easyeda.exe" daemon start

# 2. 检查守护进程与 EasyEDA Pro 连接器健康状态
& "C:\Users\WEI\.local\bin\easyeda.exe" health

# 3. 停止本地守护进程
& "C:\Users\WEI\.local\bin\easyeda.exe" daemon stop

# 4. 查看当前 CLI 版本
& "C:\Users\WEI\.local\bin\easyeda.exe" version
```

---

## 3. 连接前置条件（若下次 `connector` 报错）

1. 在嘉立创 EDA 专业版 **V4**（推荐 `>= 4.1.60`，当前使用 `4.1.105`）中确认已启用 `easyeda-agent` 扩展连接器。
2. 在 EDA 设置中开启 **「设置 → 允许外部交互」**，并打开目标工程。
3. 执行 `easyeda.exe health` 确认 `daemon` 与 `connector` 均为 `ok` 后再进行原理图 / PCB 读写。
