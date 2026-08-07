# 安全红线

绝对禁止违反。

---

## 禁止 eval() / exec()

代码注入风险。

---

## SQL 注入

```python
# ❌ 字符串拼接
query = f"SELECT * FROM users WHERE name = '{name}'"

# ✅ 参数化查询
cursor.execute("SELECT * FROM users WHERE name = %s", (name,))
```

---

## 命令注入

```python
# ❌
os.system(f"ping {ip}")

# ✅ 严格验证 + subprocess
if not re.match(r"^[0-9.]+$", ip):
    raise ValueError("无效 IP")
subprocess.run(["ping", ip], check=True)
```

---

## 外部输入验证

传感器数据、网络数据、用户输入必须在系统边界校验。内部函数信任已校验的输入。

---

## 硬件控制安全

- 必须设置超时
- 机器人运动必须有工作空间限位检查
- 异常时执行紧急停止

---

## 错误消息安全

不泄露敏感信息（密码、堆栈、内部路径）。详细错误记日志，用户看到通用消息。

---

## 日志安全

不记录密码、token、密钥。

---

## 密码安全

- 密码必须使用哈希存储（bcrypt），禁止明文
- 密码比较必须使用恒定时间比较（`secrets.compare_digest`）
- 会话 Token 必须使用密码学安全的随机生成（`secrets.token_urlsafe`）

---

## 依赖安全

- 定期审计已知漏洞（`pip audit`）
- 禁止使用不带版本号的依赖
- 依赖版本必须锁定，提交锁文件