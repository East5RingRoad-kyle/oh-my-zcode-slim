# ✨ oh-my-zcode-slim ✨

**简体中文** | [English](README.en.md)

给 ZCode 的精简多 agent 编排套件:**9 个原生子代理(含 council 仲裁席位)+ 主 agent 编排 skill**,零编译代码,纯 markdown。

> 本仓库同时是 ZCode 插件市场:在 **设置 → 插件 → 创建 → 添加插件市场** 填入
> `East5RingRoad-kyle/oh-my-zcode-slim`,即可直接安装并加载全部 9 个角色和
> `omzs-*` skills;传统 `git clone + ./install.sh` 安装方式依然可用。

> 本项目是 [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
> (by alvinunreal / Boring Dystopia Development,MIT License)的衍生作品。
> 角色 prompt 与路由表改编自原项目 `src/agents/*.ts`。详见 [NOTICE](NOTICE)。

## 这是什么

你照常跟主 agent 对话。它加载 `omzs-dispatch` 后成为编排者,自动把工作拆成
lane,按路由表派给最合适的专家子代理,专家返回后统一 reconcile 再汇报给你。
**你不需要手工调用任何角色,专家之间也不互相调用**(星型调度,所有路由都经主 agent;自动匹配是尽力而为,偶尔不触发时说一句 "orchestrate this")。

| 角色 | 职责 | 工具权限 |
|---|---|---|
| 主 agent(编排者) | 计划、路由、派发、对账 | 不限 |
| `explorer` | 代码库快速侦察:"X 在哪" | 只读(无 Edit/Write;Bash 走只读纪律,写操作触发确认) |
| `oracle` | 架构顾问、评审、YAGNI 执法 | 只读(硬约束) |
| `librarian` | 外部文档调研、最新 API 用法 | 只读 + 网络检索 |
| `fixer` | 有界执行者:实现,不规划不研究 | 不限(可用 Edit/Write) |
| `designer` | 前端 UI/UX 专家 | 不限 |
| `observer` | 图像/截图/PDF 视觉分析,精确 OCR | 只读(硬约束) |
| `council` + 两个 `councillor` | 多视角仲裁:两个独立顾问并行分析,synthesizer 综合出唯一答案 | councillor 只读;council 无信息/文件工具(仅 TodoWrite 自有清单) |

另有 `omzs-deepwork` skill:大型高风险变更的分相位工作流(相位文件 +
oracle 审查门 + 相位提交)。

权限边界是三层,诚实地说:
1. **工具白名单(硬)**:只读角色没有 Edit/Write;observer 和两个
   councillor 连 Bash 都没有;council 仅剩 TodoWrite(无信息/文件工具,
   纯文本进出);fixer/designer 禁用了联网工具(Agent/Task/WebFetch/WebSearch)。
2. **permissionMode: default(半硬)**:explorer/oracle/librarian 的 Bash
   写操作会触发用户确认。
3. **prompt 行为约束(软)**:角色剧本里的只读纪律。
Bash 理论上仍可达写路径(`sed -i` 等),第 2、3 层就是为此设的——在
`bypassPermissions` 会话里请自行斟酌风险。

## 环境要求

- macOS / Linux 自带 `bash`(脚本纯 bash,不依赖 python3/node)。
- Windows 请用 WSL 或 Git Bash(软链在原生 Windows 上需管理员/开发者模式)。
- 建议使用支持 `disallowedTools`、`permissionMode`、`thoughtLevel` 等
  frontmatter 字段的 ZCode 版本;旧版会静默忽略这些字段,只读约束随之变弱。

## 安装

先拿到这份代码，任选其一(install.sh 不依赖 git/GitHub,只要目录在就能装):

- **git(推荐,已有仓库地址后)**:`git clone <repo-url> ~/oh-my-zcode-slim`
- **内网/共享目录**:把整个 `oh-my-zcode-slim/` 目录拷到目标机器
- **压缩包**:`tar -czf omzs.tgz .` 打包后发过去解压

拿到目录后:

```bash
cd ~/oh-my-zcode-slim   # 或你放置该目录的路径
./install.sh
```

重启 ZCode 会话即可。卸载:`./uninstall.sh`;若当初用 `--scope workspace`
装的,用 `./uninstall.sh --scope workspace`;两个都装了用 `--all`。只删带
本项目标记的文件,你的自定义角色和 `*.omzs-backup.*` 备份不会被删(卸载
会保留这些备份和空目录,彻底清除可自行删除)。

安装器做两件事:

1. 把 `agents/*.md` 拷到 `~/.zcode/agents/`——九个角色立刻出现在
   Settings → Subagents 的 Installed 列表;
2. 把 `skills/omzs-*` 拷到 `~/.agents/skills/` 并在 `~/.zcode/skills/`
   建软链(编排 skill 给主 agent 用)。

选项:`--scope workspace` 把子代理装到当前项目的 `.zcode/agents/`(仅本
项目生效;**编排 skill 始终装到全局目录**,不随 scope 隔离);`ZCODE_HOME` /
`AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR` 环境变量可覆盖目标路径。

**注意**:重装会覆盖已安装的副本。若你在 ZCode 设置页改过某个专家,重装
前会自动备份为 `<name>.md.omzs-backup.<时间戳>`。想固化修改,请改仓库
里的 `agents/*.md` 再重装。

**安装后 30 秒自检**:新开一个 ZCode 会话 → Settings → Subagents 应列出
9 个角色;输入 `/` 应能看到 omzs-dispatch / omzs-deepwork;然后输入
`omzs self-test`(或中文说「团队自检」),它会 ping 全部 9 个角色并返回
一张 PASS/FAIL 表,每个角色都 PASS 即说明整支队伍已接通。

**更新**(已安装用户):

1. 先拿到新版代码:git 用户 `git pull`;非 git 用户重新拷目录或用新包覆盖旧目录。
2. 回到仓库目录跑 `cd ~/oh-my-zcode-slim && ./install.sh`(install.sh 不依赖 git,没 .git 也能更新)。
3. 重跑后新开一个 ZCode 会话即可。脚本会打印 `version: <旧> -> <新>` 告诉你从哪版升到哪版;你在设置页改过的角色会被自动备份为 `<name>.md.omzs-backup.<时间戳>` 不会丢。

**查看当前装的版本**:看 `~/.zcode/agents/.omzs-version`(workspace 装在 `.zcode/agents/.omzs-version`),数字就是已安装版本;仓库里的 `VERSION` 是最新版。

**检查是否有新版**:在仓库目录跑 `./check-update.sh`(git 和非 git 用户都行,会对比本地 `VERSION` 与远端;fork 用户用 `OMZS_REPO=你的owner/repo ./check-update.sh`)。

**回退**:git 用户 `git checkout <tag> && ./install.sh`;非 git 用户保留旧包,重新覆盖安装即可。想固化本地修改请改仓库源文件,skill 侧本地改动不备份会被覆盖。

**故障排查**:角色没出现 → 确认 `~/.zcode/agents/` 下有 9 个 md 且配过
`storage.dir` 的用 `ZCODE_HOME` 指向实际根;skill 没触发 → 说一句
"orchestrate this" 强制加载;项目里 `.slim/deepwork/` 相位文件请单独
commit 或加入 .gitignore。

## 模型配置(可选)

**不配置 = 所有角色继承会话模型,开箱即用**(frontmatter 里
`model: "inherit"`)。

要给角色配不同模型/推理档位,装好后打开 **Settings → Subagents**,每个
专家右侧有模型和 thought level 下拉框,像调内置 Explore agent 一样调,
由 ZCode 原生生效。也可以直接改 `~/.zcode/agents/<name>.md` 的
frontmatter(`model:` / `thoughtLevel:` 字段),或用 `--scope workspace`
为某个项目单独配一套。

推荐搭配:explorer/librarian 用快而便宜的模型(Flash 档),oracle/fixer
用强模型(high/max 档);**council 双席位务必配不同模型**(如 alpha 用 A
家、beta 用 B 家,council 综合者用强模型)——同模型双席位合法但价值有限。

## 怎么用

- **自动**:开始多 lane 的非平凡任务,主 agent 加载 `omzs-dispatch` 自行编排。
- **手动**:说 "orchestrate this" / "用 deepwork 流程做这个大重构"(没触发时手动说一句即可)。
- 子代理派发语法:Agent 工具 + `subagent_type: "explorer"` 等(编排 skill
  里有完整模板)。

一个典型的编排流:

1. 你描述目标(例如“给这个 API 加缓存并补测试”)。
2. 主 agent 拆 lane:先派 `explorer` 摸清现状,再派 `oracle` 定方案。
3. 方案定了,把实现派给 `fixer`(UI 派给 `designer`),互不依赖的 lane 并行跑。
4. 专家都返回后,主 agent reconcile 冲突、汇总成一份报告给你。

装完先跑一次 `omzs self-test`,9 个角色全 `PASS` 即说明整支队伍已接通。

## 设计取舍(相对 oh-my-opencode-slim)

砍掉:preset 运行时热切换、桌面 companion、multiplexer 分屏、AST 工具、
后台任务唤醒调度。council 多模型仲裁保留为手动版:在设置页给两个席位
配不同模型即可(原版是运行时自动切换)。保留:角色 + 路由契约 +
权限边界这一最小核心。相对原版还升级了一点:OMO 用插件 API 注册
agent,ZCode 原生支持 markdown 子代理定义,所以这里连插件机制都不需要,
`git clone` + 一个脚本即完成。

## 与其他 skills(superpowers 等)协作

superpowers 等**流程类** skill 负责“做什么、何时做、怎么验证”;本项目负责
“每步派给哪个角色”。两者不抢活:流程 skill 定了顺序后,omzs-dispatch 只做
角色路由,不在其上再套一层流程;每个步骤只派一次,专家是叶子节点,不再加载
skill 或继续派发。优先顺序:流程 skill 决定顺序与验证门,dispatch 决定执行者。

## 开发与贡献

- 提交信息遵循 [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
  规范,仓库内置 `commit-msg` 钩子校验。克隆后启用:
  `git config core.hooksPath .githooks`。
- 变更记录维护在 [CHANGELOG.md](CHANGELOG.md),遵循
  [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);发版时更新它并
  递增 `VERSION`。

## 致谢

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal。本项目大量借鉴其 agent
  prompt 设计与路由哲学。

## License

MIT — 见 [LICENSE](LICENSE)(含原作者版权声明)与 [NOTICE](NOTICE)。
