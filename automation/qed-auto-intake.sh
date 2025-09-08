#!/bin/bash
# QED Automated Knowledge Intake using Jina Reader API
# Usage: ./qed-auto-intake.sh <URL> [priority]

set -e  # Exit on any error

# Configuration
JINA_API_KEY="***REMOVED***"
QED_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Input validation
if [ -z "$1" ]; then
    echo "Usage: $0 <URL> [priority]"
    echo "Priority: high|medium|low (default: medium)"
    exit 1
fi

URL="$1"
PRIORITY="${2:-medium}"
TIMESTAMP=$(date +%Y-%m-%d)
URL_SLUG=$(echo "$URL" | sed 's|https\?://||g' | sed 's/[^a-zA-Z0-9]/-/g' | cut -c1-50)

echo "🔄 Starting QED automated knowledge intake"
echo "📍 URL: $URL"
echo "⏰ Time: $(date)"
echo "📊 Priority: $PRIORITY"

# Step 1: Extract content with Jina Reader
echo ""
echo "📖 Extracting content with Jina Reader API..."

CONTENT=$(curl -s "https://r.jina.ai/$URL" \
  -H "Authorization: Bearer $JINA_API_KEY" \
  -H "Accept: text/plain" \
  --max-time 30)

# Validate extraction
if [ ${#CONTENT} -lt 500 ]; then
    echo "❌ Content extraction failed or content too short"
    echo "Content length: ${#CONTENT} characters"
    echo "Response preview: $(echo "$CONTENT" | head -3)"
    exit 1
fi

echo "✅ Content extracted: ${#CONTENT} characters"

# Content quality validation
echo ""
echo "🔍 Validating content quality..."

# Technical relevance check
if echo "$CONTENT" | grep -qi -E "(AI|artificial intelligence|machine learning|development|programming|software|architecture|pattern|framework|tool|API|system)"; then
    echo "✅ Technically relevant content detected"
else
    echo "⚠️  Content may not be technically relevant - proceeding with caution"
fi

# Marketing content detection
if echo "$CONTENT" | grep -qi -E "(buy now|sign up|contact sales|limited time|pricing|subscribe|purchase)"; then
    echo "⚠️  Potential marketing content detected"
fi

# Step 2: Extract metadata
echo ""
echo "📋 Processing metadata..."

TITLE=$(echo "$CONTENT" | head -10 | grep -E "^#[^#]" | head -1 | sed 's/^# *//' || echo "$(basename "$URL")")
DOMAIN=$(echo "$URL" | sed 's|https\?://||' | cut -d/ -f1)

echo "📰 Title: $TITLE"
echo "🌐 Domain: $DOMAIN"

# Step 3: Create analysis file
echo ""
echo "📁 Creating analysis structure..."

FILENAME="$TIMESTAMP-$(echo "$TITLE" | sed 's/[^a-zA-Z0-9 ]//g' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | cut -c1-50).md"
ANALYSIS_FILE="$QED_ROOT/src/analysis/$FILENAME"

mkdir -p "$(dirname "$ANALYSIS_FILE")"

cat > "$ANALYSIS_FILE" << EOF
# Automated Analysis: $TITLE

**Source**: [$URL]($URL)  
**Domain**: $DOMAIN  
**Processing Date**: $TIMESTAMP  
**Priority**: $PRIORITY  
**Status**: Automated Extraction - Requires QED Evaluation  

## Executive Summary

**Content Length**: ${#CONTENT} characters  
**Extraction Method**: Jina Reader API  
**Technical Relevance**: $(echo "$CONTENT" | grep -qi -E "(AI|development|programming)" && echo "Confirmed" || echo "Uncertain")  

**Preliminary Assessment**: Requires full QED evaluation framework application for proper tier assignment and risk assessment.

## Source Analysis

**URL**: $URL  
**Domain Authority**: $(echo "$DOMAIN" | grep -q -E "(martinfowler\.com|thoughtworks\.com|developers\.googleblog\.com|openai\.com|anthropic\.com)" && echo "High (Recognized Technical Authority)" || echo "To Be Assessed")  
**Content Type**: Technical Article/Blog Post  

## Extracted Content

\`\`\`markdown
$(echo "$CONTENT" | head -150)
$([ ${#CONTENT} -gt 5000 ] && echo "..." && echo "[Content truncated - full content available for evaluation]")
\`\`\`

## QED Evaluation Status

**Framework Applied**: Not yet - requires manual evaluation  
**Confidence Score**: Pending evaluation  
**Tier Recommendation**: Pending evaluation  
**Risk Assessment**: Pending evaluation  

### Required Next Steps

1. **Apply QED Evaluation Framework**
   - Use standardized prompt template from \`automation/qed-evaluation-prompt.md\`
   - Generate systematic risk assessment
   - Assign confidence score (X/25)

2. **Determine Tier Placement**
   - Tier 1: Research collection (< 15/25)
   - Tier 2: Professional analysis (15-22/25) 
   - Tier 3: Proven practice (23+/25, rare)

3. **Create Cross-References**
   - Link to related QED content
   - Update navigation and indexes
   - Add to appropriate decision records

4. **Archive Source Materials**
   - Move to appropriate tier directory
   - Update processing logs
   - Create audit trail

## Raw Processing Data

**Extraction Timestamp**: $(date)  
**Content Hash**: $(echo "$CONTENT" | md5sum | cut -d' ' -f1)  
**Processing Script**: automation/qed-auto-intake.sh  

---

**Note**: This is an automated extraction requiring manual evaluation completion before integration into QED knowledge base.
EOF

echo "✅ Analysis file created: $ANALYSIS_FILE"

# Step 4: Update knowledge structures
echo ""
echo "🔗 Updating knowledge structures..."

# Update analysis README
if [ -f "$QED_ROOT/src/analysis/README.md" ]; then
    BASENAME=$(basename "$ANALYSIS_FILE" .md)
    if ! grep -q "$BASENAME" "$QED_ROOT/src/analysis/README.md"; then
        # Add under appropriate category
        if echo "$CONTENT" | grep -qi -E "(google|gemini|openai|anthropic|claude)"; then
            CATEGORY="Tool-Specific Evaluations"
        elif echo "$CONTENT" | grep -qi -E "(framework|pattern|architecture)"; then
            CATEGORY="Framework Assessments"  
        else
            CATEGORY="Tool-Specific Evaluations"
        fi
        
        # Insert after category header
        sed -i.bak "/### $CATEGORY/a\\
- **[$BASENAME]($FILENAME)** - Automated analysis from $DOMAIN (requires evaluation completion)" "$QED_ROOT/src/analysis/README.md"
        
        echo "✅ Updated analysis README under $CATEGORY"
    fi
fi

# Update main TODO.md
if [ -f "$QED_ROOT/TODO.md" ]; then
    if ! grep -q "$(basename "$URL")" "$QED_ROOT/TODO.md"; then
        sed -i.bak "/## Recent Major Changes/a\\
- Added automated analysis: $(echo "$TITLE" | cut -c1-50)... ($TIMESTAMP)" "$QED_ROOT/TODO.md"
        echo "✅ Updated project TODO"
    fi
fi

# Step 5: Git integration
echo ""
echo "💾 Committing to git..."

cd "$QED_ROOT"
git add .

# Create structured commit message
COMMIT_MSG="Automated knowledge intake: $TITLE

Source: $URL
Domain: $DOMAIN  
Processing: Jina Reader API extraction ($TIMESTAMP)
Content: ${#CONTENT} characters extracted
Priority: $PRIORITY
Status: Requires QED evaluation completion

Auto-generated analysis ready for systematic evaluation framework application."

git commit -m "$COMMIT_MSG"

echo "✅ Changes committed to git"

# Step 6: Summary report
echo ""
echo "🎉 Automated knowledge intake complete!"
echo "════════════════════════════════════════"
echo "📄 Analysis File: $ANALYSIS_FILE"
echo "📰 Title: $TITLE"
echo "🌐 Domain: $DOMAIN"
echo "📊 Content: ${#CONTENT} characters processed"
echo "📅 Date: $TIMESTAMP"
echo "⏱️  Processing Time: ~30 seconds"
echo "🔄 Status: Ready for QED evaluation"

echo ""
echo "🔗 Next steps:"
echo "1. Review: $ANALYSIS_FILE"
echo "2. Apply: QED evaluation framework (automation/qed-evaluation-prompt.md)"
echo "3. Score: Assign confidence rating (X/25)"
echo "4. Place: Move to appropriate tier based on score"
echo "5. Link: Create cross-references as needed"

echo ""
echo "📚 To apply QED evaluation:"
echo "claude-code --file '$ANALYSIS_FILE' --prompt automation/qed-evaluation-prompt.md"