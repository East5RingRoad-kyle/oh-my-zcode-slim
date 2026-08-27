# ✨ oh-my-zcode-slim ✨

**简体中文** | [English](README.en.md)

给 ZCode 的精简多 agent 编排套件:**5 个原生子代理专家 + 主 agent 编排 skill**,零编译代码,纯 markdown。

> 本项目是 [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
> (by alvinunreal / Boring Dystopia Development,MIT License)的衍生作品。
> 角色 prompt 与路由表改编自原项目 `src/agents/*.ts`。详见 [NOTICE](NOTICE)。

## 这是什么

你照常跟主 agent 对话。它加载 `omzs-dispatch` 后成为编排者,自动把工作拆成
lane,按路由表派给最合适的专家子代理,专家返回后统一 reconcile 再汇报给你。
**你不需要手工调用任何角色,专家之间也不互相调用**(星型调度,所有路由都经主 agent)。

| 角色 | 职责 | 工具权限 |
|---|---|---|
| 主 agent(编排者) | 计划、路由、派发、对账 | 不限 |
| `explorer` | 代码库快速侦察:"X 在哪" | 只读(无写工具,硬约束) |
| `oracle` | 架构顾问、评审、YAGNI 执法 | 只读(硬约束) |
| `librarian` | 外部文档调研、最新 API 用法 | 只读 + 网络检索 |
| `fixer` | 有界执行者:实现,不规划不研究 | 不限(可用 Edit/Write) |
| `designer` | 前端 UI/UX 专家 | 不限 |

另有 `omzs-deepwork` skill:大型高风险变更的分相位工作流(相位文件 +
oracle 审查门 + 相位提交)。

权限边界靠两层:角色 prompt 的行为约束(软)+ ZCode 子代理的 `tools`
白名单(硬——explorer/oracle/librarian 的工具表里根本没有写工具)。

## 安装

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh
```

重启 ZCode 会话即可。卸载:`./uninstall.sh`。

安装器做两件事:

1. 把 `agents/*.md` 拷到 `~/.zcode/agents/`——五个专家立刻出现在
   Settings → Subagents 的 Installed 列表;
2. 把 `skills/omzs-*` 拷到 `~/.agents/skills/` 并在 `~/.zcode/skills/`
   建软链(编排 skill 给主 agent 用)。

选项:`--scope workspace` 把子代理装到当前项目的 `.zcode/agents/`(仅本
项目生效);`ZCODE_HOME` / `AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR` 环境
变量可覆盖目标路径。

**注意**:重装会覆盖已安装的副本。若你在 ZCode 设置页改过某个专家,重装
前会自动备份为 `<name>.md.omzs-backup.<时间戳>`。想固化修改,请改仓库
里的 `agents/*.md` 再重装。

## 模型配置(可选)

**不配置 = 所有角色继承会话模型,开箱即用**(frontmatter 里
`model: "inherit"`)。

要给角色配不同模型/推理档位,装好后打开 **Settings → Subagents**,每个
专家右侧有模型和 thought level 下拉框,像调内置 Explore agent 一样调,
由 ZCode 原生生效。也可以直接改 `~/.zcode/agents/<name>.md` 的
frontmatter(`model:` / `thoughtLevel:` 字段),或用 `--scope workspace`
为某个项目单独配一套。

推荐搭配:explorer/librarian 用快而便宜的模型(Flash 档),oracle/fixer
用强模型(high/max 档)。

## 怎么用

- **自动**:开始多 lane 的非平凡任务,主 agent 加载 `omzs-dispatch` 自行编排。
- **手动**:说 "orchestrate this" / "用 deepwork 流程做这个大重构"。
- 子代理派发语法:Agent 工具 + `subagent_type: "explorer"` 等(编排 skill
  里有完整模板)。

## 设计取舍(相对 oh-my-opencode-slim)

砍掉:preset 运行时热切换、council 多模型仲裁、桌面 companion、
multiplexer 分屏、AST 工具、后台任务唤醒调度。保留:角色 + 路由契约 +
权限边界这一最小核心。相对原版还升级了一点:OMO 用插件 API 注册
agent,ZCode 原生支持 markdown 子代理定义,所以这里连插件机制都不需要,
`git clone` + 一个脚本即完成。

## 致谢

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal。本项目大量借鉴其 agent
  prompt 设计与路由哲学。

## License

MIT — 见 [LICENSE](LICENSE)(含原作者版权声明)与 [NOTICE](NOTICE)。
