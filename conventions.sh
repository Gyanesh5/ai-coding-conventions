#!/usr/bin/env bash
# AI 编程规范接入工具（ai-coding-conventions）
#
# 架构（插件式）：
#   Agent Skills 标准插件：项目 .agents/skills/coding-conventions → 规范库（SKILL.md，任务匹配自动加载）
#   Claude Code 走 .claude/skills/ 相对 symlink；或用 .claude-plugin/ marketplace 通道安装
#   规范正文单一真源：skills/coding-conventions/references/*.md
#
# 用法（install/status 在项目根目录执行）：
#   bash /path/to/ai-coding-conventions/conventions.sh install        # 项目级（幂等）
#   bash /path/to/ai-coding-conventions/conventions.sh install user   # 用户级（全项目生效）
#   bash /path/to/ai-coding-conventions/conventions.sh status         # 检查接入健康
#   bash /path/to/ai-coding-conventions/conventions.sh sync           # 更新规范库，已接入项目即时跟随
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SKILL_DIR="$REPO/skills/coding-conventions"

die() { echo "✗ $*" >&2; exit 1; }

[ -f "$SKILL_DIR/SKILL.md" ] || die "规范库缺 skills/coding-conventions/SKILL.md（版本过旧？先 git pull）"

cmd_install() {
  local scope="${1:-project}"

  if [ "$scope" = "user" ]; then
    mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills"
    ln -sfn "$SKILL_DIR" "$HOME/.agents/skills/coding-conventions"
    ln -sfn "$SKILL_DIR" "$HOME/.claude/skills/coding-conventions"
    echo "✓ 用户级已装：~/.agents/skills（Codex/Cursor/Gemini CLI/Copilot）+ ~/.claude/skills（Claude Code）"
    echo "本机全部项目生效；更新规范后 sync 一次即全量跟随。"
    return
  fi

  local proj="$PWD"

  # 1) .agents/skills/coding-conventions（公共发现路径：Codex/Cursor/Gemini CLI/Copilot）
  if [ -e "$proj/.agents/skills/coding-conventions/SKILL.md" ]; then
    echo "✓ .agents/skills/coding-conventions 就绪"
  else
    mkdir -p "$proj/.agents/skills"
    ln -sfn "$SKILL_DIR" "$proj/.agents/skills/coding-conventions"
    echo "✓ .agents/skills/coding-conventions → $SKILL_DIR"
  fi
  [ -e "$proj/.agents/skills/coding-conventions/SKILL.md" ] \
    || die "skill 链接无效——项目 .agents 若是实体目录会挡住 skills 入口，手动处理后重跑 install"

  # 2) .claude/skills 相对 symlink（Claude Code 只认此路径；相对链接保持仓库可移植）
  mkdir -p "$proj/.claude/skills"
  ln -sfn ../../.agents/skills/coding-conventions "$proj/.claude/skills/coding-conventions"
  echo "✓ .claude/skills/coding-conventions → ../../.agents/skills/coding-conventions"

  # 3) C++ 项目附带 .clang-format
  if [ ! -e "$proj/.clang-format" ] && \
     find "$proj" -maxdepth 2 \( -name "*.cpp" -o -name "CMakeLists.txt" \) 2>/dev/null | head -1 | grep -q .; then
    cp "$REPO/.clang-format" "$proj/.clang-format"
    echo "✓ .clang-format 已复制（C++ 项目）"
  fi

  echo "接入完成（Codex / Cursor / Gemini CLI / Copilot / Claude Code 自动发现）。"
  echo "建议项目 .gitignore 追加 .agents 与 .claude/（链接指向本机规范库克隆，不随 git 旅行；新机 clone 后重跑 install）。"
}

cmd_status() {
  local proj="$PWD" ok=1
  if [ -f "$REPO/.claude-plugin/plugin.json" ]; then
    echo "✓ 插件清单 $REPO/.claude-plugin/plugin.json（Claude Code: /plugin marketplace add <本仓库路径或 git URL>）"
  else
    echo "✗ 插件清单缺失（版本过旧？git pull）"
    ok=0
  fi
  if [ -e "$proj/.agents/skills/coding-conventions/SKILL.md" ]; then
    echo "✓ .agents/skills/coding-conventions（Codex/Cursor/Gemini/Copilot）"
  else
    echo "• 未接入（可选，跑 install）"
  fi
  if [ -e "$proj/.claude/skills/coding-conventions/SKILL.md" ]; then
    echo "✓ .claude/skills/coding-conventions（Claude Code）"
  else
    echo "• Claude Code 入口未接入（可选，跑 install）"
  fi
  [ "$ok" = 1 ] && echo "接入健康" || exit 1
}

cmd_sync() {
  git -C "$REPO" pull --ff-only
  echo "规范库已更新；install 接入的项目即时生效，无需逐项目同步。"
}

case "${1:-}" in
  install)       cmd_install "${2:-project}" ;;
  status)        cmd_status ;;
  sync)          cmd_sync ;;
  link)          die "link 已移除（引用式安装下线），改用 install" ;;
  *) echo "用法: $0 {install [user]|status|sync}（install/status 在项目根执行）"; exit 1 ;;
esac
