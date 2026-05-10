# xg-skills

xiao 的个人 [Claude Code](https://claude.ai/code) skills 集合。每个 skill 是一个可被 Claude Code 自动加载、按 `description` 触发的能力包；同时收录少量精选外部 skill，集中管理免去四处翻仓库。

## 安装方式

### 方式一：让 Agent 自动安装（推荐）

直接在 Claude Code 里告诉它：

```
帮我安装这个 skill：<skill 地址>
```

例如：

```
帮我安装这个 skill：https://github.com/ujnop8/xg-skills/tree/main/skills/xg-jgj
```

Agent 会自己 clone 仓库、把目标 skill 放到 `~/.claude/skills/` 下并重启 skill 索引。

### 方式二：手动安装

```bash
# 克隆整个仓库到本地
git clone https://github.com/ujnop8/xg-skills.git ~/xg-skills

# 把需要的单个 skill 软链到 ~/.claude/skills/
ln -s ~/xg-skills/skills/xg-jgj ~/.claude/skills/xg-jgj
```

加载后，Claude Code 会根据 `SKILL.md` frontmatter 里的 `description` 自动在合适场景触发，无需手动调用。

## 技能清单（本仓库）

### 经典释义

| 技能 | 路径 | 用途 | 触发场景 |
| --- | --- | --- | --- |
| **xg-jgj** | [skills/xg-jgj/](skills/xg-jgj/) | 金刚经解读 — 以"金刚破相场"风格用〔经〕→〔破〕→〔照〕→〔归〕四步过镜，每段 ≤150 字，必带一个当代生活景象 | 用户引用《金刚经》原文，提到"须菩提/无相/应无所住/般若"等，或请求白话解读经句 |

### 关系洞察

| 技能 | 路径 | 用途 | 触发场景 |
| --- | --- | --- | --- |
| **xg-quanli-ditu** | [skills/xg-quanli-ditu/](skills/xg-quanli-ditu/) | 权力地图 — 从对话/会议纪要/群聊中识别真实影响力网络，七维扫描 + 五段输出（地形速写、角色定位、流向图、关键时刻、待观察疑点），只看行为不看头衔 | 用户给出对话/纪要/聊天记录并问"谁说了算 / 谁是真正核心 / 影响力分布 / 谁在站队 / 这场对话谁占上风 / 背后的潜流" |
| **xg-guanxi-xianying** | [skills/xg-guanxi-xianying/](skills/xg-guanxi-xianying/) | 关系显影场 — 以"八卦灵媒"语气从对话/聊天记录/剧本片段里显影人际关系的温度与暗流，按"亲/疏/暗"三重引力扫描 + 四段输出（一眼看场、关系特写、暗流时刻、留白处），闺蜜耳语风、不评判不教训 | 用户贴出多人对话/群聊/聊天记录/剧本台词并说"嗑一下 / 八卦一下 / 他们关系怎么样 / 谁跟谁好 / 谁跟谁有矛盾 / 谁在暗中站队 / 这俩什么情况 / cp 一下 / 你看出来什么了吗"。和"权力地图"的区别：那个看权力流向，这个只看亲疏冷暖明暗 |

## 外部技能清单

收录的优秀第三方 skill。本地**不**建文件夹、不重复维护，按各自仓库的安装说明走（也可直接用上面的"方式一"让 Agent 装）。

| 技能 | 用途 | 触发场景 | 地址 |
| --- | --- | --- | --- |
| **web-access** | 给 Agent 装上完整联网能力 — 自动在 WebSearch / WebFetch / curl / Jina / 浏览器 CDP 之间选最合适的方式；通过 CDP Proxy 直连用户日常 Chrome，天然带登录态，支持动态页面、交互操作、视频截帧、本地 Chrome 书签/历史检索；按域名沉淀站点经验跨 session 复用 | 用户要求搜索信息、查看网页内容、访问需要登录的网站、操作网页界面、抓取社交媒体内容（小红书、微博、推特等）、读取动态渲染页面、以及任何需要真实浏览器环境的网络任务 | <https://github.com/eze-is/web-access> |

## 目录结构

```
xg-skills/
├── CLAUDE.md              # 给 Claude Code 看的仓库说明（含写 skill 的约定）
├── README.md              # 本文件
├── .gitignore
└── skills/
    ├── xg-jgj/                  # 纯 prompt 型 skill
    │   └── SKILL.md
    ├── xg-quanli-ditu/          # 纯 prompt 型 skill
    │   └── SKILL.md
    └── xg-guanxi-xianying/      # 纯 prompt 型 skill
        └── SKILL.md
```

每个 skill 至少包含一个 `SKILL.md`，frontmatter 含 `name` 与 `description`。详细约定见 [CLAUDE.md](CLAUDE.md)。

## 新增 / 更新 skill 时

每次新增或修改 skill **都要回头更新本 README 的"技能清单"表格**：用途和触发场景两列要与 `SKILL.md` 的 `description` 对得上，不要让两边漂移。引入新的外部 skill 时同步更新"外部技能清单"。

## 许可

个人自用，未指定开源协议。如需引用或改造请先开 issue 沟通。
