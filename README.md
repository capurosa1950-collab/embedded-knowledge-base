# 个人嵌入式研发知识库 (Embedded Knowledge Base)

这是一个针对嵌入式系统开发的个人专属知识库。采用纯 Markdown + Git 驱动，**不依赖任何专有数据库，对所有 AI 模型完全中立**。

---

## 目录索引与架构

```text
embedded-knowledge-base/
├── AGENTS.md                    # 给所有 AI 的全局指令与嵌入式代码铁律
├── README.md                    # 本知识库说明文档
├── repomix.config.json          # 一键打包知识库为单文件的配置文件
│
├── scripts/                     # 自动化效率脚本
│   └── create_project.bat       # 【双击即用】一键生成符合规范的新项目脚手架
│
├── templates/                   # 模板中心
│   ├── project-template/        # 新项目标准结构模板
│   ├── Pinout_Template.md       # 引脚与外设映射表模板
│   ├── Specs_Template.md        # 需求规格与设计参数模板
│   └── Packing_Spec_Template.md # 【量产交付与出货清单规范模板】
│
├── chips/                       # 芯片级硬件踩坑与 Errata 库
│   └── stm32/                   # STM32 系列踩坑记录（附带示例）
│
├── hardware-profiles/           # 硬件板卡画像（引脚、电源轨、核心器件）
│   └── board-template.md        # 板卡画像标准模板
│
└── protocols/                   # 通信协议与时序调试经验
    └── communication-checklist.md # 串口/I2C/SPI/CAN 联调自查表
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
