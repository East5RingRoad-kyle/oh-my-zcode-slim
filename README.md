# ✨ oh-my-zcode-slim ✨

**简体中文** | [English](README.en.md)

给 ZCode 的精简多 agent 编排套件：一个编排者 + 五位专家(explorer / oracle /
librarian / fixer / designer),纯 markdown skill、零编译代码。

> 本项目是 [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim)
> (by alvinunreal / Boring Dystopia Development,MIT License)的衍生作品。
> 角色 prompt 与路由表改编自原项目 `src/agents/*.ts`。详见 [NOTICE](NOTICE)。

## 这是什么

你照常跟主 agent 对话。主 agent 加载 `omzs-dispatch` 后成为编排者，自动把
工作拆成 lane,按路由表派给最合适的专家子代理，专家返回后统一 reconcile
再汇报给你。**你不需要手工调用任何角色。**

| 角色 | 职责 | 权限 |
|---|---|---|
| orchestrator(你对话的主 agent) | 计划、路由、派发、对账 | 可写 |
| `@explorer` | 代码库快速侦察："X 在哪" | 只读 |
| `@oracle` | 架构顾问、评审、YAGNI 执法 | 只读(只建议不动手) |
| `@librarian` | 外部文档调研、最新 API 用法 | 只读 |
| `@fixer` | 有界执行者：实现，不规划不研究 | 可写 |
| `@designer` | 前端 UI/UX 专家 | 可写 |

另有 `omzs-deepwork`:大型高风险变更的分相位工作流(相位文件 + oracle
审查门 + 相位提交)。

## 安装

```bash
git clone <this-repo> ~/oh-my-zcode-slim
cd ~/oh-my-zcode-slim
./install.sh                # 安装 skills(默认,推荐)
./install.sh --with-config  # 同时安装模型配置模板
```

重启 ZCode 会话即可使用。卸载:`./uninstall.sh`(加 `--purge-config`
一并删配置)。

安装器做三件事：把 `skills/omzs-*` 复制到 `~/.agents/skills/`;在
`~/.zcode/skills/` 建软链(与机器上既有 skill 的布局一致)；可选安装模型
配置模板。`AGENTS_SKILLS_DIR` / `ZCODE_SKILLS_DIR` 环境变量可覆盖目标路径。

## 模型配置(可选)

**不配置 = 所有角色继承会话模型，开箱即用。** 要给不同角色配不同模型，
把 `config.example.json` 拷到 `~/.agents/oh-my-zcode-slim.json` 编辑：

```json
{
  "preset": "custom",
  "presets": {
    "custom": {
      "explorer":  { "model": "zhipu/glm-4.7-flash" },
      "oracle":    { "model": "zhipu/glm-4.7" },
      "fixer":     { "model": "zhipu/glm-4.7" }
    }
  }
}
```

`"model": null`(或整个文件不存在)= 继承会话模型。注意：ZCode 子代理
目前若不支持按 agent 选模型，这些字段会被优雅忽略，不影响使用；配置文件
同时是一份"角色 → 模型"的备忘，等宿主支持后即生效。

## 怎么用

- **自动**：直接开始非平凡任务，主 agent 会加载 `omzs-dispatch` 自行编排。
- **手动**：说 "orchestrate this" / "用 deepwork 流程做这个大重构"。

## 设计取舍(相对 oh-my-opencode-slim)

砍掉：preset 运行时热切换、council 多模型仲裁、桌面 companion、
multiplexer 分屏、AST 工具、后台任务唤醒调度。保留：角色 + 路由契约 +
权限边界这一最小核心。理由:ZCode 的扩展点( Agent 工具、skill 系统)
对这些有天然对位物，其余的是 OpenCode 特有外围。

## 致谢

- [oh-my-opencode-slim](https://github.com/alvinunreal/oh-my-opencode-slim) —
  MIT License, Copyright (c) 2025 alvinunreal。本项目大量借鉴其 agent
  prompt 设计与路由哲学。

## License

MIT — 见 [LICENSE](LICENSE)(含原作者版权声明)与 [NOTICE](NOTICE)。
