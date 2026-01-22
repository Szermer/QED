#!/bin/bash
# Collect context engineering metrics during finalization
#
# METRICS EXPLAINED:
# - pack_size: Finalization pack token count (target: <2000 tokens)
# - compression_ratio: Only meaningful when session memory >= 2000 tokens
#   (Sparse notes produce negative ratios - this is expected)

set -e

# Determine project name from current directory
PROJECT_NAME=$(basename "$(pwd)")
METRICS_DIR="${HOME}/Dev/.shared-patterns/metrics"
COMPACTION_FILE="${METRICS_DIR}/compaction-effectiveness.json"
SESSION_STATS_FILE="${METRICS_DIR}/session-statistics.json"
MEMORY_DIR=".agent-memory"
ARTIFACTS_DIR=".agent-artifacts"

# Minimum session memory for meaningful compression ratio
MIN_TOKENS_FOR_COMPRESSION=2000

# Get session date (latest artifact directory - directories only, not files)
SESSION_DATE=$(find "${ARTIFACTS_DIR}/" -maxdepth 1 -type d -name "20*" 2>/dev/null | sort -r | head -1 | xargs basename 2>/dev/null)

if [ -z "${SESSION_DATE}" ]; then
  echo "⚠️  No finalization pack found. Run /finalize first."
  exit 1
fi

FINALIZATION_PACK="${ARTIFACTS_DIR}/${SESSION_DATE}/finalization-pack.json"

if [ ! -f "${FINALIZATION_PACK}" ]; then
  echo "⚠️  Finalization pack not found: ${FINALIZATION_PACK}"
  exit 1
fi

echo "📊 Collecting metrics for ${PROJECT_NAME} session ${SESSION_DATE}..."
echo ""

# Calculate token counts (rough approximation: 4 chars = 1 token)
calculate_tokens() {
  local file="$1"
  if [ -f "${file}" ]; then
    wc -c < "${file}" | awk '{print int($1/4)}'
  else
    echo "0"
  fi
}

# Count tokens in memory files (before finalization)
# First try current memory, then archived memory in finalization pack
TOKENS_BEFORE=0
ARCHIVED_MEMORY="${ARTIFACTS_DIR}/${SESSION_DATE}/session-memory"

if [ -d "${MEMORY_DIR}" ]; then
  for memory_file in "${MEMORY_DIR}"/*.md; do
    if [ -f "${memory_file}" ]; then
      tokens=$(calculate_tokens "${memory_file}")
      TOKENS_BEFORE=$((TOKENS_BEFORE + tokens))
    fi
  done
fi

# If no current memory, use archived memory from finalization
if [ "${TOKENS_BEFORE}" -eq 0 ] && [ -d "${ARCHIVED_MEMORY}" ]; then
  for memory_file in "${ARCHIVED_MEMORY}"/*.md; do
    if [ -f "${memory_file}" ]; then
      tokens=$(calculate_tokens "${memory_file}")
      TOKENS_BEFORE=$((TOKENS_BEFORE + tokens))
    fi
  done
fi

# Count tokens in finalization pack (after finalization) - this is PACK SIZE
PACK_SIZE=$(calculate_tokens "${FINALIZATION_PACK}")

# Evaluate pack size against target
PACK_SIZE_STATUS="✅"
if [ "${PACK_SIZE}" -gt 2000 ]; then
  PACK_SIZE_STATUS="⚠️  (above 2000 target)"
fi

# Calculate compression ratio ONLY if session memory is substantial
# Sparse notes (< 2000 tokens) produce meaningless negative ratios
COMPRESSION_RATIO_DISPLAY="N/A (memory < ${MIN_TOKENS_FOR_COMPRESSION})"
COMPRESSION_RATIO_JSON="null"
COMPRESSION_NOTE=""

if [ "${TOKENS_BEFORE}" -ge "${MIN_TOKENS_FOR_COMPRESSION}" ]; then
  COMPRESSION_RATIO=$(echo "scale=2; (1 - ${PACK_SIZE}/${TOKENS_BEFORE}) * 100" | bc)
  COMPRESSION_RATIO_DISPLAY="${COMPRESSION_RATIO}%"
  COMPRESSION_RATIO_JSON="${COMPRESSION_RATIO}"

  # Evaluate compression
  COMP_INT=${COMPRESSION_RATIO%.*}
  if [ "${COMP_INT}" -ge 70 ]; then
    COMPRESSION_NOTE=" ✅ (target: 70%+)"
  elif [ "${COMP_INT}" -ge 50 ]; then
    COMPRESSION_NOTE=" ⚠️  (target: 70%+)"
  else
    COMPRESSION_NOTE=" ❌ (target: 70%+)"
  fi
else
  COMPRESSION_NOTE=""
  # For sparse sessions, track pack size as primary metric
  echo "   ℹ️  Session memory sparse (${TOKENS_BEFORE} tokens)"
  echo "   ℹ️  Using pack_size as primary metric instead of compression"
  echo ""
fi

# Extract session metadata from finalization pack
COMMIT_COUNT=$(jq -r '.metrics.commits // .commits // [] | if type == "array" then length else . end' "${FINALIZATION_PACK}" 2>/dev/null || echo "0")
MIGRATION_COUNT=$(jq -r '.artifacts.db_plans // [] | length' "${FINALIZATION_PACK}" 2>/dev/null || echo "0")
DURATION_HOURS=$(jq -r '.handoff.time_used_s // 0 | . / 3600' "${FINALIZATION_PACK}" 2>/dev/null || echo "0")

echo "📈 Session Metrics:"
echo "   Session memory tokens:      ${TOKENS_BEFORE}"
echo "   Pack size (target <2000):   ${PACK_SIZE} ${PACK_SIZE_STATUS}"
echo "   Compression ratio:          ${COMPRESSION_RATIO_DISPLAY}${COMPRESSION_NOTE}"
echo "   Commits:                    ${COMMIT_COUNT}"
echo "   Migrations:                 ${MIGRATION_COUNT}"
echo "   Duration:                   ${DURATION_HOURS}h"
echo ""

# Update compaction effectiveness metrics
TEMP_FILE=$(mktemp)
jq --arg date "${SESSION_DATE}" \
   --arg project "${PROJECT_NAME}" \
   --argjson tokens_before "${TOKENS_BEFORE}" \
   --argjson pack_size "${PACK_SIZE}" \
   --argjson compression "${COMPRESSION_RATIO_JSON}" \
   --argjson duration "${DURATION_HOURS}" \
   --argjson min_tokens "${MIN_TOKENS_FOR_COMPRESSION}" \
   '
  .last_updated = (now | strftime("%Y-%m-%dT%H:%M:%SZ")) |
  .sessions += [{
    date: $date,
    project: $project,
    session_memory_tokens: $tokens_before,
    pack_size: $pack_size,
    compression_ratio: $compression,
    duration_hours: $duration
  }] |
  .aggregate_stats.total_sessions = (.sessions | length) |
  # Only average compression for sessions with sufficient memory (>= 2000 tokens)
  .aggregate_stats.avg_compression_ratio = (
    [.sessions[] | select(.session_memory_tokens >= $min_tokens and .compression_ratio != null) | .compression_ratio] |
    if length > 0 then (add / length | floor) else null end
  ) |
  .aggregate_stats.valid_compression_sessions = (
    [.sessions[] | select(.session_memory_tokens >= $min_tokens and .compression_ratio != null)] | length
  ) |
  # Pack size is always valid - track average
  .aggregate_stats.avg_pack_size = (
    [.sessions[].pack_size // .sessions[].tokens_after] |
    map(select(. != null)) |
    if length > 0 then (add / length | floor) else null end
  ) |
  .aggregate_stats.pack_size_target = 2000 |
  .aggregate_stats.sessions_under_target = (
    [.sessions[] | select((.pack_size // .tokens_after) <= 2000)] | length
  )
' "${COMPACTION_FILE}" > "${TEMP_FILE}" && mv "${TEMP_FILE}" "${COMPACTION_FILE}"

# Update session statistics
TEMP_FILE=$(mktemp)
jq --arg project "${PROJECT_NAME}" \
   --argjson commits "${COMMIT_COUNT}" \
   --argjson migrations "${MIGRATION_COUNT}" \
   --argjson duration "${DURATION_HOURS}" \
   '
  .last_updated = (now | strftime("%Y-%m-%dT%H:%M:%SZ")) |
  .projects[$project].total_sessions += 1 |
  .projects[$project].total_commits += $commits |
  .projects[$project].total_migrations += $migrations |
  .projects[$project].total_duration_hours += $duration |
  .projects[$project].avg_session_duration = (
    .projects[$project].total_duration_hours / .projects[$project].total_sessions
  )
' "${SESSION_STATS_FILE}" > "${TEMP_FILE}" && mv "${TEMP_FILE}" "${SESSION_STATS_FILE}"

# Run pattern detection and track cross-project discoveries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATTERN_DETECTION_OUTPUT=$("${SCRIPT_DIR}/detect-pattern-usage.sh" "${ARTIFACTS_DIR}/${SESSION_DATE}" json 2>/dev/null || echo '{"cross_project_discoveries": 0}')

CROSS_PROJECT_COUNT=$(echo "${PATTERN_DETECTION_OUTPUT}" | jq -r '.cross_project_discoveries // 0')
TOTAL_PATTERNS_DETECTED=$(echo "${PATTERN_DETECTION_OUTPUT}" | jq -r '.total_detected // 0')

if [ "${TOTAL_PATTERNS_DETECTED}" -gt 0 ]; then
  echo "🔍 Pattern Detection:"
  echo "   Patterns detected:          ${TOTAL_PATTERNS_DETECTED}"
  echo "   Cross-project discoveries:  ${CROSS_PROJECT_COUNT}"
  echo ""
fi

# Update cross-project discovery stats in session statistics
TEMP_FILE=$(mktemp)
jq --argjson cross_discoveries "${CROSS_PROJECT_COUNT}" \
   --argjson patterns_detected "${TOTAL_PATTERNS_DETECTED}" \
   '
  .cross_project_stats.cross_project_discoveries += $cross_discoveries |
  .cross_project_stats.total_patterns_detected += $patterns_detected |
  .cross_project_stats.last_updated = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
' "${SESSION_STATS_FILE}" > "${TEMP_FILE}" && mv "${TEMP_FILE}" "${SESSION_STATS_FILE}"

echo "✅ Metrics collected and stored in ${METRICS_DIR}"
echo ""
echo "💡 View metrics dashboard:"
echo "   ./scripts/metrics-dashboard.sh"
