# 常用成熟单元电路库 (Reusable Circuit Blocks)

本目录用于沉淀经过打板验证或深度审查的成熟单元电路设计规范，方便新项目直接复用，避免重复踩坑。

---

## 已验证 / 重点单元电路索引

| 模块类别 | 典型器件 | 核心要点摘要 | 详细文档 |
|---|---|---|---|
| **24V 低侧感性负载驱动** | `20N06` + `S8050` + `SS34FA` | 续流二极管阴极接 24V；栅极就近串 `47~100Ω` 阻尼电阻；`10k` 上拉放 MCU 侧；`4.7k` 选 ≥0805 封装 | [low-side-20n06-traps.md](../../chips/power-switches/low-side-20n06-traps.md) |
| **AC 220V → DC 12V 工业电源** | `LS10-13B12R3P` + `14D561K` + `6.8Ω/3W` | 压敏电阻在保险丝后；外接 `22uF/450V` 储能与 `1nF/400VAC` Y 电容；初次级开 `1.5~2.0mm` 防爬电槽；12V TVS 选 `SMBJ15CA` | [jlcpcb-mixed-signal-rules.md](../pcb-rules/jlcpcb-mixed-signal-rules.md) |
| **12V → 3.8V / 3.3V 同步降压** | `SCT2330CTVBR` | $V_{out}=0.8\times(1+R_1/R_2)$；3.8V 给 4G 模组配 `22uF×3+100nF`；输入电容距 `VIN/GND <= 2mm`，`SW` 短粗不铺大铜 | [jlcpcb-mixed-signal-rules.md](../pcb-rules/jlcpcb-mixed-signal-rules.md) |
| **单/多路隔离 RS-485** | `CA-IS3092W` + `SM712` | 内置隔离 DC-DC，两侧 `10uF+100nF` 同层紧贴引脚；下方 ≥4mm 隔离带；每路独立地岛禁互连；预留 `120Ω` 终端与 `DE` 10k 下拉 | [jlcpcb-mixed-signal-rules.md](../pcb-rules/jlcpcb-mixed-signal-rules.md) |
| **4G Cat.1 模组最小系统** | `ML307R-DC` + `SRV05-4` | `VBAT` 独立 `3.8V/2A` 禁串磁珠，先过 `220uF`；SIM 线严格按 `22Ω串阻→33pF→ESD→卡座`；`ANT_MAIN` 50Ω 顶层不打孔；`VCC_CAMA` 悬空 | [ml307r-opencpu-notes.md](../../chips/cmiot/ml307r-opencpu-notes.md) |
| **100M 以太网内置 PHY 接口** | `CH32V407RET6` + `HR911105A` | `3V3_PHY` 经 `600Ω` 磁珠独立滤波；`MDI` 100Ω 差分误差 <10mil；变压器下方全层挖空；`CHS_GND` 预留 `1MΩ // 1nF/2kV` 接 `GND` | [jlcpcb-mixed-signal-rules.md](../pcb-rules/jlcpcb-mixed-signal-rules.md) |

---

## 新增单元电路记录模板

后续每定型一个新模块（如 CAN 隔离、POE、锂电池充放电、PT100/ADC 采样前端），按以下结构新增 `<module-name>.md`：
1. **适用场景与核心芯片**
2. **关键参数计算公式（分压、限流、耐压、功耗）**
3. **原理图必查项（上下拉、防反接、默认电平）**
4. **PCB 布局布线红线**
5. **实测踩坑记录**
