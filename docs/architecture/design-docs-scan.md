---
title: 审计层设计 — 文档扫描（docs-scan）
status: active
created: 2026-07-27
updated: 2026-07-27
tags: [docs-scan, audit, frontmatter, INDEX, directory]
---

# 审计层设计：文档扫描

> doc-maintenance 三层设计的第三层。任务完成后手动触发的全项目文档审计工具。
> 核心能力：10 项检查，三级处理（🟢 自动 / 🟡 确认 / 🔴 报告）。

---

## 第一部分：审查结果

### 维度一：Description ✅

这是三个 skill 里 description 写得最好的——已经是触发条件声明式，关键词和反例都到位。**不需修改。**

### 维度二：5 态残留（严重）

| 文件 | 位置 | 问题 |
|------|------|------|
| SKILL.md 检查 #2 | 合法 status 集 | `demand / discuss / active / stable / archived` |
| SKILL.md 检查 #6 | 过期条件 | `status=stable 且 updated > 30 天` |
| SKILL.md 速查区 | frontmatter 注释 | `# demand \| discuss \| active \| stable \| archived` |
| SKILL.md 速查区 | INDEX 格式 | 含 版本 列（4 列） |
| SKILL.md 阶段一② | INDEX 解析 | 「解析路径、状态、版本」 |
| frontmatter-rules.md | 合法字段表 + 检查 #1/#2/#6 | 全部引用 5 态 |
| index-rules.md | INDEX 格式 + 检查 #3 | 含 版本 列 + 版本自动填充逻辑 |
| directory-rules.md | 检查 #5 | 旧状态目录列表仍有效但可缩减 |

### 维度三：检查 #6 需要重新设计

原来的逻辑：`status=stable 且 updated > 30天` → 建议归档。

`stable` 状态已被移除。新逻辑：

```
status=active 且 updated > STALE_DAYS(30)天 → 🟡 建议用户考虑归档
```

条件更直白——活跃文档超过一个月没更新，可能是「写好就不碰」的稳定文档，也可能是「废弃但忘了标记」。

### 维度四：结构清晰 ✅

渐进式披露做得最好。SKILL.md 有完整工作流 + 10 项检查清单，references/ 按检查主题分文件，gotchas 独立。

### 维度五：描述本身 — 已是最优

与前面两个 skill 不同，docs-scan 的 description 本来就用触发声明式写的。但有一个反例可以更精确。

---

## 第二部分：变更清单

### #1：对齐 2 态模型（3 文件，多处修改）

| 修改 | 位置 | 旧值 | 新值 |
|------|------|------|------|
| status 合法值 | SKILL.md #2, frontmatter-rules.md 合法字段表 + #2 | `demand / discuss / active / stable / archived` | `active / archived` |
| frontmatter 注释 | SKILL.md 速查区 | `# demand \| discuss \| active \| stable \| archived` | `# active \| archived` |
| 过期条件 | SKILL.md #6, frontmatter-rules.md #6 | `status=stable 且 updated > 30 天` | `status=active 且 updated > 30 天` |
| INDEX 列数 | SKILL.md 速查区 + 阶段一②, index-rules.md | 4 列（含版本） | 3 列 |
| 版本自动填充 | index-rules.md 检查 #3 | 「读取 frontmatter tags 版本信息」 | 删除此行 |

### #2：强化收尾清单（同类问题）

加上 run-log 步骤：

```
每次执行 docs-scan 后：
1. 追加操作记录到 .run-log.jsonl
2. 累计约 10 条后，询问用户是否需要总结为 gotcha
```

### #3：Gotchas 保持不动 ✅

5 条全部适用于 2 态模型。G003 关于 INDEX 格式差异在新 3 列格式下依然有意义。

---

## 第三部分：实施

### 需要改动的文件

| 文件 | 操作 |
|------|------|
| `SKILL.md` | 🔄 修改 #2、#6、速查区 frontmatter+INDEX、阶段一②、收尾清单 |
| `references/frontmatter-rules.md` | 🔄 修改合法字段表 + #1 + #2 + #6 |
| `references/index-rules.md` | 🔄 删除版本列、修改 #3 自动修复逻辑 |
| `references/directory-rules.md` | ✅ 保持不变（检查 #5 仍有效） |
| `docs/design-docs-scan.md` | ✨ 创建（本文件） |

---

## 第四部分：neat-freak 启发（新增改进）

参考 [neat-freak](https://github.com/KKKKhazix/khazix-skills/tree/main/neat-freak) 的实战经验，吸收了三个模式：

### ① 多模式触发词

原来只有关键词匹配。现在同时支持：
- **命令**：`/skill:docs-scan`（Pi 内置）
- **意图**："收尾""文档收尾""扫一下文档"
- **点名**："跑一下 docs-scan"

### ② 阶段〇：尺寸体检

在正式扫描前先做文件大小检查，对标 neat-freak 的「第零步」：
- 单文件 > 500 行 → 警告（建议拆分）
- 单文件 > 50KB → 警告（超过 read 截断阈值）
- 0 字节文件 → 触发检查 #7

### ③ 检查 #10：规范执行审计

新增检查项，不只检查格式对不对，而是检查**规则有没有被执行**：
- 命名规范执行
- INDEX.md 同步
- 单源 truth（无重复内容）
- 目录归属正确性
- Frontmatter 一致性

新增 `references/norm-audit.md` 作为规则文件。
