#!/bin/bash
# Search finalization artifacts and patterns by keyword
# Enhanced with Google File Search semantic search

set -e

ARTIFACTS_DIR=".agent-artifacts"
INDEX_FILE="${ARTIFACTS_DIR}/index.json"
AGENTIC_INDEX="${ARTIFACTS_DIR}/AGENTIC-INDEX.md"
PATTERNS_DIR="${HOME}/.shared-patterns"
PATTERNS_INDEX="${PATTERNS_DIR}/index.json"
PROJECT_NAME=$(basename "$(pwd)")

# Parse flags
GLOBAL_SEARCH=false
AGENTIC_MODE=false
SEMANTIC_MODE=false
OUTPUT_FORMAT="index"  # Progressive disclosure: index (compact) or full (detailed)
FILTER_TYPE=""         # Taxonomy type filter (ADR-023)
FILTER_CONCEPT=""      # Taxonomy concept filter (ADR-023)

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      # Show help and exit
      echo "Usage: search-artifacts.sh [OPTIONS] <keyword>"
      echo ""
      echo "Options:"
      echo "  --help, -h         Show this help message"
      echo "  --global, -g       Search across all projects and shared patterns"
      echo "  --agentic, -a      Use reasoning-based navigation (faster, more precise)"
      echo "  --semantic, -s     Use Google File Search (semantic understanding)"
      echo "  --format, -f FMT   Output format: 'index' (compact, default) or 'full' (detailed)"
      echo "  --index            Shorthand for --format index (50-100 tokens/result)"
      echo "  --full             Shorthand for --format full (500-1000 tokens/result)"
      echo "  --type, -t TYPE    Filter by session type (ADR-023 taxonomy):"
      echo "                     bugfix|feature|refactor|change|discovery|decision"
      echo "  --concept, -c CON  Filter by concept (ADR-023 taxonomy):"
      echo "                     how-it-works|why-it-exists|what-changed|problem-solution|"
      echo "                     gotcha|pattern|trade-off"
      echo ""
      echo "Examples:"
      echo "  search-artifacts.sh migration              # Index view (compact)"
      echo "  search-artifacts.sh --full migration       # Full details"
      echo "  search-artifacts.sh --type decision auth   # Only decision sessions"
      echo "  search-artifacts.sh --concept pattern RLS  # Only pattern-related"
      echo "  search-artifacts.sh --global RLS"
      echo "  search-artifacts.sh --agentic user personas"
      echo "  search-artifacts.sh --semantic \"authentication fixes\""
      echo ""
      echo "💡 Progressive Disclosure: Use --index first, then get-artifact.sh <id> for details"
      echo "💡 Token savings: Index view uses ~10x fewer tokens than full view"
      exit 0
      ;;
    --global|-g)
      GLOBAL_SEARCH=true
      shift
      ;;
    --agentic|-a)
      AGENTIC_MODE=true
      shift
      ;;
    --semantic|-s)
      SEMANTIC_MODE=true
      shift
      ;;
    --format|-f)
      OUTPUT_FORMAT="$2"
      shift 2
      ;;
    --full)
      OUTPUT_FORMAT="full"
      shift
      ;;
    --index)
      OUTPUT_FORMAT="index"
      shift
      ;;
    --type|-t)
      FILTER_TYPE="$2"
      shift 2
      ;;
    --concept|-c)
      FILTER_CONCEPT="$2"
      shift 2
      ;;
    *)
      break
      ;;
  esac
done

QUERY="${1:-}"

if [ -z "${QUERY}" ]; then
  echo "Usage: search-artifacts.sh [OPTIONS] <keyword>"
  echo ""
  echo "Options:"
  echo "  --global, -g       Search across all projects and shared patterns"
  echo "  --agentic, -a      Use reasoning-based navigation (faster, more precise)"
  echo "  --semantic, -s     Use Google File Search (semantic understanding)"
  echo "  --format, -f FMT   Output format: 'index' (compact, default) or 'full' (detailed)"
  echo "  --index            Shorthand for --format index (50-100 tokens/result)"
  echo "  --full             Shorthand for --format full (500-1000 tokens/result)"
  echo "  --type, -t TYPE    Filter by session type (ADR-023 taxonomy):"
  echo "                     bugfix|feature|refactor|change|discovery|decision"
  echo "  --concept, -c CON  Filter by concept (ADR-023 taxonomy):"
  echo "                     how-it-works|why-it-exists|what-changed|problem-solution|"
  echo "                     gotcha|pattern|trade-off"
  echo ""
  echo "Examples:"
  echo "  search-artifacts.sh migration              # Index view (compact)"
  echo "  search-artifacts.sh --full migration       # Full details"
  echo "  search-artifacts.sh --type decision auth   # Only decision sessions"
  echo "  search-artifacts.sh --concept pattern RLS  # Only pattern-related"
  echo "  search-artifacts.sh --global RLS"
  echo "  search-artifacts.sh --agentic user personas"
  echo "  search-artifacts.sh --semantic \"authentication fixes\""
  echo ""
  echo "💡 Progressive Disclosure: Use --index first, then get-artifact.sh <id> for details"
  echo "💡 Token savings: Index view uses ~10x fewer tokens than full view"
  exit 1
fi

# ========== SEMANTIC SEARCH MODE (ADR-025) ==========
if [ "${SEMANTIC_MODE}" = true ]; then
  echo "🔍 Semantic Search Mode (ADR-025)"
  echo "   Query: ${QUERY}"
  echo ""

  # Check if File Search is available (Google File Search)
  GEMINI_AVAILABLE=false
  if [ -f ".gemini-config.json" ]; then
    ENABLED=$(jq -r '.enabled' .gemini-config.json 2>/dev/null)
    if [ "$ENABLED" = "true" ] && [ -n "$GEMINI_API_KEY" ] && [ -x "./scripts/gemini-wrapper.sh" ]; then
      GEMINI_AVAILABLE=true
    fi
  fi

  if [ "${GEMINI_AVAILABLE}" = true ]; then
    echo "📡 Using: Google File Search"
    if [ "${GLOBAL_SEARCH}" = true ]; then
      echo "   ⚠️  Note: Global semantic search searches current project only"
    fi
    echo ""
    exec ./scripts/gemini-wrapper.sh search "${QUERY}"
  else
    # Suggest MCP semantic search tools (ADR-025 Pattern)
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "💡 MCP Semantic Search (ADR-025)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Use these MCP tools in Claude Code for semantic search:"
    echo ""
    echo "🔎 Search session memory (current session):"
    echo "   session_search(query: \"${QUERY}\")"
    echo ""
    echo "🎯 Find patterns (fast Qdrant search, 50-200ms):"
    echo "   findPatterns(query: \"${QUERY}\", mode: \"fast\")"
    echo ""
    echo "🔬 Deep pattern search (Google FS, 5-10s):"
    echo "   findPatterns(query: \"${QUERY}\", mode: \"comprehensive\")"
    echo ""
    echo "📚 Search across all sessions:"
    echo "   semanticSearch(query: \"${QUERY}\", projectPath: \"$(pwd)\")"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⚠️  Google File Search not configured. Options:"
    echo "   1. Use MCP tools above in Claude Code"
    echo "   2. Configure File Search: bootstrap with --file-search flag"
    echo "   3. Set GEMINI_API_KEY environment variable"
    echo ""
    echo "Falling back to traditional keyword search..."
    echo ""
    SEMANTIC_MODE=false
  fi
fi

# ========== TRADITIONAL SEARCH (if not semantic or fallback) ==========

# If agentic mode and only local search, delegate to navigate-artifacts-agentic.sh
if [ "${AGENTIC_MODE}" = true ] && [ "${GLOBAL_SEARCH}" = false ]; then
  if [ -x "./scripts/navigate-artifacts-agentic.sh" ]; then
    exec ./scripts/navigate-artifacts-agentic.sh "${QUERY}"
  else
    echo "⚠️  Agentic navigation not available (navigate-artifacts-agentic.sh not found)"
    echo "    Falling back to traditional search..."
    echo ""
    AGENTIC_MODE=false
  fi
fi

# Agentic mode with global search uses index-based reasoning
if [ "${AGENTIC_MODE}" = true ] && [ "${GLOBAL_SEARCH}" = true ]; then
  echo "🤖 Agentic mode (reasoning-based navigation)"
  echo "   Query: ${QUERY}"
  echo "   Scope: All projects + shared patterns"
  echo ""
  echo "⚠️  Global agentic search not yet implemented"
  echo "    Falling back to local agentic search..."
  echo ""
  if [ -x "./scripts/navigate-artifacts-agentic.sh" ]; then
    exec ./scripts/navigate-artifacts-agentic.sh "${QUERY}"
  fi
fi

echo "🔍 Searching for: ${QUERY}"
if [ "${GLOBAL_SEARCH}" = true ]; then
  echo "   Scope: All projects + shared patterns"
else
  echo "   Scope: ${PROJECT_NAME} only"
fi
if [ -n "${FILTER_TYPE}" ]; then
  echo "   Type filter: ${FILTER_TYPE}"
fi
if [ -n "${FILTER_CONCEPT}" ]; then
  echo "   Concept filter: ${FILTER_CONCEPT}"
fi
echo "   Format: ${OUTPUT_FORMAT}"
echo ""

# ========== LOCAL PROJECT ARTIFACTS ==========
if [ -f "${INDEX_FILE}" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 ${PROJECT_NAME} Sessions"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ "${OUTPUT_FORMAT}" = "index" ]; then
    # INDEX FORMAT: Compact view (~50-100 tokens per result)
    RESULTS=$(jq -r --arg query "${QUERY}" '
      .[] |
      select(
        (.summary | ascii_downcase | contains($query | ascii_downcase)) or
        (.risks | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase)) or
        (.areas | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "[\(.date)] \(.summary | .[0:80])..."
    ' "${INDEX_FILE}")
  else
    # FULL FORMAT: Detailed view (~500-1000 tokens per result)
    RESULTS=$(jq -r --arg query "${QUERY}" '
      .[] |
      select(
        (.summary | ascii_downcase | contains($query | ascii_downcase)) or
        (.risks | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase)) or
        (.areas | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "📅 \(.date) [\(.branch)]
   📊 \(.commit_count) commits, \(.migration_count) migrations (\(.duration_hours)h)
   📝 \(.summary)
   📁 \(.artifact_path | split("/")[0:-1] | join("/"))
   "
    ' "${INDEX_FILE}")
  fi

  if [ -z "${RESULTS}" ]; then
    echo "   No results found in ${PROJECT_NAME}"
  else
    echo "${RESULTS}"
  fi

  echo ""
fi

# ========== SHARED PATTERN LIBRARY ==========
if [ "${GLOBAL_SEARCH}" = true ] && [ -f "${PATTERNS_INDEX}" ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📚 Shared Pattern Library"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  if [ "${OUTPUT_FORMAT}" = "index" ]; then
    # INDEX FORMAT: Compact view
    PATTERN_RESULTS=$(jq -r --arg query "${QUERY}" '
      .patterns[] |
      select(
        (.name | ascii_downcase | contains($query | ascii_downcase)) or
        (.category | ascii_downcase | contains($query | ascii_downcase)) or
        (.source_projects | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "[\(.id)] \(.name) (\(.category)) - reused \(.reuse_count)x"
    ' "${PATTERNS_INDEX}")
  else
    # FULL FORMAT: Detailed view
    PATTERN_RESULTS=$(jq -r --arg query "${QUERY}" '
      .patterns[] |
      select(
        (.name | ascii_downcase | contains($query | ascii_downcase)) or
        (.category | ascii_downcase | contains($query | ascii_downcase)) or
        (.source_projects | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "🎯 \(.id) - \(.name)
   📂 Category: \(.category) | Complexity: \(.complexity)
   🔄 Reused: \(.reuse_count) times | Score: \(.effectiveness_score)
   📦 Source: \(.source_projects | join(", ")) [\(.source_session)]
   📄 File: .shared-patterns/patterns/\(.file)
   "
    ' "${PATTERNS_INDEX}")
  fi

  if [ -z "${PATTERN_RESULTS}" ]; then
    echo "   No patterns found matching \"${QUERY}\""
  else
    echo "${PATTERN_RESULTS}"
  fi

  echo ""
fi

# ========== OTHER PROJECT ARTIFACTS (Global only) ==========
# Helper function for cross-project search
search_other_project() {
  local project_path="$1"
  local project_name="$2"
  local index_path="${project_path}/.agent-artifacts/index.json"

  if [ ! -f "${index_path}" ]; then
    return
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 ${project_name} Sessions"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  local results
  if [ "${OUTPUT_FORMAT}" = "index" ]; then
    results=$(jq -r --arg query "${QUERY}" '
      .[] |
      select(
        (.summary | ascii_downcase | contains($query | ascii_downcase)) or
        (.risks | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase)) or
        (.areas | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "[\(.date)] \(.summary | .[0:80])..."
    ' "${index_path}")
  else
    results=$(jq -r --arg query "${QUERY}" --arg path "${project_path}" '
      .[] |
      select(
        (.summary | ascii_downcase | contains($query | ascii_downcase)) or
        (.risks | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase)) or
        (.areas | map(if type == "string" then . else .description // "" end) | map(ascii_downcase) | join(" ") | contains($query | ascii_downcase))
      ) |
      "📅 \(.date) [\(.branch)]
   📊 \(.commit_count) commits, \(.migration_count) migrations (\(.duration_hours)h)
   📝 \(.summary)
   📁 \($path)/\(.artifact_path | split("/")[0:-1] | join("/"))
   "
    ' "${index_path}")
  fi

  if [ -z "${results}" ]; then
    echo "   No results found in ${project_name}"
  else
    echo "${results}"
  fi

  echo ""
}

if [ "${GLOBAL_SEARCH}" = true ]; then
  # Search PrivateLanguage if we're in Mermaid
  if [ "${PROJECT_NAME}" = "Mermaid" ]; then
    search_other_project "${HOME}/Dev/PrivateLanguage" "PrivateLanguage"
  fi

  # Search Mermaid if we're in PrivateLanguage
  if [ "${PROJECT_NAME}" = "PrivateLanguage" ]; then
    search_other_project "${HOME}/Dev/Mermaid" "Mermaid"
  fi
fi

# ========== TIPS ==========
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💡 Tips"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
if [ "${OUTPUT_FORMAT}" = "index" ]; then
  echo "Get full details for a session:"
  echo "  ./scripts/get-artifact.sh <session-id>"
  echo ""
  echo "Or re-run with --full flag:"
  echo "  ./scripts/search-artifacts.sh --full \"${QUERY}\""
  echo ""
fi
echo "View session details directly:"
echo "  cat ${ARTIFACTS_DIR}/<date>/finalization-pack.json"
echo ""
echo "View pattern details:"
echo "  cat ${PATTERNS_DIR}/patterns/<pattern-file>.md"
echo ""
echo "Extract new pattern:"
echo "  ./scripts/extract-pattern.sh <date> <pattern-name>"
echo ""
if [ -f ".gemini-config.json" ] && [ "$(jq -r '.enabled' .gemini-config.json)" = "true" ]; then
  echo "Semantic search (conceptual understanding):"
  echo "  ./scripts/search-artifacts.sh --semantic \"your query\""
  echo ""
fi
