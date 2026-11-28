# 个人嵌入式研发知识库 (Embedded Knowledge Base)

这是一个针对嵌入式系统开发的个人专属知识库。采用纯 Markdown + Git 驱动，**不依赖任何专有数据库，对所有 AI 模型完全中立**。

---

## 目录索引与架构

```text
embedded-knowledge-base/
├── AGENTS.md                    # 顶层路由索引 + 固件/上位机/脚本全局铁律
├── README.md                    # 本知识库说明文档
├── repomix.config.json          # 一键打包知识库为单文件的配置文件
│
├── hardware/                    # 【硬件与 PCB 专属域】
│   ├── AGENTS_HW.md             # 硬件原理图与 PCB 设计 AI 专属铁律
│   ├── circuits/                # 已验证可复用单元电路库（AC-DC、DCDC、485、4G、20N06）
│   ├── pcb-rules/               # 嘉立创工业混合信号 PCB 规则与手工布线 7 步顺序
│   ├── bom-preferred/           # 个人优选元器件与选型避坑参考表
│   └── checklists/              # 原理图评审与投板前 PCB/DFM 自检清单
│
├── chips/                       # 【软硬共享】芯片级硬件/固件踩坑与 Errata 库
├── hardware-profiles/           # 【软硬共享】各项目硬件板卡画像（电源轨、引脚、器件）
├── protocols/                   # 【软硬共享】通信协议与时序调试经验
├── datasheets/                  # 常用小体积数据手册与摘要索引（大型资产建议外置）
│
├── scripts/                     # 自动化效率脚本（脚手架、ML307R 编译/烧录）
├── ai-scripts/                  # 跨项目 AI 临时分析/辅助脚本隔离区
└── templates/                   # 新项目结构、Pinout、规格书与装箱规范模板
```

---

## 核心使用流程

### 1. 开新项目：一键生成标准工程目录
每次开发新项目时，无需手动建文件夹：
1. 运行 `scripts/create_project.bat`
2. 输入项目名（如 `Smart-Gateway-V1`），自动在当前位置生成包含 `00_Docs` ~ `06_Release` 的完整结构与 `.gitignore` 过滤规则。

### 2. 换新设备/换新 AI 时：一秒载入记忆
当你切换到一台新电脑，或者开启一个新的大模型会话（Claude / ChatGPT / DeepSeek）时：
1. 在本仓库根目录下运行：
   ```bash
   npx repomix
   ```
2. 它会把你的代码规范、板卡引脚、芯片避坑经验自动打包成一个 `repomix-output.txt`。
3. 把这个文件直接拖给任意 AI，它将立即完全掌握你的编程习惯与硬件背景，不会出现幻觉和低级错误。

### 3. 日常沉淀：遇到硬件/固件 Bug 随手记
在解决棘手的硬件 Bug 或寄存器问题后，直接对 AI 说：
> *“把刚才这个 I2C 硬件锁死的问题，按规范总结存入 `chips/xxx.md`”*
