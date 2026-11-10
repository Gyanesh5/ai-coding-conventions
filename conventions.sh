#!/usr/bin/env bash
# AI 编程规范接入工具（ai-coding-conventions）
#
# 架构（双轨）：
#   轨 1（AGENTS.md 生态）：项目 .agents → 规范库 .agents（symlink），AGENTS.md 索引段按文件类型引用
#   轨 2（Agent Skills 标准）：项目 .agents/skills/coding-conventions（SKILL.md 插件，任务匹配自动加载）
#   规范正文单一真源：skills/coding-conventions/references/*.md；.agents/*.md 是 symlink 兼容层
#   项目 AGENTS.md 一次生成后，规范更新永不触碰它
#
# 用法（在项目根目录执行）：
#   bash /path/to/ai-coding-conventions/conventions.sh link           # 接入轨 1（幂等）
#   bash /path/to/ai-coding-conventions/conventions.sh install        # 接入轨 2，项目级（幂等）
#   bash /path/to/ai-coding-conventions/conventions.sh install user   # 接入轨 2，用户级（全项目生效）
#   bash /path/to/ai-coding-conventions/conventions.sh status         # 检查双轨接入健康
#   bash /path/to/ai-coding-conventions/conventions.sh sync           # 更新规范库，全部已接入项目即时跟随
set -euo pipefail

REPO="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
INDEX_HEADING="## 按文件类型加载规范"
SKILL_DIR="$REPO/skills/coding-conventions"

die() { echo "✗ $*" >&2; exit 1; }

[ -f "$SKILL_DIR/SKILL.md" ] || die "规范库缺 skills/coding-conventions/SKILL.md（版本过旧？先 git pull）"

# 从模板提取「按文件类型加载规范」段（heading 到其后第一个 ---，含两端）
extract_index() {
  awk -v h="$INDEX_HEADING" '
    $0 == h { ing = 1 }
    ing { print; if ($0 == "---") exit }
  ' "$REPO/AGENTS.md"
}

cmd_link() {
  local proj="$PWD"

  # 1) .agents symlink（轨 1 载体；轨 2 的 skills 入口也随库内 .agents/skills 自动可见）
  if [ -L "$proj/.agents" ]; then
    [ -d "$proj/.agents" ] || die ".agents 链接悬空: $(readlink "$proj/.agents")——先 rm .agents 再重跑 link"
    echo "✓ .agents → $(readlink "$proj/.agents")"
  elif [ -e "$proj/.agents" ]; then
    die ".agents 已是实体目录（旧 cp 副本）。迁移：确认里面没有项目私有规范后 rm -rf .agents，再重跑 link"
  else
    ln -s "$REPO/.agents" "$proj/.agents"
    echo "✓ .agents → $REPO/.agents"
  fi

  # 2) AGENTS.md：只在缺失时从模板创建；已存在则仅在缺索引段时追加，不改动任何现有内容
  if [ ! -f "$proj/AGENTS.md" ]; then
    cp "$REPO/AGENTS.md" "$proj/AGENTS.md"
    echo "✓ AGENTS.md 已从模板创建（请填写 {{ PROJECT_NAME }} 等 TODO 占位）"
  fi
  if ! grep -qF "$INDEX_HEADING" "$proj/AGENTS.md"; then
    { echo ""; echo "---"; echo ""; extract_index; } >> "$proj/AGENTS.md"
    echo "✓ 已在 AGENTS.md 末尾追加规范索引段（建议挪到文件头部；此后规范更新不会再动此文件）"
  else
    echo "✓ AGENTS.md 已含规范索引段（未做任何改动）"
  fi

  # 3) CLAUDE.md（Claude Code 兼容）
  if [ -e "$proj/CLAUDE.md" ] || [ -L "$proj/CLAUDE.md" ]; then
    echo "• CLAUDE.md 已存在，跳过"
  else
    ln -s AGENTS.md "$proj/CLAUDE.md"
    echo "✓ CLAUDE.md → AGENTS.md"
  fi

  # 4) C++ 项目附带 .clang-format
  if [ ! -e "$proj/.clang-format" ] && \
     find "$proj" -maxdepth 2 \( -name "*.cpp" -o -name "CMakeLists.txt" \) 2>/dev/null | head -1 | grep -q .; then
    cp "$REPO/.clang-format" "$proj/.clang-format"
    echo "✓ .clang-format 已复制（C++ 项目）"
  fi

  echo "轨 1 完成。建议再执行 install 接入 skills 轨（agent 任务匹配时自动加载规范）。"
}

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
    || die "skill 链接无效——.agents 若是旧 cp 实体目录会挡住 skills 入口，先跑 link 迁移"

  # 2) .claude/skills 相对 symlink（Claude Code 只认此路径；相对链接保持仓库可移植）
  mkdir -p "$proj/.claude/skills"
  ln -sfn ../../.agents/skills/coding-conventions "$proj/.claude/skills/coding-conventions"
  echo "✓ .claude/skills/coding-conventions → ../../.agents/skills/coding-conventions"

  echo "轨 2 完成（Codex / Cursor / Gemini CLI / Copilot / Claude Code 自动发现）。"
  echo "建议项目 .gitignore 追加 .agents 与 .claude/（链接指向本机规范库克隆，不随 git 旅行；新机 clone 后重跑 link + install）。"
}

cmd_status() {
  local proj="$PWD" ok=1
  if [ -L "$proj/.agents" ] && [ -d "$proj/.agents" ]; then
    echo "✓ 轨1 .agents → $(readlink "$proj/.agents")"
  else
    echo "✗ 轨1 .agents 未接入或链接悬空（重跑 link）"
    ok=0
  fi
  if [ -f "$proj/AGENTS.md" ]; then
    if grep -qF "$INDEX_HEADING" "$proj/AGENTS.md"; then
      echo "✓ 轨1 AGENTS.md 含规范索引段"
    else
      echo "✗ 轨1 AGENTS.md 缺规范索引段（重跑 link 补上）"
      ok=0
    fi
  else
    echo "✗ 无 AGENTS.md"
    ok=0
  fi
  if [ -e "$proj/.agents/skills/coding-conventions/SKILL.md" ]; then
    echo "✓ 轨2 .agents/skills/coding-conventions（Codex/Cursor/Gemini/Copilot）"
  else
    echo "• 轨2 未接入（可选，跑 install）"
  fi
  if [ -e "$proj/.claude/skills/coding-conventions/SKILL.md" ]; then
    echo "✓ 轨2 .claude/skills/coding-conventions（Claude Code）"
  else
    echo "• 轨2 Claude Code 入口未接入（可选，跑 install）"
  fi
  [ "$ok" = 1 ] && echo "接入健康" || exit 1
}

cmd_sync() {
  git -C "$REPO" pull --ff-only
  echo "规范库已更新；symlink 接入的项目（双轨）即时生效，无需逐项目同步。"
}

case "${1:-}" in
  link)          cmd_link ;;
  install)       cmd_install "${2:-project}" ;;
  status)        cmd_status ;;
  sync)          cmd_sync ;;
  *) echo "用法: $0 {link|install [user]|status|sync}（link/install/status 在项目根执行）"; exit 1 ;;
esac
