#!/bin/bash
# Memory Note - Quick note-taking for session memory
# Enhanced with structured format support per ADR-022

set -e

PROJECT_ROOT="${1:-.}"
MEMORY_DIR=".agent-memory"
SESSION_STATE="${MEMORY_DIR}/session-state.md"

# If first arg is a path, use it as project root and shift
if [[ -d "$1" ]] && [[ ! "$1" =~ ^- ]]; then
  cd "$1"
  shift
fi

NOTE=""
TYPE="progress"
STRUCTURED=false
CONTEXT=""
OPTIONS=""
CHOICE=""
RATIONALE=""
OUTCOME=""

# Parse flags
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--decision)
      TYPE="decision"
      shift
      ;;
    -h|--hypothesis)
      TYPE="hypothesis"
      shift
      ;;
    -b|--blocker)
      TYPE="blocker"
      shift
      ;;
    -o|--outcome)
      TYPE="outcome"
      shift
      ;;
    --context)
      STRUCTURED=true
      CONTEXT="$2"
      shift 2
      ;;
    --options)
      STRUCTURED=true
      OPTIONS="$2"
      shift 2
      ;;
    --choice)
      STRUCTURED=true
      CHOICE="$2"
      shift 2
      ;;
    --rationale)
      STRUCTURED=true
      RATIONALE="$2"
      shift 2
      ;;
    --result)
      OUTCOME="$2"
      shift 2
      ;;
    --evidence)
      EVIDENCE="$2"
      shift 2
      ;;
    *)
      NOTE="$*"
      break
      ;;
  esac
done

show_usage() {
  echo "Usage: memory-note.sh [-d|-h|-b|-o] \"<note>\""
  echo ""
  echo "Quick mode (freeform):"
  echo "  -d, --decision    Log a key decision"
  echo "  -h, --hypothesis  Log a working theory"
  echo "  -b, --blocker     Log a blocker or question"
  echo "  -o, --outcome     Log an outcome for a decision"
  echo "  (default)         Log progress note"
  echo ""
  echo "Structured mode (ACE playbook format - recommended for decisions):"
  echo "  --context    \"Problem or situation being addressed\""
  echo "  --options    \"Option1,Option2,Option3\" (comma-separated)"
  echo "  --choice     \"Selected option\""
  echo "  --rationale  \"Why this choice was made\""
  echo ""
  echo "Outcome mode (for tracking decision results):"
  echo "  --result     \"success|partial|failure\""
  echo "  --evidence   \"Observable evidence of the result\""
  echo ""
  echo "Examples:"
  echo ""
  echo "  # Quick decision (freeform)"
  echo "  memory-note.sh -d \"Using UUID v7 for temporal ordering\""
  echo ""
  echo "  # Structured decision (recommended - per ADR-022)"
  echo "  memory-note.sh -d \\"
  echo "    --context \"Need unique IDs with temporal ordering\" \\"
  echo "    --options \"UUID v4,UUID v7,ULID,nanoid\" \\"
  echo "    --choice \"UUID v7\" \\"
  echo "    --rationale \"Native temporal ordering, widely supported\""
  echo ""
  echo "  # Record outcome of a decision"
  echo "  memory-note.sh -o --result success --evidence \"IDs sort correctly, no collisions in 100k test\""
  echo ""
  echo "  # Other types"
  echo "  memory-note.sh -h \"Debounce might improve performance\""
  echo "  memory-note.sh -b \"Need to clarify RLS policy scope\""
  exit 1
}

# Handle structured decision format - single line for awk compatibility
format_structured_decision() {
  local output="**Context:** ${CONTEXT} | "
  if [ -n "${OPTIONS}" ]; then
    output+="**Options:** ${OPTIONS} | "
  fi
  output+="**Choice:** ${CHOICE} | "
  output+="**Rationale:** ${RATIONALE}"
  echo "${output}"
}

# Check if we have required args
if [ -z "${NOTE}" ] && [ "${STRUCTURED}" = false ] && [ "${TYPE}" != "outcome" ]; then
  show_usage
fi

# Validate structured decision has required fields
if [ "${STRUCTURED}" = true ] && [ "${TYPE}" = "decision" ]; then
  if [ -z "${CONTEXT}" ] || [ -z "${CHOICE}" ] || [ -z "${RATIONALE}" ]; then
    echo "❌ Structured decisions require --context, --choice, and --rationale"
    echo ""
    show_usage
  fi
  NOTE=$(format_structured_decision)
fi

# Validate outcome has required fields
if [ "${TYPE}" = "outcome" ]; then
  if [ -z "${OUTCOME}" ]; then
    echo "❌ Outcomes require --result (success|partial|failure)"
    show_usage
  fi
  NOTE="**Result:** ${OUTCOME}"
  if [ -n "${EVIDENCE}" ]; then
    NOTE+=" | **Evidence:** ${EVIDENCE}"
  fi
fi

if [ -z "${NOTE}" ]; then
  show_usage
fi

if [ ! -f "${SESSION_STATE}" ]; then
  echo "❌ Session memory not initialized"
  echo "Run: ./scripts/memory-init.sh"
  exit 1
fi

TIMESTAMP=$(date '+%H:%M')

case $TYPE in
  decision)
    TARGET="${MEMORY_DIR}/session-state.md"
    SECTION="Key Decisions This Session"
    PREFIX="🎯 [${TIMESTAMP}]"
    ;;
  hypothesis)
    TARGET="${MEMORY_DIR}/hypotheses.md"
    SECTION="Current Theories"
    PREFIX="💡 [${TIMESTAMP}]"
    ;;
  blocker)
    TARGET="${MEMORY_DIR}/blockers.md"
    SECTION="Open Questions"
    PREFIX="⚠️  [${TIMESTAMP}]"
    ;;
  outcome)
    TARGET="${MEMORY_DIR}/session-state.md"
    SECTION="Outcomes"
    PREFIX="✅ [${TIMESTAMP}]"
    # Create Outcomes section if it doesn't exist
    if ! grep -q "## Outcomes" "${TARGET}"; then
      echo "" >> "${TARGET}"
      echo "## Outcomes" >> "${TARGET}"
      echo "" >> "${TARGET}"
      echo "*Track results of decisions made this session*" >> "${TARGET}"
      echo "" >> "${TARGET}"
    fi
    ;;
  *)
    TARGET="${MEMORY_DIR}/session-state.md"
    SECTION="Progress Notes"
    PREFIX="📝 [${TIMESTAMP}]"
    ;;
esac

# Find the section and append note after it
if grep -q "## ${SECTION}" "${TARGET}"; then
  # Insert after the section header, before the next section or end marker
  awk -v section="## ${SECTION}" -v note="${PREFIX} ${NOTE}" '
    /^## / { if (found && !inserted) { print note; inserted=1 } found=0 }
    { print }
    $0 ~ section { found=1; print note; inserted=1 }
  ' "${TARGET}" > "${TARGET}.tmp" && mv "${TARGET}.tmp" "${TARGET}"

  echo "✅ Noted in $(basename ${TARGET})"

  # Update session-tasks.json knowledge counts if it exists
  TASKS_FILE="${MEMORY_DIR}/session-tasks.json"
  if [ -f "${TASKS_FILE}" ]; then
    case $TYPE in
      decision)
        jq '.knowledge.decisions += 1' "${TASKS_FILE}" > "${TASKS_FILE}.tmp" && mv "${TASKS_FILE}.tmp" "${TASKS_FILE}"
        ;;
      hypothesis)
        jq '.knowledge.hypotheses += 1' "${TASKS_FILE}" > "${TASKS_FILE}.tmp" && mv "${TASKS_FILE}.tmp" "${TASKS_FILE}"
        ;;
      blocker)
        jq '.knowledge.blockers += 1' "${TASKS_FILE}" > "${TASKS_FILE}.tmp" && mv "${TASKS_FILE}.tmp" "${TASKS_FILE}"
        ;;
      outcome)
        jq '.knowledge.outcomes += 1' "${TASKS_FILE}" > "${TASKS_FILE}.tmp" && mv "${TASKS_FILE}.tmp" "${TASKS_FILE}"
        ;;
    esac
  fi
else
  echo "❌ Section '${SECTION}' not found in ${TARGET}"
  exit 1
fi
