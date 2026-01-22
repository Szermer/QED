#!/bin/bash
# Display context engineering metrics dashboard

set -e

METRICS_DIR="${HOME}/Dev/.shared-patterns/metrics"
COMPACTION_FILE="${METRICS_DIR}/compaction-effectiveness.json"
SESSION_STATS_FILE="${METRICS_DIR}/session-statistics.json"
PATTERNS_INDEX="${HOME}/Dev/.shared-patterns/index.json"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║      📊 CONTEXT ENGINEERING METRICS DASHBOARD             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Check if metrics exist
if [ ! -f "${COMPACTION_FILE}" ]; then
  echo "⚠️  No metrics collected yet. Run ./scripts/collect-metrics.sh after finalization."
  exit 1
fi

# ========== PACK SIZE & COMPRESSION ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 FINALIZATION PACK METRICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL_SESSIONS=$(jq -r '.aggregate_stats.total_sessions' "${COMPACTION_FILE}")
AVG_PACK_SIZE=$(jq -r '.aggregate_stats.avg_pack_size // "N/A"' "${COMPACTION_FILE}")
SESSIONS_UNDER_TARGET=$(jq -r '.aggregate_stats.sessions_under_target // 0' "${COMPACTION_FILE}")
VALID_COMPRESSION_SESSIONS=$(jq -r '.aggregate_stats.valid_compression_sessions // 0' "${COMPACTION_FILE}")
AVG_COMPRESSION=$(jq -r '.aggregate_stats.avg_compression_ratio // "N/A"' "${COMPACTION_FILE}")

echo "  Total Sessions:           ${TOTAL_SESSIONS}"
echo ""
echo "  📦 Pack Size (primary metric):"
echo "     Average:               ${AVG_PACK_SIZE} tokens (target: <2000)"
echo "     Sessions under target: ${SESSIONS_UNDER_TARGET}/${TOTAL_SESSIONS}"

# Pack size indicator
if [ "${AVG_PACK_SIZE}" != "null" ] && [ "${AVG_PACK_SIZE}" != "N/A" ]; then
  if [ "${AVG_PACK_SIZE}" -le 2000 ]; then
    echo "     ✅ Pack size UNDER target"
  else
    echo "     ⚠️  Pack size above target"
  fi
fi

echo ""
echo "  📉 Compression Ratio (requires memory ≥2000 tokens):"
echo "     Valid sessions:        ${VALID_COMPRESSION_SESSIONS}/${TOTAL_SESSIONS}"
if [ "${AVG_COMPRESSION}" != "null" ] && [ "${AVG_COMPRESSION}" != "N/A" ]; then
  echo "     Average:               ${AVG_COMPRESSION}% (target: 70%+)"
  # Compression ratio indicator
  if [ $(echo "${AVG_COMPRESSION} >= 70" | bc -l) -eq 1 ]; then
    echo "     ✅ Compression EXCEEDS target"
  elif [ $(echo "${AVG_COMPRESSION} >= 50" | bc -l) -eq 1 ]; then
    echo "     ⚠️  Compression approaching target"
  else
    echo "     ❌ Compression below target"
  fi
else
  echo "     Average:               N/A (no sessions with ≥2000 token memory)"
  echo "     ℹ️  Take more session notes to enable compression tracking"
fi

echo ""

# Recent sessions
echo "  📋 Recent Sessions:"
jq -r '.sessions[-5:] | reverse[] |
  "     \(.date) [\(.project)]: pack=\(.pack_size // .tokens_after) tokens" +
  (if .compression_ratio != null then ", \(.compression_ratio)% compression" else "" end)' "${COMPACTION_FILE}"

echo ""

# ========== SESSION STATISTICS ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📈 SESSION STATISTICS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# PrivateLanguage stats
PL_SESSIONS=$(jq -r '.projects.PrivateLanguage.total_sessions' "${SESSION_STATS_FILE}")
PL_COMMITS=$(jq -r '.projects.PrivateLanguage.total_commits' "${SESSION_STATS_FILE}")
PL_MIGRATIONS=$(jq -r '.projects.PrivateLanguage.total_migrations' "${SESSION_STATS_FILE}")
PL_AVG_DURATION=$(jq -r '.projects.PrivateLanguage.avg_session_duration' "${SESSION_STATS_FILE}")

echo "  PrivateLanguage:"
echo "    Sessions:               ${PL_SESSIONS}"
echo "    Total Commits:          ${PL_COMMITS}"
echo "    Total Migrations:       ${PL_MIGRATIONS}"
echo "    Avg Session Duration:   $(printf "%.1f" ${PL_AVG_DURATION})h"
echo ""

# Mermaid stats
MM_SESSIONS=$(jq -r '.projects.Mermaid.total_sessions' "${SESSION_STATS_FILE}")
MM_COMMITS=$(jq -r '.projects.Mermaid.total_commits' "${SESSION_STATS_FILE}")
MM_MIGRATIONS=$(jq -r '.projects.Mermaid.total_migrations' "${SESSION_STATS_FILE}")
MM_AVG_DURATION=$(jq -r '.projects.Mermaid.avg_session_duration' "${SESSION_STATS_FILE}")

echo "  Mermaid:"
echo "    Sessions:               ${MM_SESSIONS}"
echo "    Total Commits:          ${MM_COMMITS}"
echo "    Total Migrations:       ${MM_MIGRATIONS}"
echo "    Avg Session Duration:   $(printf "%.1f" ${MM_AVG_DURATION})h"
echo ""

# ========== PATTERN LIBRARY ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  📚 PATTERN LIBRARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

TOTAL_PATTERNS=$(jq -r '.total_patterns' "${PATTERNS_INDEX}")
TOTAL_REUSES=$(jq -r '[.patterns[].reuse_count] | add // 0' "${PATTERNS_INDEX}")

# Calculate reuse rate
if [ "${TOTAL_SESSIONS}" -gt 0 ]; then
  REUSE_RATE=$(echo "scale=2; (${TOTAL_REUSES} / ${TOTAL_SESSIONS}) * 100" | bc)
else
  REUSE_RATE="0"
fi

echo "  Total Patterns:           ${TOTAL_PATTERNS}"
echo "  Total Reuses:             ${TOTAL_REUSES}"
echo "  Pattern Reuse Rate:       ${REUSE_RATE}% (target: 40%+)"
echo ""

# Pattern reuse indicator
if [ $(echo "${REUSE_RATE} >= 40" | bc -l) -eq 1 ]; then
  echo "  ✅ Reuse rate EXCEEDS target"
elif [ $(echo "${REUSE_RATE} >= 30" | bc -l) -eq 1 ]; then
  echo "  ⚠️  Reuse rate approaching target"
else
  echo "  ❌ Reuse rate below target"
fi

echo ""

# Pattern breakdown by category
echo "  📂 Patterns by Category:"
jq -r '
  [.patterns[] | .category] |
  group_by(.) |
  map({category: .[0], count: length}) |
  sort_by(.count) |
  reverse[] |
  "     \(.category): \(.count)"
' "${PATTERNS_INDEX}"

echo ""

# Most reused patterns
echo "  🔥 Most Reused Patterns:"
jq -r '
  [.patterns[] | select(.reuse_count > 0)] |
  sort_by(.reuse_count) |
  reverse |
  .[:5][] |
  "     \(.id) - \(.name): \(.reuse_count) reuses"
' "${PATTERNS_INDEX}"

if [ "${TOTAL_REUSES}" -eq 0 ]; then
  echo "     (No patterns reused yet)"
fi

echo ""

# ========== CROSS-PROJECT INTELLIGENCE ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🔗 CROSS-PROJECT INTELLIGENCE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SHARED_PATTERNS=$(jq -r '[.patterns[] | select(.source_projects | length > 1)] | length' "${PATTERNS_INDEX}")
CROSS_DISCOVERIES=$(jq -r '.cross_project_stats.cross_project_discoveries // 0' "${SESSION_STATS_FILE}")
TOTAL_PATTERNS_DETECTED=$(jq -r '.cross_project_stats.total_patterns_detected // 0' "${SESSION_STATS_FILE}")

echo "  Shared Patterns:          ${SHARED_PATTERNS} (used in multiple projects)"
echo "  Patterns Detected:        ${TOTAL_PATTERNS_DETECTED} (across all sessions)"
echo "  Cross-Project Discoveries: ${CROSS_DISCOVERIES}"
echo ""

# Calculate cross-project discovery rate (% of detected patterns from other projects)
if [ "${TOTAL_PATTERNS_DETECTED}" -gt 0 ]; then
  DISCOVERY_RATE=$(echo "scale=2; (${CROSS_DISCOVERIES} / ${TOTAL_PATTERNS_DETECTED}) * 100" | bc)
else
  DISCOVERY_RATE="0"
fi

echo "  Discovery Rate:           ${DISCOVERY_RATE}% (target: 10%+)"
echo "  (% of detected patterns from other projects)"
echo ""

# Discovery rate indicator
if [ $(echo "${DISCOVERY_RATE} >= 10" | bc -l) -eq 1 ]; then
  echo "  ✅ Discovery rate EXCEEDS target"
elif [ $(echo "${DISCOVERY_RATE} >= 5" | bc -l) -eq 1 ]; then
  echo "  ⚠️  Discovery rate approaching target"
else
  echo "  ❌ Discovery rate below target"
fi

echo ""

# ========== SUMMARY ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎯 KEY METRICS SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

printf "  | %-30s | %-12s | %-12s |\n" "Metric" "Current" "Target"
echo "  |--------------------------------|--------------|--------------|"
printf "  | %-30s | %-12s | %-12s |\n" "Avg Pack Size" "${AVG_PACK_SIZE}" "<2000"
printf "  | %-30s | %-12s | %-12s |\n" "Pattern Reuse Rate" "${REUSE_RATE}%" "40%+"
printf "  | %-30s | %-12s | %-12s |\n" "Cross-Project Discovery" "${DISCOVERY_RATE}%" "10%+"

# Show compression only if there are valid sessions
if [ "${VALID_COMPRESSION_SESSIONS}" -gt 0 ]; then
  printf "  | %-30s | %-12s | %-12s |\n" "Compression (${VALID_COMPRESSION_SESSIONS} sessions)" "${AVG_COMPRESSION}%" "70%+"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 Tips:"
echo "   - Extract patterns: ./scripts/extract-pattern.sh <date> <name>"
echo "   - Search patterns: ./scripts/search-artifacts.sh --global <keyword>"
echo "   - Collect metrics: ./scripts/collect-metrics.sh (after /finalize)"
echo "   - Pattern effectiveness: ./scripts/pattern-effectiveness.sh (ADR-022)"
echo "   - Simplification audit: ./scripts/simplification-audit.sh (ADR-025)"
echo ""
