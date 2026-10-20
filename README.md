# AI Coding Conventions

公司统一编码规范，用于约束 AI 编程 Agent（Claude Code / Cursor / Copilot 等）的代码生成行为。

## 设计原则

- **工具能约束的不写进规范** — 缩进、import 顺序交给 formatter，不重复写
- **通用规则提取共享** — Python 和 C++ 共同的规则放 `coding.md`，语言特有的才单独拆
- **极简** — 只写 AI 容易犯错的点，不写人类常识

## 文件结构

```
ai-coding-conventions/
├── AGENTS.md            # 项目入口模板（复制到新项目后填写 TODO）
├── .clang-format        # C++ 格式化配置（Google 风格）
└── .agents/
    ├── coding.md        # 通用编码规范（命名/错误处理/日志/设计哲学）
    ├── general.md       # 工程规范（Git 分支/Commit/PR/变更原则）
    ├── layout.md        # 项目目录规范（Monorepo 多服务布局）
    ├── cpp.md           # C++ 规范（Core Guidelines 精简版）
    ├── python.md        # Python 规范（类型标注/异常层级/配置管理）
    ├── testing.md       # 测试规范（分层/TDD/Mock 原则）
    └── security.md      # 安全红线（注入防护/硬件控制安全）
```

## 在新项目中引入

```bash
# 1. 复制规范文件到项目根目录
cp -r /path/to/ai-coding-conventions/.agents .
cp /path/to/ai-coding-conventions/AGENTS.md .
cp /path/to/ai-coding-conventions/.clang-format .  # C++ 项目才需要

# 2. 创建 CLAUDE.md 软链接（Claude Code 自动读取）
ln -s AGENTS.md CLAUDE.md

# 3. 编辑 AGENTS.md，填写 TODO 占位部分
#    - {{ PROJECT_NAME }} → 项目名称
#    - {{ 项目简介 }} → 一句话描述
#    - 环境配置 / 构建和测试 / 项目架构 / 关键文件
```

完成后 AI Agent 会在每次对话时自动加载这些规范。

## 工作机制

AI 编程 Agent 启动时按以下顺序读取项目指令：

```
AGENTS.md（或 CLAUDE.md）
  └─ 按「按文件类型加载规范」章节，按需读取 .agents/*.md
```

`AGENTS.md` 是入口，通过引用链告诉 Agent 哪些规范适用于当前文件类型，避免一次性加载全部内容浪费 token。

## 修改规范

规范文件是通用的，针对具体项目的特殊规则直接写在 `AGENTS.md` 的项目架构章节中，不改动 `.agents/` 下的共享文件。

如果通用规范本身需要调整，在本仓库修改后所有引入了该仓库的项目下次 `cp` 时同步更新。
