# QED Article Evaluation Prompt Template

## Instructions for Use
Copy this prompt and paste it along with your markdown article to evaluate it for the QED knowledge base.

---

## PROMPT:

I need you to evaluate the following article for inclusion in my AI development patterns knowledge base (QED). This knowledge base helps practitioners use AI coding assistants in client projects and production environments.

The knowledge base has three tiers:
- **Tier 1: Research** - Raw, unvalidated material that needs investigation
- **Tier 2: Analysis** - Professionally evaluated patterns with caveats
- **Tier 3: Practice** - Battle-tested guidance ready for production use

Please analyze the article and provide:

### 1. EXECUTIVE SUMMARY
- **Core Pattern**: (One sentence describing the main actionable insight)
- **Tier Recommendation**: (1, 2, or 3 with justification)
- **Confidence Score**: (1-25 based on credibility, evidence, applicability, clarity, and risk/reward)

### 2. SOURCE EVALUATION
- **Author Credibility**: Is this from a practitioner with production experience or theoretical exploration?
- **Evidence Type**: Opinion, case study, multiple cases, research, or experiment?
- **Potential Biases**: Any vendor bias, overoptimism, or missing failure cases?

### 3. PATTERN EXTRACTION
Identify:
- **What specific problem does this solve?**
- **Implementation steps** (numbered list)
- **Prerequisites** (technical, organizational, skill-based)
- **Success metrics** (how would you measure if this works?)

### 4. RISK ASSESSMENT
- **Failure modes**: What could go wrong?
- **Red flags**: When should this pattern NOT be used?
- **Client safety**: Is this appropriate for production/client environments?

### 5. CONTEXT MAPPING
Where does this pattern apply best?
- Team size (startup/small, mid-size, enterprise)
- Industry constraints (regulated vs unregulated)
- Technical maturity required
- AI tool dependencies

### 6. KNOWLEDGE GAP ANALYSIS
- **What's missing**: What isn't addressed that practitioners would need?
- **Validation needed**: What experiments would prove/disprove this pattern?
- **Related patterns**: What other patterns would complement or conflict with this?

### 7. INTEGRATION RECOMMENDATIONS
If accepted into QED:
- **Suggested category**: (Architecture/Workflow/Security/Team/Tool/Performance/Risk/Client)
- **File path**: Where in the structure should this live?
- **Cross-references**: What existing content should link to this?
- **Title suggestion**: A clear, searchable title for the pattern

### 8. ACTIONABLE NEXT STEPS
Provide 3 specific actions:
1. Immediate filing decision and location
2. Additional research or validation needed
3. Questions to explore with real projects

### 9. CRITICAL WARNINGS
Highlight any concerns about:
- Outdated information (rapidly changing tools/APIs)
- Overgeneralization (works in specific context but presented as universal)
- Missing security/compliance considerations
- Unrealistic resource requirements

### 10. ONE-PARAGRAPH PRACTITIONER SUMMARY
Write a brief summary that a developer could read to quickly understand:
- What problem this solves
- When to use it
- What to watch out for

---

**EVALUATION CRITERIA REMINDER:**
- Prioritize patterns that are **client-safe** and **production-ready**
- Value **failure examples** as much as success stories
- Consider **ROI** for real-world implementation
- Check for **regulatory/compliance** implications
- Assess **team adoption friction**

---

## ARTICLE TO EVALUATE:

[Paste your markdown article here]

---

After evaluation, please also suggest:
- Whether this article reveals a gap in the current QED framework that needs addressing
- If this represents an emerging trend that warrants its own section
- Any counter-patterns or alternative approaches that should be documented alongside this one