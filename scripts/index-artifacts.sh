#!/bin/bash
# Index finalization artifacts for searchability
# Enhanced with Google File Search integration

set -e

ARTIFACTS_DIR=".agent-artifacts"
INDEX_FILE="${ARTIFACTS_DIR}/index.json"

echo "Indexing finalization artifacts..."

# Create array to hold all entries
entries=()

# Find all finalization-pack.json files
while IFS= read -r file; do
  if [ -f "$file" ]; then
    # Extract date from path (handles both "2025-11-03/" and "2025-11-03-qa-session/")
    date=$(echo "$file" | sed 's|.*/\([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][^/]*\)/.*|\1|')

    # Read and process the JSON file - handle multiple formats
    # Includes ADR-023 taxonomy fields (type, concepts)
    entry=$(jq --arg date "$date" --arg path "$file" '{
      date: $date,
      type: (.type // "change"),
      concepts: (.concepts // []),
      branch: (
        .branch //
        .session_metadata.session_type //
        .session.focus //
        "unknown"
      ),
      areas: (
        if (.summary | type) == "object" then
          (.summary.areas // (if .session.focus then [.session.focus] else ["legacy"] end))
        elif .session.focus then
          [.session.focus]
        else
          ["legacy"]
        end
      ),
      change_types: (
        if (.summary | type) == "object" then
          (.summary.change_type // ["sync"])
        else
          ["sync"]
        end
      ),
      commit_count: (
        if .commits then (.commits | length)
        elif .session_metadata.commits then (.session_metadata.commits | length)
        elif .technical_changes.commit then 1
        else 0
        end
      ),
      migration_count: (
        if (.artifacts | type) == "object" and .artifacts.db_plans then (.artifacts.db_plans | length)
        elif (.artifacts | type) == "array" then 0
        elif .migration_analysis.unapplied_migrations then (.migration_analysis.unapplied_migrations | length)
        else 0
        end
      ),
      risks: (
        (.risks // []) | map(.item // .)
      ),
      standards_pass: (
        if .standards then
          (.standards |
          to_entries |
          map(select(.key != "notes")) |
          all(.value == "pass"))
        elif .success_criteria then
          .success_criteria.all_met
        else
          true
        end
      ),
      duration_hours: (
        if .handoff.time_used_s then (.handoff.time_used_s / 3600 | floor)
        elif .metrics.session_duration_hours then .metrics.session_duration_hours
        elif .session.duration_hours then .session.duration_hours
        else 0
        end
      ),
      summary: (
        .handoff.context_pack_summary //
        .session_summary.objective //
        (if (.summary | type) == "object" then (.summary.one_line // .summary.key_achievement) else null end) //
        (if (.summary | type) == "string" then .summary else null end) //
        "Legacy session"
      ),
      discovery_tokens: (.metrics.discovery_tokens // null),
      session_tokens: (.metrics.session_tokens // null),
      artifact_path: $path
    }' "$file")

    entries+=("$entry")
  fi
done < <(find "${ARTIFACTS_DIR}/" -type f -name "finalization-pack.json" 2>/dev/null)

# Combine all entries into a single JSON array
if [ ${#entries[@]} -gt 0 ]; then
  printf '%s\n' "${entries[@]}" | jq -s 'sort_by(.date) | reverse' > "${INDEX_FILE}"
  echo "✓ Index created: ${INDEX_FILE}"
  echo "Found $(jq 'length' "${INDEX_FILE}") artifact set(s)"

  # Display summary
  echo ""
  echo "Recent sessions:"
  jq -r '.[] | "  \(.date): \(.commit_count) commits, \(.migration_count) migrations, \(.duration_hours)h - \(.branch)"' "${INDEX_FILE}"

  # Build agentic index for reasoning-based navigation
  echo ""
  echo "Building agentic index for LLM-native navigation..."
  if [ -x "./scripts/build-agentic-index.sh" ]; then
    ./scripts/build-agentic-index.sh
  else
    echo "⚠️  Warning: build-agentic-index.sh not found or not executable"
  fi

  # ========== GOOGLE FILE SEARCH INTEGRATION ==========
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🔍 Google File Search Integration"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Check if File Search is enabled
  if [ -f ".gemini-config.json" ]; then
    ENABLED=$(jq -r '.enabled' .gemini-config.json)
    AUTO_INDEX=$(jq -r '.auto_index' .gemini-config.json)

    if [ "$ENABLED" = "true" ] && [ "$AUTO_INDEX" = "true" ]; then
      echo "✓ File Search enabled (auto-index: ON)"

      # Check if API key is set
      if [ -z "$GEMINI_API_KEY" ]; then
        echo "⚠️  Warning: GEMINI_API_KEY not set"
        echo "   Skipping semantic indexing"
        echo "   Set key: export GEMINI_API_KEY='your-key'"
      else
        # Call gemini wrapper to index
        if [ -x "./scripts/gemini-wrapper.sh" ]; then
          echo ""
          echo "📤 Indexing to Google File Search..."
          ./scripts/gemini-wrapper.sh index
        else
          echo "⚠️  Warning: gemini-wrapper.sh not found"
          echo "   Run bootstrap script to install File Search integration"
        fi
      fi
    elif [ "$ENABLED" = "true" ] && [ "$AUTO_INDEX" != "true" ]; then
      echo "ℹ️  File Search enabled but auto-index is OFF"
      echo "   Manual index: ./scripts/gemini-wrapper.sh index"
    else
      echo "ℹ️  File Search disabled"
      echo "   Enable: Set enabled=true in .gemini-config.json"
    fi
  else
    echo "ℹ️  File Search not configured"
    echo "   Setup: Run bootstrap script with --file-search flag"
  fi

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
else
  echo "No finalization artifacts found in ${ARTIFACTS_DIR}"
  echo "Run /finalize at the end of a session to create artifacts"
fi
