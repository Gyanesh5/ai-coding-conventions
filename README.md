# AI Coding Conventions

公司统一编码规范，用于约束 AI 编程 Agent（Claude Code / Cursor / Copilot 等）的代码生成行为。

## 设计原则

- **工具能约束的不写进规范** — 缩进、import 顺序交给 formatter，不重复写
- **通用规则提取共享** — Python 和 C++ 共同的规则放 `coding.md`，语言特有的才单独拆
- **极简** — 只写 AI 容易犯错的点，不写人类常识

## 文件结构

```
ai-coding-conventions/
├── AGENTS.md            # 项目入口模板（由 conventions.sh link 复制到新项目）
├── conventions.sh       # 接入工具：link / install / status / sync
├── .clang-format        # C++ 格式化配置（Google 风格）
├── .claude-plugin/      # Claude Code 插件清单（plugin.json + 自举 marketplace.json）
├── skills/
│   └── coding-conventions/    # Agent Skills 标准插件（SKILL.md 格式，跨工具通用）
│       ├── SKILL.md           # 触发入口：按文件类型路由到规范
│       └── references/        # 规范正文（唯一真源）
│           ├── coding.md      # 通用编码规范（命名/错误处理/日志/设计哲学）
│           ├── general.md     # 工程规范（Git 分支/Commit/PR/变更原则）
│           ├── layout.md      # 项目目录规范（Monorepo 多服务布局）
│           ├── cpp.md         # C++ 规范（Core Guidelines 精简版）
│           ├── python.md      # Python 规范（类型标注/异常层级/配置管理）
│           ├── frontend.md    # 前端界面规范（工业 Web tokens/状态/去 AI 味）
│           ├── testing.md     # 测试规范（节奏三档/少而全设计/断言强度）
│           └── security.md    # 安全红线（注入防护/硬件控制安全）
└── .agents/             # 兼容层（symlink → skills/.../references/，旧引用路径不变）
    ├── *.md → ../skills/coding-conventions/references/*.md
    └── skills/coding-conventions → ../../skills/coding-conventions
```

## 在新项目中引入

```bash
# 在项目根执行（一条命令完成接入）
bash /path/to/ai-coding-conventions/conventions.sh link
```

`link` 做四件事（幂等，重复执行无副作用）：

1. `.agents` → 规范库的 **symlink**（不复制内容——规范更新即时生效，无需逐项目同步）
2. 项目无 `AGENTS.md` 时从模板复制一份；**已有则不改动任何现有内容**，仅在缺索引段时于文末追加
3. 无 `CLAUDE.md` 时建指向 `AGENTS.md` 的软链接（Claude Code 兼容）
4. 检测到 C++（`.cpp` / `CMakeLists.txt`）时附带 `.clang-format`

之后编辑 `AGENTS.md` 填写 TODO 占位（项目名、简介、环境配置、构建和测试、架构、关键文件）。

> 旧 cp 方式已废弃：cp 副本与规范库脱钩，更新须逐项目重拷。已有 cp 副本的项目，
> 确认 `.agents/` 内没有项目私有规范文件后 `rm -rf .agents`，重跑 `link` 即完成迁移。

## skills 轨（Agent 工具插件）

支持 Agent Skills 标准（SKILL.md 格式，AAIF 托管）的工具可用第二条接入轨道——**任务匹配时自动加载**，不依赖 agent 记得去读 AGENTS.md：

```bash
bash /path/to/ai-coding-conventions/conventions.sh install        # 项目级
bash /path/to/ai-coding-conventions/conventions.sh install user   # 用户级（本机全项目生效）
```

`install` 建两条链：

- `.agents/skills/coding-conventions` → 规范库（Codex / Cursor / Gemini CLI / Copilot 的公共发现路径）
- `.claude/skills/coding-conventions` → `../../.agents/skills/coding-conventions`（Claude Code 只认 `.claude/skills/`，相对 symlink 保持仓库可移植）

建议项目 `.gitignore` 追加 `.agents` 与 `.claude/`：链接指向各机规范库克隆，不随 git 旅行；新机 clone 项目后重跑一次 `link + install` 即恢复（每机一次性成本）。

**Claude Code 插件通道**（第三条轨道，替代用户级 `install user` 的软链）：仓库自带 `.claude-plugin/`（plugin.json + 自举 marketplace.json），一条命令接入——

```bash
claude plugin marketplace add Gyanesh5/ai-coding-conventions   # GitHub 公共仓；或直接给本地路径
claude plugin install coding-conventions@ai-coding-conventions
```

安装后 skills 自动随任务匹配加载；规范更新 `claude plugin marketplace update` 即跟随。主仓在 GitHub（公共），gitee 为同步镜像（`git pushall` 双推）。

## 工作机制

AI 编程 Agent 启动时按以下顺序读取项目指令：

```
AGENTS.md（或 CLAUDE.md）
  └─ 按「按文件类型加载规范」章节，按需读取 .agents/*.md
```

`AGENTS.md` 是入口，通过引用链告诉 Agent 哪些规范适用于当前文件类型，避免一次性加载全部内容浪费 token。索引段只引用文件名——文件名稳定，所以规范内容更新**永远不需要再碰项目 AGENTS.md**。

## 更新规范

规范只在本仓库改；各机执行 `bash /path/to/ai-coding-conventions/conventions.sh sync`（即 `git pull`），所有 symlink 接入的项目即时生效——不触碰任何项目的 `AGENTS.md`。

针对具体项目的特殊规则写在项目 `AGENTS.md` 的项目章节里，不进共享规范。
