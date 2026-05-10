# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 仓库定位

这是 xiao 的个人 Claude Code skills 集合仓库，远端在 https://github.com/ujnop8/xg-skills。每个 skill 是一个可被 Claude Code 加载、按 description 自动触发的能力包。这里**没有应用代码、没有构建系统、没有测试套件**——仓库本质是一组结构化 prompt 与配套脚本。

## Skill 目录结构约定

所有 skill 放在 `skills/<skill-name>/` 下，目录名即 skill 名。一个 skill 至少包含：

- **`SKILL.md`**（必需）— 带 YAML frontmatter 的主入口。frontmatter 必须有 `name` 和 `description` 两个字段：
  - `name` 与目录名一致
  - `description` 决定 skill 何时被触发，必须明确写出"用户说什么/做什么时使用"，而不是只描述能力
- **`scripts/`**（可选）— skill 调用的可执行脚本（bash、python 等）。脚本是相对路径调用，例如 SKILL.md 里写 `bash scripts/xxx.sh "<args>"`，由 Claude Code 在 skill 工作目录下执行
- **`agents/<platform>.yaml`**（可选）— 平台特定元数据。当前只见过 `agents/openai.yaml`，含 `interface.display_name` 和 `interface.short_description`，用于 OpenAI 平台展示

参考实现：
- [skills/pdf-compressor/](skills/pdf-compressor/) — 带脚本 + 平台 yaml 的完整型 skill，Ghostscript 调用、自动安装、批量递归
- [skills/xg-jgj/](skills/xg-jgj/) — 纯 prompt 型 skill（无脚本），整个能力靠 SKILL.md 里的工作流和约束文字驱动

## 写新 skill 的关键判断

- **要不要写脚本？** 如果靠 LLM 推理 + 标准工具就能做（如 prompt 风格化、文本改写），就纯 prompt；如果涉及二进制处理、外部 CLI、批量文件操作、需要严格幂等的步骤，写脚本，让 SKILL.md 只负责调度
- **description 怎么写才会被触发？** 列出**具体的用户措辞和场景**。"compress PDF" 不如 "when the user asks to reduce PDF size, optimize document storage, or run one-click compression"。中文 skill 同理，要把口语触发词列全（"画个图"/"flowchart"/"架构图" 都得有）
- **不要在 SKILL.md 里塞客套话**。skill 是给 LLM 看的执行手册，所有"概述/背景/支持文档"段落都浪费 token。直接给规则、工作流、铁律、示例

## 维护 README.md（强制）

仓库根目录的 [README.md](README.md) 是对外的技能清单与索引，**每次新增 skill、删除 skill、或修改 skill 的用途/触发条件时，必须同步更新 README 里的"技能清单"表格**——不允许只改 SKILL.md 不动 README。检查清单：

- 新增 skill → 在表格里加一行（技能名、路径、用途、触发场景）
- 修改 skill 的 `description` 或工作流 → 同步更新对应行的"用途"和"触发场景"两列，确保口径与 SKILL.md frontmatter 一致
- 删除 skill → 从表格里删掉对应行
- 改完 README 与 SKILL.md 一并提交，commit message 里同时说明两边的改动

如果只改了 SKILL.md 没动 README，提交前主动停下来补 README，不要拖到下次。

## 提交与推送

- **commit message 用中文**（用户在 init 时明确指定）
- 当前分支：`main`；远端：`origin` → `https://github.com/ujnop8/xg-skills`
- 本仓库由 `git init` 而来，无 PR 流程，本地 commit + push 即可
- `.DS_Store` 已在 `.gitignore`，不要提交
