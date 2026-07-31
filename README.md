# doc-maintenance

> 文件结构管理技能 — 项目文档的全面梳理与维护

## 做什么

- **/docs-scan skill** — 任务完成后手动触发，10 项检查全量扫描文档结构
- 管理 `doc-contract` 和 `project-doc-architecture` skill 的规则迭代

## 文件结构

```
doc-maintenance/
├── AGENTS.md                 ← 项目规则（含多 agent 共用的 Git/GitHub 协作规范）
├── README.md                 ← 本文
├── skills/                   ← 技能源码（唯一权威）
│   ├── docs-scan/
│   ├── doc-contract/
│   └── project-doc-architecture/
├── scripts/
│   └── sync-skills.ps1       ← 同步技能到 ~/.pi/agent/skills/
└── docs/
    ├── INDEX.md              ← 文档索引（必需）
    └── architecture/         ← 设计文档
        ├── design.md                          ← 整体设计报告
        ├── design-doc-contract.md             ← doc-contract 审查与重建设计
        ├── design-docs-scan.md                ← docs-scan 审计层设计
        └── design-project-doc-architecture.md ← 宏观层设计
```

## 相关

- Skill 位置：`skills/`（仓库源码，唯一权威）+ `~/.pi/agent/skills/`（部署副本，用 `scripts/sync-skills.ps1` 同步）
- 参考项目：[neat-freak](https://github.com/KKKKhazix/khazix-skills/tree/main/neat-freak) — 吸取了知识治理收尾的设计理念
- 依赖规则：`doc-contract` + `project-doc-architecture` skill
- Git/GitHub 操作规范见 [AGENTS.md](AGENTS.md)
