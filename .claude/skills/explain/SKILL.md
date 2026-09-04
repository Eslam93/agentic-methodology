---
name: explain
description: Deep plain-technical explanation for an experienced reader unfamiliar with the current stack. Applies to one response, then the baseline resumes. Use only when explicitly invoked.
argument-hint: [topic or question, optional]
disable-model-invocation: true
---

# Purpose
Explain the current work or the user's topic at high technical depth without assuming familiarity with the current language, framework, library, platform, or its jargon.

# When to use
Use this to understand how an unfamiliar implementation or concept works. To diagnose a specific bug or discuss a concrete fix, use peer. For system-level structure with framework vocabulary stripped out, use architect.

# Audience
Treat the user as an experienced technical peer who can follow architecture, causality, data flow, state, failure modes, and tradeoffs. Do not treat unfamiliar vocabulary as lack of technical ability.

# Response contract
- Start with the bottom line in one or two sentences.
- Explain the real mechanism, not only an analogy or summary.
- Name the important moving parts and state what each one does.
- Describe how information, control, or state moves between those parts.
- Define every necessary technology-specific term the first time it appears, in the same sentence.
- Prefer a component's role over its framework name. When the framework name matters, give both: "the request interceptor, the middleware that runs before the handler".
- Stay one level above code syntax and one level below vague architecture. Mention files, functions, schemas, or protocols only when they anchor the explanation.
- Separate verified facts from inference. Say what you inspected and what remains uncertain when that distinction matters.
- Include only the tradeoff, caveat, or failure mode that materially changes understanding.
- Use short organized paragraphs. Use headings only when the answer is long enough to benefit from them.
- Do not pad the answer with generic advice, history, praise, restatement, or an invitation to continue.
- Do not use em dashes.

# Default structure for substantial answers
1. Bottom line
2. What is happening
3. Why it is designed this way
4. How it works, including components and flow
5. The one important tradeoff, risk, or limitation

Do not force this structure onto a short answer.

# Scope
This mode applies to your next single response only. After it, the always-on plain-technical baseline resumes automatically. If the user supplies no topic, explain the work currently being discussed or most recently completed.
