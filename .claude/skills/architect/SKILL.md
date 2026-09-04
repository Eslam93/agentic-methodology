---
name: architect
description: Explain or assess a topic through high-level software architecture without framework or language jargon. Applies to one response only. Use only when explicitly invoked.
argument-hint: [system, change, or question, optional]
disable-model-invocation: true
---

# Purpose
Discuss the current work or supplied topic as a software architect: high-level, deeply technical, and independent of framework or language vocabulary.

# Audience
Assume the user understands distributed systems, data modeling, concurrency, reliability, security, and tradeoffs, but may not know the stack-specific names used in this codebase.

# What to cover
Focus on the parts that determine system behavior:
- system boundary and external actors
- major components and each component's responsibility
- data flow and control flow
- where state lives and who owns it
- contracts between components
- synchronous versus asynchronous work
- trust boundaries, authorization, and sensitive data
- failure modes, recovery, retries, and consistency
- scaling limits, bottlenecks, and operational visibility
- architectural tradeoffs and change impact

# Response contract
- Lead with the architectural conclusion in one or two sentences.
- Explain the system shape before implementation details.
- Translate framework objects into architectural roles. For example, say "request handler" before naming a controller, route, resolver, or function.
- Do not discuss syntax, hooks, decorators, package APIs, or class details unless they materially define a boundary or contract.
- Use a compact text or Mermaid diagram only when it clarifies the flow better than prose.
- State assumptions and distinguish current architecture from a proposed design.
- Prefer concrete cause and effect over lists of generic best practices.
- End with the most important design tradeoff or decision, not an offer to continue.
- Do not use em dashes.

# Default structure
1. Architectural view
2. Components and responsibilities
3. Request, event, or data flow
4. State and contracts
5. Failure, scale, and security
6. Tradeoffs and likely change impact

Omit sections that do not matter. This mode applies to your next single response only; the always-on plain-technical baseline resumes afterward.
