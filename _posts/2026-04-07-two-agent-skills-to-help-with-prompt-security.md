---
layout: post
title: Two Agent Skills to Help With Prompt Security
date: '2026-04-07 04:48:07 +0000'
slug: two-agent-skills-to-help-with-prompt-security
tags:
- ai
- llm
- agentic-ai
- skills
description: 51 checks that might help combat some of prompt injections in LLM applications.
image: "/assets/images/posts/two-agent-skills-to-help-with-prompt-security/29aed759-e7f2-4e01-a3a5-945967ce17a6.png"
last_modified_at: '2026-04-07 04:48:07 +0000'
---

When you build a product that uses LLMs and prompts, security becomes a specific kind of hard problem.

Simon Willison described the core risk well in [The Lethal Trifecta](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/). When three things combine in a system: access to private data, exposure to untrusted content, and the ability to communicate externally, the situation becomes dangerous.

The reason is structural: LLMs follow instructions in content. That is what makes them useful. It is also what makes them exploitable. An attacker embeds instructions in a document, an email, a webpage, and the model may execute them.

**Prompt injection** is the number one vulnerability in LLM applications according to [OWASP's Top 10 for LLMs](https://owasp.org/www-project-top-10-for-large-language-model-applications/). And unlike SQL injection, where patterns are well-defined and tools are mature, LLM security does not yet have a comparable development workflow.

I tried to compile some best practices into two Claude Code skills, or better said, agentic skills because they should work with multiple agent harnesses.

I want to be clear upfront: this will not protect you as well as a static analysis tool would. LLM-based security review is not the same as deterministic rule checking. What these skills do is give you a structured checklist, grounded in authoritative sources, that you can run as part of your normal workflow. Still even if you use these skills you can still be open to prompt injection or other possible attack vectors. But I think these are a good start or at least a better start.

I am of course open to PRs and changes at [https://github.com/lucianghinda/llm-prompts-skill](https://github.com/lucianghinda/llm-prompts-skill) if you discover better heuristics that we can apply to improve the security of LLMs prompts.

## The Problem

Think about what "checking for prompt injection" actually means in practice. It is not one thing. The [OWASP LLM01:2025 checklist](https://cheatsheetseries.owasp.org/cheatsheets/Prompt_Injection_Prevention_Cheat_Sheet.html) has 23 items just for direct injection. [MITRE ATLAS](https://atlas.mitre.org) adds 12 mitigation controls. [NVIDIA NeMo Guardrails](https://github.com/NVIDIA/NeMo-Guardrails) covers another 16 implementation patterns for RAG pipelines and jailbreak detection.

That is 51 distinct checks, and the list grows every time a new attack vector is discovered.

We have linters for code style, static analysis for bugs, dependency scanners for known CVEs. We have nothing comparable for LLM security that runs as part of a normal development workflow. Knowing about prompt injection in the abstract and having a structured way to check for it are two different things.

So I tried to build something useful here.

## What I Built

Two companion skills, designed to be used with the Claude Code CLI or Codex or OpenCode or any kind of agentic harness that uses skills.

`llm-prompts:reviewer` — point it at any codebase and it runs 51 checks across OWASP, MITRE ATLAS, and NeMo Guardrails. Every finding is rated CRITICAL / HIGH / MEDIUM / LOW with a precise location in your code and concrete remediation guidance. Of course when I say "running the 51 checks" I mean the LLM will try to read the code, understand it and check it against those checks. This is not a static analysis tool.

`llm-prompts:builder` — answer 6 questions about your integration (role, task, data sources, output usage, language, architecture) and it generates a secure system prompt plus scaffolding code. Every generated line is annotated with the check ID it satisfies: `# WHY: [O-7]`.

Here is what a reviewer report looks like:

```markdown
PROMPT INJECTION SECURITY REVIEW
=================================
Scope:    codebase
CRITICAL: 3 fail / 2 pass
HIGH:     5 fail / 4 pass

TOP RISKS
---------
1. [O-7] No structured prompt separation
   Risk: User input is concatenated directly into the prompt
         — attacker can override system instructions
   Location: app.py:42
   Remediation: Wrap user input in a USER_DATA_TO_PROCESS block
                with --- delimiters...
```

## The 51 Checks, Briefly

The framework is grounded in three authoritative sources.

**OWASP LLM01:2025 (O-1 through O-23)** covers the fundamentals: input validation, injection pattern detection, typoglycemia defenses (deliberately misspelled words used to bypass keyword filters), the [StruQ structured prompt separation](https://arxiv.org/abs/2402.06363) pattern, output validation, system prompt leakage, HTML/Markdown injection in outputs, access control, rate limiting, logging, and alerting.

**MITRE ATLAS (M-1 through M-12)** maps to their adversarial AI threat framework: GenAI Guardrails (AML.M0020), GenAI Guidelines (AML.M0021), Human-in-the-Loop gates (AML.M0029), Tool Invocation restrictions (AML.M0030), Memory Hardening (AML.M0031).

**NeMo Guardrails patterns (N-1 through N-16)** go deeper into RAG-specific risks: pre-indexing document validation, retrieval filtering, source attribution, heuristic and classifier-based jailbreak detection, PII detection, and three-layer defense configuration.

Each finding in the report maps to one of these check IDs so when you fix something, you know exactly which risk you addressed.

Of course I feel the need to say again that this is not a static analysis tool but an LLM so it might skip some of these checks or decide that they pass even if they should not. I see this as a starting point and you should make sure to manually review the prompts.

## The Builder: Focused on security

I think the reviewer is the more immediately useful skill, but the builder is more interesting to me as a design idea.

The insight is this: it is easier to build something secure from the start than to retrofit security onto existing code. The builder operationalizes that by generating code where every defense is intentional and documented.

You answer the six questions, and it generates in Ruby and if you need to in Python:

*   A **system prompt** with all five OWASP structural elements present
    
*   `guardrails.rb` with InputGuardrail (length limits, encoding detection, injection pattern matching, typoglycemia defense) and OutputGuardrail (leakage detection, PII scanning, HTML injection detection)
    
*   `integration.rb` with rate limiting, structured logging, and the main request handler
    
*   `tools.rb` if you chose tool calling — parameterized queries, allowlisted tables, human-approval gates for destructive actions
    
*   `rag.rb` if you chose RAG — pre-indexing validation, retrieval filtering, source provenance tracking
    

For JavaScript/TypeScript, the builder generates the prompt construction function.

Every generated line of code includes a comment like `# WHY: [O-7]`. That annotation does two things. First, it makes the purpose of the code explicit a future developer can see that a particular block exists to prevent structured prompt injection, not as an arbitrary formatting choice. Second, it makes the code reviewable against the framework. You can grep for `WHY: [O-7]` and immediately see all the places where that specific check is addressed.

This is what I mean by **security that documents itself**. The check IDs become a shared vocabulary between the code, the review report, and the security team without any additional documentation effort.

## A Reference Implementation

The repo includes two fixture apps in `tests/fixtures/`:

*   `defended-app/` — a complete Flask + OpenAI chatbot that demonstrates every defense. This is the canonical reference the builder generates from.
    
*   `vulnerable-app/` — the same app, stripped of all guardrails. Raw string concatenation, no validation, no structured separation.
    

I found having both versions genuinely useful while building this. The vulnerable version is not just for illustration — it is the test target. Seeing what an insecure app looks like at the code level makes it much easier to recognize the same pattern in your own codebase.

## Testing

I wanted to be able to trust that the skills catch what they claim to catch.

The test suite runs both skills against the fixture apps using the real Claude CLI and validates that the output contains the expected PASS/FAIL verdicts:

```shell
# Reviewer against both fixtures
./tests/run-tests.sh --claude-only vulnerable-app
./tests/run-tests.sh --claude-only defended-app

# Builder scenarios
./tests/test-builder-claude.sh basic-chatbot
./tests/test-builder-claude.sh rag-assistant
./tests/test-builder-claude.sh tool-calling-agent
```

Each test invokes real LLM calls, so they take 60-180 seconds. A test fails only when a CRITICAL or HIGH verdict is missing — MEDIUM and LOW mismatches are reported as warnings.

The supported languages for code templates are Python, JavaScript/TypeScript, Ruby, and Go.

## What This Is and Is Not

I want to be honest about the limits here.

LLM-based security review is not deterministic. A static analysis tool will catch every instance of a pattern, every time, with no variation. These skills run a checklist using an LLM, so results can vary. Willison's point in the lethal trifecta piece is worth repeating: in security contexts, 95% protection is not protection. A missed check is a real gap.

So I am not arguing this replaces a security audit. A dedicated penetration tester will find things this framework misses. I am not even arguing these skills are equivalent to a good static analyzer.

What I think they do: they raise the floor, especially for solo developers and small teams building LLM features without dedicated security expertise. The 51 checks give you a structured starting point you can run during development, not just at the end. The check IDs give you a shared vocabulary. And the annotations give you documentation you did not have to write separately.

It is more comfortable to identify gaps in a review report than to explain them after a production incident.

The project is open source. If you find that the builder generates code that does not hold up against your real requirements, or if you think I got a check wrong, I would genuinely like to know. Please open an issue.

## Resources

*   [The Lethal Trifecta for AI Agents](https://simonwillison.net/2025/Jun/16/the-lethal-trifecta/) by Simon Willison
    
*   [OWASP Top 10 for Large Language Models 2025](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
    
*   [OWASP Prompt Injection Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Prompt_Injection_Prevention_Cheat_Sheet.html)
    
*   [MITRE ATLAS — Adversarial Threat Landscape for AI Systems](https://atlas.mitre.org/)
    
*   [NVIDIA NeMo Guardrails](https://github.com/NVIDIA/NeMo-Guardrails)
    
*   [StruQ: Defending Against Prompt Injection with Structured Queries](https://arxiv.org/abs/2402.06363)
    
*   [llm-prompt-injection-reviewer on GitHub](https://github.com/lucianghinda/llm-prompt-injection-reviewer)
