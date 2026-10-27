# 通用规范

---

## 提交前检查

提交前必须通过：类型检查、格式化、测试。

```bash
# Python
ruff check . && ruff format . && mypy . && pytest

# C++
clang-format -i $(git diff --name-only --cached -- '*.cpp' '*.h') \
  && cmake --build build && ctest --test-dir build
```

---

## Git 提交规范

### 分支命名

| 前缀 | 用途 | 示例 |
|------|------|------|
| `feature/` | 新功能 | `feature/dual-busbar` |
| `fix/` | Bug 修复 | `fix/pose-calculation` |
| `refactor/` | 重构 | `refactor/machine-split` |
| `hotfix/` | 紧急修复 | `hotfix/crash-on-startup` |
| `docs/` | 文档 | `docs/api-standard` |

必须使用 feature 分支开发，禁止直接提交到 main。

### 禁止用 Git 命令回滚代码

禁止 `git reset --hard`、`git checkout -- .` 等命令丢弃工作区改动。需要"回滚"时，用编辑工具按 diff 手动恢复代码——过程可见、可审查；Git 命令一把抹掉，不可见且不可逆。

### Commit 消息

Conventional Commits 格式：

```
<type>(<scope>): <简短描述>

<可选详细描述，解释"为什么"而非"做了什么">
```

类型：`feat` / `fix` / `refactor` / `docs` / `test` / `chore` / `perf` / `style`

```
✅ feat(auth): 添加会话超时机制
✅ fix(vision): 修复圆检测 180° 旋转问题
❌ update
❌ fix bug
```

一个 commit 只做一件事。subject 在 50 字符以内。

### scope 与对外可见性

- scope 必须是仓库中真实存在的模块/包名（如 `analyzers`、`config`、`core`）；跨模块的改动用 `misc`，禁止虚构领域名
- 标题与描述禁止引用仓库外部不可感知的信息（本地票据编号、未入库路径、会话上下文）——对审查者与历史检索没有信息量；交代背景用仓库可见的事实（如"#5 合并后追加"）

```
✅ refactor(misc): 补齐关键节点日志与测试时钟注入
❌ refactor(conventions): 票 11 规范合规修复  （conventions 非仓库模块；"票 11"为本地编号）
```

---

## PR 规范

- PR 标题遵循 Commit 消息格式与约束（`type(scope): 简短描述`，≤50 字符，含 scope 取值与对外可见性要求）
- 必须至少一人审查批准后才能合并
- 合并前必须通过所有 CI 检查
- PR 描述必须说明变更内容和动机

---

## 脚本执行

禁止在 bash 中 inline 多行脚本或 heredoc——先写成文件再执行。inline 脚本不可读、不可复跑、无法审查；落盘的文件本身就是记录。

---

## 变更原则

- 每次提交只做一个逻辑变更
- 依赖必须带版本约束（`numpy>=1.24,<2.0`），提交锁文件
- 禁止提交 `.env` 和含密码/IP 的配置文件
- 发布版本必须打 Git tag
- 每次修改须同时兼顾用户体验、开发体验、AI Agent 使用体验：三者都要变好，且不得破坏现有功能
- 被纠正后交付干净终态：commit/PR/注释中禁止留修改痕迹（"已移除误加的 X"）和"为什么不做 Y"式辩解