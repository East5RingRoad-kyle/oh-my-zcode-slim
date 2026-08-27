# ✨ oh-my-zcode-slim ✨

**简体中文** | [English](README.en.md)

给 ZCode 的精简多 agent 编排套件:**9 个原生子代理(含 council 仲裁席位)+ 主 agent 编排 skill**,零编译代码,纯 markdown。

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
| `explorer` | 代码库快速侦察:"X 在哪" | 只读(无写工具,硬约束) |
| `oracle` | 架构顾问、评审、YAGNI 执法 | 只读(硬约束) |
| `librarian` | 外部文档调研、最新 API 用法 | 只读 + 网络检索 |
| `fixer` | 有界执行者:实现,不规划不研究 | 不限(可用 Edit/Write) |
| `designer` | 前端 UI/UX 专家 | 不限 |
| `observer` | 图像/截图/PDF 视觉分析,精确 OCR | 只读(硬约束) |
| `council` + 两个 `councillor` | 多视角仲裁:两个独立顾问并行分析,synthesizer 综合出唯一答案 | councillor 只读;council 零工具 |

另有 `omzs-deepwork` skill:大型高风险变更的分相位工作流(相位文件 +
oracle 审查门 + 相位提交)。

权限边界是三层,诚实地说:
1. **工具白名单(硬)**:只读角色没有 Edit/Write;observer 和两个
   councillor 连 Bash 都没有;council 是空工具表(纯文本进出);
   fixer/designer 禁用了联网工具(Agent/Task/WebFetch/WebSearch)。
2. **permissionMode: default(半硬)**:explorer/oracle/librarian 的 Bash
   写操作会触发用户确认。
3. **prompt 行为约束(软)**:角色剧本里的只读纪律。
Bash 理论上仍可达写路径(`sed -i` 等),第 2、3 层就是为此设的——在
`bypassPermissions` 会话里请自行斟酌风险。

## 安装

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh
```

重启 ZCode 会话即可。卸载:`./uninstall.sh`。

安装器做两件事:

1. 把 `agents/*.md` 拷到 `~/.zcode/agents/`——九个角色立刻出现在
   Settings → Subagents 的 Installed 列表;
2. 把 `skills/omzs-*` 拷到 `~/.agents/skills/` 并在 `~/.zcode/skills/`
   建软链(编排 skill 给主 agent 用)。

选项:`--scope workspace` 把子代理装到当前项目的 `.zcode/agents/`(仅本
项目生效);`ZCODE_HOME` / `AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR` 环境
变量可覆盖目标路径。

**注意**:重装会覆盖已安装的副本。若你在 ZCode 设置页改过某个专家,重装
前会自动备份为 `<name>.md.omzs-backup.<时间戳>`。想固化修改,请改仓库
里的 `agents/*.md` 再重装。

**安装后 30 秒自检**:新开一个 ZCode 会话 → Settings → Subagents 应列出
9 个角色;输入 `/` 应能看到 omzs-dispatch / omzs-deepwork;然后问一句
"这个仓库里 X 在哪",看它是否派发 explorer。

**更新**:`git pull && ./install.sh`。你在设置页改过的角色会自动备份为
`<name>.md.omzs-backup.<时间戳>`,不会丢;skill 侧的本地修改不备份,
想固化请改仓库源文件。

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

## 设计取舍(相对 oh-my-opencode-slim)

砍掉:preset 运行时热切换、桌面 companion、multiplexer 分屏、AST 工具、
后台任务唤醒调度。council 多模型仲裁保留为手动版:在设置页给两个席位
配不同模型即可(原版是运行时自动切换)。保留:角色 + 路由契约 +
权限边界这一最小核心。相对原版还升级了一点:OMO 用插件 API 注册
agent,ZCode 原生支持 markdown 子代理定义,所以这里连插件机制都不需要,
`git clone` + 一个脚本即完成。

## 致谢

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal。本项目大量借鉴其 agent
  prompt 设计与路由哲学。

## License

MIT — 见 [LICENSE](LICENSE)(含原作者版权声明)与 [NOTICE](NOTICE)。
