---
name: coding-conventions
description: 写代码、改代码、写测试前加载的编码规范路由——按文件类型读取对应规范（Python/C++/前端/测试/安全/布局），违反规范的改动会被打回。
version: 1.0.0
---

# 统一编码规范（路由）

动手写/改任何代码前，按目标文件类型先读 `references/` 下对应规范：

| 文件类型 | 规范文件 |
|---|---|
| 任何文件（安全红线） | `references/security.md` |
| 所有语言通用 | `references/coding.md` |
| `.py` | `references/python.md` |
| `.cpp` / `.h` | `references/cpp.md` |
| `.vue` / `.tsx` / `.html` / `.css` | `references/frontend.md` |
| 测试代码 | `references/testing.md` |
| 工程流程（Git/提交/变更/Agent 行为） | `references/general.md` |
| 目录结构 | `references/layout.md` |

关键提醒（细则见 references）：

- **测试节奏三档**：agent 红绿循环只跑改动相关测试（相关文件 / `--lf -x`），提交前快集（`-m "not slow"`），合并前才全量——内循环禁止全量
- **测试设计少而全**：只测公共接口；参数化 + 等价类代替用例堆砌；期望值来自独立真值源，禁止用实现同款逻辑重算
- **禁改清单**：项目 AGENTS.md 中声明的禁改文件（构建配置、lock 文件、规范文件本身）修改前必须告知用户
- **行为红线**：不自行装依赖、不改构建配置、删文件先确认、用户删过的代码不加回、方案一步到位、疑问句=问题——细则见 `references/general.md`「AI 行为边界」

项目级专属约定（架构、构建命令、关键文件）在项目根 `AGENTS.md`；本 skill 只承载跨项目通用规范。
