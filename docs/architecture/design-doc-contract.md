---
title: doc-contract 审查报告与重建设计
status: active
created: 2026-07-27
updated: 2026-07-27
tags: [doc-contract, skill-design, how-to-make-a-skill, review]
---

# doc-contract 审查报告与重建设计

> 使用 how-to-make-a-skill 规范对 doc-contract skill 做全面审查，然后重建。
> 核心变更：状态机从 5 态简化为 2 态（active ↔ archived），description 重构。

---

## 第一部分：审查报告

### 审查方法

使用 how-to-make-a-skill 的四个检查维度：

1. **Description 写作规范**（references/description-writing.md）
2. **Skill = 文件夹 ≠ 文件**（references/core-concepts.md）
3. **渐进式披露**（references/progressive-disclosure.md）
4. **Gotcha 建设**

---

### 维度一：Description 审查

**当前值：**
```yaml
description: >
  管理单个文档的格式、生命周期状态流转、创建/修改/归档规则。
  当用户需要创建新文档、修改文档内容、判断文档状态、归档文档、
  或涉及 docs/ 目录下文件操作时触发。
  关键词：创建文档、修改文档、文档格式、文档状态、归档、frontmatter、
  文档契约、active、archived。
  当用户讨论整体项目文档架构（目录结构、INDEX.md）时应加载
  project-doc-architecture 而非本 skill。
```

**逐项检查（好 Description 的公式）：**

| 项 | 要求 | 结果 | 说明 |
|---|------|------|------|
| 场景描述 | 第一句话说明什么情况下触发 | ⚠️ 偏弱 | "管理XX规则"是功能简介式开头，不是触发声明 |
| 关键词 | ≥5 个具体关键词 | ✅ 有 8 个 | 但不够贴近用户日常口语 |
| 反例 | 什么情况不触发 | ✅ 有 | 指向 project-doc-architecture，清晰 |
| 长度 | ≤1024 字符 | ✅ 约 300 字 | OK |
| 不以"帮助""用于"开头 | 避免功能简介式 | ⚠️ 偏弱 | "管理XX"本质上也是功能简介式 |

**问题总结：**
1. **开头太「功能简介」** — "管理...什么什么"更像 README，不是触发声明
2. **关键词不够口语化** — 用户不会说"文档状态流转"，会说"这篇我不用了/归档吧"
3. **反例约束力弱** — 只说"当用户讨论整体文档架构时"，但"修改文档内容"和"判断文档归属"在实际中边界模糊

---

### 维度二：Skill 结构审查

**当前结构：**
```
doc-contract/
├── SKILL.md              ← 路由 + 深度内容混在一起
├── gotchas.md            ← 独立文件 ✅
└── references/
    ├── state-machine.md  ← 已规划但未创建 ⬜
    └── workflow.md       ← 已规划但未创建 ⬜
```

**逐项检查（Skill = 文件夹）：**

| 项 | 要求 | 结果 | 说明 |
|---|------|------|------|
| 多文件结构 | 不是单文件 | ✅ | 有 references/ 和 gotchas.md |
| 有文件地图 | SKILL.md 说明什么场景读哪个文件 | ✅ | 清晰的文件地图 |
| 有操作日志 | .run-log.jsonl | ⬜ 已规划 | 尚未创建 |
| 深度内容外移 | references/ | ⬜ 已规划 | state-machine.md + workflow.md 尚未创建 |

**问题总结：**
1. **SKILL.md 承载了过多深度内容** — 状态流转表、核心规则速览应该移到 references/
2. **两个 references 文件是空壳** — 只有文件地图声明了它们，实际文件不存在

---

### 维度三：渐进式披露审查

**当前层次：**

```
层 1（触发）      description         ✅ 放在 frontmatter
层 2（路由）      SKILL.md 文件地图    ✅ 有
层 3（知识）      references/         ⬜ 占位但未填
层 4（坑点）      gotchas.md          ✅ 4 条
层 5（工具）      .run-log.jsonl      ⬜ 未创建
```

**分析：**
- 层 1、2、4 都不错
- 层 3 和 5 是空壳——这是当前最大的结构缺陷
- 好消息：结构骨架本身是合理的，只需填充内容即可

---

### 维度四：Gotcha 审查

**当前 4 条：**
- G001：讨论想法 vs 明确要做（区分不清晰）
- G002：忘记更新 INDEX.md
- G003：状态流转的边界模糊
- G004：Archived 缺少 supersedes 指向

**评估：**
- G001 在新 2 态模型下仍然有效（用户说了想法不一定等于要写文档）
- G002 仍然有效
- **G003 在新模型下失效** — 因为 stable 状态已被移除，不再有 "2 周不修改才能标记 stable" 的规则
- G004 仍然有效（归档时记录替代关系）

---

### 审查总结

| 维度 | 评级 | 主要问题 |
|------|------|---------|
| Description | 🟡 | 开头偏功能简介，关键词不够口语化 |
| Skill 结构 | 🟡 | references/ 空壳，SKILL.md 内容过载 |
| 渐进式披露 | 🟡 | 层 3/5 空壳，但层次设计本身合理 |
| Gotcha | 🟢 | 去掉 G003 后剩余 3 条有效 |
| 核心逻辑 | 🔴 | 5 态状态机对独立开发者过重，需简化为 2 态 |

---

## 第二部分：状态机简化设计

### 旧模型（5 态 → 废弃）

```
demand → discuss → active → stable → archived
```

对独立开发者的问题：
- **demand** 和 **discuss** 是同一个状态——想到了就做，不需要"讨论阶段"
- **stable** 无意义——单人开发，没人会扰动稳定文档，active 就够了
- 5 态让流转规则变得复杂（哪些流转允许？要不要走中间态？），增加了 system prompt 的噪音

### 新模型（2 态）

```
         ┌──────────┐
   创建  │  active  │   归档   ┌───────────┐
  ─────→ │（启用）  │  ──────→ │  archived  │
         │          │          │ （已归档） │
         └──────────┘          └───────────┘
               ↑                      │
               └──────────────────────┘
                恢复（reactivate）
```

**规则：**
- **所有新文档**以 `active` 开始
- **归档条件**：文档不再使用、被替代、过期
- **恢复条件**：已归档文档需要重新启用时
- **不存在的操作**：不删除文档、不保留多重状态、不维护废弃文档

### Frontmatter 调整

```
旧 →            新（简化后）
─────────────────────────────────────
title           title         不变
status: active  status: active  合法值只剩 active | archived
status: demand  ✗ 移除
status: discuss ✗ 移除
status: stable  ✗ 移除
created         created       不变
updated         updated       不变
tags            tags          可选，不变
supersedes      supersedes    可选，归档时推荐填
```

### Gotcha G003 替换

**移除** G003（状态流转边界模糊 — 已不适用）

**新增** G005：归档不是删除

> 用户可能会说"把这个文档删掉"，但我们的实践是归档（标记 archived），不是物理删除。
> 归档保留内容可追溯，删除造成信息丢失。
> 正确做法：解释 "归档而不是删除的好处"，用户执意要删再用 git rm。

---

## 第三部分：Description 重建

### 重建过程（按 how-to-make-a-skill 步骤）

**步骤 1：列出用户可能说的话**

针对独立开发者场景：
- "记一下这个想法" / "记录一下"
- "写个文档"
- "新开个文档"
- "改一下这篇"
- "更新内容"
- "这个文档状态不对"
- "这篇不用了，归档吧"
- "废弃掉"
- "frontmatter 改一下"
- "这篇恢复了，改回启用"

**步骤 2：提取关键词**

核心词：创建文档、写文档、新文档、记录
修改词：更新文档、修改文档、改文档、编辑
归档词：归档、废弃、不用了、过期
元数据词：frontmatter、文档格式、文档状态、启用、active、archived
边界词：目录结构、INDEX、文件归属 → 这些应该去 project-doc-architecture

**步骤 3：写场景描述**

"当用户需要创建、修改或归档文档，或者检查和修正文档的 frontmatter 时触发"

**步骤 4：写反例**

反例两类：
1. "讨论整体文档架构、目录结构、INDEX.md 维护、判断文件归属" → project-doc-architecture
2. "任务完成后做全项目扫描" → docs-scan

**步骤 5：精简**

**最终版：**
```yaml
description: >
  当用户需要创建、修改或归档文档，或者检查和修正文档的 frontmatter 格式与状态时触发。
  适用场景：写新文档、更新内容、改 frontmatter、废弃/归档、恢复已归档文档。
  关键词：创建文档、写文档、新文档、记录、更新文档、修改文档、改文档、编辑、归档、
  废弃、不用了、过期、frontmatter、文档格式、文档状态、active、archived。
  当用户讨论整体文档架构（目录结构、INDEX.md 维护、文件归属判断）时应触发
  project-doc-architecture skill；当需要全项目扫描文档结构时应触发 docs-scan skill。
```

---

## 第四部分：Skill 结构重建

### 新结构

```
doc-contract/
├── SKILL.md                   ← 层2（路由）+ 层3（核心规则，按需简写）
├── references/
│   ├── state-machine.md       ← 层3：2 态状态机完整规则
│   └── workflow.md            ← 层3：创建/修改/归档标准操作流程
├── gotchas.md                 ← 层4：坑点记录
└── .run-log.jsonl             ← 层5：操作日志
```

**原则：**
- SKILL.md 只包含路由 + 必要速查，不包含深度规则
- references/ 填充实际内容（之前只有占位符）
- .run-log.jsonl 创建空文件

### SKILL.md 内容拆分

| 当前内容块 | 保留在 SKILL.md | 移入 references/ |
|-----------|----------------|-----------------|
| 文件地图 | ✅ | |
| 职责边界 | ✅ | |
| 核心规则速览 | ⚠️ 精简后保留 | |
| frontmatter 格式 | ✅ 简表 | |
| 状态流转表 | | ✅ references/state-machine.md |
| 更新收尾清单 | ✅ | |
| 操作日志说明 | ✅ | |

---

## 第五部分：实施清单

### 需要修改的文件

| 文件 | 操作 | 说明 |
|------|------|------|
| **docs/design-doc-contract.md** | ✅ 已更新 | 本文件，包含审查 + 重建设计 |
| **~/.pi/agent/skills/doc-contract/SKILL.md** | 🔜 修改 | 更新 description + 精简状态机 + 核心规则 |
| **~/.pi/agent/skills/doc-contract/gotchas.md** | 🔜 修改 | 移除 G003，新增 G005 |
| **~/.pi/agent/skills/doc-contract/references/state-machine.md** | 🔜 创建 | 2 态状态机完整规则 |
| **~/.pi/agent/skills/doc-contract/references/workflow.md** | 🔜 创建 | 标准操作流程 |
| **~/.pi/agent/skills/doc-contract/.run-log.jsonl** | 🔜 创建 | 空日志文件 |

### 状态流转

```
旧态         新态
──────────────────────
demand       → active（想好了直接做）
discuss      → active（同上）
active       → active（保留）
stable       → active（合并到 active）
archived     → archived（保留）
```
