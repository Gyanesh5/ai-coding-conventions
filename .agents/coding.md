# 通用编码规范

Python 和 C++ 共同遵守的规则。

---

## 设计哲学

- **可维护性优先于聪明**：选可读的方案，不选最短的方案
- **显式优于隐式**：行为的来源应当看得见，不隐藏依赖和副作用
- **Fail-fast**：问题越早暴露，修复成本越低。不 `except: pass`，不用 None 表示异常/失败（None 作为正常业务结果如"未找到"是允许的）
- **KISS**：选择能工作的最简方案
- **DRY**：提取公共逻辑，避免复制粘贴。不到三次的相似不急于提取
- **YAGNI**：不提前构建不需要的功能
- **外科手术式变更**：每行改动须直接追溯到用户需求。不顺手改进相邻代码、格式、导入。发现死代码在总结中提及，不自行删除

---

## 命名

使用具体、有意义的名称。禁止模糊命名。名字回答"是什么"而非"怎么做"。

```
# ✅
robot_left_arm / camera_overhead / conveyor_belt_motor
extract_weld_seam / detect_circle_centers
WeldingParameter / CircleDetectionResult
is_last_workpiece / has_lease / should_retry

# ❌
robot_a / camera_b / motor_1
do_stuff / process_data / handle
Data / Info / Result
last = True       # 语义不明
flag = False      # 无意义
```

---

## 单一职责

每个函数、类、模块只做一件事，只有一个变更的理由。

---

## 最小惊讶

函数/变量/API 的行为应当与其名称暗示一致。名字暗示"获取"时不应有副作用。

---

## 依赖注入

通过参数传递依赖，避免全局变量。高层依赖抽象（接口），不依赖具体实现。

---

## 错误处理

### 尽早失败（Fail Fast）

在函数入口验证参数，不"带病运行"。

### 异常 vs 返回值

- **异常**：不可预期的错误（网络断开、文件不存在）
- **返回值**：正常的业务结果（查找失败、空结果）

### 不吞掉异常

捕获后必须至少执行之一：记日志、重新抛出、转换后抛出（`raise X from exc`）。

### 转换异常时保留异常链

```python
# ✅ 保留原始堆栈
raise ServiceError("服务不可用") from exc

# ❌ 丢失异常链
raise ServiceError("服务不可用")
```

---

## 防御性编程

在系统边界（外部输入入口）校验输入，在内部函数中信任已校验的输入。

---

## 代码坏味道

- 函数超过 50 行 → 拆分
- 嵌套超过 3 层 → 提前返回（卫语句）
- 魔法数字 → 命名常量

---

## 注释原则

解释 WHY，不解释 WHAT。命名清晰时不需要注释。

TODO 必须包含署名和日期：`# TODO(alice, 2026-07-09): 支持 N 组配置`

---

## 接口设计

- 最小接口：只暴露必要的方法
- 显式优于隐式：通过参数传递依赖
- 副作用在函数名中声明（`fetch_user_and_log_access` 而非 `get_user`）

---

## 日志规范

### 业务代码禁止使用 print()

无论使用什么日志系统，`print()` 绕过所有级别控制、轮转和过滤。例外：CLI 入口的 `--help` 输出、测试和脚本。

### 正确使用日志级别

| 级别 | 使用场景 | 频率 |
|------|----------|------|
| TRACE | 极细粒度的执行轨迹 | 极高频，生产关闭 |
| DEBUG | 内部状态、算法中间值、逐帧数据 | 高频，生产关闭 |
| INFO | 关键业务节点：启动、状态切换、任务完成 | 中频 |
| WARNING | 可恢复异常：重试触发、兜底、配置缺失用默认值 | 低频 |
| ERROR | 不可恢复错误：设备断连、写入失败、检测失败 | 极低频 |
| CRITICAL | 系统级故障：无法启动、数据损坏 | 极少 |

禁止用 INFO 记录高频循环内的逐帧日志（应用 DEBUG）。禁止用 ERROR 记录可恢复异常（应用 WARNING）。

### 异常日志必须包含完整堆栈

```
✅ 记录完整堆栈
logger.error("设备连接失败: %s", exc, exc_info=True)
# 或等价的 logger.exception("设备连接失败")

❌ 只记消息不记堆栈
logger.error(str(exc))
```

### 日志消息应包含足够上下文

```
❌ logger.error("连接失败")

✅ logger.error("Modbus 连接失败: host=%s, port=%d, error=%s", host, port, exc)
```

### 日志语言：中文描述业务语义，技术标识符保持英文

```
✅ logger.info("等待 PLC 触发 taskB, robot_id=%s", robot_id)
✅ logger.warning("SAM3 服务未就绪，将重试")

❌ logger.info("Waiting for PLC trigger taskB")
```