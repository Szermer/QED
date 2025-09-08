# QED Article Evaluator Prototype

A web-based tool for evaluating articles for inclusion in the QED (AI Development Patterns) knowledge base using Jina Reader for content extraction.

## Features

- **Article Extraction**: Uses Jina Reader API to convert web pages to clean markdown
- **QED Evaluation**: Structured evaluation against QED criteria
- **Tier Classification**: Automatic recommendation for Tier 1/2/3 placement
- **Queue Management**: Approve, revise, or reject articles for the knowledge base

## Setup Options

### Option 1: With Proxy Server (Recommended)

1. Install dependencies:
```bash
cd prototype
npm install
```

2. Start the proxy server:
```bash
npm start
```

3. Open browser to: http://localhost:3001/qed-evaluator-prototype.html

### Option 2: Direct Browser Usage

Simply open `qed-evaluator-prototype.html` in your browser. Note that direct API calls to Jina Reader may be blocked by CORS, but the tool will automatically open the Jina URL in a new tab for manual content copying.

## Usage

1. **Enter Article URL**: Paste the URL of the article you want to evaluate
2. **Extract Content**: Click "Extract with Jina" to fetch and convert the article to markdown
3. **Review Content**: The extracted markdown appears in the text area (you can also paste content manually)
4. **Evaluate**: Click "Evaluate for QED" to run the evaluation against QED criteria
5. **Queue Action**: After evaluation, use the action buttons to approve, revise, or reject

## Evaluation Criteria

The evaluator assesses articles across 10 dimensions:

1. **Executive Summary** - Core pattern and tier recommendation
2. **Source Evaluation** - Author credibility and evidence type
3. **Pattern Extraction** - Problem, implementation, prerequisites
4. **Risk Assessment** - Failure modes and safety considerations
5. **Context Mapping** - Applicability to different environments
6. **Knowledge Gap Analysis** - What's missing or needs validation
7. **Integration Recommendations** - Where it fits in QED structure
8. **Actionable Next Steps** - Immediate actions required
9. **Critical Warnings** - Important concerns or limitations
10. **Practitioner Summary** - Quick overview for developers

## API Integration

The prototype currently uses a mock evaluation function. To integrate with a real AI API:

1. Replace the `generateMockEvaluation()` function in the HTML
2. Send the combined prompt + article content to your AI endpoint
3. Parse and display the structured response

## Jina Reader API

The tool uses Jina Reader (https://r.jina.ai) to extract clean content from web pages:

- **Standard pages**: `GET https://r.jina.ai/{url}`
- **SPAs with hash routing**: `POST https://r.jina.ai/` with `url` in body
- **Waiting for content**: Use `x-timeout` or `x-wait-for-selector` headers

## Development

To modify the evaluation prompt, edit the `QED_EVALUATION_PROMPT` constant in the HTML file.

The proxy server (`server.js`) handles:
- CORS bypass for Jina Reader API
- Support for both standard and SPA extraction
- Error handling and fallback options

## Next Steps

1. **AI Integration**: Connect to Claude, GPT-4, or another LLM for actual evaluation
2. **Database**: Add persistent storage for evaluated articles
3. **Batch Processing**: Support evaluating multiple articles at once
4. **Export**: Generate markdown files for approved articles
5. **Authentication**: Add user management for team collaboration