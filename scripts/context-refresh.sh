#!/bin/bash
# Context Refresh - Load essential project context for new sessions

set -e

PROJECT_ROOT="${1:-.}"
cd "${PROJECT_ROOT}"

# Auto-detect project name from directory
PROJECT_NAME=$(basename "$(pwd)")
echo "🔄 Loading ${PROJECT_NAME} project context..."
echo ""

# 1. Current date/time
echo "📅 Today: $(date '+%A, %B %d, %Y')"
echo "⏰ Time: $(date '+%H:%M %Z')"
echo ""

# 2. Active branch
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "🌿 Branch: ${BRANCH}"
echo ""

# 3. Recent changes (last 3 days) - Anthropic pattern: show files changed
echo "📝 Recent Activity (last 3 days):"
git log --since="3 days ago" --oneline --no-merges --name-only | head -n 30 | while IFS= read -r line; do
  if [[ "$line" =~ ^[a-f0-9]{7,} ]]; then
    echo "   $line"
  elif [[ -n "$line" ]]; then
    echo "      └─ $line"
  fi
done
echo ""

# 4. Uncommitted changes detection
STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
UNSTAGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

if [ "$STAGED" -gt 0 ] || [ "$UNSTAGED" -gt 0 ] || [ "$UNTRACKED" -gt 0 ]; then
  echo "⚠️  Uncommitted Changes:"
  if [ "$STAGED" -gt 0 ]; then
    echo "   📦 Staged: $STAGED file(s)"
    git diff --cached --name-only | head -n 5 | sed 's/^/      /'
  fi
  if [ "$UNSTAGED" -gt 0 ]; then
    echo "   ✏️  Modified: $UNSTAGED file(s)"
    git diff --name-only | head -n 5 | sed 's/^/      /'
  fi
  if [ "$UNTRACKED" -gt 0 ]; then
    echo "   ❓ Untracked: $UNTRACKED file(s)"
    git ls-files --others --exclude-standard | head -n 5 | sed 's/^/      /'
  fi
  echo ""
fi

# 5. Current TODO context
echo "📋 Current Sprint (from TODO.md):"
if [ -f "TODO.md" ]; then
  grep -A 5 "^## " TODO.md | head -n 15 | sed 's/^/   /'
else
  echo "   (TODO.md not found)"
fi
echo ""

# 6. Recent ADRs (last 5)
echo "📚 Recent Architecture Decisions:"
if [ -d "docs" ]; then
  find docs -name "*.md" -path "*/decision*" -o -path "*/adr*" 2>/dev/null | \
    xargs ls -t 2>/dev/null | head -n 5 | while read file; do
    TITLE=$(grep "^# " "$file" | head -n 1 | sed 's/^# //')
    FILENAME=$(basename "$file")
    echo "   ${FILENAME}: ${TITLE}"
  done
else
  echo "   (ADR directory not found)"
fi
echo ""

# 7. Outstanding items
echo "⚠️  Outstanding Items:"
if [ -f "TODO.md" ]; then
  grep -E "^- \[ \]|Priority 0|Priority 1" TODO.md | head -n 5 | sed 's/^/   /'
else
  echo "   (Check TODO.md when available)"
fi
echo ""

# 8. Session tasks (if exists)
MEMORY_DIR=".agent-memory"
TASKS_FILE="${MEMORY_DIR}/session-tasks.json"
if [ -f "${TASKS_FILE}" ]; then
  echo "📋 Session Tasks:"

  # Parse JSON and display tasks by status
  IN_PROGRESS=$(jq -r '.tasks[] | select(.status == "in_progress") | "   🔄 \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  PENDING=$(jq -r '.tasks[] | select(.status == "pending") | "   ⏳ \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  BLOCKED=$(jq -r '.tasks[] | select(.status == "blocked") | "   🚫 \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  COMPLETED_COUNT=$(jq -r '[.tasks[] | select(.status == "completed")] | length' "${TASKS_FILE}" 2>/dev/null)
  TOTAL_COUNT=$(jq -r '.tasks | length' "${TASKS_FILE}" 2>/dev/null)

  if [ -n "$IN_PROGRESS" ]; then
    echo "$IN_PROGRESS"
  fi
  if [ -n "$BLOCKED" ]; then
    echo "$BLOCKED"
  fi
  if [ -n "$PENDING" ]; then
    echo "$PENDING" | head -n 5
  fi

  # Summary line
  echo "   ─────────────────────────"
  echo "   Progress: ${COMPLETED_COUNT}/${TOTAL_COUNT} completed"

  # Knowledge counts
  DECISIONS=$(jq -r '.knowledge.decisions // 0' "${TASKS_FILE}" 2>/dev/null)
  HYPOTHESES=$(jq -r '.knowledge.hypotheses // 0' "${TASKS_FILE}" 2>/dev/null)
  BLOCKERS=$(jq -r '.knowledge.blockers // 0' "${TASKS_FILE}" 2>/dev/null)
  if [ "$DECISIONS" -gt 0 ] || [ "$HYPOTHESES" -gt 0 ] || [ "$BLOCKERS" -gt 0 ]; then
    echo "   Knowledge: ${DECISIONS}D ${HYPOTHESES}H ${BLOCKERS}B"
  fi
  echo ""
fi

# 9. Session working memory (if exists)
if [ -d "${MEMORY_DIR}" ]; then
  echo "🧠 Active Session Memory:"

  # Show session state
  if [ -f "${MEMORY_DIR}/session-state.md" ]; then
    echo "   📍 Session State:"
    grep -A 10 "## Current Focus" "${MEMORY_DIR}/session-state.md" | grep -v "^#" | grep -v "^--" | grep -v "^<!--" | grep -v "^$" | sed 's/^/      /' | head -n 5

    # Show key decisions
    DECISION_COUNT=$(grep -c "^🎯" "${MEMORY_DIR}/session-state.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
    if [ "${DECISION_COUNT}" -gt 0 ]; then
      echo "   💡 Key Decisions: ${DECISION_COUNT}"
      grep "^🎯" "${MEMORY_DIR}/session-state.md" | sed 's/^/      /' | head -n 3
    fi
  fi

  # Show active hypotheses
  if [ -f "${MEMORY_DIR}/hypotheses.md" ]; then
    HYPOTHESIS_COUNT=$(grep -c "^💡" "${MEMORY_DIR}/hypotheses.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
    if [ "${HYPOTHESIS_COUNT}" -gt 0 ] 2>/dev/null; then
      echo "   🔬 Active Theories: ${HYPOTHESIS_COUNT}"
      grep "^💡" "${MEMORY_DIR}/hypotheses.md" | sed 's/^/      /' | head -n 2
    fi
  fi

  # Show blockers
  if [ -f "${MEMORY_DIR}/blockers.md" ]; then
    BLOCKER_COUNT=$(grep -c "^⚠️" "${MEMORY_DIR}/blockers.md" 2>/dev/null | tr -d '[:space:]' || echo "0")
    if [ "${BLOCKER_COUNT}" -gt 0 ] 2>/dev/null; then
      echo "   🚧 Open Blockers: ${BLOCKER_COUNT}"
      grep "^⚠️" "${MEMORY_DIR}/blockers.md" | sed 's/^/      /' | head -n 2
    fi
  fi
  echo ""
else
  echo "🧠 Session Memory: Not initialized"
  echo "   💡 Start session with: ./scripts/memory-init.sh"
  echo ""
fi

echo "✅ Context loaded. Key files to reference:"
echo "   • CLAUDE.md - Development standards"
echo "   • TODO.md - Current sprint goals  (User stories with acceptance criteria)"
echo "   • docs/ - Architecture decisions"
echo "   • docs/development/ - PRD framework"
echo "   • .agent-memory/ - Current session memory"
echo ""
echo "💡 Session workflow:"
echo "   • During work: ./scripts/memory-note.sh \"<note>\""
echo "   • Search past: ./scripts/search-artifacts.sh <keyword>"
echo "   • At session end: /finalize + ./scripts/index-artifacts.sh"
