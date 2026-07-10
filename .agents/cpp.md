# C++ 规范

基于 C++ Core Guidelines。提交前必须通过 clang-format 格式化，配置见项目根目录 `.clang-format`。

---

## 资源管理

### 智能指针（R.11/R.20）

```cpp
// ✅
auto device = std::make_unique<Device>(ip, port);

// ❌ 禁止裸 new/delete
Device* device = new Device(ip, port);
```

### Rule of 0 或 Rule of 5

类要么不定义析构/拷贝/移动（Rule of 0），要么全部定义（Rule of 5）。

### RAII

资源获取即初始化，利用对象生命周期管理资源。

---

## 初始化

### `{}` 初始化（ES.23）

```cpp
// ✅
int x{0};
std::vector<int> v{1, 2, 3};
std::string s{"hello"};
```

---

## 虚析构（C.35）

基类必须声明虚析构函数。

```cpp
class DeviceBase {
public:
    virtual ~DeviceBase() = default;
    virtual void connect() = 0;
};
```

---

## const 正确性

```cpp
// ✅ 不修改成员的函数标记 const
class Calculator {
public:
    int compute(int a, int b) const { return a + b; }
};

// ✅ 不修改的参数用 const 引用
void process(const std::string& data);
```

---

## 命名约定

| 类型 | 约定 | 示例 |
|------|------|------|
| 类 | PascalCase | `Camera` |
| 函数 | snake_case | `detect_circles` |
| 成员变量 | `_` 前缀 | `_ip` |
| 常量 | UPPER_SNAKE_CASE | `MAX_RETRY` |
| 布尔 | `is_`/`has_` 前缀 | `is_connected` |

---

## 异常处理

捕获具体异常，禁止 `catch(...)` 吞掉异常。

转换异常时保留异常链。

---

## 禁止模式

- C 风格转换 `(int)x`（用 `static_cast<int>(x)`）
- `NULL`（用 `nullptr`）
- C 数组 `int arr[10]`（用 `std::array` 或 `std::vector`）