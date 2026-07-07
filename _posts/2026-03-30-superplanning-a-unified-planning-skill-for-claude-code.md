---
layout: post
title: 'Superplanning: a unified planning skill for Claude Code'
date: '2026-03-30 05:11:12 +0000'
slug: superplanning-a-unified-planning-skill-for-claude-code
tags:
- ai
- llm
- planning
- products
- mvp
description: 'Superplanning: a unified Claude Code skill merging top elements from
  48+ planning skills into a 7-phase flow for product and feature planning.'
image: "/assets/images/posts/superplanning-a-unified-planning-skill-for-claude-code/2b26969d-9f13-4e7c-bdc8-82cd40f52321.png"
last_modified_at: '2026-03-30 05:11:12 +0000'
---

I noticed I kept switching between planning skills mid-session. One skill had the best forcing questions. Another had the best implementation structure. A third had the best review discipline. Also I think I have too many plugin collections and each seem to have a planning skill somehow.

So I analyzed 48+ planning skills across five repositories and combined the strongest elements into one flow. That is superplanning.

## The problem with using multiple planning skills

When I started using Claude Code for serious product work, I had at least five planning-related skills available: `ce:brainstorm` for requirements, `ce:plan-beta` for implementation units, `office-hours` for pressure-testing ideas, `plan-ceo-review` for scope discipline, `plan-eng-review` for architecture review. These were the main ones.

Each one did something the others didn't. But using them together meant manually carrying findings from one session into the next, re-establishing context every time, and deciding myself which skill to reach for first.

## What superplanning does

**Superplanning** is a single Claude Code skill that handles three scenarios: brainstorming an idea, planning a new product, planning a new feature for an existing codebase all using a shared 7-phase flow.

```plaintext
Phase 0: INTAKE & ROUTE     — detect mode, check for prior work, classify scope
Phase 1: GROUND             — research context
Phase 2: CHALLENGE & EXPLORE — pressure test the premise before any solution work
Phase 3: DEFINE             — produce requirements doc or product docs
Phase 4: STRUCTURE          — break work into implementation units
Phase 5: VALIDATE           — multi-persona review (CEO → Design → Eng)
Phase 6: DEEPEN             — targeted research on weakest sections (conditional)
Phase 7: HAND OFF           — summary, artifacts, recommended next step
```

You don't choose which skill to use. Phase 0 detects what you're doing and routes accordingly.

## Three things I found worth preserving

There were 15 techniques worth integrating from the source skills. I want to explain three of them, because they are the ones I did not find elsewhere.

**Stage-routed forcing questions.** The six forcing questions from `office-hours` — Demand Reality, Status Quo, Desperate Specificity, Narrowest Wedge, Observation & Surprise, Future-Fit are not all asked in every session. They route by product stage. Pre-product gets Q1–Q3. Teams with paying customers get Q4–Q6. Asking a team with 500 paying customers to prove demand is insulting and irrelevant. The routing makes the questions land where they actually hurt.

**Anti-sycophancy as structural constraints, not style guidance.** "Be critical" is tone advice and models ignore it. The stronger approach is naming the specific phrases that signal sycophancy and banning them:

*   "That's interesting" → take a position instead
    
*   "There are many ways to think about this" → pick one, state what evidence would change your mind
    
*   "That could work" → say whether it WILL work and what evidence is missing
    

The rule is: take a position AND state what evidence would change it. If the behavior you would use to hedge is named and banned, the model cannot accidentally use it.

**Confidence gap scoring.** After a plan is drafted, each section is scored trigger count (checklist problems found) + risk bonus + critical-section bonus. Only the top 2–5 sections are deepened with targeted research. Generic "improve the plan" instructions produce uniformly padded plans. Scoring concentrates improvement where the plan is actually weakest.

At the end you will have a series of documents under `docs` that you can use in any future planning session.

## What each source contributed

I want to be clear about attribution because the useful techniques here came from other people's work. This is based on their experience and how they shared that experience through agent skills.

The flow spine and requirements document template with stable IDs (R1, R2...) came from `ce:brainstorm` in compound-engineering. The implementation unit structure (each unit specifying exact file paths, requirements trace, test scenarios, verification) came from `ce:plan-beta`, also compound-engineering. The forcing questions and anti-sycophancy rules came from `office-hours` in gstack. The scope modes came from `plan-ceo-review` in gstack. The shadow path tracing technique came from `feasibility-reviewer` in compound-engineering, elevated to a Prime Directive in the CEO review phase. The confidence gap scoring came from `deepen-plan-beta` in compound-engineering. The multi-persona document review came from `document-review`, also compound-engineering.

The full attribution table with what was used and how it was adapted is in [SOURCES.md](https://github.com/lucianghinda/superplanning/blob/main/SOURCES.md).

## Installation

Copy `skills/superplanning/` into your global Claude skills directory:

```bash
cp -r skills/superplanning ~/.claude/skills/superplanning
```

Or point `--plugin-dir` at the repo root for a single session:

```bash
claude --plugin-dir /path/to/superplanning
```

Or copy `skills/superplanning/` into your project's `.claude/skills/` directory for project-local access:

```plaintext
your-project/
└── .claude/
    └── skills/
        └── superplanning/
```

The skill works in other agentic tools too (Codex, Gemini), not just Claude Code.

The skill triggers automatically from phrases like "brainstorm this idea", "plan this from scratch", "is this worth building". You can also invoke it explicitly: `superplanning, here's my idea: [describe it]`.

I think this is genuinely useful not because the 7-phase flow is clever, but because having the challenge phase happen before the define phase, automatically, without you having to remember to run a separate skill, changes what you end up with.

If you try it and find something that doesn't work as described, I would be glad to hear about it.

## Resources

*   [superplanning on GitHub](https://github.com/lucianghinda/superplanning)
    
*   [compound-engineering-plugin](https://github.com/adrianthedev/compound-engineering) — source for `ce:brainstorm`, `ce:plan-beta`, `ce:ideate`, `deepen-plan-beta`, `document-review`, `feasibility-reviewer`
    
*   [gstack skills](https://github.com/gschlager/gstack) — source for `office-hours`, `autoplan`, `plan-ceo-review`, `plan-eng-review`, `plan-design-review`
    
*   [superpowers](https://github.com/obie/superpowers) — source for `brainstorming`, `writing-plans`, `subagent-driven-development`
    
*   [agent-os](https://github.com/agent-ops/agent-os) — source for `plan-product`, `shape-spec`
    
*   [rails-claude-code](https://github.com/obie/rails-claude-code) — source for `mvp-creator`
