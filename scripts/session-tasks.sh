#!/bin/bash
# Session Tasks - JSON-based task tracking for development sessions
#
# Usage:
#   session-tasks.sh add "Task title"           # Add new task (status: pending)
#   session-tasks.sh start <id>                 # Mark task as in_progress
#   session-tasks.sh complete <id>              # Mark task as completed
#   session-tasks.sh block <id> "reason"        # Mark task as blocked
#   session-tasks.sh list                       # List all tasks
#   session-tasks.sh status                     # Show summary status
#   session-tasks.sh init                       # Initialize empty tasks file

set -e

MEMORY_DIR=".agent-memory"
TASKS_FILE="${MEMORY_DIR}/session-tasks.json"

# Initialize tasks file if it doesn't exist
init_tasks() {
  if [ ! -d "${MEMORY_DIR}" ]; then
    echo "❌ Session memory not initialized. Run: ./scripts/memory-init.sh"
    exit 1
  fi

  if [ ! -f "${TASKS_FILE}" ]; then
    cat > "${TASKS_FILE}" << 'EOF'
{
  "version": "1.0",
  "created": "",
  "tasks": [],
  "knowledge": {
    "decisions": 0,
    "hypotheses": 0,
    "blockers": 0
  }
}
EOF
    # Set creation timestamp
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s/\"created\": \"\"/\"created\": \"${timestamp}\"/" "${TASKS_FILE}"
    else
      sed -i "s/\"created\": \"\"/\"created\": \"${timestamp}\"/" "${TASKS_FILE}"
    fi
    echo "✅ Session tasks initialized: ${TASKS_FILE}"
  else
    echo "ℹ️  Tasks file already exists: ${TASKS_FILE}"
  fi
}

# Generate next task ID
next_id() {
  local max_id
  max_id=$(jq -r '[.tasks[].id // 0] | max // 0' "${TASKS_FILE}" 2>/dev/null)
  echo $((max_id + 1))
}

# Add a new task
add_task() {
  local title="$1"
  if [ -z "$title" ]; then
    echo "❌ Usage: session-tasks.sh add \"Task title\""
    exit 1
  fi

  # Ensure tasks file exists
  if [ ! -f "${TASKS_FILE}" ]; then
    init_tasks
  fi

  local id
  id=$(next_id)
  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Add task using jq
  local tmp_file="${TASKS_FILE}.tmp"
  jq --arg title "$title" --arg ts "$timestamp" --argjson id "$id" \
    '.tasks += [{
      "id": $id,
      "title": $title,
      "status": "pending",
      "created": $ts,
      "updated": $ts
    }]' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"

  echo "✅ Added task #${id}: ${title}"
}

# Update task status
update_status() {
  local id="$1"
  local new_status="$2"
  local reason="$3"

  if [ -z "$id" ] || [ -z "$new_status" ]; then
    echo "❌ Usage: session-tasks.sh <start|complete|block> <id>"
    exit 1
  fi

  if [ ! -f "${TASKS_FILE}" ]; then
    echo "❌ No tasks file found. Run: session-tasks.sh init"
    exit 1
  fi

  # Check if task exists
  local exists
  exists=$(jq --argjson id "$id" '.tasks[] | select(.id == $id) | .id' "${TASKS_FILE}" 2>/dev/null)
  if [ -z "$exists" ]; then
    echo "❌ Task #${id} not found"
    exit 1
  fi

  local timestamp
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Update task
  local tmp_file="${TASKS_FILE}.tmp"
  if [ -n "$reason" ]; then
    jq --argjson id "$id" --arg status "$new_status" --arg ts "$timestamp" --arg reason "$reason" \
      '(.tasks[] | select(.id == $id)) |= . + {
        "status": $status,
        "updated": $ts,
        "blocked_reason": $reason
      }' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"
  else
    jq --argjson id "$id" --arg status "$new_status" --arg ts "$timestamp" \
      '(.tasks[] | select(.id == $id)) |= . + {
        "status": $status,
        "updated": $ts
      } | del(.tasks[] | select(.id == $id) | .blocked_reason)' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"
  fi

  local title
  title=$(jq -r --argjson id "$id" '.tasks[] | select(.id == $id) | .title' "${TASKS_FILE}")

  case "$new_status" in
    in_progress)
      echo "🔄 Started: #${id} - ${title}"
      ;;
    completed)
      echo "✅ Completed: #${id} - ${title}"
      ;;
    blocked)
      echo "🚫 Blocked: #${id} - ${title}"
      [ -n "$reason" ] && echo "   Reason: ${reason}"
      ;;
    pending)
      echo "⏳ Pending: #${id} - ${title}"
      ;;
  esac
}

# List all tasks
list_tasks() {
  if [ ! -f "${TASKS_FILE}" ]; then
    echo "ℹ️  No tasks file. Run: session-tasks.sh init"
    return
  fi

  echo "📋 Session Tasks"
  echo "════════════════════════════════════════"

  # In Progress
  local in_progress
  in_progress=$(jq -r '.tasks[] | select(.status == "in_progress") | "#\(.id) \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  if [ -n "$in_progress" ]; then
    echo ""
    echo "🔄 In Progress:"
    echo "$in_progress" | while read -r line; do echo "   $line"; done
  fi

  # Blocked
  local blocked
  blocked=$(jq -r '.tasks[] | select(.status == "blocked") | "#\(.id) \(.title)\(if .blocked_reason then " [" + .blocked_reason + "]" else "" end)"' "${TASKS_FILE}" 2>/dev/null)
  if [ -n "$blocked" ]; then
    echo ""
    echo "🚫 Blocked:"
    echo "$blocked" | while read -r line; do echo "   $line"; done
  fi

  # Pending
  local pending
  pending=$(jq -r '.tasks[] | select(.status == "pending") | "#\(.id) \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  if [ -n "$pending" ]; then
    echo ""
    echo "⏳ Pending:"
    echo "$pending" | while read -r line; do echo "   $line"; done
  fi

  # Completed
  local completed
  completed=$(jq -r '.tasks[] | select(.status == "completed") | "#\(.id) \(.title)"' "${TASKS_FILE}" 2>/dev/null)
  if [ -n "$completed" ]; then
    echo ""
    echo "✅ Completed:"
    echo "$completed" | while read -r line; do echo "   $line"; done
  fi

  echo ""
  echo "════════════════════════════════════════"
}

# Show status summary
show_status() {
  if [ ! -f "${TASKS_FILE}" ]; then
    echo "ℹ️  No tasks file. Run: session-tasks.sh init"
    return
  fi

  local total in_progress pending blocked completed
  total=$(jq -r '.tasks | length' "${TASKS_FILE}")
  in_progress=$(jq -r '[.tasks[] | select(.status == "in_progress")] | length' "${TASKS_FILE}")
  pending=$(jq -r '[.tasks[] | select(.status == "pending")] | length' "${TASKS_FILE}")
  blocked=$(jq -r '[.tasks[] | select(.status == "blocked")] | length' "${TASKS_FILE}")
  completed=$(jq -r '[.tasks[] | select(.status == "completed")] | length' "${TASKS_FILE}")

  local decisions hypotheses blockers
  decisions=$(jq -r '.knowledge.decisions // 0' "${TASKS_FILE}")
  hypotheses=$(jq -r '.knowledge.hypotheses // 0' "${TASKS_FILE}")
  blockers=$(jq -r '.knowledge.blockers // 0' "${TASKS_FILE}")

  echo "📊 Session Status"
  echo "════════════════════════════════════════"
  echo "Tasks: ${completed}/${total} completed"
  echo ""
  echo "  🔄 In Progress: ${in_progress}"
  echo "  ⏳ Pending:     ${pending}"
  echo "  🚫 Blocked:     ${blocked}"
  echo "  ✅ Completed:   ${completed}"
  echo ""
  echo "Knowledge Captured:"
  echo "  🎯 Decisions:   ${decisions}"
  echo "  💡 Hypotheses:  ${hypotheses}"
  echo "  🚧 Blockers:    ${blockers}"
  echo "════════════════════════════════════════"
}

# Increment knowledge count
increment_knowledge() {
  local type="$1"
  if [ ! -f "${TASKS_FILE}" ]; then
    return
  fi

  local tmp_file="${TASKS_FILE}.tmp"
  case "$type" in
    decision)
      jq '.knowledge.decisions += 1' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"
      ;;
    hypothesis)
      jq '.knowledge.hypotheses += 1' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"
      ;;
    blocker)
      jq '.knowledge.blockers += 1' "${TASKS_FILE}" > "$tmp_file" && mv "$tmp_file" "${TASKS_FILE}"
      ;;
  esac
}

# Main command dispatch
case "${1:-}" in
  init)
    init_tasks
    ;;
  add)
    shift
    add_task "$*"
    ;;
  start)
    update_status "$2" "in_progress"
    ;;
  complete|done)
    update_status "$2" "completed"
    ;;
  block)
    update_status "$2" "blocked" "$3"
    ;;
  unblock|resume)
    update_status "$2" "in_progress"
    ;;
  pending|reset)
    update_status "$2" "pending"
    ;;
  list|ls)
    list_tasks
    ;;
  status|stats)
    show_status
    ;;
  increment)
    increment_knowledge "$2"
    ;;
  *)
    echo "Session Tasks - JSON-based task tracking"
    echo ""
    echo "Usage:"
    echo "  session-tasks.sh init                    Initialize tasks file"
    echo "  session-tasks.sh add \"Task title\"        Add new task"
    echo "  session-tasks.sh start <id>              Mark as in_progress"
    echo "  session-tasks.sh complete <id>           Mark as completed"
    echo "  session-tasks.sh block <id> \"reason\"     Mark as blocked"
    echo "  session-tasks.sh unblock <id>            Resume blocked task"
    echo "  session-tasks.sh list                    List all tasks"
    echo "  session-tasks.sh status                  Show summary"
    echo ""
    echo "Examples:"
    echo "  session-tasks.sh add \"Implement user auth\""
    echo "  session-tasks.sh start 1"
    echo "  session-tasks.sh block 1 \"Waiting for API docs\""
    echo "  session-tasks.sh complete 1"
    ;;
esac
