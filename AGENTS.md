# doc-maintenance 项目规则

## 项目定位

维护 Pi Agent 的文件结构管理技能（/docs-scan），确保项目文档的完整性、一致性和可维护性。

## 目录约定

- `docs/` — 设计文档；必须维护 `docs/INDEX.md`，文档按主题放入 `architecture/`、`specification/`、`guide/`、`research/`、`reference/`
- `skills/` — 三个技能的源码（唯一权威）：docs-scan、doc-contract、project-doc-architecture
- `scripts/` — 辅助脚本（如技能同步）
- 技能实际运行位置：`~/.pi/agent/skills/`（部署副本，由 `scripts/sync-skills.ps1` 同步）
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
4. **分支策略（PR 流程约定）**：main 是唯一主线，所有改动一律走 PR，不直接推 main：
   - `git checkout -b feature/<说明>` 新建分支
   - 提交并推送：`git push -u origin feature/<说明>`
   - 用 `gh pr create --fill` 发起 PR，等待用户审阅后合并（用户可在网页点击 Merge）
   - 禁止对 main 执行直接推送、force push 或删除操作
   - main 已在 GitHub 启用分支保护：禁止直接推送、禁止强制推送、禁止删除分支，GitHub 会强制执行此流程
5. **凭据安全**：token/密钥绝不写入仓库文件或 AGENTS.md；GitHub 认证统一用 `gh auth login`（一次登录，全机器共享），或系统凭据管理器。
6. **提交后**：向用户简要汇报提交号与变更内容。

## 技能同步规则

- 修改技能只改仓库 `skills/` 下对应目录，走 PR 合并到 main
- 合并到 main 后运行 `scripts/sync-skills.ps1`，把最新版复制到 `~/.pi/agent/skills/`
- 不要直接修改 `~/.pi/agent/skills/` 的部署副本；临时热修也要回写 `skills/` 并记录，避免源码与部署分叉

## 自迭代

每次改动后检查是否产生新的 gotcha，确认后可追加到对应 skill 的 `gotchas.md`。
