# The Psychology Of Trust In AI: A Guide To Measuring And Designing For User Confidence — Smashing Magazine

- 21 min read

- [UX](https://www.smashingmagazine.com/category/ux), [Design](https://www.smashingmagazine.com/category/design), [AI](https://www.smashingmagazine.com/category/ai), [Guides](https://www.smashingmagazine.com/category/guides)

When AI “hallucinates,” it’s more than just a glitch — it’s a collapse of trust. As generative AI becomes part of more digital products, trust has become the invisible user interface. But trust isn’t mystical. It can be understood, measured, and designed for. Here is a practical guide for designing more trustworthy and ethical AI systems.

Misuse and misplaced trust of AI is becoming an unfortunate [common event](https://www.damiencharlotin.com/hallucinations/). For example, lawyers trying to leverage the power of generative AI for research submit court filings citing multiple compelling legal precedents. The problem? The AI had confidently, eloquently, and completely fabricated the cases cited. The resulting sanctions and public embarrassment can become [a viral cautionary tale](https://www.lawnext.com/2025/05/ai-hallucinations-strike-again-two-more-cases-where-lawyers-face-judicial-wrath-for-fake-citations.html), shared across social media as a stark example of AI’s fallibility.

This goes beyond a technical glitch; it’s a catastrophic **failure of trust in AI tools** in an industry where accuracy and trust are critical. The trust issue here is twofold — the law firms are submitting briefs in which they have blindly over-trusted the AI tool to return accurate information. The subsequent fallout can lead to a strong distrust in AI tools, to the point where platforms featuring AI might not be considered for use until trust is reestablished.

Issues with trusting AI aren’t limited to the legal field. We are seeing the impact of fictional AI-generated information in critical fields such as [healthcare](https://apnews.com/article/ai-artificial-intelligence-health-business-90020cdf5fa16c79ca2e5b6c4c9bbb14) and [education](https://mitsloanedtech.mit.edu/ai/basics/addressing-ai-hallucinations-and-bias/). On a more personal scale, many of us have had the experience of asking Siri or Alexa to perform a task, only to have it done incorrectly or not at all, for no apparent reason. I’m guilty of sending more than one out-of-context hands-free text to an unsuspecting contact after Siri mistakenly pulls up a completely different name than the one I’d requested.

[![Cartoon illustration split into two panels. On the left, a man in a blue hoodie speaks into his phone, saying, “Siri, text Dave, I’m waiting outside of your door.” On the right, a cheerful cartoon phone with a face and arms replies, “I have just texted Martha, I am standing outside of your door.”](https://res.cloudinary.com/indysigner/image/fetch/f_auto,q_80/w_400/https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/1-siri-confuse-recipient-message.png)](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/1-siri-confuse-recipient-message.png)

Figure 1: Siri and Alexa often tend to confuse the recipient of my message, causing me to distrust using them when accuracy matters. Image generated using Gemini Pro. ([Large preview](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/1-siri-confuse-recipient-message.png))

With digital products moving to incorporate generative and agentic AI at an increasingly frequent rate, **trust has become the invisible user interface**. When it works, our interactions are seamless and powerful. When it breaks, the entire experience collapses, with potentially devastating consequences. As UX professionals, we’re on the front lines of a new twist on a common challenge. How do we build products that users can rely on? And how do we even begin to measure something as ephemeral as trust in AI?

Trust isn’t a mystical quality. It is a psychological construct built on predictable factors. I won’t dive deep into academic literature on trust in this article. However, it is important to understand that trust is a concept that can be **understood**, **measured**, and **designed for**. This article will provide a **practical guide** for UX researchers and designers. We will briefly explore the psychological anatomy of trust, offer concrete methods for measuring it, and provide actionable strategies for designing more trustworthy and ethical AI systems.

## The Anatomy of Trust: A Psychological Framework for AI [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-anatomy-of-trust-a-psychological-framework-for-ai)

To build trust, we must first understand its components. Think of trust like a four-legged stool. If any one leg is weak, the whole thing becomes unstable. Based on classic [psychological models](https://pmc.ncbi.nlm.nih.gov/articles/PMC10083508/#:~:text=The%20model%20of%20interpersonal%20trust,in%20human%20interpersonal%20trust%20development.), we can adapt these “legs” for the AI context.

### 1\. Ability (or Competence) [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#1-ability-or-competence)

This is the most straightforward pillar: Does the AI have the **skills** to perform its function accurately and effectively? If a weather app is consistently wrong, you stop trusting it. If an AI legal assistant creates fictitious cases, it has failed the basic test of ability. This is the functional, foundational layer of trust.

### 2\. Benevolence [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#2-benevolence)

This moves from function to **intent**. Does the user believe the AI is acting in their best interest? A GPS that suggests a toll-free route even if it’s a few minutes longer might be perceived as benevolent. Conversely, an AI that aggressively pushes sponsored products feels self-serving, eroding this sense of benevolence. This is where user fears, such as concerns about job displacement, directly challenge trust—the user starts to believe the AI is not on their side.

### 3\. Integrity [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#3-integrity)

Does AI operate on predictable and ethical principles? This is about **transparency**, **fairness**, and **honesty**. An AI that clearly states how it uses personal data demonstrates integrity. A system that quietly changes its terms of service or uses dark patterns to get users to agree to something violates integrity. An AI job recruiting tool that has subtle yet extremely harmful social biases, existing in the algorithm, violates integrity.

### 4\. Predictability & Reliability [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#4-predictability-reliability)

Can the user form a **stable and accurate mental model** of how the AI will behave? Unpredictability, even if the outcomes are occasionally good, creates anxiety. A user needs to know, roughly, what to expect. An AI that gives a radically different answer to the same question asked twice is unpredictable and, therefore, hard to trust.

## The Trust Spectrum: The Goal of a Well-Calibrated Relationship [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-trust-spectrum-the-goal-of-a-well-calibrated-relationship)

Our goal as UX professionals shouldn’t be to maximize trust at all costs. An employee who blindly trusts every email they receive is a security risk. Likewise, a user who blindly trusts every AI output can be led into dangerous situations, such as the legal briefs referenced at the beginning of this article. The goal is _well-calibrated_ trust.

Think of it as a spectrum where the upper-mid level is the ideal state for a truly trustworthy product to achieve:

- **Active Distrust**  
  The user believes the AI is incompetent or malicious. They will avoid it or actively work against it.
- **Suspicion & Scrutiny**  
  The user interacts cautiously, constantly verifying the AI’s outputs. This is a common and often healthy state for users of new AI.
- **Calibrated Trust (The Ideal State)**  
  This is the sweet spot. The user has an accurate understanding of the AI’s capabilities—its strengths and, crucially, its weaknesses. They know when to rely on it and when to be skeptical.
- **Over-trust & Automation Bias**  
  The user unquestioningly accepts the AI’s outputs. This is where users follow flawed AI navigation into a field or accept a fictional legal brief as fact.

> [Our job is to design experiences that guide users away from the dangerous poles of Active Distrust and Over-trust and toward that healthy, realistic middle ground of Calibrated Trust.](https://twitter.com/share?text=%0aOur%20job%20is%20to%20design%20experiences%20that%20guide%20users%20away%20from%20the%20dangerous%20poles%20of%20Active%20Distrust%20and%20Over-trust%20and%20toward%20that%20healthy,%20realistic%20middle%20ground%20of%20Calibrated%20Trust.%0a&url=https://smashingmagazine.com%2f2025%2f09%2fpsychology-trust-ai-guide-measuring-designing-user-confidence%2f)
>
> “

[![The trust spectrum](https://res.cloudinary.com/indysigner/image/fetch/f_auto,q_80/w_400/https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/2-trust-spectrum.png)](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/2-trust-spectrum.png)

Figure 2: Build user trust in your AI product, avoiding both distrust and over-reliance. Image generated using Gemini Pro. ([Large preview](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/2-trust-spectrum.png))

## The Researcher’s Toolkit: How to Measure Trust In AI [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-researcher-s-toolkit-how-to-measure-trust-in-ai)

Trust feels abstract, but it leaves measurable fingerprints. Academics in the social sciences have done much to define both what trust looks like and how it might be measured. As researchers, we can capture these signals through a mix of **qualitative**, **quantitative**, and **behavioral** methods.

### Qualitative Probes: Listening For The Language Of Trust [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#qualitative-probes-listening-for-the-language-of-trust)

During interviews and usability tests, go beyond _“Was that easy to use?”_ and listen for the underlying psychology. Here are some questions you can start using tomorrow:

- **To measure Ability:**  
  _“Tell me about a time this tool’s performance surprised you, either positively or negatively.”_
- **To measure Benevolence:**  
  _“Do you feel this system is on your side? What gives you that impression?”_
- **To measure Integrity:**  
  _“If this AI made a mistake, how would you expect it to handle it? What would be a fair response?”_
- **To measure Predictability:**  
  _“Before you clicked that button, what did you expect the AI to do? How closely did it match your expectation?”_

### Investigating Existential Fears (The Job Displacement Scenario) [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#investigating-existential-fears-the-job-displacement-scenario)

One of the most potent challenges to an AI’s Benevolence is the fear of job displacement. When a participant expresses this, it is a critical research finding. It requires a specific, ethical probing technique.

Imagine a participant says, _“Wow, it does that part of my job pretty well. I guess I should be worried.”_

An untrained researcher might get defensive or dismiss the comment. An ethical, trained researcher validates and explores:

> “Thank you for sharing that; it’s a vital perspective, and it’s exactly the kind of feedback we need to hear. Can you tell me more about what aspects of this tool make you feel that way? In an ideal world, how would a tool like this work **with** you to make your job better, not to replace it?”

This approach respects the participant, validates their concern, and reframes the feedback into an actionable insight about designing a collaborative, augmenting tool rather than a replacement. Similarly, your findings should reflect the concern users expressed about replacement. We shouldn’t pretend this fear doesn’t exist, nor should we pretend that every AI feature is being implemented with pure intention. Users know better than that, and we should be prepared to argue on their behalf for how the technology might best co-exist within their roles.

### Quantitative Measures: Putting A Number On Confidence [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#quantitative-measures-putting-a-number-on-confidence)

You can quantify trust without needing a data science degree. After a user completes a task with an AI, supplement your standard usability questions with a few simple Likert-scale items:

- _“The AI’s suggestion was reliable.”_ (1-7, Strongly Disagree to Strongly Agree)

- _“I am confident in the AI’s output.”_ (1-7)
- _“I understood why the AI made that recommendation.”_ (1-7)

- _“The AI responded in a way that I expected.”_ (1-7)
- _“The AI provided consistent responses over time.”_ (1-7)

Over time, these metrics can track how trust is changing as your product evolves.

**Note**: _If you want to go beyond these simple questions that I’ve made up, there are numerous scales (measurements) of trust in technology that exist in academic literature. It might be an interesting endeavor to measure some relevant psychographic and demographic characteristics of your users and see how that correlates with trust in AI/your product. [Table 1 at the end of the article](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#table-1-published-academic-scales-measuring-trust-in-automated-systems) contains four examples of current scales you might consider using to measure trust. You can decide which is best for your application, or you might pull some of the items from any of the scales if you aren’t looking to publish your findings in an academic journal, yet want to use items that have been subjected to some level of empirical scrutiny._

### Behavioral Metrics: Observing What Users Do, Not Just What They Say [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#behavioral-metrics-observing-what-users-do-not-just-what-they-say)

People’s true feelings are often revealed in their actions. You can use behaviors that reflect the specific context of use for your product. Here are a few general metrics that might apply to most AI tools that give insight into users’ behavior and the trust they place in your tool.

- **Correction Rate**  
  How often do users manually edit, undo, or ignore the AI’s output? A high correction rate is a powerful signal of low trust in its Ability.
- **Verification Behavior**  
  Do users switch to Google or open another application to double-check the AI’s work? This indicates they don’t trust it as a standalone source of truth. It can also potentially be positive that they are calibrating their trust in the system when they use it up front.
- **Disengagement**  
  Do users turn the AI feature off? Do they stop using it entirely after one bad experience? This is the ultimate behavioral vote of no confidence.

## Designing For Trust: From Principles to Pixels [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#designing-for-trust-from-principles-to-pixels)

Once you’ve researched and measured trust, you can begin to design for it. This means translating psychological principles into tangible interface elements and user flows.

### Designing for Competence and Predictability [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#designing-for-competence-and-predictability)

- **Set Clear Expectations**  
  Use onboarding, tooltips, and empty states to honestly communicate what the AI is good at and where it might struggle. A simple _“I’m still learning about \[topic X\], so please double-check my answers”_ can work wonders.
- **Show Confidence Levels**  
  Instead of just giving an answer, have the AI signal its own uncertainty. A weather app that says _“70% chance of rain”_ is more trustworthy than one that just says _“It will rain”_ and is wrong. An AI could say, _“I’m 85% confident in this summary,”_ or highlight sentences it’s less sure about.

### The Role of Explainability (XAI) and Transparency [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-role-of-explainability-xai-and-transparency)

Explainability isn’t about showing users the code. It’s about providing a _useful, human-understandable rationale_ for a decision.

> **Instead of:**  
> “Here is your recommendation.”
>
> **Try:**  
> “Because you frequently read articles about UX research methods, I’m recommending this new piece on measuring trust in AI.”

This addition transforms AI from an opaque oracle to a transparent logical partner.

Many of the popular AI tools (e.g., ChatGPT and Gemini) show the thinking that went into the response they provide to a user. Figure 3 shows the steps Gemini went through to provide me with a non-response when I asked it to help me generate the masterpiece displayed above in Figure 2. While this might be more information than most users care to see, it provides a useful resource for a user to audit how the response came to be, and it has provided me with instructions on how I might proceed to address my task.

[![Gemini explains its process and why it can’t complete a task](https://res.cloudinary.com/indysigner/image/fetch/f_auto,q_80/w_400/https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/3-gemini-explains-response.png)](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/3-gemini-explains-response.png)

Figure 3: Gemini shows its process and why it can’t complete a task I’ve asked it to perform. Smartly, it suggests an alternative way to achieve what I’ve requested. ([Large preview](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/3-gemini-explains-response.png))

Figure 4 shows an example of a [scorecard](https://openai.com/index/gpt-4o-system-card/) OpenAI makes available as an attempt to increase users’ trust. These scorecards are available for each ChatGPT model and go into the specifics of how the models perform as it relates to key areas such as hallucinations, health-based conversations, and much more. In reading the scorecards closely, you will see that no AI model is perfect in any area. The user must remain in a trust but verify mode to make the relationship between human reality and AI work in a way that avoids potential catastrophe. There should never be blind trust in an LLM.

[![Example of OpenAI scorecard for GPT-4o](https://res.cloudinary.com/indysigner/image/fetch/f_auto,q_80/w_400/https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/4-openai-scorecard-gpt-4o.png)](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/4-openai-scorecard-gpt-4o.png)

Figure 4: Example of OpenAI scorecard for GPT-4o. ([Large preview](https://files.smashing.media/articles/psychology-trust-ai-guide-measuring-designing-user-confidence/4-openai-scorecard-gpt-4o.png))

### Designing For Trust Repair (Graceful Error Handling) And Not Knowing an Answer [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#designing-for-trust-repair-graceful-error-handling-and-not-knowing-an-answer)

Your AI will make mistakes.

> Trust is not determined by the absence of errors, but by how those errors are handled.

- **Acknowledge Errors Humbly.**  
  When the AI is wrong, it should be able to state that clearly. _“My apologies, I misunderstood that request. Could you please rephrase it?”_ is far better than silence or a nonsensical answer.
- **Provide an Easy Path to Correction.**  
  Make feedback mechanisms (like thumbs up/down or a correction box) obvious. More importantly, show that the feedback is being used. A _“Thank you, I’m learning from your correction”_ can help rebuild trust after a failure. As long as this is true.

Likewise, your AI can’t know everything. You should acknowledge this to your users.

> [UX practitioners should work with the product team to ensure that honesty about limitations is a core product principle.](https://twitter.com/share?text=%0aUX%20practitioners%20should%20work%20with%20the%20product%20team%20to%20ensure%20that%20honesty%20about%20limitations%20is%20a%20core%20product%20principle.%0a&url=https://smashingmagazine.com%2f2025%2f09%2fpsychology-trust-ai-guide-measuring-designing-user-confidence%2f)
>
> “

This can include the following:

- **Establish User-Centric Metrics:** Instead of only measuring engagement or task completion, UXers can work with product managers to define and track metrics like:
  - **Hallucination Rate:** The frequency with which the AI provides verifiably false information.
  - **Successful Fallback Rate:** How often the AI correctly identifies its inability to answer and provides a helpful, honest alternative.
- **Prioritize the “I Don’t Know” Experience:** UXers should frame the “I don’t know” response not as an error state, but as a critical feature. They must lobby for the engineering and content resources needed to design a high-quality, helpful fallback experience.

## UX Writing And Trust [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#ux-writing-and-trust)

All of these considerations highlight the critical role of [UX writing](https://lmsanchez.medium.com/what-is-ux-writing-1eb71b0f0606) in the development of trustworthy AI. UX writers are the architects of the AI’s voice and tone, ensuring that its communication is clear, honest, and empathetic. They translate complex technical processes into user-friendly explanations, craft helpful error messages, and design conversational flows that build confidence and rapport. Without **thoughtful UX writing**, even the most technologically advanced AI can feel opaque and untrustworthy.

The words and phrases an AI uses are its primary interface with users. UX writers are uniquely positioned to shape this interaction, ensuring that every tooltip, prompt, and response contributes to a positive and trust-building experience. Their expertise in **human-centered language and design** is indispensable for creating AI systems that not only perform well but also earn and maintain the trust of their users.

A few key areas for UX writers to focus on when writing for AI include:

- **Prioritize Transparency**  
  Clearly communicate the AI’s capabilities and limitations, especially when it’s still learning or if its responses are generated rather than factual. Use phrases that indicate the AI’s nature, such as _“As an AI, I can…”_ or _“This is a generated response.”_
- **Design for Explainability**  
  When the AI provides a recommendation, decision, or complex output, strive to explain the reasoning behind it in an understandable way. This builds trust by showing the user how the AI arrived at its conclusion.
- **Emphasize User Control**  
  Empower users by providing clear ways to provide feedback, correct errors, or opt out of certain AI features. This reinforces the idea that the user is in control and the AI is a tool to assist them.

## The Ethical Tightrope: The Researcher’s Responsibility [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-ethical-tightrope-the-researcher-s-responsibility)

As the people responsible for understanding and advocating for users, we walk an ethical tightrope. Our work comes with profound responsibilities.

### The Danger Of “Trustwashing” [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-danger-of-trustwashing)

We must draw a hard line between designing for _calibrated trust_ and designing to _manipulate_ users into trusting a flawed, biased, or harmful system. For example, if an AI system designed for loan approvals consistently discriminates against certain demographics but presents a user interface that implies fairness and transparency, this would be an instance of trustwashing.

Another example of trustwashing would be if an AI medical diagnostic tool occasionally misdiagnoses conditions, but the user interface makes it seem infallible. To avoid trustwashing, the system should clearly communicate the potential for error and the need for human oversight.

Our goal must be to create genuinely trustworthy systems, not just the perception of trust. Using these principles to lull users into a false sense of security is a betrayal of our professional ethics.

**To avoid and prevent trustwashing, researchers and UX teams should:**

- **Prioritize genuine transparency.**  
  Clearly communicate the limitations, biases, and uncertainties of AI systems. Don’t overstate capabilities or obscure potential risks.
- **Conduct rigorous, independent evaluations.**  
  Go beyond internal testing and seek external validation of system performance, fairness, and robustness.
- **Engage with diverse stakeholders.**  
  Involve users, ethics experts, and impacted communities in the design, development, and evaluation processes to identify potential harms and build genuine trust.
- **Be accountable for outcomes.**  
  Take responsibility for the societal impact of AI systems, even if unintended. Establish mechanisms for redress and continuous improvement.
- **Be accountable for outcomes.**  
  Establish clear and accessible mechanisms for redress when harm occurs, ensuring that individuals and communities affected by AI decisions have avenues for recourse and compensation.
- **Educate the public.**  
  Help users understand how AI works, its limitations, and what to look for when evaluating AI products.
- **Advocate for ethical guidelines and regulations.**  
  Support the development and implementation of industry standards and policies that promote responsible AI development and prevent deceptive practices.
- **Be wary of marketing hype.**  
  Critically assess claims made about AI systems, especially those that emphasize “trustworthiness” without clear evidence or detailed explanations.
- **Publish negative findings.**  
  Don’t shy away from reporting challenges, failures, or ethical dilemmas encountered during research. Transparency about limitations is crucial for building long-term trust.
- **Focus on user empowerment.**  
  Design systems that give users control, agency, and understanding rather than just passively accepting AI outputs.

#### The Duty To Advocate [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#the-duty-to-advocate)

When our research uncovers deep-seated distrust or potential harm — like the fear of job displacement — our job has only just begun. We have an ethical duty to advocate for that user. In my experience directing research teams, I’ve seen that the hardest part of our job is often carrying these uncomfortable truths into rooms where decisions are made. We must champion these findings and advocate for **design and strategy shifts that prioritize user well-being, even when it challenges the product roadmap**.

I personally try to approach presenting this information as an opportunity for growth and improvement, rather than a negative challenge.

For example, instead of stating _“Users don’t trust our AI because they fear job displacement,”_ I might frame it as _“Addressing user concerns about job displacement presents a significant opportunity to build deeper trust and long-term loyalty by demonstrating our commitment to responsible AI development and exploring features that enhance human capabilities rather than replace them.”_ This reframing can shift the conversation from a defensive posture to a proactive, problem-solving mindset, encouraging collaboration and innovative solutions that ultimately benefit both the user and the business.

It’s no secret that one of the more appealing areas for businesses to use AI is in workforce reduction. In reality, there will be many cases where businesses look to cut 10–20% of a particular job family due to the perceived efficiency gains of AI. However, giving users the opportunity to shape the product may steer it in a direction that makes them **feel safer** than if they do not provide feedback. We should not attempt to convince users they are wrong if they are distrustful of AI. We should appreciate that they are willing to provide feedback, creating an experience that is informed by the human experts who have long been doing the task being automated.

## Conclusion: Building Our Digital Future On A Foundation Of Trust [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#conclusion-building-our-digital-future-on-a-foundation-of-trust)

The rise of AI is not the first major technological shift our field has faced. However, it presents one of the most significant psychological challenges of our current time. Building products that are not just usable but also **responsible**, **humane**, and **trustworthy** is our obligation as UX professionals.

**Trust is not a soft metric.** It is the fundamental currency of any successful human-technology relationship. By understanding its psychological roots, measuring it with rigor, and designing for it with intent and integrity, we can move from creating “intelligent” products to building a future where users can place their confidence in the tools they use every day. A trust that is earned and deserved.

### Table 1: Published Academic Scales Measuring Trust In Automated Systems [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#table-1-published-academic-scales-measuring-trust-in-automated-systems)

Survey Tool Name

Focus

Key Dimensions of Trust

Citation

Trust in Automation Scale

12-item questionnaire to assess trust between people and automated systems.

Measures a general level of trust, including reliability, predictability, and confidence.

Jian, J. Y., Bisantz, A. M., & Drury, C. G. (2000). [Foundations for an empirically determined scale of trust in automated systems](https://www.researchgate.net/publication/247502831_Foundations_for_an_Empirically_Determined_Scale_of_Trust_in_Automated_Systems). International Journal of Cognitive Ergonomics, 4(1), 53–71.

Trust of Automated Systems Test (TOAST)

9-items used to measure user trust in a variety of automated systems, designed for quick administration.

Divided into two main subscales: Understanding (user’s comprehension of the system) and Performance (belief in the system’s effectiveness).

Wojton, H. M., Porter, D., Lane, S. T., Bieber, C., & Madhavan, P. (2020). [Initial validation of the trust of automated systems test (TOAST)](https://research.testscience.org/post/2019-initial-validation-of-the-trust-of-automated-systems-test-toast/paper.pdf). (PDF) The Journal of Social Psychology, 160(6), 735–750.

Trust in Automation Questionnaire

A 19-item questionnaire capable of predicting user reliance on automated systems. A 2-item subscale is available for quick assessments; the full tool is recommended for a more thorough analysis.

Measures 6 factors: Reliability, Understandability, Propensity to trust, Intentions of developers, Familiarity, Trust in automation

Körber, M. (2018). [Theoretical considerations and development of a questionnaire to measure trust in automation](https://www.researchgate.net/publication/323611886_Theoretical_considerations_and_development_of_a_questionnaire_to_measure_trust_in_automation). In Proceedings 20th Triennial Congress of the IEA. Springer.

Human Computer Trust Scale

12-item questionnaire created to provide an empirically sound tool for assessing user trust in technology.

Divided into two key factors:

1.  **Benevolence and Competence**: This dimension captures the positive attributes of the technology
2.  **Perceived Risk**: This factor measures the user’s subjective assessment of the potential for negative consequences when using a technical artifact.

Siddharth Gulati, Sonia Sousa & David Lamas (2019): [Design, development and evaluation of a human-computer trust scale](https://www.researchgate.net/profile/Sonia-Sousa-9/publication/335667672_Towards_an_empirically_developed_scale_for_measuring_trust/links/5f6f36d7458515b7cf508e88/Towards-an-empirically-developed-scale-for-measuring-trust.pdf), (PDF) Behaviour & Information Technology

### Appendix A: Trust-Building Tactics Checklist [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#appendix-a-trust-building-tactics-checklist)

To design for calibrated trust, consider implementing the following tactics, organized by the four pillars of trust:

#### 1\. Ability (Competence) & Predictability [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#1-ability-competence-predictability)

- ✅ **Set Clear Expectations:** Use onboarding, tooltips, and empty states to honestly communicate the AI’s strengths and weaknesses.

- ✅ **Show Confidence Levels:** Display the AI’s uncertainty (e.g., “70% chance,” “85% confident”) or highlight less certain parts of its output.
- ✅ **Provide Explainability (XAI):** Offer useful, human-understandable rationales for the AI’s decisions or recommendations (e.g., “Because you frequently read X, I’m recommending Y”).

- ✅ **Design for Graceful Error Handling:**
  - ✅ Acknowledge errors humbly (e.g., “My apologies, I misunderstood that request.”).
  - ✅ Provide easy paths to correction (e. \] g., prominent feedback mechanisms like thumbs up/down).
  - ✅ Show that feedback is being used (e.g., “Thank you, I’m learning from your correction”).
- ✅ **Design for “I Don’t Know” Responses:**
  - ✅ Acknowledge limitations honestly.
  - ✅ Prioritize a high-quality, helpful fallback experience when the AI cannot answer.
- ✅ **Prioritize Transparency:** Clearly communicate the AI’s capabilities and limitations, especially if responses are generated.

#### 2\. Benevolence [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#2-benevolence-1)

- ✅ **Address Existential Fears:** When users express concerns (e.g., job displacement), validate their concerns and reframe the feedback into actionable insights about collaborative tools.

- ✅ **Prioritize User Well-being:** Advocate for design and strategy shifts that prioritize user well-being, even if it challenges the product roadmap.
- ✅ **Emphasize User Control:** Provide clear ways for users to give feedback, correct errors, or opt out of AI features.

#### 3\. Integrity [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#3-integrity-1)

- ✅ **Adhere to Ethical Principles:** Ensure the AI operates on predictable, ethical principles, demonstrating fairness and honesty.

- ✅ **Prioritize Genuine Transparency:** Clearly communicate the limitations, biases, and uncertainties of AI systems; avoid overstating capabilities or obscuring risks.
- ✅ **Conduct Rigorous, Independent Evaluations:** Seek external validation of system performance, fairness, and robustness to mitigate bias.

- ✅ **Engage Diverse Stakeholders:** Involve users, ethics experts, and impacted communities in the design and evaluation processes.
- ✅ **Be Accountable for Outcomes:** Establish clear mechanisms for redress and continuous improvement for societal impacts, even if unintended.

- ✅ **Educate the Public:** Help users understand how AI works, its limitations, and how to evaluate AI products.
- ✅ **Advocate for Ethical Guidelines:** Support the development and implementation of industry standards and policies that promote responsible AI.

- ✅ **Be Wary of Marketing Hype:** Critically assess claims about AI “trustworthiness” and demand verifiable data.
- ✅ **Publish Negative Findings:** Be transparent about challenges, failures, or ethical dilemmas encountered during research.

#### 4\. Predictability & Reliability [#](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign#4-predictability-reliability-1)

- ✅ **Set Clear Expectations:** Use onboarding, tooltips, and empty states to honestly communicate what the AI is good at and where it might struggle.

- ✅ **Show Confidence Levels:** Instead of just giving an answer, have the AI signal its own uncertainty.
- ✅ **Provide Explainability (XAI) and Transparency:** Offer a useful, human-understandable rationale for AI decisions.

- ✅ **Design for Graceful Error Handling:** Acknowledge errors humbly and provide easy paths to correction.
- ✅ **Prioritize the “I Don’t Know” Experience:** Frame “I don’t know” as a feature and design a high-quality fallback experience.

- ✅ **Prioritize Transparency (UX Writing):** Clearly communicate the AI’s capabilities and limitations, especially when it’s still learning or if responses are generated.
- ✅ **Design for Explainability (UX Writing):** Explain the reasoning behind AI recommendations, decisions, or complex outputs.

![Smashing Editorial](https://www.smashingmagazine.com/images/logo/logo--red.png) (yk)

---

Source: [The Psychology Of Trust In AI: A Guide To Measuring And Designing For User Confidence — Smashing Magazine](https://www.smashingmagazine.com/2025/09/psychology-trust-ai-guide-measuring-designing-user-confidence/?utm_source=tldrdesign)
