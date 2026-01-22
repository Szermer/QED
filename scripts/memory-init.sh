#!/bin/bash
# Memory Init - Initialize session working memory

set -e

PROJECT_ROOT="${1:-.}"
cd "${PROJECT_ROOT}"

MEMORY_DIR=".agent-memory"
SESSION_STATE="${MEMORY_DIR}/session-state.md"
HYPOTHESES="${MEMORY_DIR}/hypotheses.md"
BLOCKERS="${MEMORY_DIR}/blockers.md"

echo "🧠 Initializing session memory..."

# Create memory directory if it doesn't exist
mkdir -p "${MEMORY_DIR}"

# Initialize session state
cat > "${SESSION_STATE}" << EOF
# Session State - $(date '+%Y-%m-%d %H:%M')

## Current Focus
<!-- What are you working on right now? -->

## Key Decisions This Session
<!-- Track important decisions made during this session -->

## Progress Notes
<!-- Quick updates as you work -->

---
*This file tracks ephemeral context for the current session*
*It will be harvested during finalization and then cleared*
EOF

# Initialize hypotheses
cat > "${HYPOTHESES}" << EOF
# Working Hypotheses - $(date '+%Y-%m-%d %H:%M')

## Current Theories
<!-- Approaches being explored, not yet validated -->

## Testing Next
<!-- What experiments or tests need to run? -->

## Observations
<!-- Interesting findings that don't yet fit a pattern -->

---
*Track exploratory work and emerging patterns*
*Validated patterns move to finalization, dead ends are noted*
EOF

# Initialize blockers
cat > "${BLOCKERS}" << EOF
# Session Blockers - $(date '+%Y-%m-%d %H:%M')

## Open Questions
<!-- What needs to be answered? -->

## Dependencies
<!-- Waiting on what/whom? -->

## Technical Challenges
<!-- Hard problems being worked through -->

---
*Track impediments and questions for resolution*
*Resolved items move to session-state as decisions*
EOF

echo "✅ Session memory initialized"
echo ""
echo "📁 Memory files created:"
echo "   • ${SESSION_STATE}"
echo "   • ${HYPOTHESES}"
echo "   • ${BLOCKERS}"
echo ""
echo "💡 Quick note during work:"
echo "   ./scripts/memory-note.sh \"<note>\""
echo ""
echo "📝 Or edit files directly:"
echo "   code ${MEMORY_DIR}/"
