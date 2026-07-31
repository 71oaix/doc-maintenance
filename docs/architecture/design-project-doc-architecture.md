---
title: 宏观层设计 — 项目文档架构（project-doc-architecture）
status: active
created: 2026-07-27
updated: 2026-07-27
tags: [project-doc-architecture, directory, INDEX, architecture]
---

# 宏观层设计：项目文档架构

> doc-maintenance 三层设计的第二层。聚焦项目整体的文档组织——目录结构、INDEX.md 索引、命名规范，不涉及单文档的 frontmatter 或状态流转。
> 审查方法：how-to-make-a-skill 四维框架。

---

## 第一部分：审查结果

### 维度一：Description

| 项 | 要求 | 结果 |
|---|------|------|
| 第一句话是「什么情况触发」 | ✅ | "当用户需要..." OK |
| 关键词 ≥5 个 | ⚠️ | "文档架构""目录结构""多版本"——太抽象，用户不会说这些 |
| 反例 | ✅ | 指向 doc-contract |
| 不以功能简介式开头 | ❌ | "管理项目整体文档架构" = 功能简介式 |
| ≤1024 字符 | ✅ | |

**问题**：开头 "管理XX" 和关键词都不够口语化。用户说的不是「判断文档归属」，而是「这个文件放哪」「目录建在哪里」。

### 维度二：Skill 结构

```
project-doc-architecture/
├── SKILL.md              ← 路由 + 冗余的"触发场景"（边界污染）
├── gotchas.md            ← 3 条
├── .run-log.jsonl        ← 空文件
└── references/
    ├── directory-structure.md  ← 含多版本架构（对独立开发者过重）
    ├── conventions.md          ← 含文档生命周期（该在 doc-contract）
    ├── index-maintenance.md    ← 含 5 态模型（与 doc-contract 矛盾）
    └── auto-rules.md           ← 含 discuss 默认状态（与 doc-contract 矛盾）
```

**问题**：结构结构合理（有分层），但内容有 3 类污染。

### 维度三：渐进式披露

层 1-5 框架本身没问题，但：

- **SKILL.md 「触发场景」是层 2 污染了层 1 的职责** —— description 已经说了什么时候触发
- **references/ 里混入了 doc-contract 的管辖内容**（conventions.md 的文档生命周期、auto-rules.md 的 frontmatter 默认状态）

### 维度四：与 doc-contract 2 态模型的一致性

| 文件 | 新旧冲突 |
|------|---------|
| SKILL.md 核心原则速查 | 显示 5 态 `demand → discuss → active → stable → archived` |
| auto-rules.md 规则 1 | `默认为 discuss` — discuss 状态已不存在 |
| index-maintenance.md | 引用「五阶段流转」 |
| conventions.md | `status: superseded` — superseded 不是合法状态 |

**必须全部对齐到 2 态模型。**

### 其他发现

- `directory-structure.md` 中 `docs/` 目录在结构树中出现了两次（复制粘贴错误）
- `conventions.md` 的「设计文档生命周期」章节是 doc-contract 的职责，边界越界
- `conventions.md` 的「什么时候写 / 什么时候读」表与实际的 2 态简化模型矛盾

---

## 第二部分：重建设计

### 原则：为独立开发者简化

1. **砍掉多版本架构** — 独立开发者用 git 管理版本，不需要 v1/v2/... 目录分层
2. **砍掉项目特化机制** — 一个开发者维护一个规则集，不需要覆盖机制
3. **对齐 2 态模型** — 所有地方只出现 active | archived
4. **收紧边界** — 不重复 doc-contract 的职责

### 简化后的目录结构

```
<project-root>/
├── AGENTS.md              # 项目规则
├── README.md              # 项目说明
├── docs/                  # 设计文档（唯一文档目录）
│   ├── INDEX.md           # 文档索引
│   ├── architecture/      # 架构设计、设计决策
│   ├── specification/     # 技术规格、协议
│   ├── guide/             # 开发指南、操作流程
│   ├── research/          # 技术调研、方案对比
│   └── reference/         # 配置、端口、命令速查
```

**没有了**：`knowledge/`（外部知识放 research/）、`v1/`/`v2/`（git 管理）、项目特化声明。

### INDEX.md 格式

```markdown
| 文档 | 状态 | 路径 |
|------|:----:|------|
| v2 架构设计 | active | docs/architecture/v2-architecture.md |
| SQLite 选型 | active | docs/research/sqlite-choice.md |
| 旧版架构 | archived | docs/architecture/v1-architecture.md |
```

**变化**：移除「版本」列——不再需要跨版本标记。

### Description 重建

```
旧（功能简介式）：
  管理项目整体文档架构：目录结构、多版本组织、单源 truth 原则...

新（触发条件声明式）：
  当用户需要创建项目目录、组织文档结构、判断文档放哪个目录、
  维护 INDEX.md 索引、或清理重复文档时触发。
  关键词：目录结构、文档放哪、INDEX.md、文档索引、建目录、
  文档组织、文档归属、重复文档、文件结构、doc架构。
  当涉及单个文档的格式/状态/创建/归档时应触发 doc-contract 而非本 skill。
```

### 职责边界（调整后）

| 职责 | 所属 skill |
|------|-----------|
| 目录结构规范、命名规范、INDEX.md 格式与维护 | **本 skill** |
| 单文档 frontmatter、状态流转 | doc-contract |
| 全项目文档扫描 | docs-scan |
| ~~多版本架构~~ | ~~移除（git 管理）~~ |
| ~~项目特化声明~~ | ~~移除（单开发者维护一套规则）~~ |

### References 文件瘦身

| 文件 | 原来 | 改后 |
|------|------|------|
| directory-structure.md | 含多版本架构 + 重复的 docs/ 目录 | 仅 5 主题目录 + 单源 truth |
| conventions.md | 含文档生命周期（doc-contract 职责） | 仅命名规范 + 单源 truth |
| index-maintenance.md | 含 5 态模型 | 对齐 2 态 |
| auto-rules.md | 含 discuss 默认状态 | 对齐 active 默认 |

---

## 第三部分：实施清单

### 需要改动的文件

| 文件 | 操作 | 变更 |
|------|------|------|
| **SKILL.md** | 🔄 修改 | description + 移除 5 态 + 删除"触发场景" |
| **gotchas.md** | 🔄 修改 | 更新时间，检查一致性 |
| **references/directory-structure.md** | 🔄 修改 | 移除多版本 + 修复重复目录 + 简化 |
| **references/conventions.md** | 🔄 修改 | 移除生命周期章节（doc-contract 职责） |
| **references/index-maintenance.md** | 🔄 修改 | 对齐 2 态 |
| **references/auto-rules.md** | 🔄 修改 | discuss→active + 对齐 2 态 |
| **docs/design-project-doc-architecture.md** | ✨ 创建 | 本文件 |
