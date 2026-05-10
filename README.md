# xg-skills

xiao 的个人 [Claude Code](https://claude.ai/code) skills 集合。每个 skill 是一个可被 Claude Code 自动加载、按 `description` 触发的能力包。

## 技能清单

| 技能 | 路径 | 用途 | 触发场景 |
| --- | --- | --- | --- |
| **xg-jgj** | [skills/xg-jgj/](skills/xg-jgj/) | 金刚经解读 — 以"金刚破相场"风格用〔经〕→〔破〕→〔照〕→〔归〕四步过镜，每段 ≤150 字，必带一个当代生活景象 | 用户引用《金刚经》原文，提到"须菩提/无相/应无所住/般若"等，或请求白话解读经句 |
| **xg-quanli-ditu** | [skills/xg-quanli-ditu/](skills/xg-quanli-ditu/) | 权力地图 — 从对话/会议纪要/群聊中识别真实影响力网络，七维扫描 + 五段输出（地形速写、角色定位、流向图、关键时刻、待观察疑点），只看行为不看头衔 | 用户给出对话/纪要/聊天记录并问"谁说了算 / 谁是真正核心 / 影响力分布 / 谁在站队 / 这场对话谁占上风 / 背后的潜流" |

## 安装与使用

把整个仓库（或单个 skill 目录）放到 Claude Code 能识别 skill 的位置，例如：

```bash
# 克隆到本地
git clone https://github.com/ujnop8/xg-skills.git ~/xg-skills

# 或者把单个 skill 软链到 ~/.claude/skills/
ln -s ~/xg-skills/skills/xg-jgj ~/.claude/skills/xg-jgj
```

加载后，Claude Code 会根据 `SKILL.md` frontmatter 里的 `description` 自动在合适场景触发，无需手动调用。

## 目录结构

```
xg-skills/
├── CLAUDE.md              # 给 Claude Code 看的仓库说明（含写 skill 的约定）
├── README.md              # 本文件
├── .gitignore
└── skills/
    ├── xg-jgj/                  # 纯 prompt 型 skill
    │   └── SKILL.md
    └── xg-quanli-ditu/          # 纯 prompt 型 skill
        └── SKILL.md
```

每个 skill 至少包含一个 `SKILL.md`，frontmatter 含 `name` 与 `description`。详细约定见 [CLAUDE.md](CLAUDE.md)。

## 新增 / 更新 skill 时

每次新增或修改 skill **都要回头更新本 README 的"技能清单"表格**：用途和触发场景两列要与 `SKILL.md` 的 `description` 对得上，不要让两边漂移。

## 许可

个人自用，未指定开源协议。如需引用或改造请先开 issue 沟通。
