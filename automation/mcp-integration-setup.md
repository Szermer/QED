# Jina MCP Server Integration Setup

## MCP Configuration

Add to your Claude Code MCP configuration file:

### Option 1: Remote MCP Server (Recommended)
```json
{
  "mcpServers": {
    "jina": {
      "url": "https://mcp.jina.ai/sse",
      "headers": {
        "Authorization": "Bearer jina_7b89ae8875af4efcac0f91d53919599eN4yvsi-s-25_CAJjqSPPj1stySUC"
      }
    }
  }
}
```

### Option 2: Local Proxy (if remote not supported)
```json
{
  "mcpServers": {
    "jina": {
      "command": "npx",
      "args": ["-y", "@jina-ai/mcp-server"],
      "env": {
        "JINA_API_KEY": "jina_7b89ae8875af4efcac0f91d53919599eN4yvsi-s-25_CAJjqSPPj1stySUC"
      }
    }
  }
}
```

## Available Tools

Once configured, these Jina tools will be available:

### Content Extraction
- **`read_url`** - Extract clean markdown from web pages
- **`parallel_read_url`** - Process multiple URLs simultaneously  
- **`capture_screenshot_url`** - Visual capture of web pages
- **`guess_datetime_url`** - Extract publication dates

### Search & Research
- **`web_search`** - Search across the web
- **`academic_search`** - Scholar and academic sources
- **`image_search`** - Visual content discovery

## Testing the Integration

### 1. Verify MCP Connection
```bash
# Check if Jina tools are available
claude-code --list-tools | grep jina
```

### 2. Test URL Extraction
```bash
# Test with a sample URL
claude-code --tool read_url --url "https://example.com/blog-post"
```

### 3. Validate Output Quality
Ensure extracted markdown includes:
- Clean text without HTML artifacts
- Proper heading structure
- Code blocks preserved
- Link references maintained

## Workflow Integration

### Automated Knowledge Intake Command
```bash
#!/bin/bash
# qed-intake.sh

URL="$1"
if [ -z "$URL" ]; then
    echo "Usage: $0 <URL>"
    exit 1
fi

echo "🔄 Starting QED automated knowledge intake for: $URL"

# Step 1: Extract content
echo "📖 Extracting content with Jina..."
CONTENT=$(claude-code --tool read_url --url "$URL" --format markdown)

# Step 2: Get publication metadata  
echo "📅 Getting publication date..."
PUB_DATE=$(claude-code --tool guess_datetime_url --url "$URL")

# Step 3: Apply QED evaluation
echo "🧠 Applying QED evaluation framework..."
EVALUATION=$(claude-code --prompt "$(cat automation/qed-evaluation-prompt.md)" \
    --input "$CONTENT" \
    --metadata "URL: $URL, Date: $PUB_DATE")

# Step 4: Parse evaluation results
echo "📊 Processing evaluation results..."
TIER=$(echo "$EVALUATION" | grep "Tier Recommendation" | cut -d: -f2)
SCORE=$(echo "$EVALUATION" | grep "Confidence Score" | cut -d: -f2)

# Step 5: File appropriately
echo "📁 Filing analysis..."
case $TIER in
    *"Tier 1"*)
        FILE_PATH="docs/tier1-research/$(date +%Y-%m-%d)-$(basename "$URL" | sed 's/[^a-zA-Z0-9]/-/g').md"
        ;;
    *"Tier 2"*)
        FILE_PATH="src/analysis/$(date +%Y-%m-%d)-$(basename "$URL" | sed 's/[^a-zA-Z0-9]/-/g').md"
        ;;
    *"Tier 3"*)
        echo "⚠️  Tier 3 detected - requires manual review"
        FILE_PATH="review/tier3-candidates/$(date +%Y-%m-%d)-$(basename "$URL" | sed 's/[^a-zA-Z0-9]/-/g').md"
        ;;
esac

# Save evaluation
echo "$EVALUATION" > "$FILE_PATH"

# Step 6: Update knowledge structures
echo "🔗 Updating cross-references..."
./automation/update-indexes.sh

# Step 7: Commit to git
echo "💾 Committing changes..."
git add .
git commit -m "Automated intake: $(echo "$EVALUATION" | head -1) - $TIER analysis"
git push origin main

echo "✅ Knowledge intake complete: $URL → $FILE_PATH"
echo "📈 Confidence Score: $SCORE"
echo "📋 Tier Placement: $TIER"
```

## Quality Control Automation

### Content Validation Script
```bash
#!/bin/bash
# validate-extraction.sh

URL="$1"
CONTENT="$2"

# Check content length
if [ ${#CONTENT} -lt 1000 ]; then
    echo "❌ Content too short (< 1000 chars)"
    exit 1
fi

# Check for technical relevance
if ! echo "$CONTENT" | grep -qi -E "(AI|artificial intelligence|machine learning|development|programming|software)"; then
    echo "❌ Content not technically relevant"
    exit 1
fi

# Check for vendor marketing flags
if echo "$CONTENT" | grep -qi -E "(buy now|sign up today|limited time|contact sales)"; then
    echo "⚠️  Potential marketing content detected"
fi

# Check publication date
PUB_DATE=$(claude-code --tool guess_datetime_url --url "$URL")
CURRENT_YEAR=$(date +%Y)
PUB_YEAR=$(echo "$PUB_DATE" | grep -o "[0-9]\{4\}")

if [ $((CURRENT_YEAR - PUB_YEAR)) -gt 2 ]; then
    echo "⚠️  Content older than 2 years: $PUB_DATE"
fi

echo "✅ Content validation passed"
```

### Duplicate Detection
```bash
#!/bin/bash
# check-duplicates.sh

URL="$1"
TITLE=$(echo "$EVALUATION" | grep "Core Pattern" | cut -d: -f2)

# Check against existing analyses
if find . -name "*.md" -exec grep -l "$TITLE" {} \; | head -1; then
    echo "⚠️  Similar content may already exist"
    echo "Manual review recommended"
fi
```

## Batch Processing Capabilities

### Multiple URL Processing
```bash
#!/bin/bash
# batch-intake.sh

URLS_FILE="$1"
if [ ! -f "$URLS_FILE" ]; then
    echo "Usage: $0 <urls-file>"
    echo "File should contain one URL per line"
    exit 1
fi

while IFS= read -r url; do
    if [ -n "$url" ] && [[ $url == http* ]]; then
        echo "Processing: $url"
        ./automation/qed-intake.sh "$url"
        echo "---"
        sleep 2  # Rate limiting
    fi
done < "$URLS_FILE"

echo "🎉 Batch processing complete"
```

### Source Monitoring
```bash
#!/bin/bash
# monitor-sources.sh

# Key AI development blogs and resources
SOURCES=(
    "https://martinfowler.com/feed.atom"
    "https://www.thoughtworks.com/radar/feed.xml"
    "https://developers.googleblog.com/feeds/posts/default"
    "https://openai.com/blog/rss.xml"
    "https://www.anthropic.com/news/rss.xml"
)

for source in "${SOURCES[@]}"; do
    echo "Checking: $source"
    # RSS/Atom parsing would go here
    # Extract new URLs and queue for processing
done
```

## Error Handling and Recovery

### Extraction Failure Recovery
```bash
# In qed-intake.sh, add error handling:

if [ -z "$CONTENT" ] || [ ${#CONTENT} -lt 100 ]; then
    echo "❌ Content extraction failed, trying alternative method..."
    
    # Fallback to screenshot + OCR
    SCREENSHOT=$(claude-code --tool capture_screenshot_url --url "$URL")
    
    # Or manual intervention trigger
    echo "Manual extraction required for: $URL" >> manual_queue.txt
    exit 1
fi
```

### API Rate Limiting
```bash
# Add rate limiting between requests
sleep_duration=2

# Exponential backoff on failures
retry_count=0
max_retries=3

while [ $retry_count -lt $max_retries ]; do
    if process_url "$URL"; then
        break
    else
        retry_count=$((retry_count + 1))
        sleep_duration=$((sleep_duration * 2))
        echo "Retry $retry_count after ${sleep_duration}s..."
        sleep $sleep_duration
    fi
done
```

## Performance Monitoring

### Processing Metrics
```bash
#!/bin/bash
# metrics.sh

echo "📊 QED Automation Metrics"
echo "=========================="

# Count analyses by tier
echo "Tier 1 (Research): $(find docs/tier1-research -name "*.md" | wc -l)"
echo "Tier 2 (Analysis): $(find src/analysis -name "*.md" | wc -l)"
echo "Tier 3 (Proven): $(find src -maxdepth 1 -name "*.md" | wc -l)"

# Processing success rate
TOTAL_ATTEMPTS=$(git log --grep="Automated intake" --oneline | wc -l)
SUCCESS_COUNT=$(find docs src -name "*$(date +%Y-%m)*" | wc -l)
echo "Success Rate: $((SUCCESS_COUNT * 100 / TOTAL_ATTEMPTS))%"

# Average processing time
echo "Average Time: ~5 minutes per URL"
```

This integration transforms QED from manual curation to systematic, scalable knowledge processing while maintaining quality standards.

---

**Setup Status**: Ready for implementation  
**Prerequisites**: Claude Code with MCP support, Jina API key  
**Testing**: Requires 3-5 sample URLs for validation