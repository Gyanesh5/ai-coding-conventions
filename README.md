# AI Coding Conventions

公司统一编码规范，用于约束 AI 编程 Agent（Claude Code / Cursor / Copilot 等）的代码生成行为。以 Agent Skills 插件形式分发，任务匹配时自动加载。

## 设计原则

- **工具能约束的不写进规范** — 缩进、import 顺序交给 formatter，不重复写
- **通用规则提取共享** — Python 和 C++ 共同的规则放 `coding.md`，语言特有的才单独拆
- **极简** — 只写 AI 容易犯错的点，不写人类常识

## 文件结构

```
ai-coding-conventions/
├── conventions.sh       # 接入工具：install / status / sync
├── .clang-format        # C++ 格式化配置（Google 风格，install 时附带）
├── .claude-plugin/      # Claude Code 插件清单（plugin.json + 自举 marketplace.json）
└── skills/
    └── coding-conventions/    # Agent Skills 标准插件（SKILL.md 格式，跨工具通用）
        ├── SKILL.md           # 触发入口：按文件类型路由到规范
        └── references/        # 规范正文（唯一真源）
            ├── coding.md      # 通用编码规范（命名/错误处理/日志/设计哲学）
            ├── general.md     # 工程规范（Git 分支/Commit/PR/变更原则）
            ├── layout.md      # 项目目录规范（Monorepo 多服务布局）
            ├── cpp.md         # C++ 规范（Core Guidelines 精简版）
            ├── python.md      # Python 规范（类型标注/异常层级/配置管理）
            ├── frontend.md    # 前端界面规范（工业 Web tokens/状态/去 AI 味）
            ├── testing.md     # 测试规范（节奏三档/少而全设计/断言强度）
            └── security.md    # 安全红线（注入防护/硬件控制安全）
```

## 在新项目中接入

### 方式一：conventions.sh install（symlink 接入）

```bash
bash /path/to/ai-coding-conventions/conventions.sh install        # 项目级
bash /path/to/ai-coding-conventions/conventions.sh install user   # 用户级（本机全项目生效）
```

`install` 建两条链：

- `.agents/skills/coding-conventions` → 规范库（Codex / Cursor / Gemini CLI / Copilot 的公共发现路径）
- `.claude/skills/coding-conventions` → `../../.agents/skills/coding-conventions`（Claude Code 只认 `.claude/skills/`，相对 symlink 保持仓库可移植）

检测到 C++（`.cpp` / `CMakeLists.txt`）时附带 `.clang-format`。

建议项目 `.gitignore` 追加 `.agents` 与 `.claude/`：链接指向各机规范库克隆，不随 git 旅行；新机 clone 项目后重跑一次 `install` 即恢复（每机一次性成本）。

### 方式二：Claude Code 插件通道（替代用户级 `install user` 的软链）

仓库自带 `.claude-plugin/`（plugin.json + 自举 marketplace.json），一条命令接入——

```bash
claude plugin marketplace add Gyanesh5/ai-coding-conventions   # GitHub 公共仓；或直接给本地路径
claude plugin install coding-conventions@ai-coding-conventions
```

安装后 skills 自动随任务匹配加载；规范更新 `claude plugin marketplace update` 即跟随。主仓在 GitHub（公共），gitee 为同步镜像（`git pushall` 双推）。

## 工作机制

Agent Skills 标准插件（SKILL.md 格式，AAIF 托管）：工具在任务匹配时自动加载 `SKILL.md`，按其路由表按需读取 `references/` 下对应规范——不依赖 agent 记得去读某个入口文件，也不一次性加载全部内容浪费 token。

## 修改规范

规范只在本仓库改。`skills/coding-conventions/SKILL.md` 是按文件类型的路由入口，规范正文在 `skills/coding-conventions/references/`——改规范内容时两者保持同步。

**禁止 AI 修改**（修改规范属于对外行为，须用户明确发起）：

- `skills/coding-conventions/` 下的规范文件（`SKILL.md` 与 `references/*.md`）
- `.gitignore`、依赖版本约束（`*.lock` / `requirements*.txt` / `pyproject.toml`）

规范更新发布：各机执行 `bash /path/to/ai-coding-conventions/conventions.sh sync`（即 `git pull`），install 接入的项目即时生效；插件通道执行 `claude plugin marketplace update`。

针对具体项目的特殊规则写在项目 `AGENTS.md` 的项目章节里，不进共享规范。

## 本仓库开发说明

纯 Markdown 仓库，无构建步骤；`conventions.sh` 为 bash 脚本，无第三方依赖。改动后验证：

```bash
bash -n conventions.sh    # 语法检查
# 接入逻辑改动：在临时目录实测 install / status（见「在新项目中接入」）
```
