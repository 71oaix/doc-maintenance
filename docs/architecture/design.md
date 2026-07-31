---
title: 文档结构管理技能体系 — 整体设计报告
status: active
created: 2026-07-27
updated: 2026-07-31
tags: [docs-scan, doc-contract, project-doc-architecture, skill-design, architecture]
---

# 文档结构管理技能体系

> 覆盖 doc-maintenance 项目的全部产出：docs-scan、doc-contract、project-doc-architecture 三个 skill，以及它们在 Pi Agent 生态中的定位和协作方式。
> 本文为当前有效版本；自 2026-07-27 起，全体系已统一到 2 态模型（active | archived）。

---

## 一、概述

doc-maintenance 项目产出的是一个**分层协作的文档治理工具箱**，而非一个单体 skill。它把「让项目文档保持整洁」这件事拆成了三个职责明确的 skill，外加一个元 skill 指导整个体系的设计。

### 三 skill 分工一览

| Skill | 职责 | 视角 | 触发时机 |
|-------|------|------|---------|
| **doc-contract** | 单文档的格式 + 生命周期状态流转 | 微观（单个文件） | 创建/修改/归档文档时 |
| **project-doc-architecture** | 目录结构 + 命名规范 + INDEX 索引维护 | 宏观（整个项目） | 建项目目录、重构文档、判断归属时 |
| **docs-scan** | 全量扫描 + 批量修复 | 审计（回顾式） | 任务完成后手动触发 |

### 设计原则

1. **单一职责** — 每个 skill 管好自己的边界，不越界
2. **渐进式暴露** — SKILL.md 只做路由，细则按需加载（references/ + gotchas.md + 模板）
3. **自动与人工分级** — 🟢 可自动修复 / 🟡 需人工确认 / 🔴 仅报告
4. **附着点工程** — frontmatter 是文档的「元数据黏胶」；INDEX.md 是文档网络的「路由表」
5. **自迭代** — 操作日志积累为 gotcha，skill 自身也持续进化

---

## 二、微观层：doc-contract

> 文件位置：`~/.pi/agent/skills/doc-contract/`

负责**单个文档**的完整生命周期。

### Frontmatter 契约

每个文档在 `---` 块内声明自己的元数据：

```yaml
title: 文档标题
status: active        # active | archived
created: 2026-06-01
updated: 2026-06-05
tags: [标签1, 标签2]
supersedes:           # 归档时填写被替代文件
```

状态字段是文档生命周期的「信号灯」，其他所有规则（扫描、索引、目录归类）都以它为参考点。

### 状态流转（2 态）

```
         ┌──────────┐
   创建  │  active  │   归档（不再使用/被替代/过期）
  ─────→ │ （启用） │  ──────────────────────────────→  ┌───────────┐
         │          │                                     │ archived  │
         └──────────┘  ←──────────────────────────────   │（已归档） │
                        恢复（reactivate）                └───────────┘
```

| 流转 | 条件 |
|------|------|
| _创建 → active | 创建新文档时自动设为 active |
| active → archived | 文档不再使用、被替代、过期（需用户确认） |
| archived → active | 已归档文档需要重新启用时 |

> 2026-07-27 审查后由 5 态（demand/discuss/active/stable/archived）简化为 2 态，理由与重建过程见 [design-doc-contract.md](design-doc-contract.md)。

### 操作清单（每次修改文档后）

1. 更新 `docs/INDEX.md`
2. 向用户汇报当前文档状态概览
3. 追加操作日志到 `.run-log.jsonl`

### 关键 gotcha（G001、G002、G004、G005）

- **G001** — 文档的 `title` 字段是业务语义，AI 不能自动「优化」
- **G002** — 每次动文档（创建/修改/移动/归档）都要同步 INDEX.md
- **G004** — archived 文档因被替代而归档时必须填 `supersedes`
- **G005** — 归档不是删除；用户说「删掉」时先解释归档的好处

---

## 三、宏观层：project-doc-architecture

> 文件位置：`~/.pi/agent/skills/project-doc-architecture/`

负责**项目级**的文档组织策略。

### 推荐目录结构

```
<project-root>/
├── AGENTS.md              # 项目规则
├── README.md              # 项目说明
└── docs/                  # 设计文档（唯一文档目录）
    ├── INDEX.md           # 文档索引（必需）
    ├── architecture/      # 系统架构、设计决策
    ├── specification/     # 技术规格、协议
    ├── guide/             # 开发指南、操作流程
    ├── research/          # 技术调研、方案对比
    └── reference/         # 配置、端口、命令速查
```

> 多版本架构与项目特化覆盖机制已在重建中移除：版本交给 git 管理，规则集全局唯一。重建过程见 [design-project-doc-architecture.md](design-project-doc-architecture.md)。

### 核心原则：单源 Truth

每个知识点只在一个文件中维护。引用用 Markdown 链接，不复制粘贴。

### INDEX.md 格式（3 列）

```markdown
| 文档 | 状态 | 路径 |
|------|:----:|------|
| 整体设计报告 | active | docs/architecture/design.md |
```

INDEX 是文档网络的**路由表**——通过它可快速定位任意文档及其状态。

---

## 四、审计层：docs-scan（核心产出）

> 文件位置：`~/.pi/agent/skills/docs-scan/`

这是 doc-maintenance 项目的**核心产出**——一个任务完成后手动触发的全项目文档扫描与修复工具。

### 工作流程

```
阶段〇：尺寸体检
  → 单文件 > 500 行或 > 50KB → 警告（建议拆分/注意 read 截断）
  → 0 字节文件 → 触发检查 #7

阶段一：扫描（只读）
  → 遍历 docs/ 下所有 .md 文件
  → 解析 INDEX.md
  → 逐文件运行 10 项检查

阶段二：分类
  → 🟢 可自动修复（frontmatter、孤儿、幽灵）
  → 🟡 需用户确认（状态非法、目录迁移、过期、不一致）
  → 🔴 仅报告（空文件、交叉引用失效、规范执行审计）

阶段三：执行
  → 自动修复 → 批量确认 → 报告剩余问题

阶段四：输出报告
  → Markdown 格式报告，含自动修复记录/用户确认记录/待处理问题
```

### 10 项检查清单（核心价值）

| # | 检查项 | 严重级 | 说明 |
|---|--------|--------|------|
| 1 | frontmatter 缺失 | 🟢 | 自动从 H1 推断 title，默认 status=active |
| 2 | status 值非法 | 🟡 | 不在 active/archived 中，列出建议给用户选 |
| 3 | 孤儿文档 | 🟢 | 文件存在但 INDEX 无对应行，自动追加 |
| 4 | 幽灵条目 | 🟢 | INDEX 有行但文件不存在，自动删除 |
| 5 | 旧状态目录 | 🟡 | active/discuss/ 等旧目录存在，建议迁移 |
| 6 | 过期文档 | 🟡 | status=active 且 30 天未更新，建议归档 |
| 7 | 空文件/破损 | 🔴 | 内容为空或无法解析，仅报告 |
| 8 | INDEX/frontmatter 不一致 | 🟡 | 标题/状态不一致，建议以 frontmatter 为准 |
| 9 | 交叉引用失效 | 🔴 | Markdown 链接指向不存在的锚点/文件，仅报告 |
| 10 | 规范执行审计 | 🔴 | 命名规范、INDEX 同步、单源 truth 等约定是否被执行，仅报告 |

执行时，🟢 项立即修复，🟡 项批量展示给用户一次确认，🔴 项只报告不触碰。

### 参考规则文件

| 文件 | 内容 |
|------|------|
| `references/frontmatter-rules.md` | frontmatter 格式定义和自动生成逻辑 |
| `references/index-rules.md` | INDEX.md 格式和一致性检查规则 |
| `references/directory-rules.md` | 目录结构规范和目录迁移规则 |
| `references/norm-audit.md` | 规范执行审计（检查 #10）的判定标准 |
| `gotchas.md` | 5 条踩坑记录（G001-G005） |

### Gotchas 亮点

| 编号 | 教训 |
|------|------|
| G001 | 无 docs/ 目录的项目正常跳过，不报错 |
| G002 | 即使看起来明显，文件移动也需用户确认 |
| G003 | INDEX.md 列数不固定，以第一行为准识别映射 |
| G004 | 不修改 frontmatter 的业务字段（title/tags） |
| G005 | 空文档 ≠ 空文件（只有 frontmatter 无正文是合法的） |

---

## 五、三 skill 协作流程

```
用户操作文档
      │
      ▼
┌─────────────────────────────────────────────┐
│  doc-contract                                │
│  检查 frontmatter 格式                      │
│  判断状态流转是否合法                       │
│  确认后写入                                 │
│  追加 .run-log.jsonl                        │
└──────────────┬──────────────────────────────┘
               │ 文档写完后
               ▼
┌─────────────────────────────────────────────┐
│  project-doc-architecture                    │
│  判断：这个文件该放哪个目录？                │
│  检查：INDEX.md 是否已注册？                │
│  自动追加新行到 INDEX.md                    │
│  遵循单源 truth 原则                        │
└──────────────┬──────────────────────────────┘
               │ 任务完成后（用户手动触发）
               ▼
┌─────────────────────────────────────────────┐
│  docs-scan                                   │
│  10 项全量检查                               │
│  🟢 自动修复 / 🟡 批量确认 / 🔴 仅报告      │
│  输出 Markdown 审计报告                     │
│  自迭代：false positive/negative → gotchas   │
└─────────────────────────────────────────────┘
```

### 完整流程示例

1. 用户写了一个新文档 `docs/guide/query-usage.md`
2. **doc-contract** 检查 frontmatter：title/status/created/updated 是否完整 → 不完整则自动补全
3. **project-doc-architecture** 判断归属：在 `guide/` 目录下正确 → 追加到 INDEX.md
4. （一段时间后）任务完成，**用户手动触发** /docs-scan
5. **docs-scan** 发现 query-usage.md 的 INDEX/frontmatter 状态不一致 → 🟡 提示用户确认
6. 问题修复后，docs-scan 输出完整审计报告

---

## 六、元 skill：how-to-make-a-skill（设计哲学）

> 文件位置：`~/.pi/agent/skills/how-to-make-a-skill/`

以上三个 skill 都遵循了 how-to-make-a-skill 的 6 条关键原则：

| 原则 | 在 doc-maintenance 中的体现 |
|------|---------------------------|
| **Skill = 文件夹 ≠ 文件** | 每个 skill 有 SKILL.md + references/ + gotchas.md + 模板文件 |
| **渐进式暴露** | SKILL.md 只做路由，细则按需读取加载 |
| **Description 写给模型** | description 字段用关键词声明触发条件 |
| **Gotcha 最高信号** | 每个 skill 都有 gotchas.md，docs-scan 已积累 5 条 |
| **脚本 > 期望 Agent 自写** | frontmatter-rules.md 给出自动生成 frontmatter 的完整逻辑 |
| **自迭代** | 每次执行后检查是否有新 gotcha 可追加 |

---

## 七、状态与待办

### ✅ 已就绪

- docs-scan skill（SKILL.md + 4 份参考规则 + gotchas.md，5 条）
- doc-contract skill（SKILL.md + references/state-machine.md + references/workflow.md + gotchas.md，重建完成）
- project-doc-architecture skill（SKILL.md + 4 份参考规则 + gotchas.md，重建完成）
- 三 skill 职责边界清晰，互相协作，全部对齐 2 态模型与 3 列 INDEX
- 本项目 docs/ 已建立 INDEX.md，设计文档已按主题归档（本文档为入口）

### ⬜ 待完善

- docs-scan、doc-contract 的 `.run-log.jsonl` 尚未积累操作记录
- 检查 #9 交叉引用、#10 规范执行审计依赖 LLM 判断，尚无脚本化实现
- 跨项目的一致性验证 — 目前扫描限定在单个项目内
- 项目尚未接入 git/GitHub；接入后所有 agent 遵循 AGENTS.md 中的协作规范

---

## 八、总结

doc-maintenance 项目构建了一个**三层文档治理体系**：

```
微观（doc-contract）→ 单文档的生命周期
宏观（project-doc-architecture）→ 整个项目的文档架构
审计（docs-scan）→ 回顾式全量检查与修复
```

三个 skill 职责正交、协作紧密，加上 how-to-make-a-skill 这个元 skill 指导设计，构成了 Pi Agent 中「项目文档整洁度」的完整解决方案。

核心设计复用模式：**附着点（frontmatter）+ 路由表（INDEX）+ 审计器（10 项检查）+ 三级处理策略（🟢🟡🔴）**。
