# doc-maintenance 项目规则

## 项目定位

维护 Pi Agent 的文件结构管理技能（/docs-scan），确保项目文档的完整性、一致性和可维护性。

## 目录约定

- `docs/` — 设计文档；必须维护 `docs/INDEX.md`，文档按主题放入 `architecture/`、`specification/`、`guide/`、`research/`、`reference/`
- Skill 代码在 `~/.pi/agent/skills/`（docs-scan、doc-contract、project-doc-architecture）
- 本项目的 AGENTS.md 不包含业务代码约束（纯文档管理项目）

## 文档规则

- 文档遵循 doc-contract：frontmatter 必填 `title / status / created / updated`，状态只有 `active | archived`
- 创建、修改、移动、归档文档后，必须同步更新 `docs/INDEX.md`
- 归档不删除：被替代/过期的文档标记 `archived`，被替代时填写 `supersedes`

## 参考技能

| 技能 | 用途 |
|------|------|
| `docs-scan` | 10 项检查全量扫描（本项目的核心产出） |
| `doc-contract` | 单文档格式和状态流转规则 |
| `project-doc-architecture` | 文档架构、目录结构规则 |
| `how-to-make-a-skill` | Skill 设计规范 |

## Git / GitHub 协作规范（所有 agent 通用）

本仓库接入 GitHub 后，任何 agent 的提交/更新都遵循以下统一流程：

1. **改动前**：`git fetch` + `git pull`，确保基于最新内容修改。
2. **改动后**：`git add` 具体文件 → `git commit` → `git push`。
   - 提交信息格式：`<类型>: <中文摘要>`，例如 `docs: 补全 INDEX.md`、`fix: 修正过期的 5 态规则`
   - 常用类型：`docs:`（文档）、`skill:`（技能规则）、`fix:`（修正）、`chore:`（杂项）
3. **冲突处理**：推送被拒时先 `git pull --rebase` 再推；无法自动解决时停下询问用户，不覆盖任何人的修改。
4. **分支策略**：默认直接推 main；若仓库开启了分支保护，则新建 `feature/<说明>` 分支并提交 PR，由用户合并。
5. **凭据安全**：token/密钥绝不写入仓库文件或 AGENTS.md；GitHub 认证统一用 `gh auth login`（一次登录，全机器共享），或系统凭据管理器。
6. **提交后**：向用户简要汇报提交号与变更内容。

## 自迭代

每次改动后检查是否产生新的 gotcha，确认后可追加到对应 skill 的 `gotchas.md`。
