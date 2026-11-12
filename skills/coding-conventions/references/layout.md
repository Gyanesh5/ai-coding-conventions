# 项目目录规范

Monorepo 多服务项目目录约定。适用于 Python 业务服务 + Web 前端 + 未来 C++ 服务混合形态，部署到产线/边缘设备。

---

## 顶层结构

```
project-root/
├── services/        # 可独立部署的服务（一服务一目录）
├── packages/        # 内部自研共享库 / 协议定义 / SDK
├── vendor/          # 第三方代码本地副本（git submodule、vendored deps）
├── web/             # Web 前端（构建工具链与后端不同，独立顶层）
├── configs/         # 全局配置（按产线/环境区分）
├── scripts/         # 运维 / 部署 / 启停脚本
├── tools/           # 领域 CLI（标定、数据转换、批量处理）
├── deploy/          # 部署编排（systemd unit / docker-compose）
├── docs/            # 项目文档（含 PRD）
├── tests/           # 跨服务集成测试 / 端到端测试
├── .agents/         # 编码规范
├── AGENTS.md
└── .gitignore
```

---

## `packages/` vs `vendor/` —— 必须严格区分

这两个目录语义相反，混淆会导致自研代码被当第三方代码对待、或第三方代码被当业务代码修改。

| 目录 | 语义 | 来源 | 版本控制 | 示例 |
|------|------|------|----------|------|
| `packages/` | **自研**可复用代码 | 团队编写，本仓库原生 | 直接提交源码 | `protocol/`、`common/`、`model-sdk/` |
| `vendor/` | **第三方**代码本地副本 | 外部仓库、git submodule | 提交快照或子模块指针 | `vendor/<外部库名>/` |

**禁止把自研代码放进 `vendor/`，禁止修改 `vendor/` 下的第三方源码**（如需定制，fork 后作为独立仓库引入）。

---

## 服务层 `services/<service-name>/`

一服务一目录，每个服务自包含。Python 服务采用**标准 src layout**：

```
services/vision/
├── src/
│   └── vision/              # 包名 = 服务名
│       ├── __init__.py
│       ├── __main__.py      # python -m vision 入口
│       ├── detection/       # 业务模块
│       └── config.py        # 服务内配置加载
├── tests/                   # 服务内单元/集成测试，镜像 src 结构
│   ├── test_detection.py
│   └── fixtures/            # 测试样本数据
├── pyproject.toml           # 独立依赖声明
└── README.md                # 服务职责、启动方式、依赖说明
```

C++ 服务：

```
services/controller/
├── src/
├── include/
├── tests/
├── CMakeLists.txt
└── README.md
```

### import 写法约定

标准 src layout 的核心收益是包名与目录解耦：

```python
# ✅ 包名 = 服务名，与目录层级解耦
from vision.detection import detect_object
from common.logging import get_logger          # 来自 packages/common

# ❌ 暴露 src 目录层级
from src.vision.detection import detect_object
```

> **存量项目迁移**：从 `from src.xxx import` 写法迁移到 src layout 时，去掉 `src.` 前缀调整 import 路径，并在 `pyproject.toml` 配置 `[tool.setuptools.packages.find] where = ["src"]`。

---

## 共享库层 `packages/`

跨服务复用的代码必须放这里。**禁止服务之间直接互 import 源码**。

```
packages/
├── protocol/        # 多服务共享的协议定义（消息体、状态码、错误码）
├── common/          # 通用工具（日志、配置加载、异常基类）
└── model-sdk/       # 模型推理 SDK（Python 封装 + 未来 C++ 绑定）
```

每个 package 自带 `pyproject.toml`，被各服务以**路径依赖**方式引入：

```toml
# services/vision/pyproject.toml
[tool.setuptools.packages.find]
where = ["src"]

[project]
dependencies = [
    "protocol @ file://../../../packages/protocol",
    "common @ file://../../../packages/common",
]
```

---

## 配置 `configs/`

按产线/环境分目录，**与代码完全分离**：

```
configs/
├── default/         # 默认值基线
│   └── vision.yaml
├── line-a/          # A 产线差异化配置
└── line-b/          # B 产线差异化配置
```

业务代码禁止硬编码配置文件路径，统一通过启动参数或环境变量 `CONFIG_DIR` 指向。

> 目录名统一用 `configs/`（复数）。

---

## 脚本分层：`scripts/` vs `tools/`

| 目录 | 用途 | 谁来用 | 示例 |
|------|------|--------|------|
| `scripts/` | 部署、启停、运维 | 现场工程师 / systemd | `service.sh`、`deploy.sh`、`verify.sh` |
| `tools/` | 领域 CLI（一次性但有业务语义） | 开发、调试 | `convert_dataset.py`、`gen_config_reference.py` |

```
scripts/
├── service.sh        # systemd 启停包装
├── deploy.sh
└── verify.sh

tools/
├── convert_dataset.py       # 数据集批量转换
└── gen_config_reference.py  # 配置参考生成
```

- `tools/` 下的脚本须在文件头注明作者、日期、用途
- `scripts/` 下的脚本须可被 systemd 或运维流程直接调用，不依赖交互输入

---

## 运行时产物（.gitignore 约定）

| 目录 | 用途 | 版本控制 |
|------|------|----------|
| `logs/` | 运行日志 | ❌ 忽略 |
| `outputs/` | 检测结果、截图、中间产物 | ❌ 忽略 |
| `data/` | 运行时数据集、缓存 | ❌ 忽略 |
| `models/` | AI 模型权重文件 | ⚠️ 视大小，大文件用 Git LFS 或外部存储 |
| `__pycache__/` `.venv/` `build/` `dist/` | 构建产物 | ❌ 忽略 |

统一在仓库根 `.gitignore` 约定，子目录不再单独维护。运行时产物建议各服务自放（`services/<name>/logs/`），避免互相干扰；如需集中采集通过日志配置指向统一目录。

---

## 测试布局规则

- **单元测试**：放 `services/<name>/tests/`，目录结构镜像 `src/`
- **跨服务集成 / 端到端测试**：放顶层 `tests/`
- **测试夹具**（fixture 数据、样本图像）放对应 `tests/fixtures/`

---

## 禁止模式

- ❌ 服务之间直接互 import 源码（必须走 `packages/`）
- ❌ 自研代码放进 `vendor/`，或修改 `vendor/` 下第三方源码
- ❌ 非 src layout（顶层 `vision/` 包与 `src/vision/` 二选一，强制 src layout）
- ❌ `from src.xxx import`（暴露目录层级，应 `from vision.xxx import`）
- ❌ 在业务代码中硬编码配置文件路径
- ❌ 运行时产物（logs/outputs）提交到版本控制
- ❌ 把运维脚本、领域 CLI 散落在源码目录（必须归 `scripts/` 或 `tools/`）
- ❌ 多服务共享的工具函数复制粘贴到各服务
