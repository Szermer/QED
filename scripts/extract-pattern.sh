#!/bin/bash
# Extract reusable patterns from finalization packs

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED_PATTERNS_DIR="${HOME}/Dev/.shared-patterns"
PATTERNS_DIR="${SHARED_PATTERNS_DIR}/patterns"
INDEX_FILE="${SHARED_PATTERNS_DIR}/index.json"
ARTIFACTS_DIR=".agent-artifacts"
PROJECT_NAME=$(basename "$(pwd)")

# Parse arguments
SESSION_DATE="$1"
PATTERN_NAME="$2"

if [ -z "${SESSION_DATE}" ] || [ -z "${PATTERN_NAME}" ]; then
  echo "Usage: extract-pattern.sh <session-date> <pattern-name>"
  echo ""
  echo "Examples:"
  echo "  ./scripts/extract-pattern.sh 2025-10-03 \"anti-hallucination-guardrails\""
  echo "  ./scripts/extract-pattern.sh 2025-10-05 \"multi-tenant-rls\""
  echo ""
  echo "Available sessions:"
  ls -1 "${ARTIFACTS_DIR}" 2>/dev/null | sed 's/^/  - /'
  exit 1
fi

FINALIZATION_PACK="${ARTIFACTS_DIR}/${SESSION_DATE}/finalization-pack.json"
SESSION_SUMMARY="${ARTIFACTS_DIR}/${SESSION_DATE}/session-summary.md"

if [ ! -f "${FINALIZATION_PACK}" ]; then
  echo "❌ Error: Finalization pack not found: ${FINALIZATION_PACK}"
  exit 1
fi

echo "📦 Extracting pattern from ${PROJECT_NAME} session ${SESSION_DATE}..."
echo "   Pattern name: ${PATTERN_NAME}"
echo ""

# Generate pattern ID (category will be determined interactively)
echo "📂 Select category:"
echo "  1) database"
echo "  2) security"
echo "  3) ui"
echo "  4) backend"
echo "  5) testing"
echo "  6) architecture"
read -p "Enter number (1-6): " CATEGORY_NUM

# Map number to category
case "${CATEGORY_NUM}" in
  1) CATEGORY="database" ;;
  2) CATEGORY="security" ;;
  3) CATEGORY="ui" ;;
  4) CATEGORY="backend" ;;
  5) CATEGORY="testing" ;;
  6) CATEGORY="architecture" ;;
  *)
    echo "❌ Invalid selection. Must be 1-6"
    exit 1
    ;;
esac

echo "   Selected: ${CATEGORY}"
echo ""

# Get next pattern number for this category
PATTERN_COUNT=$(jq -r --arg cat "${CATEGORY}" '[.patterns[] | select(.category == $cat)] | length' "${INDEX_FILE}")
PATTERN_NUM=$(printf "%03d" $((PATTERN_COUNT + 1)))
PATTERN_ID="${CATEGORY}-${PATTERN_NUM}"

echo "🎚️  Select complexity:"
echo "  1) low"
echo "  2) medium"
echo "  3) high"
read -p "Enter number (1-3): " COMPLEXITY_NUM

# Map number to complexity
case "${COMPLEXITY_NUM}" in
  1) COMPLEXITY="low" ;;
  2) COMPLEXITY="medium" ;;
  3) COMPLEXITY="high" ;;
  *)
    echo "❌ Invalid selection. Must be 1-3"
    exit 1
    ;;
esac

echo "   Selected: ${COMPLEXITY}"
echo ""

# Extract key information from finalization pack (with null safety)
SUMMARY=$(jq -r '.handoff.context_pack_summary // .focus // .summary // "No summary available"' "${FINALIZATION_PACK}")
RISKS=$(jq -r 'if .risks then (.risks[] | "- **\(.item)**: \(.mitigation)") else "No specific risks documented" end' "${FINALIZATION_PACK}")
MIGRATIONS=$(jq -r 'if .artifacts.db_plans then (.artifacts.db_plans[] | "### \(.migration)\n\(.notes // "No notes")\n") else "No migrations documented" end' "${FINALIZATION_PACK}")
# Parse commit strings (format: "sha - message")
COMMIT_SHAS=$(jq -r '.commits[]?' "${FINALIZATION_PACK}" | sed 's/ -.*//' | head -3 | tr '\n' ', ' | sed 's/,$//')

# Extract changed files from finalization pack for symbol enrichment
# Try multiple sources: files_changed, then commits, then artifacts
CHANGED_FILES=$(jq -r '.files_changed[]? // empty' "${FINALIZATION_PACK}" 2>/dev/null | head -10)

# If no files_changed, try to extract from artifacts.code_artifacts or ask user
if [ -z "${CHANGED_FILES}" ]; then
  CODE_ARTIFACTS=$(jq -r '.artifacts.code_artifacts[]?.file // empty' "${FINALIZATION_PACK}" 2>/dev/null | head -10)
  if [ -n "${CODE_ARTIFACTS}" ]; then
    CHANGED_FILES="${CODE_ARTIFACTS}"
  fi
fi

# Try kit symbol enrichment (graceful degradation if kit unavailable)
SYMBOL_METADATA=""
KIT_ENRICH_SCRIPT="${SCRIPT_DIR}/kit-enrich-pattern.sh"
if [ -x "${KIT_ENRICH_SCRIPT}" ] && [ -n "${CHANGED_FILES}" ]; then
  echo "🔬 Enriching pattern with kit symbol extraction..."
  # shellcheck disable=SC2086
  SYMBOL_JSON=$("${KIT_ENRICH_SCRIPT}" ${CHANGED_FILES} 2>/dev/null || echo '{"error": "kit unavailable"}')

  if echo "${SYMBOL_JSON}" | jq -e '.symbols | length > 0' > /dev/null 2>&1; then
    SYMBOL_COUNT=$(echo "${SYMBOL_JSON}" | jq -r '.summary.total_symbols')
    SYMBOL_TYPES=$(echo "${SYMBOL_JSON}" | jq -r '.summary.by_type | to_entries | map("\(.key): \(.value)") | join(", ")')
    SYMBOL_METADATA="
### Symbol Analysis (via kit)

**Total Symbols:** ${SYMBOL_COUNT}
**Types:** ${SYMBOL_TYPES}

<details>
<summary>Symbol Details</summary>

\`\`\`json
$(echo "${SYMBOL_JSON}" | jq '.symbols')
\`\`\`

</details>
"
    echo "   ✅ Found ${SYMBOL_COUNT} symbols"
  else
    echo "   ⚠️  No symbols extracted (kit may not support these file types)"
  fi
else
  echo "   ℹ️  Skipping kit enrichment (no changed files or kit unavailable)"
fi

# Generate pattern file
PATTERN_FILE="${PATTERNS_DIR}/${PATTERN_ID}-${PATTERN_NAME}.md"

cat > "${PATTERN_FILE}" <<EOF
# Pattern: ${PATTERN_NAME}

**ID:** \`${PATTERN_ID}\`
**Category:** ${CATEGORY}
**Complexity:** ${COMPLEXITY}
**Source Project:** ${PROJECT_NAME}
**Source Session:** ${SESSION_DATE}
**Reuse Count:** 0
**Effectiveness Score:** 1.0 (initial)
**Last Updated:** $(date +%Y-%m-%d)

---

## 📋 Context

### When to Use This Pattern

${SUMMARY}

### When NOT to Use This Pattern

*To be filled based on learnings from reuse attempts*

---

## 🎯 Pattern Overview

This pattern was extracted from a successful implementation during the ${SESSION_DATE} session.

### Key Components

$(jq -r 'if .artifacts.db_plans then (.artifacts.db_plans[] | "- Migration: \(.migration)") else "- No migrations" end' "${FINALIZATION_PACK}")
$(jq -r '.commits[]?' "${FINALIZATION_PACK}" | sed 's/^/- Commit: /')
${SYMBOL_METADATA}

---

## 🛠️ Implementation Guide

### Overview

Refer to the original implementation for detailed code examples:
- Finalization pack: \`.agent-artifacts/${SESSION_DATE}/finalization-pack.json\`
- Session summary: \`.agent-artifacts/${SESSION_DATE}/session-summary.md\`
- Commits: ${COMMIT_SHAS}

### Migrations

${MIGRATIONS}

---

## 📦 Required Components

*Extract specific requirements from the finalization pack*

- [ ] Review \`${FINALIZATION_PACK}\` for complete component list
- [ ] Check \`artifacts.db_plans\` for database changes
- [ ] Review \`commits\` for code changes

---

## ⚠️ Risks & Mitigations

${RISKS}

---

## ✅ Verification Checklist

- [ ] All migrations apply successfully
- [ ] RLS policies are tested
- [ ] Security review completed
- [ ] Performance impact measured
- [ ] Tests pass

---

## 📊 Performance Considerations

*To be filled based on monitoring data*

- **Token cost:** TBD
- **Runtime impact:** TBD
- **Scale limits:** TBD

---

## 🔗 Related Patterns

*To be filled as related patterns are discovered*

---

## 📚 References

- Finalization pack: \`.agent-artifacts/${SESSION_DATE}/finalization-pack.json\`
- Session summary: \`.agent-artifacts/${SESSION_DATE}/session-summary.md\`
- Project: ${PROJECT_NAME}

---

## 🔄 Version History

| Version | Date | Changes | Source |
|---------|------|---------|--------|
| 1.0 | $(date +%Y-%m-%d) | Initial extraction from ${SESSION_DATE} session | ${PROJECT_NAME} |

---

## 💡 Lessons Learned

*To be filled after pattern has been reused at least once*

1. (Awaiting first reuse)
2. (Awaiting feedback)
3. (Awaiting iteration)

---

**Pattern Effectiveness Score:** 1.0 (0 implementations, 0 bugs, 0 reuses)

*Score will be updated after each reuse*
EOF

echo "✅ Pattern extracted: ${PATTERN_FILE}"
echo ""

# Update pattern index
TEMP_FILE=$(mktemp)
jq --arg id "${PATTERN_ID}" \
   --arg name "${PATTERN_NAME}" \
   --arg category "${CATEGORY}" \
   --arg complexity "${COMPLEXITY}" \
   --arg project "${PROJECT_NAME}" \
   --arg session "${SESSION_DATE}" \
   --arg file "${PATTERN_ID}-${PATTERN_NAME}.md" \
   '
  .last_updated = (now | strftime("%Y-%m-%dT%H:%M:%SZ")) |
  .total_patterns += 1 |
  .patterns += [{
    id: $id,
    name: $name,
    category: $category,
    complexity: $complexity,
    source_projects: [$project],
    source_session: $session,
    reuse_count: 0,
    effectiveness_score: 1.0,
    last_updated: (now | strftime("%Y-%m-%d")),
    file: $file,
    related_patterns: []
  }]
' "${INDEX_FILE}" > "${TEMP_FILE}" && mv "${TEMP_FILE}" "${INDEX_FILE}"

echo "✅ Pattern indexed in ${INDEX_FILE}"
echo ""
echo "📖 View pattern:"
echo "   cat ${PATTERN_FILE}"
echo ""
echo "🔍 Search for this pattern:"
echo "   ./scripts/search-artifacts.sh --global \"${PATTERN_NAME}\""
