# {{ PROJECT_NAME }}

{{ 项目简介 }}

> 本项目遵循统一编码规范。请务必阅读 `.agents/` 目录下的规范文件。

---

## ⚠️ 以下内容禁止 AI 修改

- 本文件中的「禁止 AI 修改」声明
- `.agents/` 目录下的所有规范文件
- `.gitignore`
- 任何 `*.lock` / `requirements*.txt` / `pyproject.toml` 中的依赖版本约束

---

## 按文件类型加载规范

- **任何文件**，必须遵守：`.agents/security.md`
- **所有语言通用**，必须参考：`.agents/coding.md`
- **.py 文件**，请同时参考：`.agents/python.md`
- **.cpp/.h 文件**，请同时参考：`.agents/cpp.md`
- **测试代码**，请同时参考：`.agents/testing.md`
- **通用规范**，请同时参考：`.agents/general.md`
- **项目目录结构**，必须遵守：`.agents/layout.md`

---

## AI 行为边界

以下行为约束是编码 Agent 工具未覆盖的项目级红线：

- **不自行安装新依赖**：新增第三方库前必须告知用户
- **不修改构建配置**：CMakeLists.txt / pyproject.toml / requirements.txt 等，修改前必须告知用户
- **删除文件前必须确认**

---

## 环境配置

<!-- TODO: 填写项目的环境配置 -->

---

## 构建和测试

<!-- TODO: 填写项目的构建和测试命令 -->

---

## 项目架构

<!-- TODO: 描述项目架构、模块划分、关键设计 -->

---

## 关键文件

<!-- TODO: 列出项目中最关键的文件及其用途 -->
