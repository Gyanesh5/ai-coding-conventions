# Python 规范

---

## 类型标注

所有函数必须标注参数和返回值类型。禁止使用 `Any`。

```python
# ✅
def detect_circles(image: NDArray, min_radius: int = 10) -> list[CircleResult]:
    ...

# ❌
def detect_circles(image, min_radius=10):
    ...

# ❌ Any 绕过类型检查
def apply_state(ctx: Any, workcell: Any):
    ...
```

集合类型必须标注元素类型：

```python
# ✅
def filter_items(items: list[Item], category: int) -> list[Item]:

# ❌
def filter_items(items: list, category: int) -> list:
```

---

## 异常处理

捕获具体异常，禁止裸 except，禁止吞掉异常。

```python
# ✅
try:
    device.connect()
except ConnectionError as exc:
    logger.error("连接失败: %s", exc, exc_info=True)
    raise

# ❌
try:
    device.connect()
except:
    pass
```

---

## 异常层级

建立统一的自定义异常基类，所有自定义异常继承统一基类。

```
BaseError
├── ConfigError
├── DeviceError
│   ├── CameraError
│   ├── RobotError
│   └── ModbusError
├── ServiceError
└── ValidationError
```

异常应当携带结构化上下文：

```python
class CameraError(DeviceError):
    def __init__(self, message: str, camera_id: str | None = None):
        super().__init__(message)
        self.camera_id = camera_id
```

---

## 文档字符串

公开函数和类必须有 docstring，使用 Google 风格。

```python
def detect_circles(image: NDArray, min_radius: int = 10) -> list[CircleResult]:
    """检测图像中的圆形。

    Args:
        image: 输入灰度图。
        min_radius: 最小半径，默认 10。

    Returns:
        检测到的圆形列表。

    Raises:
        ValueError: 图像为空或参数无效。
    """
```

---

## 配置管理

### config.get() 必须提供显式默认值

```python
# ✅
retry = config.get("vision.max_retry", 3)

# ❌ 返回 None，后续 int(None) 崩溃
retry = config.get("vision.max_retry")
```

### 默认值集中定义

```python
DEFAULTS = {"max_retry": 3, "timeout_s": 2.0}
retry = config.get("max_retry", DEFAULTS["max_retry"])
```

### 配置加载时必须校验，校验失败 fail-fast 退出

---

## 线程安全

共享状态使用 `threading.Lock`。

---

## 禁止模式

- mutable 默认参数（用 `None` + 函数体内赋值）
- `import *`
- `type(x) == T`（用 `isinstance(x, T)`）
- 函数内 import（循环依赖除外，须注释说明）
- 单文件超过 500 行（需拆分模块）