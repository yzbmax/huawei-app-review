#!/usr/bin/env bash
# huawei-app-review 一键安装脚本
#
# 用法：
#   curl -fsSL https://raw.githubusercontent.com/yzbmax/huawei-app-review/main/install.sh | bash
#   或者本地运行：bash install.sh

set -euo pipefail

REPO_URL="https://github.com/yzbmax/huawei-app-review.git"
DEFAULT_DIR="${HUAWEI_APP_REVIEW_DIR:-${HOME}/.local/share/huawei-app-review}"

ANSI_BOLD=$'\033[1m'
ANSI_GREEN=$'\033[32m'
ANSI_YELLOW=$'\033[33m'
ANSI_RED=$'\033[31m'
ANSI_RESET=$'\033[0m'

log()  { printf "%s>> %s%s\n" "${ANSI_BOLD}" "$*" "${ANSI_RESET}"; }
ok()   { printf "%s[ok] %s%s\n" "${ANSI_GREEN}" "$*" "${ANSI_RESET}"; }
warn() { printf "%s[!] %s%s\n" "${ANSI_YELLOW}" "$*" "${ANSI_RESET}"; }
err()  { printf "%s[x] %s%s\n" "${ANSI_RED}" "$*" "${ANSI_RESET}" >&2; }

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { err "需要 $1，但未找到。请先安装 $1 后重试。"; exit 1; }
}

require_cmd git

# 判断是本地执行还是远程脚本执行
if [ -f "$(pwd)/install.sh" ] && [ -f "$(pwd)/SKILL.md" ]; then
  REPO_DIR="$(pwd)"
  log "使用当前本地仓库路径: ${REPO_DIR}"
elif [ -d "${DEFAULT_DIR}/.git" ]; then
  log "更新已有目录: ${DEFAULT_DIR}"
  git -C "${DEFAULT_DIR}" pull --ff-only --quiet || warn "git pull 失败，使用现有版本"
  REPO_DIR="${DEFAULT_DIR}"
else
  log "克隆仓库 ${REPO_URL} -> ${DEFAULT_DIR}"
  mkdir -p "$(dirname "${DEFAULT_DIR}")"
  git clone --depth=1 "${REPO_URL}" "${DEFAULT_DIR}" --quiet
  REPO_DIR="${DEFAULT_DIR}"
fi

SKILL_DIR="${REPO_DIR}"
[ -f "${SKILL_DIR}/SKILL.md" ] || { err "在 ${SKILL_DIR} 中未找到 SKILL.md"; exit 1; }

INSTALLED=0
SKIPPED=0

link_to() {
  local target="$1" label="$2"
  mkdir -p "$(dirname "$target")"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$SKILL_DIR" ]; then
    ok "${label}: 已正确链接（保持不变）"
    SKIPPED=$((SKIPPED + 1))
    return
  fi
  if [ -L "$target" ] || [ -e "$target" ]; then
    warn "${label}: 替换已有软链/目录 ${target}"
    rm -rf "$target"
  fi
  ln -s "$SKILL_DIR" "$target"
  ok "${label}: ${target} -> ${SKILL_DIR}"
  INSTALLED=$((INSTALLED + 1))
}

# === Claude Code ===
if [ -d "$HOME/.claude" ] || command -v claude >/dev/null 2>&1; then
  link_to "$HOME/.claude/skills/huawei-app-review" "Claude Code"
fi

# === Antigravity / Gemini CLI ===
if [ -d "$HOME/.gemini" ] || command -v gemini >/dev/null 2>&1; then
  link_to "$HOME/.gemini/config/skills/huawei-app-review" "Antigravity Global"
  link_to "$HOME/.gemini/skills/huawei-app-review" "Gemini CLI"
fi

# === Standard Agent Skills Directory (~/.agents/skills) ===
link_to "$HOME/.agents/skills/huawei-app-review" "Standard Agent Skills (~/.agents)"

# === OpenAI Codex CLI ===
if [ -d "$HOME/.codex" ] || command -v codex >/dev/null 2>&1; then
  link_to "$HOME/.codex/skills/huawei-app-review" "OpenAI Codex CLI"
fi

# === Cursor ===
if [ -d "$HOME/.cursor" ] || command -v cursor >/dev/null 2>&1; then
  link_to "$HOME/.cursor/skills/huawei-app-review" "Cursor"
fi

echo ""
log "huawei-app-review 安装完成！(新增/更新: ${INSTALLED}, 已就绪: ${SKIPPED})"
echo ">> 技能根目录: ${SKILL_DIR}"
