---
title: "Building Agents for Small Language Models: A Deep Dive into Lightweight AI | Matt Suiche"
description: "Exploring the architecture, challenges, and implementation patterns for building AI agents with small language models (270M-32B parameters) that can run on consumer hardware"
keywords: ""
source: "https://www.msuiche.com/posts/building-agents-for-small-language-models-a-deep-dive-into-lightweight-ai/?utm_source=tldrai"
---

Aug 27, 2025 · 3777 words · 18 minute read

The landscape of AI agents has been dominated by large language models (LLMs) like GPT-4 and Claude, but a new frontier is opening up: lightweight, open-source, locally-deployable agents that can run on consumer hardware. This post shares internal notes and discoveries from my journey building agents for small language models (SLMs) – models ranging from 270M to 32B parameters that run efficiently on CPUs or modest GPUs. These are lessons learned from hands-on experimentation, debugging, and optimizing inference pipelines.

SLMs offer immense potential: privacy through local deployment, predictable costs, and full control thanks to open weights. However, they also present unique challenges that demand a shift in how we design agent architectures.

### Key Takeaways [🔗](#key-takeaways)

* **Embrace Constraints:** SLM agent design is driven by resource limitations (memory, CPU speed). Stability is more important than features.
* **Simplicity is Key:** Move complex logic from prompts to external code. Use simple, direct prompts.
* **Safety First:** Implement a multi-layer safety architecture to handle crashes and errors gracefully.
* **Structured I/O:** Use structured data formats like JSON or XML for reliable tool calling, as small models struggle with free-form generation.
* **Avoid Complex Reasoning:** Chain-of-Thought (CoT) prompting often fails with SLMs. Use alternative techniques like direct prompting with external verification or decomposed mini-chains.
* **The 270M Sweet Spot:** Ultra-small models (around 270M parameters) are surprisingly capable for specific tasks and can run on edge devices.

## Part 1: Fundamentals of SLM Agent Architecture [🔗](#part-1-fundamentals-of-slm-agent-architecture)

### Core Principles [🔗](#core-principles)

#### 1. Resource-Driven Design [🔗](#1-resource-driven-design)

ß Unlike cloud-based LLMs with near-infinite compute, SLMs operate within strict boundaries:

* **Memory:** Models must fit in RAM (typically 8-32GB).
* **Inference Speed:** CPU-only inference is significantly slower than GPU.
* **Context Windows:** 4K-32K tokens is common, compared to 128K+ for large models.
* **Batch Processing:** Small batch sizes (e.g., 512 tokens) are necessary to prevent crashes.

#### 2. Stability Over Features [🔗](#2-stability-over-features)

A stable, reliable agent is infinitely more valuable than a feature-rich one that crashes. This means:

* Extensive error handling.
* Process isolation for risky operations.
* Conservative resource allocation.
* Graceful degradation when limits are reached.

#### 3. Model-Specific Optimizations [🔗](#3-model-specific-optimizations)

Each model family (e.g., Llama, Qwen, Gemma) has unique characteristics:

* Prompt formatting dramatically affects output quality.
* Temperature and sampling parameters require model-specific tuning.
* Context sizing must align with the model’s training.

### Reference Architecture [🔗](#reference-architecture)

Hardware Layer

Inference Engine

Model Management

Safety Layer

User Layer

CPU Inference

Memory Manager

GGML Backend

Context Manager

Batch Safety

Token Generator

UTF-8 Handler

Model Detector

Unified Config

Prompt Formatter

Crash Protection

Signal Handlers

Panic Wrapper

CLI Interface

HTTP API

#### Core Components [🔗](#core-components)

1. **Safety Layer**: Prevents terminal crashes through signal handlers and panic catching
2. **Model Management**: Detects model type and applies appropriate configuration
3. **Inference Engine**: Handles token generation with batch safety and UTF-8 compliance
4. **Hardware Abstraction**: Manages CPU-only inference with memory constraints

### Cloud vs Local: Fundamental Differences [🔗](#cloud-vs-local-fundamental-differences)

#### Performance and Capability Trade-offs [🔗](#performance-and-capability-trade-offs)

| Aspect | Cloud LLMs | Local SLMs |
| --- | --- | --- |
| **Latency** | Network dependent (50-500ms) | Consistent (10-100ms first token) |
| **Throughput** | 50-200 tokens/sec | 2-20 tokens/sec |
| **Context** | 128K-1M tokens | 4K-32K tokens |
| **Availability** | Subject to rate limits | Always available |
| **Privacy** | Data leaves premises | Complete data control |
| **Cost Model** | Per-token pricing | One-time hardware cost |

#### Architectural Implications [🔗](#architectural-implications)

Local Architecture

Direct Call

App

Local Model

Hardware

Cloud architectures can rely on elastic scaling and retry logic, while local architectures must:

* Pre-allocate resources carefully
* Implement defensive programming patterns
* Handle hardware limitations gracefully
* Optimize for single-instance performance

### Essential Tooling for Open Source SLM Development [🔗](#essential-tooling-for-open-source-slm-development)

#### Required Tools and Frameworks [🔗](#required-tools-and-frameworks)

1. **Open Source Model Formats & Runtimes**
    
    * **[GGUF](https://ggml.ai/)**: The successor to GGML, a quantized format for CPU inference.
    * **[llama.cpp](https://github.com/ggerganov/llama.cpp)**: A high-performance C++ inference engine that supports various model architectures.
2. **Development Tools**
    
    * **Model Quantization**: Convert and compress models (llama.cpp quantize)
    * **Prompt Testing**: Iterate on prompt formats quickly
    * **Memory Profiling**: Track RAM usage patterns
    * **Crash Handlers**: Catch segfaults and assertion failures
3. **IDE Integration Examples**
    
    * **llama.vim to Qt Creator**: Cristian Adam’s work on [integrating AI assistance from llama.vim to Qt Creator](https://cristianadam.eu/20250817/from-llama-dot-vim-to-qt-creator-using-ai/) demonstrates how small models can enhance development workflows
    * **VSCode Extensions**: Local model integration for code completion
    * **Neovim Plugins**: Direct model interaction within text editors

#### Model Management Pipeline [🔗](#model-management-pipeline)

HuggingFace Hub  
Open Models

Download GGUF

Validate Format

Local Storage

Load on Demand

Memory Cache

Inference

### Current Limitations and Challenges [🔗](#current-limitations-and-challenges)

#### 1. Context Window Management [🔗](#1-context-window-management)

Small models struggle with limited context, requiring creative solutions:

* **Sliding window approaches**: Maintain only recent context
* **Compression techniques**: Summarize older interactions
* **Selective memory**: Store only critical information

#### 2. Reasoning Capabilities [🔗](#2-reasoning-capabilities)

SLMs often lack the deep reasoning of larger models:

* **Challenge**: Complex multi-step logic
* **Solution**: Break tasks into smaller, guided steps
* **Trade-off**: More prompting overhead

#### 3. Consistency and Hallucination [🔗](#3-consistency-and-hallucination)

Smaller models are more prone to inconsistent outputs:

* **Challenge**: Maintaining coherent long-form responses
* **Solution**: Structured prompting and validation layers
* **Reality**: Accept limitations for certain use cases

#### 4. Performance vs Quality [🔗](#4-performance-vs-quality)

The fundamental tension in SLM agents:

Smaller

Larger

Model Size

Trade-off

Fast Inference  
Low Memory  
Quick Loading

Better Quality  
More Capabilities  
Broader Knowledge

270M-7B Models

13B-32B Models

#### 5. Hardware Compatibility [🔗](#5-hardware-compatibility)

Getting models to run reliably across different hardware:

* **macOS**: Metal framework conflicts requiring `GGML_METAL=0`
* **Linux**: CUDA version mismatches
* **Windows**: Inconsistent BLAS support
* **Solution**: CPU-only fallback for maximum compatibility

#### 6. Error Recovery [🔗](#6-error-recovery)

Unlike cloud APIs with automatic retries, local agents must handle:

* Out-of-memory errors
* Assertion failures in native code
* Incomplete UTF-8 sequences
* Model loading failures

### Conclusion: Embracing Constraints [🔗](#conclusion-embracing-constraints)

Building agents for small language models requires embracing constraints and designing for reliability over raw capability. The key insights:

1. **Stability first**: A working agent beats a crashing one
2. **Know your limits**: Design around context and memory constraints
3. **Model-specific tuning**: One size doesn’t fit all
4. **Defensive architecture**: Assume things will fail
5. **Local advantages**: Privacy, consistency, and control

The next section dives deeper into specific implementation patterns, exploring advanced prompting techniques for small models and examining how to build tool-calling capabilities within resource constraints.

The future of AI agents isn’t just in the cloud - it’s also in the millions of devices running lightweight, specialized models tailored to specific tasks. Understanding how to build for this paradigm opens up new possibilities for privacy-preserving, always-available AI assistance.

* * *

## Part 2: Practical Implementation with Ultra-Small Open Source Models [🔗](#part-2-practical-implementation-with-ultra-small-open-source-models)

With open source models like [Gemma](https://deepmind.google/gemma/), [TinyLlama](https://github.com/jzhang38/TinyLlama), and [Qwen](https://github.com/QwenLM/Qwen) at just 270M-1B parameters, we’re entering an era where AI agents can run on smartphones, IoT devices, and even embedded systems. These ultra-small open source models challenge every assumption about agent architecture - they’re 100x smaller than GPT-3.5 yet can still perform surprisingly well on focused tasks. The open source nature means you can inspect, modify, and deploy them without licensing constraints.

The key insight: **stop trying to make small models behave like large ones**. Instead, embrace their constraints and design specifically for their strengths.

### Architectural Philosophy: Simplicity and Externalized Logic [🔗](#architectural-philosophy-simplicity-and-externalized-logic)

Unlike traditional LLM agents that rely on complex prompting strategies and thousands of tokens in system prompts, SLM agents require a fundamentally different approach:

#### Externalize Logic from Prompts [🔗](#externalize-logic-from-prompts)

Traditional LLM agents often embed complex logic in prompts:

```
// DON'T: Large model approach with 2000+ token system prompt
const SYSTEM_PROMPT = `You are an AI assistant that...
[500 lines of instructions]
When the user asks about X, you should...
Consider these 47 edge cases...
Follow this 23-step decision tree...`;
```

SLM agents must move this logic to code:

```
// DO: Small model approach with external logic
struct AgentRouter {
    intent_classifier: IntentClassifier,
    response_templates: HashMap<Intent, Template>,
    validation_rules: Vec<Rule>,
}

impl AgentRouter {
    fn process(&self, input: &str) -> Response {
        // 1. Classify the user's intent using a dedicated classifier.
        let intent = self.intent_classifier.classify(input);
        // 2. Select a response template based on the intent.
        let template = self.response_templates.get(&intent);
        
        // 3. Generate a minimal prompt for the model.
        let prompt = format("{}: {}", template.prefix, input);
        let response = self.model.generate(prompt, MAX_TOKENS);
        
        // 4. Post-process and validate the model's response externally.
        self.validate_and_format(response)
    }
}
```

#### Performance as a First-Class Concern [🔗](#performance-as-a-first-class-concern)

Every millisecond matters when running on edge devices:

```
// Cache everything that can be cached to avoid repeated computations.
lazy_static! {
    static ref TOKENIZER: Arc<Tokenizer> = Arc::new(load_tokenizer());
    static ref TEMPLATES: HashMap<String, String> = load_templates();
    static ref EMBEDDINGS: EmbeddingCache = EmbeddingCache::new(10_000);
}

// Pre-compute and pre-compile frequently used assets.
struct OptimizedAgent {
    // Pre-tokenized common phrases to avoid tokenizing them at runtime.
    common_tokens: HashMap<String, Vec<i32>>,
    // Pre-computed embeddings for frequent queries.
    cached_embeddings: LruCache<String, Vec<f32>>,
    // Compiled regex patterns for faster matching.
    patterns: Vec<Regex>,
}

// Batch operations aggressively to reduce overhead.
fn process_batch(queries: Vec<String>) -> Vec<Response> {
    // 1. Tokenize all queries at once.
    let all_tokens = batch_tokenize(&queries);
    
    // 2. Make a single model call for the entire batch.
    let responses = model.generate_batch(all_tokens);
    
    // 3. Use parallel processing for post-processing.
    responses.par_iter()
        .map(|r| post_process(r))
        .collect()
}
```

#### Minimal Context, Maximum Impact [🔗](#minimal-context-maximum-impact)

With only 2-4K tokens of context, every token must count:

```
struct ContextOptimizer {
    max_context: usize,  // e.g., 2048 tokens
    
    fn optimize_prompt(&self, user_input: &str, history: &[Message]) -> String {
        // 1. No system prompt: Embed behavior in the agent's code, not the prompt.
        
        // 2. Compress the conversation history aggressively.
        let compressed_history = self.compress_messages(history);
        
        // 3. Use the shortest possible instructions for the model.
        format!("Q: {}\nA:", user_input)  // Instead of "Question: ... Assistant Response:"
    }
    
    fn compress_messages(&self, messages: &[Message]) -> String {
        // Keep only the most essential information from the conversation history.
        messages.iter()
            .rev()
            .take(2)  // Only include the last 2 exchanges.
            .map(|m| format!("{}: {}", 
                m.role.as_str().chars().next().unwrap(),  // Use "U:" instead of "User:".
                truncate(&m.content, 50)))  // Truncate long messages.
            .collect::<Vec<_>>()
            .join("\n")
    }
}
```

### Core Implementation Patterns [🔗](#core-implementation-patterns)

Here are battle-tested patterns for building robust SLM agents:

#### 1. Multi-Layer Safety Architecture [🔗](#1-multi-layer-safety-architecture)

Crashes are inevitable. A defense-in-depth approach is crucial to keep agents running:

```
// Layer 1: Signal handlers for C-level crashes (e.g., segfaults)
unsafe fn install_signal_handlers() {
    let signals = [SIGSEGV, SIGBUS, SIGILL, SIGFPE, SIGABRT];
    for signal in signals {
        if sigaction(signal, &action, std::ptr::null_mut()) != 0 {
            warn!("Failed to install handler for signal {}", signal);
        }
    }
}

// Layer 2: Panic catching for Rust errors
let load_result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
    LlamaModel::load_from_file(&backend, model_path_str.clone(), &model_params)
}));

// Layer 3: Process isolation and error handling
match load_result {
    Ok(Ok(m)) => m,
    Ok(Err(e)) => handle_model_error(e),
    Err(panic_info) => recover_from_panic(panic_info),
}
```

This three-layer approach prevents terminal crashes, even when the underlying GGML library fails.

#### 2. Dynamic Batch Management [🔗](#2-dynamic-batch-management)

Small models can’t handle large batches. Enforce strict, safe limits:

```
fn get_safe_batch_size() -> usize {
    // A fixed size like 512 prevents GGML_ASSERT failures
    512
}

fn prepare_batch_with_safety(tokens: &[i32], context_size: usize) -> Result<(LlamaBatch, usize)> {
    let safe_size = get_safe_batch_size();
    let actual_size = tokens.len().min(safe_size);
    
    if tokens.len() > safe_size {
        warn!("Truncating {} tokens to {} for safety", tokens.len(), safe_size);
    }
    
    let mut batch = LlamaBatch::new(actual_size, 1);
    for (i, &token) in tokens[..actual_size].iter().enumerate() {
        batch.add(token, i as i32, &[0], false)?;
    }
    
    Ok((batch, actual_size))
}
```

#### 3. Model-Specific Configuration [🔗](#3-model-specific-configuration)

Different model families require different configurations. Abstract this away with a unified config:

```
// A unified configuration structure for different model families.
pub struct UnifiedModelConfig {
    pub temperature: f32,
    pub top_p: f32,
    pub top_k: i32,
    pub max_context: usize,
    pub format_type: ModelFormat,
}

impl UnifiedModelConfig {
    // Returns a model-specific configuration.
    pub fn for_model(name: &str) -> Self {
        if name.contains("gemma") {
            // Configuration for Gemma models.
            Self { temperature: 0.3, top_p: 0.95, top_k: 10, max_context: 2048, format_type: ModelFormat::Gemma }
        } else if name.contains("qwen") {
            // Configuration for Qwen models.
            Self { temperature: 0.7, top_p: 0.8, top_k: 20, max_context: 32768, format_type: ModelFormat::ChatML }
        } else if name.contains("tinyllama") || name.contains("llama") {
            // Configuration for Llama models.
            Self { temperature: 0.6, top_p: 0.9, top_k: 15, max_context: 4096, format_type: ModelFormat::Llama }
        } else {
            // Default configuration.
            Self::default()
        }
    }
}
```

#### 4. Streaming with UTF-8 Safety [🔗](#4-streaming-with-utf-8-safety)

Small models often generate incomplete UTF-8 sequences. Buffer and validate the output stream to prevent errors:

```
// A buffer to handle incomplete UTF-8 sequences when streaming responses.
struct Utf8Buffer {
    incomplete: Vec<u8>,
}

impl Utf8Buffer {
    // Processes a new chunk of bytes from the model's output stream.
    fn process_bytes(&mut self, new_bytes: &[u8]) -> String {
        // 1. Combine the new bytes with any incomplete bytes from the previous chunk.
        let mut combined = std::mem::take(&mut self.incomplete);
        combined.extend_from_slice(new_bytes);
        
        // 2. Try to convert the combined bytes to a UTF-8 string.
        match String::from_utf8(combined) {
            // If successful, the buffer is cleared.
            Ok(valid) => valid,
            // If it fails, store the incomplete remainder for the next chunk.
            Err(e) => {
                let (valid, remainder) = combined.split_at(e.utf8_error().valid_up_to());
                self.incomplete = remainder.to_vec();
                String::from_utf8_lossy(valid).into_owned()
            }
        }
    }
}
```

### Advanced Prompting and Reasoning [🔗](#advanced-prompting-and-reasoning)

Small models require different prompting strategies than their larger counterparts. Here’s how to get the most out of them.

#### 1. The Chain-of-Density Approach [🔗](#1-the-chain-of-density-approach)

Instead of long, complex reasoning chains, use a progressive compression technique:

User Query

Step 1: Extract Key Terms

Step 2: Simple Answer

Step 3: Compress & Validate

Response

This forces the model to focus on one simple task at a time.

#### 2. Role Specialization with Micro-Agents [🔗](#2-role-specialization-with-micro-agents)

Deploy multiple specialized micro-agents instead of one generalist:

```
enum MicroAgent {
    CodeCompleter,
    ErrorExplainer,
    DocGenerator,
    TestWriter,
}

impl MicroAgent {
    fn get_system_prompt(&self) -> &str {
        match self {
            Self::CodeCompleter => "Complete code. No explanations.",
            Self::ErrorExplainer => "Explain error. Be concise.",
            Self::DocGenerator => "Write docs. Use examples.",
            Self::TestWriter => "Generate tests. Cover edge cases.",
        }
    }
}
```

#### 3. Aggressive Context Management [🔗](#3-aggressive-context-management)

With only 2-4K tokens, every token is precious:

```
struct ContextManager {
    max_tokens: usize,
    history: VecDeque<Message>,
}

impl ContextManager {
    fn compress_context(&mut self) -> String {
        let mut token_budget = self.max_tokens;
        let mut compressed = String::new();
        
        // Keep only the most recent and relevant messages
        while let Some(msg) = self.history.pop_front() {
            let msg_tokens = estimate_tokens(&msg.content);
            if token_budget > msg_tokens {
                compressed.push_str(&msg.content);
                token_budget -= msg_tokens;
            } else {
                // Summarize older messages or drop them
                compressed.push_str("[Previous context omitted]");
                break;
            }
        }
        
        compressed
    }
}
```

### Reasoning and Tool Calling [🔗](#reasoning-and-tool-calling)

Small models struggle with complex reasoning and tool selection. Here’s how to build reliable systems.

#### Why Chain-of-Thought (CoT) Fails with Small Models [🔗](#why-chain-of-thought-cot-fails-with-small-models)

Chain-of-Thought (CoT) prompting, which asks models to “think step-by-step,” is highly effective for large models but often fails with SLMs. Small models lack the working memory to maintain coherent reasoning chains, leading to:

* Lost context and nonsensical steps.
* Wasted tokens on broken logic.
* Hallucinated reasoning that sounds plausible but is incorrect.

Instead of CoT, use these alternatives:

##### 1. Direct Prompting with External Verification [🔗](#1-direct-prompting-with-external-verification)

Don’t ask the model to reason. Get a direct answer and verify it externally.

```
fn solve_with_verification(question: &str) -> Result<Answer> {
    // Simple, direct prompt
    let prompt = format!("Answer: {}", question);
    let raw_answer = model.generate(prompt, 20); // Expect a short response
    
    // Verify the answer externally
    let parsed = parse_answer(&raw_answer)?;
    if validate_answer(&parsed, &question) {
        Ok(parsed)
    } else {
        // Fallback to a rule-based solution or another method
        solve_with_rules(question)
    }
}
```

##### 2. Decomposed Mini-Chains [🔗](#2-decomposed-mini-chains)

Break complex reasoning into tiny, focused steps orchestrated by external code.

```
struct MiniChainExecutor {
    steps: Vec<MiniStep>,
}

impl MiniChainExecutor {
    fn execute(&self, input: &str) -> Result<String> {
        let mut context = input.to_string();
        
        for step in &self.steps {
            // Each step is a single, simple operation
            let prompt = step.build_prompt(&context);
            let result = model.generate(&prompt, 30);
            
            // Validate and extract only the necessary information
            let extracted = step.extract_value(&result)?;
            context = format!("{}\n{}: {}", context, step.name, extracted);
        }
        
        Ok(context)
    }
}
```

#### Tool Calling with Structured Outputs [🔗](#tool-calling-with-structured-outputs)

Small models struggle with free-form JSON. Use structured formats like XML or guided templates for reliable tool calling.

##### 1. Deterministic Tool Routing [🔗](#1-deterministic-tool-routing)

Use pattern matching to route to tools instead of letting the model decide.

```
fn route_to_tool(input: &str) -> Option<Tool> {
    if input.starts_with("search:") {
        Some(Tool::WebSearch)
    } else if input.starts_with("calc:") {
        Some(Tool::Calculator)
    } else {
        None
    }
}
```

##### 2. Structured Output with XML [🔗](#2-structured-output-with-xml)

XML is often more reliable than JSON for small models due to its explicit closing tags. The Qwen team has demonstrated this with their open-source models.

```
// Basic XML extraction for small models
fn extract_xml_content(response: &str) -> HashMap<String, String> {
    let mut result = HashMap::new();
    let tag_pattern = Regex::new(r"<(\w+)>(.*?)</\1>").unwrap();
    
    for caps in tag_pattern.captures_iter(response) {
        let tag = caps.get(1).map_or("", |m| m.as_str());
        let content = caps.get(2).map_or("", |m| m.as_str());
        result.insert(tag.to_string(), content.to_string());
    }
    
    result
}

// Advanced XML parsing inspired by Qwen3's approach
// Reference: https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct/blob/main/qwen3coder_tool_parser.py
struct AdvancedXMLParser {
    // Sentinel tokens for parsing
    tool_call_start: String,    // "<tool_call>"
    tool_call_end: String,      // "</tool_call>"
    function_prefix: String,    // "<function="
    function_end: String,       // "</function>"
    parameter_prefix: String,   // "<parameter="
    parameter_end: String,      // "</parameter>"
}

impl AdvancedXMLParser {
    fn parse_function_call(&self, xml_str: &str) -> Result<ParsedFunction> {
        // Extract function name from <function=NAME>
        if let Some(func_start) = xml_str.find(&self.function_prefix) {
            let name_start = func_start + self.function_prefix.len();
            let name_end = xml_str[name_start..].find(">")
                .ok_or("Invalid function tag")?;
            let function_name = &xml_str[name_start..name_start + name_end];
            
            // Extract parameters between function tags
            let params_start = name_start + name_end + 1;
            let params_end = xml_str.find(&self.function_end)
                .ok_or("Missing function end tag")?;
            let params_section = &xml_str[params_start..params_end];
            
            // Parse individual parameters
            let mut parameters = HashMap::new();
            let param_regex = Regex::new(&format!(
                r"{}(.*?)>(.*?){}",
                regex::escape(&self.parameter_prefix),
                regex::escape(&self.parameter_end)
            ))?;
            
            for cap in param_regex.captures_iter(params_section) {
                let param_name = cap.get(1).map_or("", |m| m.as_str());
                let param_value = cap.get(2).map_or("", |m| m.as_str())
                    .trim_start_matches('\n')
                    .trim_end_matches('\n');
                
                // Type conversion based on parameter schema
                let converted_value = self.convert_param_value(
                    param_value, 
                    param_name, 
                    function_name
                );
                parameters.insert(param_name.to_string(), converted_value);
            }
            
            Ok(ParsedFunction {
                name: function_name.to_string(),
                arguments: parameters,
            })
        } else {
            Err(anyhow::anyhow!("No function tag found"))
        }
    }
    
    fn convert_param_value(&self, value: &str, param: &str, func: &str) -> serde_json::Value {
        // Handle null values
        if value.to_lowercase() == "null" {
            return serde_json::Value::Null;
        }
        
        // Try to parse as JSON first (for objects/arrays)
        if let Ok(json_val) = serde_json::from_str(value) {
            return json_val;
        }
        
        // Try to parse as number
        if let Ok(num) = value.parse::<f64>() {
            if num.fract() == 0.0 {
                return serde_json::json!(num as i64);
            }
            return serde_json::json!(num);
        }
        
        // Try to parse as boolean
        if value == "true" || value == "false" {
            return serde_json::json!(value == "true");
        }
        
        // Default to string
        serde_json::json!(value)
    }
}

// Tool-specific XML parsers for common operations
#[derive(Debug, Clone)]
enum ToolCall {
    FileSystem { action: String, path: String, content: Option<String> },
    WebSearch { query: String, max_results: i32 },
    Calculator { expression: String },
    Database { query: String, table: String },
    Shell { command: String, args: Vec<String> },
}

impl ToolCall {
    fn from_xml_data(data: HashMap<String, String>) -> Result<Self> {
        let tool_type = data.get("tool").ok_or("Missing tool type")?;
        
        match tool_type.as_str() {
            "filesystem" => Ok(ToolCall::FileSystem {
                action: data.get("action").cloned().unwrap_or_default(),
                path: data.get("path").cloned().unwrap_or_default(),
                content: data.get("content").cloned(),
            }),
            "search" => Ok(ToolCall::WebSearch {
                query: data.get("query").cloned().unwrap_or_default(),
                max_results: data.get("max_results")
                    .and_then(|s| s.parse().ok())
                    .unwrap_or(5),
            }),
            "calculator" => Ok(ToolCall::Calculator {
                expression: data.get("expression").cloned().unwrap_or_default(),
            }),
            "database" => Ok(ToolCall::Database {
                query: data.get("query").cloned().unwrap_or_default(),
                table: data.get("table").cloned().unwrap_or_default(),
            }),
            "shell" => Ok(ToolCall::Shell {
                command: data.get("command").cloned().unwrap_or_default(),
                args: data.get("args")
                    .map(|s| s.split(',').map(|a| a.trim().to_string()).collect())
                    .unwrap_or_default(),
            }),
            _ => Err(anyhow::anyhow!("Unknown tool type: {}", tool_type))
        }
    }
}

// Example prompts for different tool calls
const FILE_TOOL_PROMPT: &str = r#"
Generate a filesystem tool call using XML tags:
<tool>filesystem</tool>
<action>read|write|delete|list</action>
<path>/path/to/file</path>

Example:
User: "Read the config file"
<tool>filesystem</tool>
<action>read</action>
<path>/etc/config.yaml</path>
"###;
```

##### 3. Multi-Strategy Parsing [🔗](#3-multi-strategy-parsing)

For maximum robustness, try multiple parsing strategies in order of reliability:

1. **Code Block Extraction:** Look for structured data within `json or` xml blocks.
2. **XML Parsing:** Parse the entire output for XML tags.
3. **Keyword-Based Extraction:** As a last resort, search for keywords and extract the relevant data.

```
fn parse_tool_call(response: &str) -> Result<ToolCall> {
    // 1. Try code block first
    if let Some(block) = extract_code_block(response) {
        if let Ok(tool_call) = serde_json::from_str(&block) {
            return Ok(tool_call);
        }
    }
    
    // 2. Try XML parsing
    let xml_data = extract_xml_content(response);
    if !xml_data.is_empty() {
        return ToolCall::from_xml_data(xml_data);
    }
    
    // 3. Fallback to keyword extraction
    extract_with_keywords(response)
}
```

#### Fallback Chains [🔗](#fallback-chains)

Always have a backup plan for when a model fails:

Yes

No

Yes

No

Try Primary Model

Success?

Return Result

Simplify Prompt & Retry

Success?

Use Rule-Based Fallback

### Deployment and Lessons Learned [🔗](#deployment-and-lessons-learned)

Deploying SLM agents in the real world requires a different mindset. Here are key patterns and takeaways.

#### 1. Hybrid Deployment Architecture [🔗](#1-hybrid-deployment-architecture)

For robust applications, combine the strengths of local and cloud models:

Cloud Backup

Edge Device

Complex Query

Cached Result

Large Model API

Result Cache

Local Agent  
270M Model

Cache Layer

Fallback Rules

This hybrid approach uses the local model for speed and privacy, escalating to a more powerful cloud model only when necessary.

#### 2. Hybrid Processing Pipeline [🔗](#2-hybrid-processing-pipeline)

Use a cascade of specialized small models to handle complex queries efficiently.

```
async fn hybrid_inference(query: &str) -> Result<String> {
    // Step 1: Use a tiny, fast model for intent classification.
    let intent = intent_classifier_model.generate(&format!("Classify: {}", query)).await?;

    // Step 2: Route to a specialized model based on the intent.
    let specialist_model = match intent.as_str() {
        "code" => get_code_model(), // e.g., a 1B CodeLlama
        "qa" => get_qa_model(),       // e.g., a 1B Qwen model
        _ => get_general_model(),   // e.g., a 2B Gemma model
    };

    let specialist_response = specialist_model.generate(query).await?;

    // Step 3: Use a slightly larger model to refine or validate the response.
    let final_response = refiner_model.generate(&format!(
        "User query: {}\nSpecialist response: {}\nRefine the response:",
        query,
        specialist_response
    )).await?;

    Ok(final_response)
}
```

#### 3. The 270M Parameter Sweet Spot [🔗](#3-the-270m-parameter-sweet-spot)

Ultra-small open source models around 270M parameters (like Gemma 3, Qwen-Nano, and TinyLlama) are ideal for edge deployment:

* **Fast Inference:** Achieves high token-per-second rates on modern mobile devices.
* **Minimal Footprint:** Low memory usage with quantization.
* **Low Power Consumption:** Suitable for battery-powered devices.
* **Basic Capabilities:** Reliably handles completion, simple Q&A, and instruction following.

#### Key Takeaways: What Works and What Doesn’t [🔗](#key-takeaways-what-works-and-what-doesnt)

**What Works:**

* **Aggressive Caching:** Cache everything you can (tokens, embeddings, responses).
* **Fail Fast:** Use tight timeouts and have robust fallback mechanisms.
* **Structured I/O:** Force model outputs into parseable formats like XML or JSON.
* **Hardware Awareness:** Design your agent to adapt to available resources.

**What Doesn’t Work:**

* **Complex, Multi-Step Reasoning:** SLMs fail at this. Keep it simple.
* **Long Contexts:** Performance degrades quickly. Be ruthless with context management.
* **Free-Form Tool Use:** Don’t let the model choose from many tools. Guide it.
* **Nuanced Responses:** SLMs are not subtle. Be direct in your prompts.

### Future Directions and Conclusion [🔗](#future-directions-and-conclusion)

Building agents for small language models is about specialization, not compromise. By embracing their constraints, we can create agents that are reliable, fast, private, and efficient.

The key insight from building production SLM agents is that **constraints breed creativity**. When you can’t rely on massive compute and infinite context, you’re forced to build better, more robust systems. The open-source nature of these models provides transparency, community collaboration, and the ability to customize for specific use cases without vendor lock-in.

The next frontier isn’t making small models act like large ones—it’s discovering the unique capabilities that emerge when we design specifically for them.

* * *

**Let’s Connect**: If you’re exploring small language models and building agents for edge deployment, I’d love to brainstorm. The SLM space is evolving rapidly. Reach out via email or on X ([@msuiche](https://x.com/msuiche)).