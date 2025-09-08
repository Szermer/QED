---
title: "Understanding LLMs: Insights from Mechanistic Interpretability — LessWrong"
description: "2 minute summary
 * At a high level, a transformer-based LLM is an autoregressive, next-token predictor. It takes a sequence of "tokens" (words or pa…"
keywords: ""
source: "https://www.lesswrong.com/posts/XGHf7EY3CK4KorBpw/understanding-llms-insights-from-mechanistic?utm_source=tldrai"
---

## 2 minute summary

* At a high level, a transformer-based LLM is an autoregressive, **next-token predictor**. It takes a sequence of "tokens" (words or parts of words) as input and produces a prediction for what the next token should be. This prediction takes the form of a probability distribution. Sampling from this distribution results in the next token. This newly selected token is appended to the sequence, and the entire process repeats to generate the next token. This loop is repeated until the full response is outputted.
* The model processes text through a pipeline that involves the main components of the transformer:
    * **Tokenizer:** Breaks the input sentence into a list of tokens (words or parts of words).
    * **Embedding layer:** Converts each token into a high-dimensional vector representing its meaning in isolation.
    * **Transformer blocks:** The core of the model, consisting of multiple layers that progressively refine the meaning of tokens in context. Each transformer layer is composed of a self-attention and MLP (multi-linear perceptron) sub-layer.
    * **Unembedding layer & softmax:** Converts the final processed residual stream vectors back into a probability distribution over the entire vocabulary to select the next token.
* **The residual stream:** This is the central backbone of the transformer. It's a list of vectors (one for each token) that flows through the model. Its shape is the same as the output of the embedding layer. The residual stream starts after the embedding layer and finishes at the unembedding layer.
* **Attention sub-layers:** The primary mechanism for understanding context. Attention heads move information between token positions.
    * They work by having a "query" at a destination token look for relevant information from the "keys" of all previous source tokens.
    * Information from the source tokens' "values" is then copied to the destination, weighted by how much attention was paid.
    * Specialized attention heads can form algorithms, like induction heads, which are crucial for in-context learning by recognizing and completing repeated patterns.
* **MLP sub-layers** These layers form about two-thirds of the model's parameters and are considered its knowledge store.
    * They function as vast key-value memories, where "keys" act as pattern detectors (e.g., "text is about TV shows") and "values" contain the likely next tokens associated with that pattern.
* **The problem of superposition:** LLMs learn far more features (concepts, ideas, patterns) than they have neurons. This forces each neuron to be "polysemantic" and respond to multiple unrelated concepts. This makes it difficult to understand what any single neuron is doing.
* **Solving superposition with sparse autoencoders (SAEs):** To make the model interpretable, SAEs are used to deconstruct the dense, polysemantic activations into a much larger set of sparse, monosemantic features. Each of these new features corresponds to a single, human-understandable concept (e.g., "The Golden Gate Bridge").
* **Circuit tracing and attribution graphs:** This technique goes a step further, aiming to explain how the model reasons. The model's uninterpretable MLP sub-layers are replaced with interpretable transcoders. The process then traces the flow of information between the monosemantic features within these transcoders, producing an attribution graph. This graph is essentially a circuit diagram, showing the specific sub-network of interconnected features that causally work together to produce a particular output, revealing the "algorithm" the model uses for that task.
* **How do LLMs work?:** Simple analogies like "it's just statistics" or "it's like a computer program" are inadequate explanations of how LLMs work. A better explanation is that LLMs perform tasks by forming emergent circuits. These circuits combine learned statistics, information-moving attention heads, and knowledge-storing MLP sub-layers into specialized sub-networks that collectively execute complex behaviors.

## Introduction

Since the release of ChatGPT in 2022, large language models (LLMs) based on the transformer architecture like ChatGPT, Gemini and Claude have transformed the world with their ability to produce high-quality, human-like text and more recently the ability to produce images and videos. Yet, behind this incredible capability lies a profound mystery: we don’t understand how these models work.

The reason is that LLMs aren't built like traditional software. A traditional program is designed by human programmers and written in explicit, human-readable code. But LLMs are different. Instead of being programmed, LLMs are automatically trained to predict the next word on vast amounts of internet text, growing a complex network of trillions of connections that enable them to perform tasks and understand language. This training process automatically creates emergent knowledge and abilities, but the resulting model is usually messy, complex and incomprehensible since the training process optimizes the model for performance but not interpretability or ease of understanding.

The field of mechanistic interpretability aims to study LLM models and reverse engineer the knowledge and algorithms they use to perform tasks, a process that is more like biology or neuroscience than computer science.

The goal of this post is to provide insights into how LLMs work using findings from the field of mechanistic interpretability.

## High-level overview of a transformer language model

Today the transformer, an ML model architecture introduced in 2017, is the most popular architecture for building LLMs. How a transformer LLM works depends on whether the model is generating text (inference) or learning from training data (training).

## Transformer LLM during inference

Usually when we interact with an LLM such as ChatGPT, it’s in inference mode. This means that the model is not learning and is optimized for outputting tokens as efficiently as possible. This process is autoregressive: the model generates one token at a time, appends it to the input, and uses the new, longer sequence to generate the next token.

Initially, the model takes a sequence of N tokens as input, and its first task is to predict the token that should come next at position N+1. To do this, it processes the entire prompt in parallel and produces a prediction for the next token at position N+1. This prediction takes the form of a probability distribution over the model's entire vocabulary, which can exceed 100,000 tokens. Every possible token is assigned a probability, indicating how likely it is to be selected for the next token. A sampling strategy, such as greedy decoding (which simply chooses the token with the highest probability), is then used to select a single token from this distribution. This newly selected token is appended to the sequence, and the entire process repeats to generate the next token, continuing the loop until the full response is formed.

### Prefill vs decode

The inference process is broken up into two steps: [prefill and decode](https://developer.nvidia.com/blog/mastering-llm-techniques-inference-optimization/).

1. **Prefill:** In the first step, the model processes the entire initial prompt. A key feature of the transformer architecture is that all N tokens of this prompt are processed in parallel in a single forward pass of the model. This phase is computationally intensive because it builds the initial context, calculating attention relationships for every token in the prompt. Its two main tasks are to generate the very first new token and to populate the KV cache with the prompt's attention data. Generating the first output token is slower than subsequent tokens since the prefill step is more computationally intensive than the decode step.
2. **Decode:** The model then generates the second token and all subsequent tokens one at a time in the decode phase. This phase is much more efficient because the model only needs to process the single newest token while reusing previous calculations via the KV cache.

This two-phase approach is made possible by a crucial optimization called the KV cache. The cache acts as short-term memory, storing intermediate calculations (the keys and values from the self-attention mechanism) generated during the parallel prefill phase. In the decoding phase, the model accesses this cache to get the contextual information from all previous tokens without having to re-process them, solving what would otherwise be a major performance bottleneck of redundant computation.

The input and output tensor (matrix) shapes are different for the prefill and decode steps. Assuming a batch size of 1 for a single user interaction:

* **Prefill:** The input tensor containing the prompt has a shape of [1, N], where N is the number of tokens in the prompt. The model processes this and produces an output logit tensor of shape [1, N, vocab_size] which is like a list of probability distributions where each distribution is a vector. We only need the last vector at position N to get the predicted token at position N + 1.
* **Decode:** For all subsequent tokens, the input tensor’s shape is just [1, 1] and contains only the most recently generated token. The model leverages the KV cache for context and outputs a logits tensor of shape [1, 1, vocab_size] which is transformed into the probability distribution for predicting the next token.

![](https://39669.cdn.cke-cs.com/rQvD3VnunXZu34m86e5f/images/fb08073a9c6a151e27a8d0fb25682d52ba1ac32bfaefd337.png)

Figure 1: Diagram showing a Transformer during the inference prefill phase for producing the first output token. The model takes N tokens (e.g., "The", "cat", "sat") as input and processes them in parallel within a single forward pass. Although it computes an output logit (p0, p1, p2) for every input token, only the final logit (p2) is used to sample the next word ("on") in the sequence.

![](https://39669.cdn.cke-cs.com/rQvD3VnunXZu34m86e5f/images/51181d645599408701101a2c29361532b00370809fd13e51.png)

Figure 2: Diagram showing a transformer during the inference decode phase for producing the second token and beyond. The model uses the KV Cache for context from previous tokens and takes only the single newest token ("on") as input. It produces a single logit prediction (p3) for the next output word.

## Transformer LLM during training

During training, the transformer produces N predictions, one for every token in the sentence. For each input position i, the output prediction at position i is the predicted token for position i + 1 (the next token). The ability to make multiple predictions increases training efficiency.

These predictions are compared to the actual words in the sentence and the prediction errors are used to update the parameters of the model and improve its performance.

## Transformer architecture and components

In this section we will learn about the components that make up a transformer LLM rather than treating the whole model as a black box like the first section.

![](https://39669.cdn.cke-cs.com/rQvD3VnunXZu34m86e5f/images/3718c3a7ee332792e341b80707f006a1e4b5514de15cda1e.png)

Figure 3: Diagram showing the transformer architecture end-to-end with all key components. We can begin to understand transformers by understanding the function of each of these components at a high level. We will also dive deeper into the inner workings of some of these components using findings from the field of mechanistic interpretability.

## Transformer processing steps

The following steps describe the sequence of events needed for a transformer to process an input sentence and output a new token.

## Step 1: tokenization: from text to tokens

* Initially the LLM receives a sentence as input such as “The cat sat”.
* This sentence is broken down into smaller pieces called tokens. A token might be a whole word (e.g., “hello”), a part of a word (e.g., “inter” and “pret” for “interpret”), or punctuation.
* Each unique token in the model's vocabulary is assigned a specific number. So, “The cat sat” might become [10, 35, 800]. This list of numbers is the list of tokens and the output of the tokenizer.
* Positional embeddings are also added to the embeddings to capture information about the position of tokens in the sentence.
* Insight: This tokenization process can sometimes explain why LLMs might struggle with tasks like precise arithmetic, as numbers can be split into multiple tokens (e.g., "1,234" might become ["1", ",", "234"]) or counting the number of ‘r’s in the word ‘strawberry’.

## Step 2: embedding: giving meaning to tokens

* The tokens are then converted into embedding vectors. An embedding vector is a list of numbers (often hundreds or thousands long) that represents each token's meaning.
* The embedding layer involves multiplying the list of tokens (numbers) by the embedding matrix which has shape [d_vocab, d_model]. There is a row in the embedding matrix for every word in the vocabulary and each row is an embedding vector for a specific token. The embedding matrix essentially functions as a lookup table where each token is mapped to a specific learned embedding vector depending on its index in the vocabulary. For example, if our vocabulary has 50,000 tokens and our model uses 1000-dimensional embeddings, the embedding matrix would be a 50,000 x 1,000 matrix.
* How do vectors represent the meaning of words? One intuition is that LLMs learn to create similar embedding vectors for words that have a similar meaning (e.g. the words see, look, watch). Similar vectors have a similar direction in the high-dimensional embedding space and there is a relatively small angle between them.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/fcd7b79c4fd80f727d6303cec2c9fc746b801ac9a8196be961b4cd604b4e01f1/w0yzzqdaohpypvglce8w)

Figure 4: Word embeddings are high-dimensional (e.g. 1000 dimension) vectors. The diagram is limited to two dimensions for clarity. Words with similar meanings have vectors that point in similar directions, resulting in a low angle between them.

## Step 3: The residual stream: the backbone of the transformer

* Throughout the transformer, data flows through what's called the residual stream. This stream is a list of vectors, one for each token position. The shape of the residual stream is [seq_len, d_model] which is the same as the output of the embedding layer.
* The residual stream is like a central communication channel or a shared workspace. Different components of the transformer read from and write to this stream, progressively refining the information at each token position.
* Insight: the initial state of the residual stream (the output of the embedding layer) is the meaning of each word in isolation and without considering context. The transformer block layers iteratively refine the meaning of each vector depending on previous tokens (see the [logit lens](https://www.lesswrong.com/posts/AcKRB8wDpdaN6v6ru/interpreting-gpt-the-logit-lens)).

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/XGHf7EY3CK4KorBpw/keun4ufjb53o64jlgrak)

Figure 5: A single transformer block showing multiple attention heads and the MLP layer.

## Step 4: Attention heads: how transformers move information between positions and make use of context

* The embedding matrix provides the initial meaning of each word in isolation.
* Perhaps the most crucial innovation in transformers is the attention mechanism. Its role is to move information from earlier to later token positions and it’s therefore crucial for allowing LLMs to understand the meaning of words in the context of previous words.
* For example, the word “bank” has a completely different meaning in the two sentences “I swam near the river bank” and “I got cash from the bank”. These two sentences illustrate the importance of context when reasoning about the meaning of words.
* An attention layer usually consists of multiple attention heads, each operating independently and in parallel.
* Each attention head can be thought of as having two main circuits:
    * **QK (Query-Key) Circuit:** This circuit determines _where_ to move information from. For each destination token (query), it calculates an attention pattern for every source token (key) in the sequence so far. These scores are turned into probabilities, indicating how much attention the destination (query) token should pay to each source (key) token.
    * **OV (Output-Value) Circuit:** This circuit determines _what_ information to move. For each source (key) token, a value vector is created. The output for a destination (query) token is then a weighted average of these value vectors, where the weights come from the attention pattern from the QK circuit. This result is then added back into the residual stream at the destination token's position.
* Essentially, a high attention score means the source token (key) contains information that the destination token (query) is “looking for” and the value vector is the information that gets moved.
* Key point: the query token (destination) always comes later in the sequence than the key tokens (source) as tokens only depend on past tokens and can’t depend on future tokens that haven’t been generated yet.
* Intuition: each query is like a ‘question’ about all previous tokens and the keys and values provide the ‘answer’.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/XGHf7EY3CK4KorBpw/utsdddg88edlh9etb57j)

Figure 6: Showing the attention pattern for a single query produced by the QK circuit. Note that every input token has its own query.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/cb52a495d4c51d714b6dd255870619f32a90d948d2e548c1337983c0b5fb9bc6/p7eibixxgr1ogdos6sub)

Figure 7: Showing a full attention pattern with a query for every word in the sentence. Each row is a single destination token (query). All the columns for that row are the query’s keys. Induction heads are also active in this attention pattern.

### A key attention mechanism: induction heads

[Induction heads](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html) are a specialized attention head in transformer models that are considered a key mechanism for in-context learning. In-context learning is the ability of transformers to learn new tasks from multiple examples of them given in the prompt (few-shot prompting).

Induction heads implement the following algorithm: “If the token A is followed by the token B earlier in the context, when the token A is seen again, the induction head strongly predicts that B will come next.”

Note that induction heads can be considered an algorithm since they can detect patterns in arbitrary repeated sequences even when they were never in the training data.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/9a246a048b64065398cfb0c9c6cb4db2134dbe3bc082c1766f24514fa4eb3125/cwszcxd2hdxbdy8cpe8f)

Figure 8: Induction heads are special attention heads that contribute to in-context learning in transformers. Induction heads attend to the token after the previous instance of the current token in a repeated sequence.

### How induction heads work

An induction head is a specialized attention head in a transformer that excels at in-context learning by detecting and completing patterns it has already seen in the prompt.

The induction circuit consists of two heads: a previous token head in the first layer and an induction head in the second layer:

1. The previous token head in layer one copies information from the “sat” token to the “on” token in the first sequence. The “on” token in the first sequence now has information saying “The word that came before me was sat”.
2. The induction head in the second layer finds the previous place in the sequence where the current token “sat” occurred and attends to the token immediately after it which is “on”. It copies this information from “on” in the first sequence to “sat” in the second sequence and increases the probability of the token “on” when producing the next token.

Insight: induction heads are evidence that LLMs can learn algorithms rather than just memorizing data. Since induction heads can only form in transformers that have at least two layers, this is evidence that larger models have qualitatively different algorithms.

### Induction heads in the attention pattern

The off-center diagonal purple stripe in the triangular attention pattern (figure 7) is the result of induction heads. Each token in the repeated second sentence strongly attends to the next token of the sequence from the first sentence.

### Indirect object identification (IOI) and attention heads

Another way to understand attention is by understanding how a task called [indirect object identification](https://arxiv.org/abs/2211.00593) (IOI) is implemented using attention heads.

Given a sentence like “When Mary and John went to the store, John gave a drink to” the answer is “Mary” and this task is called indirect object identification (IOI).

In 2022, researchers at Redwood Research reverse engineered a detailed circuit for implementing this task that involves several different types of attention heads.

The circuit implements a three-step process:

1. Identify all names in the sentence (Mary, John, John).
2. Eliminate the duplicated name (John).
3. Output the remaining name (Mary).

This algorithm is carried out by three main groups of specialized attention heads working in sequence:

* **Duplicate token heads:** are active at the second position where “John” (S2) and attend to the first position where “John” is (S1).
* **S-inhibition heads:** remove duplicate tokens from name mover heads’ attention. They are active at the last token, attend to the S2 (second “John”) token, and write to the query of the name mover heads, inhibiting their attention to S1 and S2 tokens.
* **Name mover heads:** attend to previous names and copy them to the final position. Since the duplicate “John” token is suppressed by the S-inhibition heads, the name mover heads attend to the remaining, non-duplicated name (“Mary”) and copy it, making it the predicted next token.

## Step 6: MLP layers: the knowledge store

The MLP (multi-layer perceptron) sub-layer is applied after the attention sub-layer in a transformer block. Each MLP sub-layer is a standard two-layer feed-forward neural network with two weight matrices and one activation function and can be written mathematically as:

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/XGHf7EY3CK4KorBpw/nbum1hsojn7kqptkbouy)

During both training and the initial pre-fill step of inference, the MLP layer processes all token vectors in parallel via matrix multiplication. However, in the subsequent decode step of the inference process, where new tokens are generated one by one, the MLP is applied only to the single newest token to help predict the next one.

About two thirds of the parameters in a transformer are in the MLP layers. The other third of parameters can be found in the attention, embedding and un-embedding layers.

One simple intuition for what MLPs do is that they store the model’s knowledge it needs to predict words and answer questions. For example, knowing that the sentence “The Eiffel Tower is in the city of” should be followed by “Paris” requires knowledge about the relationship between the Eifel tower and the city of Paris.

### MLP layers as key-value memories

The paper [Transformer Feed-Forward Layers Are Key-Value Memories](https://arxiv.org/pdf/2012.14913) describes transformer MLPs as key-value memories where the first weight matrix corresponds to the keys and the second weight matrix to the values. Note that this terminology should not be confused with the same terminology that is used in the attention mechanism that describes a completely different process.

1.  **Keys as pattern detectors**: The first matrix in an MLP layer can be thought of as a collection of key vectors. Each key is trained to act as a pattern detector, activating when it encounters specific types of text in the input. An input vector from the residual stream is multiplied by all the keys to produce "memory coefficients" which indicate how strongly each pattern has been detected.

These patterns are often human-interpretable and range from simple to complex:

* **Shallow patterns:** In the lower layers of the transformer (e.g., layers 1-9), keys tend to detect shallow, surface-level patterns, such as text ending with a specific word or n-gram. For instance, one key might activate strongly on sentences that end with the word "substitutes".
* **Semantic patterns:** In the upper layers (e.g., layers 10-16), keys recognize more abstract, semantic concepts. A key might activate for text related to a specific topic like "TV shows" or for sentences that describe a time range, even if they don't share exact wording.

2. **Values as next-token predictors:** Corresponding to each key is a value vector stored in the second MLP matrix. Each value vector effectively holds a probability distribution over the model's entire vocabulary. The distribution for the value represents the tokens that are most likely to appear immediately following the pattern detected by its corresponding key.

The output of the FFN layer for a given input is the weighted sum of all its value vectors, where the weights are determined by the activation of the keys:

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/50a6c045e47f1e30c9cbb1bb3d943da273590dd1e3671e98167843be7b342bd1/b3ormwf44manbaxmhq6s)

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/cab97291fd1a08c0212d755ddf792dadf86f8b1b841ed5d3736b7e4b2e983ae1/pcyjc852qhg1jeh8xgq6)

Figure 9: Diagram showing the two matrix multiplications in the MLP sub-layer. Input x contains a textual pattern that triggers (has a high dot product with) key v1 causing value v1 to be added to the output. This process shifts the output distribution towards tokens that are likely to complete the pattern.

Concrete example: given the sentence _“Stay with you for a”,_ there is a key _k2_ that is triggered by inputs that describe a period of time and end with the letter “a”. Its corresponding value vector _v2_ represents a probability distribution that puts most of its probability mass on the word _“while”_. The input sentence strongly activates key _k2_ which triggers value _v2_ and increases the probability of the word _“while”_ in the output distribution.

This paper indicates that a transformer's MLP (or feed-forward) layers, which constitute the majority of its parameters, function as a vast repository of key-value memories.

Insight: A model with more MLP parameters has a larger number of these key-value "memories." This increased capacity allows it to store a more extensive library of linguistic rules and semantic relationships, which can be interpreted as having more "knowledge of the world." Like many deep learning models and probably the human brain, this knowledge apparently involves hierarchical processing with shallower syntactic patterns forming the foundation for more complex semantic understanding in deeper layers of the network.

## Step 7. LayerNorm

The LayerNorm (layer normalization) step normalizes the activations of each layer to have zero mean and a variance of one. Layer normalization is applied before each attention and MLP sub-layer and also before the unembedding layer. This is important for stable training using gradient descent though it’s not that relevant for understanding how the model works.

## Step 8.  Back to words: The unembedding layer

* After passing through many layers of attention and MLPs, the final vectors in the residual stream (one for each token position) hold rich, contextualized information.
* The unembedding layer takes these final residual stream vectors and transforms them back into scores (logits) for every token in the vocabulary. This is a linear transformation from shape [seq_len, d_model] to [seq_len, d_vocab].
* The logits for the final token, with shape [d_vocab], are then passed through the softmax function and we sample from this distribution (or simply choose the most probable word in the case of greedy decoding) to produce the next output word.
* Then the whole process is repeated on this longer sequence to produce more words. This is why LLMs are called ‘autoregressive’.

## LLM training insights

LLMs are trained to predict the next word in a large corpus of internet text. For each batch of text, the following steps occur:

1. Calculate the gradient of the loss with respect to the model parameters. This calculation determines how the weights of the model should change to improve its predictive accuracy.
2. Update the model parameters using the gradients.

At first the transformer LLM’s weights are random and the model makes random predictions resulting in a high loss. However, as the model is trained and its weights are updated, the loss rapidly decreases as its ability to model language and predict the next word in the text corpus improves.

Transformers are trained to minimize a loss function, typically cross-entropy loss, which measures how different the model's predicted probability distribution for the next token is from the actual next token in the training data. By observing the loss curve over time, we can gain insights into the algorithms the model acquires.

The transformer’s training run has several phases:

1. **Initial state (high loss):** At the very beginning, the model's weights are random. Its predictions are essentially uniform across the entire vocabulary and the loss is high.
2. **Learning unigram, bigram and n-gram frequencies:** The loss drops sharply as the model learns the most basic patterns in language.
    1. **Unigram frequencies:** The first and easiest thing to learn is the frequency of individual tokens. The model quickly learns that common tokens like “the” and “a” are far more likely than rare ones, significantly improving its predictions.
    2. **Bigram frequencies:** The next step is learning the frequency of adjacent token pairs. For instance, “Barack” is very often followed by “Obama”. Learning these bigrams causes another major drop in the loss.
    3. **N-gram frequencies:** After mastering pairs, the model learns to recognize and memorize longer common sequences of three or more tokens (n-grams). To do this, it must first learn to understand the order of tokens, which it does by making use of its positional embeddings. Additionally, trigrams and n-grams require attention heads unlike bigrams since n-grams involve processing information from several previous tokens (rather than just the current token).

**3. Learning induction heads and more advanced algorithms:** After mastering simple frequencies, the improvements become more gradual. The model must learn more sophisticated, long-range dependencies and abstract rules. This is where complex circuits, like induction circuits, begin to form. The emergence of induction heads can cause a noticeable “bump” or sudden drop in the loss curve, as the model suddenly gains a new, powerful capability for in-context learning. This phase of training and beyond is where the model moves beyond simple statistics to generalizable algorithmic reasoning.

Insight: although the loss decrease is a quantitative difference, qualitatively different algorithms can form (e.g. induction heads are very different to n-grams) as the loss decreases.

## Singular learning theory and developmental stages

While the loss curve gives us a high-level view, recent research drawing on Singular Learning Theory (SLT) provides a more principled way to identify these developmental phases. This framework uses a metric called the Local Learning Coefficient (LLC) to quantify the “degeneracy” of the loss landscape.

Degeneracy refers to the presence of redundant parameters which are directions in the weight space that can be changed without affecting the model’s loss. The LLC can be understood as an inverse measure of this degeneracy, or more intuitively, as a measure of model complexity:

1. A low LLC means high degeneracy and corresponds to a simpler model structure (low complexity).
2. A high LLC means low degeneracy and corresponds to a more complex model structure (higher complexity).

[Researchers](https://arxiv.org/pdf/2402.02364) have shown that the distinct phases of learning described above coincide with significant changes and increases in the LLC:

1. **Learning bigrams:** The initial phase of learning simple bigram statistics corresponds to a period of low LLC, indicating the model is using a simple, highly degenerate structure.
2. **Learning n-grams:** As the model learns to use positional information and attention heads to predict more complex n-grams, the LLC begins to rise.
3. **Forming induction circuits:** The formation of powerful circuits like induction circuits, which enable in-context learning, is marked by another significant increase in the LLC. This reflects the model building a more complex, less degenerate structure.

Insight: Although the decreasing loss curve looks like a smooth continuous decline, research on SLT shows that the training process is actually made up of distinct phases separated by phase transitions where the model fundamentally changes how it processes information in each phase.

## Grokking

Another phenomenon that offers insights about the training dynamics of LLMs is grokking. Grokking occurs when a neural network suddenly and rapidly learns to generalize to unseen data after a long period of memorization and overfitting.

By studying a one-layer transformer trained on modular addition, [researchers](https://arxiv.org/pdf/2301.05217) identified three distinct phases of training that lead to grokking:

1. **Memorization:** Initially, the model simply memorizes the training data. During this phase, the training loss drops quickly while the test loss remains high. The structured, generalizing circuit has not yet formed.
2. **Circuit formation:** In the second phase, the model begins to form the generalizing Fourier multiplication circuit which involves an algorithm based on trigonometric identities.
3. **Cleanup:** The final phase is where the sudden “grokking” occurs. The generalizing circuit is now fully formed, and weight decay removes the remaining, less efficient memorization components. This cleanup process causes the test loss to drop sharply as the model relies solely on the more efficient, generalizing algorithm.

Insight: LLMs can memorize data they were trained on and later form generalizing algorithms. This makes sense since a generalizing solution achieves a lower loss than a naive memorization approach.

## The problem of superposition and SAEs

Sparse auto-encoders are a novel and powerful technique for understanding the concepts used internally by LLMs.

## Understanding superposition

To see why SAEs are so valuable, we first need to understand the problem of superposition.

LLMs exhibit a phenomenon called ‘[superposition](https://transformer-circuits.pub/2023/monosemantic-features)’ meaning the model learns many more features than it has neurons. By features we mean patterns in the input or concepts that the model might learn to detect. Examples of [features](https://transformer-circuits.pub/2024/scaling-monosemanticity/):

* **Golden gate bridge feature:** Activated by sentences that mention or describe the golden gate bridge.
* **Brain sciences feature:** Activated by sentences that mention or describe brain science concepts like neuroscience, consciousness, or learning.
* **Monuments and popular tourist attractions feature:** Activated by sentences that mention or describe popular tourist attractions like the Mona Lisa or the Egyptian pyramids.

For example, the residual stream of an LLM might have 8192 dimensions or neurons meaning that each vector in the residual stream is composed of 8192 numbers. However, real-world text is complex and there could be tens of thousands of hundreds or thousands of useful features needed to understand it.

When there are far more learned features than neurons, neurons must be polysemantic meaning each neuron must learn to respond to multiple different concepts. Additionally, each feature is processed by a weighted sum of multiple neurons. In other words, there is a complex many-to-many relationship between neurons and features.

How can a single neuron learn and process multiple features? One problem with polysemantic neurons is interference among the different learned features meaning that the activation of one feature can modify how other features are processed. An analogy is a noisy room with multiple people where the noise makes it difficult to understand what someone else is saying.

Polysemantic neurons mostly avoid interference among multiple features by exploiting the fact that real-world training data is usually sparse: this means that it’s unlikely for multiple unrelated features to be active at the same time. For example, if an Arabic feature is activated because of an Arabic text input, it’s unlikely that a Chinese feature is also activating on the same text.

If the data were not sparse, polysemanticity would cause interference and the neural network would instead assign a feature to each neuron, only learn the most important features, and ignore the rest of them. However, real-world text is usually sparse which implies that superposition and polysemanticity are common in LLMs.

Polysemantic neurons are a problem because they are difficult to interpret: since each neuron could respond to multiple unrelated features, it’s difficult to identify the role of each neuron and reverse engineer the neural network.

## Interpretability with SAEs

The [superposition hypothesis](https://transformer-circuits.pub/2023/monosemantic-features) postulates that neural networks “want to represent more features than they have neurons” and that neural networks in superposition are noisy simulations of much larger sparser neural networks. A typical vector of neuron activations such as the residual stream is not interpretable since it’s holding many features in superposition and its neurons are typically polysemantic.

The goal of sparse autoencoders (SAEs) is to learn a much larger sparse activation vector composed of monosemantic features. The goal is for the SAE’s features to have the following interpretable properties:

* **Monsemanticity:** Each feature neuron learned by the SAE should respond to only one feature.
* **Sparsity:** Since the SAE’s hidden vector is sparse, any given text input can be explained by a small number of active features and all other features are set to zero.
* **Low reconstruction loss:** The weighted sum of features produced by the SAE faithfully explains the functionality of the original layer activations and the features it’s using.

The SAE is a neural network composed of two layers: the encoder and the decoder.

Given an input x with length M, the SAE tries to reconstruct the input vector using a weighted sum of learned feature direction vectors.

The encoder produces a sparse vector of coefficients which describe how active each feature is when processing an input token:

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/d1940d3c2cb9403e878e21285cf6b2c3ee010e69ba3a36f8b8feda6c9b56ca6f/zt78gh8uarqwrwzdlx6v)

The decoder reconstructs the original input vector using a weighted sum of the coefficients and the learned feature vectors:

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/3fa39bf166eb8243f8457399480074eb40b600ee0775494ceca534a85f1ffea1/xpz8yhbvxx48us8ouvzq)

The encoder weight matrix has dimensions (F x M) and the decoder weight matrix has dimensions (M x F) where M is the dimension of the residual stream and F is the number of learned features in the SAE (typically F is ~10x larger than D). The feature directions are the columns of the decoder weight matrix and therefore there are F learned feature directions.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/d2999618d6f6a564d9d8754a85f239137c6459aab934881ed9f93fb2b77ee0e8/yxg6wzhnafycqaewa7m2)

Figure 10: Diagram showing the architecture of a sparse autoencoder (SAE).

The loss function of the autoencoder aims to minimize the reconstruction loss between the original vector x and the reconstructed input vector while also maximizing the sparsity of the hidden coefficients vector (output of the encoder) and there is a trade-off between these two goals.

A key problem is that we need to identify which feature each feature vector corresponds to. Another problem is that SAEs often learn thousands of features so it’s not easy to do manually. Fortunately, it’s possible to automatically label each feature vector using an LLM. Here’s how it works:

1. For each feature vector, find the top texts that most activate it (e.g. sentences about the golden gate bridge).
2. Pass these texts to an LLM to write a human-readable description of the feature ("Golden Gate Bridge").

Other ways to understand a feature include:

* Look at the output logits that the feature increases or decreases (e.g. the feature increases the ‘golden’ logit).
* Pin the feature to a high value and see how the LLM’s behavior changes. For example, when the Golden Gate Bridge feature is activated, the LLM obsessively talks about the Golden Gate Bridge (see [Golden Gate Claude](https://www.anthropic.com/news/golden-gate-claude)).

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/1e740e16c67c94e80d0197031de9ffc4d180b180c5c00680c31a8f4f41cf3bdf/r9rmtabw7v4ngdeboodd)

Figure 11: [Neuronpedia](https://docs.neuronpedia.org/features) is an online platform for exploring SAE features learned in popular LLMs such as Llama 3.

What kind of insights have SAEs provided about LLMs? In the [Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet](https://transformer-circuits.pub/2024/scaling-monosemanticity/) paper, researchers from Anthropic discovered the following insights:

* The features found are often abstract, multilingual, and multimodal.
* Features can be used to steer models.
* Some features are relevant to AI safety concerns such as deception, sycophancy, bias, and dangerous content.

## Circuit tracing

SAEs are useful for identifying what concepts are used internally by an LLM but they don’t provide a full picture of how LLMs perform tasks. Fortunately, Anthropic’s recent research on [Circuit Tracing](https://transformer-circuits.pub/2025/attribution-graphs/methods.html) offers explanations of how LLMs perform tasks in terms of “circuits”: graphs that show the flow of information between learned features across different tokens and layers.

## Transcoders

Circuit tracing uses a technique called transcoders rather than sparse autoencoders which are similar but different in important ways:

* Sparse autoencoders (SAEs) use a sparse weighted sum of feature vectors to recreate a vector at a particular point in the model. For example, the input and output of an SAE could be the output of an MLP layer.
* In contrast, transcoders take the input of the MLP layer as input and learn to recreate the output of the MLP layer. This means that unlike SAEs, transcoders can be used to replace the full MLP layer. Similar to SAEs, transcoders are composed of two layers: an encoder and decoder.

The goal of transcoders is to replace uninterpretable MLP blocks with transcoders composed of sparse and interpretable monosemantic features.

For circuit tracing, the researchers used cross-layer transcoders: each transcoder reads from the residual stream at layer L and writes to all subsequent layers. The researchers used cross-layer transcoders instead of per-layer transcoders because they found that they achieved better performance on metrics like mean squared error (MSE) though either could be used.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/0d9a7eaef1acd7890cbc884cdd1447336f700e9a462f0caa58365739282fc889/yvnikei43faw73f1l3lu)

Figure 12: Cross-layer transcoders are interpretable replacements for MLP sub-layers. Each cross-layer transcoder reads from the residual stream and writes to all subsequent layers. The activations of a transcoder are a sparse vector of interpretable features.

Like SAEs, the goal is to train the transcoder to minimize reconstruction loss while also maximizing feature sparsity and transcoder features can be labelled based on the texts that highly activate them and the output logits they increase or decrease when activated.

## Attribution graphs

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/ce13010fae0426b96949cf54206b961336a904971406d8a7cf242952cb1e29cc/ilbtg8nfccovjxxvtatp)

Figure 13: An attribution graph for the prompt: “the capital of the state of Dallas is”. This interactive graph was produced by the [attribution-graphs-frontend](https://github.com/anthropics/attribution-graphs-frontend) app.

Attribution graphs explain the output of the model in terms of a sub-graph of interconnected transcoder features that are activated and responsible for a model’s output.

Attribution graphs can be created from a “local interpretable model”, an interpretable model that replaces the original uninterpretable model and produces identical outputs given an input prompt p. In the local interpretable model, the MLP blocks are substituted with cross-layer transcoders. Additionally, the attention pattern from the original model is frozen and an error term is added to each layer-position coordinate to correct the difference between each MLP block and transcoder.

The interpretable local replacement model can then be used to create an attribution graph by pruning unimportant paths through the model so that the model can be explained by only a few transcoder features and connections between them. In addition, similar feature nodes may be merged into supernodes to reduce the number of features.

At a high level, the attribution graphs are composed of nodes and edges. There are four types of nodes in the graph:

* **Input nodes:** Correspond to embeddings of input tokens.
* **Intermediate nodes:** Transcoder features that are active at a specific position in the prompt.
* **Output nodes:** These correspond to candidate output tokens.
* **Error nodes:** Corresponding to the difference between the MLP output and transcoder output.

An edge in the attribution graph quantifies how much one feature influences another in a later layer or position. A strong edge indicates that the activation of one feature is a significant causal factor for another. The calculation for an edge's strength depends on whether the connection is between two transcoder features or is mediated by an attention head. The flow of information in the attribution graph is up and to the right, as information flows from earlier to later layers and from earlier to later token positions. Note that the flow of information from earlier to later positions requires attention.

## Validating the correctness of attribution graphs

A key challenge when creating attribution graphs is ensuring they faithfully reflect the inner workings of the original model. To validate these graphs, researchers applied specific perturbations, such as suppressing the activation of certain features, and then checked if these interventions produced the expected effect on the model’s output.

For example, in a prompt like “the capital of the state containing Dallas is,” the unmodified local replacement model correctly outputs “Austin.” The attribution graph for this behavior shows that the “capital,” “state” and “Dallas” features are activated. Suppressing the “Dallas” feature causes the model to output random US state capitals like “Albany” or “Sacramento” which confirms that the “Dallas” feature specifically causes the model to output the capital of Texas, rather than any state capital.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/48028abff6cf29ee916d9583e0dcdf3f0ff2c9d95912a53fc5dcd49c1ca49802/o4gq0qfnpvtnvkswdqor)

Figure 14: The faithfulness of attribution graphs to the underlying model can be validated by making perturbations to features (e.g. suppressing features) and verifying that the output of the model changes as expected. In this example, when the “Dallas” feature and its downstream “Texas” feature is suppressed, the model outputs generic state capitals instead of “Austin”, the state capital of Texas.

## Explaining LLM addition using attribution graphs

Although LLMs are only trained to predict internet text, they have the ability to add numbers but how?

One simple approach to find out is to ask an LLM to explain its reasoning. For example, I asked Claude 3.5 Haiku “Answer in one word. What is 36+59?” and “Briefly, how did you get that?” and its response was “I added the digits: 6+9=15 (write 5, carry 1), then 3+5+1=9, giving 95.”

It sounds plausible but this response is really just a high probability response to the prompt rather than a faithful description of how the LLM really adds numbers. Fortunately, circuit analysis can offer some insights into how LLMs add numbers.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/9da273f8dc07d72b4bc0fa99d949cdfd96847a81c1ecc60d10f1695f805ccd0c/gadhktdywsppngf5wjo1)

Figure 15: Attribution graph showing active features when Claude Haiku adds 36 + 59 and produces the output 95.

The two attribution graphs in this section show the features active at each position and layer for the prompt “calc: 36 + 59 = “. The first attribution graph is the original attribution graph and the second one is a simplified one showing the main supernodes in the graph.

![](https://res.cloudinary.com/lesswrong-2-0/image/upload/f_auto,q_auto/v1/mirroredImages/XGHf7EY3CK4KorBpw/aeqvgbd24nkuhezrzay2)

Figure 16: Simplified attribution graph for the prompt “calc: 36 + 59 =”.

We can understand the attribution graph by starting with the answer node “95” and working backwards. First it's important to understand the difference between input and output features:

* Output features: are found near the top of the graph in deeper layers and can best be understood by the output logits they increase the probability of.
* Input features: are found in low layers at the bottom of the graph and can be understood based on the input texts that highly activate them.

Three separate pathways contribute to the final answer:

* The left-most pathway is a low-precision pathway. The “~40 + ~50” feature is a low-precision look-up feature that is active when the left input is approximately 40 and the right output is approximately 50. The other “~36 + ~59” feature works in a similar way. These two features contribute to the “sum = ~92” that increases the probability of several output tokens around 90.
* The middle top feature increases the probability of tokens that are 95 mod 100 (numbers that end in 95) like 95, 295, and 595 and it’s activated by features including the “sum = ~92” feature and “_6 + _9” feature.
* The right pathway involves a “_5” feature that increases the probability of output tokens that end in 5. It’s activated by a “_6 + _9” feature that is active when input A ends in 6 and input B ends in 9.

The overall graph is fairly complex but the basic idea is this:

* A low precision output feature increases the probability of output tokens around 90 such as 88, 90, 94, 95 and 98.
* A 95 mod 100 output feature increases the probability of output tokens that end in 95.
* The two pathways work together to produce the correct answer: 95.
* These output features are activated by intermediate features in middle layers like the “sum = ~92” features that are activated by input features such as the “36” and “59” features.
* These input features fire on input tokens such as the exact token “36” or tokens that end in 9.

In conclusion, how does addition in LLMs work? One [paper](https://arxiv.org/pdf/2410.21272) on the subject offers a succinct high-level explanation:

> “Do LLMs rely on a robust algorithm or on memorization to solve arithmetic tasks? Our analysis suggests that the mechanism behind the arithmetic abilities of LLMs is somewhere in the middle: LLMs implement a bag of heuristics—a combination of many memorized rules—to perform arithmetic reasoning.”

## Conclusion

In conclusion, I would like to try and answer the high-level question “How do LLMs work?”.

The first sections of the post focused on describing the high-level components of a transformer such as the embedding and unembedding layers, transformer blocks, and the attention and MLP sub-layers.

At a high level, we know that LLMs use previous input tokens to predict the next token which involves outputting a probability distribution over all possible tokens in the vocabulary. Although knowing about the basic behavior and components of a transformer is useful, just this knowledge alone does not allow us to explain how LLMs work since each component is by default mostly a black box.

The middle and later sections of this post explore the components of a transformer in more depth with more detailed explanations of attention, MLP blocks, LLM training dynamics, superposition, and finding interpretable features using SAEs. We’ve also covered specific case studies of empirically observed phenomena such as induction heads, indirect object identification, SAE features, and using transcoder circuit tracing to understand addition.

Before offering an explanation of how LLMs work, it’s useful to first consider some common but imperfect analogies that could be used to explain LLMs:

* **“LLMs are just statistics”:** While LLMs learn statistical patterns such as bigrams and n-grams, this simple hypothesis is falsified by phenomena such as induction heads which can operate on text patterns that weren’t in the training data and therefore have no statistical information about them.
* **A computer program:** A program executes explicit, human-written instructions. LLMs learn their own behaviors and mix code and data. Additionally, LLMs can perform many tasks that are difficult or impossible to replicate using computer code such as text summarization. Therefore, given the substantial differences, it’s misleading to think of LLMs as traditional computer programs.
* **The human brain:** This third explanation, that LLMs are like the human brain is probably closer to the truth than the rest as both LLMs and brains excel at learning and pattern recognition. However, LLMs today use the transformer architecture, a deep learning technique that’s effective but not based on how the brain works.

## A better explanation: emergent circuits

So, what is a more accurate high-level explanation? From what I’ve read, identifying circuits, specialized sub-networks of attention heads and MLP neurons that work together, is the best explanation for how LLMs perform high-level tasks.

During its training, the model learns to do several distinct things that are useful for predicting the next word and performing tasks:

* Learning statistics of the training data such as bigrams and trigrams.
* Using attention heads to move information between different parts of the input, enabling the use of contextual information, in-context learning and algorithms that involve several specialized attention heads.
* Using MLP blocks to store useful knowledge about the world and recognize patterns and features in the input, which then influence the final prediction. The features are stored in superposition, allowing the model to learn many more features than it has neurons.
* Processing information in a layered hierarchy, where each successive layer builds more complex and abstract features and concepts by combining simpler ones identified in earlier layers and incrementally moving towards the final solution.

These different mechanisms are combined into complex circuits to execute sophisticated, high-level behaviors such as indirect object identification, addition, factual recall and others.

_Special thanks to the ARENA course, whose content was useful for writing this post._

## A note on algorithmic progress

Note that the explanation of the transformer architecture in this post is based on a design similar to GPT-2 (2019) which covers the core components of the transformer architecture without the added complexity of the many performance and efficiency optimizations that have been introduced since.

Much of the research described in this post was carried out on older models like GPT-2 and an important question is whether this research is and will continue to be relevant to understanding modern LLMs. I believe the answer is yes, because while many optimizations have been added, the foundational principles of the transformer architecture have remained consistent.

Here is a summary of the post [From GPT-2 to gpt-oss: Analyzing the Architectural Advances](https://magazine.sebastianraschka.com/p/from-gpt-2-to-gpt-oss-analyzing-the) that describes the key differences between the older GPT-2 model and a GPT-OSS, a modern one:

* **Attention mechanism:** Older models like GPT-2 used standard Multi-Head Attention (MHA), which is computationally intensive. Modern models use more efficient variants like Grouped-Query Attention (GQA) and Sliding Window Attention to drastically reduce memory usage and speed up inference for long prompts.
* **Positional embeddings:** GPT-2 used learned Absolute Positional Embeddings, which struggled to generalize to longer sequences. Modern models use Rotary Position Embeddings (RoPE), which are far more effective at handling and understanding very long contexts.
* **Model architecture:** GPT-2 used a "dense" architecture where all parameters were activated for every token. Many modern models use a "sparse" Mixture-of-Experts (MoE) architecture, which allows for a massive increase in knowledge capacity by having many specialized "expert" modules, but only activating a few of them for any given token to keep inference fast.
* **Feed-forward layers:** Older models used the GELU activation function. Modern models typically use more advanced gated activation units like SwiGLU, which provide better performance and expressivity with a more efficient parameter count.
* **Normalization:** GPT-2 used LayerNorm. Modern models have widely adopted RMSNorm (Root Mean Square Normalization), which is computationally simpler and more efficient on GPUs.

Despite the differences, in 2025 the transformer architecture and its core components such as the embedding, self-attention and feed-forward layers are still used and therefore I think any interpretability research on transformers (introduced in 2017) is still relevant.

If the transformer is replaced by a new architecture, then I think some of this post’s content such as the focus on attention heads would no longer be relevant. That said, modern LLMs are just another deep learning architecture and the insights about fully connected neural networks (MLP blocks) features, superposition, circuits, and training dynamics seem more timeless and I believe they will still be useful in future AI architectures beyond transformers just as they were relevant in pre-transformer architectures such as convolutional neural networks (CNNs) and recurrent neural networks (RNNs).

## References

Post sources:

1. [Mastering LLM Techniques: Inference Optimization](https://developer.nvidia.com/blog/mastering-llm-techniques-inference-optimization/)
2. [In-context Learning and Induction Heads](https://transformer-circuits.pub/2022/in-context-learning-and-induction-heads/index.html)
3. [Interpretability in the Wild: a Circuit for Indirect Object Identification in GPT-2 small](https://arxiv.org/abs/2211.00593)
4. [Transformer Feed-Forward Layers Are Key-Value Memories](https://arxiv.org/abs/2012.14913)
5. [Loss Landscape Degeneracy Drives Stagewise Development in Transformers](https://arxiv.org/pdf/2402.02364)
6. [Progress measures for grokking via mechanistic interpretability](https://arxiv.org/abs/2301.05217)
7. [Sparse Autoencoders Find Highly Interpretable Features in Language Models](https://arxiv.org/abs/2309.08600)
8. [Toy Models of Superposition](https://transformer-circuits.pub/2022/toy_model/index.html)
9. [Towards Monosemanticity: Decomposing Language Models With Dictionary Learning](https://transformer-circuits.pub/2023/monosemantic-features/index.html)
10. [Circuit Tracing: Revealing Computational Graphs in Language Models](https://transformer-circuits.pub/2025/attribution-graphs/methods.html)
11. [Arithmetic Without Algorithms: Language Models Solve Math with a Bag of Heuristics](https://arxiv.org/pdf/2410.21272)

Interpretability tools:

* [Transformer Explainer](https://poloclub.github.io/transformer-explainer/)
* [Neuronpedia](https://www.neuronpedia.org/)
* [attribution-graphs-frontend](https://github.com/anthropics/attribution-graphs-frontend)

Related posts and further reading:

* [An Extremely Opinionated Annotated List of My Favourite Mechanistic Interpretability Papers v2](https://www.lesswrong.com/posts/NfFST5Mio7BCAQHPA/an-extremely-opinionated-annotated-list-of-my-favourite-1)
* [Gears-Level Mental Models of Transformer Interpretability](https://www.lesswrong.com/posts/X26ksz4p3wSyycKNB/gears-level-mental-models-of-transformer-interpretability)
* [LLM Basics: Embedding Spaces - Transformer Token Vectors Are Not Points in Space](https://www.lesswrong.com/posts/pHPmMGEMYefk9jLeh/llm-basics-embedding-spaces-transformer-token-vectors-are)
* [Mech interp is not pre-paradigmatic](https://www.lesswrong.com/posts/beREnXhBnzxbJtr8k/mech-interp-is-not-pre-paradigmatic)
* [Explaining ChatGPT to Anyone in <20 Minutes](https://cameronrwolfe.substack.com/p/explaining-chatgpt-to-anyone-in-20)
* [What is ChatGPT Doing ... and Why Does It Work?](https://writings.stephenwolfram.com/2023/02/what-is-chatgpt-doing-and-why-does-it-work/)
* [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)