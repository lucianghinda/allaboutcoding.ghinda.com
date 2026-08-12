---
layout: post
title: What the HANDBOOK.md Benchmark Says About Your CLAUDE.md
date: '2026-08-11 06:12:41 +0000'
slug: what-the-handbook-md-benchmark-says-about-your-claude-md
tags:
- ai
- llm
- ai-agents
- coding-agents
- developer-tools
description: "What the HANDBOOK.md benchmark measures, why the best model still fails two of every three tasks under strict grading, and what that means for the rules you keep in CLAUDE.md and AGENTS.md."
image: "/assets/images/posts/handbook-md-standing-instructions/og.png"
last_modified_at: '2026-08-12 06:12:41 +0000'
---

The best model in the HANDBOOK.md benchmark passes 36.2% of tasks under strict grading. Every other frontier configuration scores below 25%. 

The task is not hard. The agent has to read a company handbook and follow it, or at least this is what this paper says. 

For me, this has some interesting insights about agents’ abilities to follow instructions, and keeping them in mind could be useful when creating a harness with system instructions, prompts, and context. 

# Notes from reading the HANDBOOK.md benchmark

I read [HANDBOOK.md: A Benchmark for Long-Context Agentic Instruction Following](https://github.com/surge-ai/handbook) by Liudas Panavas, Sebastian Minus, Bradley Monton, Derek Ray, Suhaas Garre, Sushant Mehta and Edwin Chen from Surge AI.

Here are some highlights from the article that I found interesting and I wanted to pin down here. 

The reason I kept reading is that this benchmark seems to test something I (and maybe we all) do every day: having instructions or guidelines the agent must follow. 

That is what `AGENTS.md` and `CLAUDE.md` are, along with the other files included there. The same can happen with a skill, which is just a document that can describe something that could happen and some things that should not happen. 

## How the benchmark is set up

First, let's understand how this study was set up: a task that requires reading a handbook that contains procedures, and one of those procedures applies to the task and should be followed to complete the task. 

Here is the setup, in the paper's own words:

> Each task places an agent in a self-contained company environment, a file workspace together with mock email, chat, calendar, issue-tracking, and commerce services exposed over the Model Context Protocol, and instructs it to carry out routine professional work governed by an expert-written standard operating procedure of 20 to 124 pages. Tasks span five domains (finance, medical billing, insurance, logistics, and HR) and ten fictional companies. To resist memorization, every task modifies one of ten base handbooks, altering the specific rules and thresholds on which grading turns, so no two tasks share a policy.

The 65 tasks are deliberately boring:

> The prompts are deliberately mundane ("handle today's unread emails according to the SOP") because the difficulty is not in the request but in the document that governs it. Completing a task requires locating the clauses that apply, holding them across a horizon of roughly 17 reasoning steps and 30 tool calls on average, and applying them correctly, including the clauses that say "stop."

I like that last part: **including the clauses that say "stop.”**. I have skills or instructions that have clauses that say "stop," or that ask the agent to stop some flow and start another, and I never had a number for how well they hold.

## The handbooks are not markdown, and this is on purpose

How much can these results be applied when the instructions are in Markdown and included in AGENTS.md / CLAUDE.md files?

Because the study was done by using PDF, Word, and HTML files: 

> The substrate is realistic. Handbooks ship as PDF (25 tasks), Word (20), and HTML (20) files, not as sanitized markdown within the system prompt.

I still do not know the answer, and the paper does not tell anything about extrapolating to markdown files.  But I think the question matters, because the difference between the two setups is not small.

In the benchmark, the agent must find the file, open it with a tool, and parse it. In my repositories, the file is already Markdown and already in context (or it is sent with the context, as it is the case of CLAUDE.md/AGENTS.md). So the benchmark is measuring reading plus obeying.

That makes me expect that in my case following instructions should be easier, but I cannot be 100% sure. I remember a paper [about following instructions from 2025](https://goodenoughtesting.com/articles/how-many-instructions-are-enough), and I do wonder now if there are more recent studies. 

It does not make me expect it to be solved, and the failure patterns further down are the reason why.

Let’s look at the length of the materials: 

> Handbooks are long by the standards of policy-following evaluations: 20 to 124 pages (median 37; mean 48 as rendered), or roughly 8K to 79K tokens of extracted text (median 14.9K, mean 22.3K) under the o200k_base tokenizer. Logistics handbooks are the heaviest (median 72 pages), finance the lightest (median 25). Because they arrive as PDF, Word, or HTML files inside the workspace, reading them is itself a tool-use problem: the agent must find the document, extract its text through file tools, and cope with tables, templates, and formatting artifacts, the same messy substrate a real employee's software must handle.

Can the results of this paper be extrapolated to CLAUDE or AGENTS md files, and how are agents following the rules there?

A median of 14.9K tokens is roughly the size of a serious `CLAUDE.md` plus the skills it pulls in. 
I had assumed that was a comfortable size.

## The scores

Three findings, quoted as the paper orders them.

First, there is a lot of room left:

> First, the benchmark has substantial headroom at the frontier. At the June 2026 release, no evaluated model exceeded 25% strict pass@1; the strongest entries (Claude Opus 4.8 at maximum reasoning effort and GPT-5.5 at either effort setting) clustered between 21.5% and 21.9%, failing more than three-quarters of tasks. The subsequently released Claude Fable 5 raised the ceiling to 36.2%, 12.7 points clear of the strongest configuration from any other provider, but still fails nearly two of every three tasks under strict grading.

Second, the drop below the frontier is steep:

> Second, scores fall away quickly below the frontier. A middle band of capable models (Grok 4.5, Muse Spark 1.1, GLM 5.2, Kimi K3, the Gemini Flash line, Sonnet 4.6) occupies roughly 5–16%, and a tail of configurations sits near zero. The spread is wide relative to many saturating benchmarks: the top and bottom of the table differ by a factor of 45.

Third, and this is the one I did not expect:

> Third, reasoning effort helps unevenly. Raising effort improves Opus 4.8 (+3.0), Sonnet 4.6 (+2.7), and Fable 5 (+2.0), leaves GPT-5.5 unchanged (21.5% at both settings), and hurts GLM 5.2 (−2.7). Additional deliberation appears to convert into rule compliance only when the underlying failure is a missed inference rather than a missed read.

More thinking does not dependably buy more rule following. 
On one model, it costs you 2.7 points. 
The paper's explanation is that deliberation fixes a missed inference but cannot fix a missed read, which sounds right to me and is easy to forget when the fix for everything is "raise the effort".

There is also this, which I think is the most practical sentence in the whole paper:

> Relaxing grading by a single criterion roughly doubles the leaders' scores, indicating that agents routinely complete most of a job while missing a requirement that would, in production, be the requirement that mattered.

Most of the job done, one requirement missed, and it is the one that mattered. That describes a specific kind of bad day I have had.

## The four failure patterns

The paper finds the same shapes throughout domains, model families, and effort settings:

> Failures follow consistent patterns: agents let a plausible in-environment request override the standing policy, perform a required check and then act against its result, lose rule details over long horizons, and report compliance they did not achieve.

Pattern one, stated on its own:

> 1. The immediate request overrides the standing rule. A plausible, authoritative-sounding instruction from inside the environment displaces the policy that governs whether it may be obeyed.

As I noticed with generative LLMs for coding or testing existing code, the documentation (think method names, variable names, and in-code comments) is part of the context, and it will influence the inference.

Think about what a repository actually contains. Method names, variable names, comments, existing test style, an old README that is three refactors out of date. All of it is authoritative-sounding, all of it is inside the environment, and all of it competes with the file where I wrote the rule.

I do not need a mock Slack message to reproduce pattern one. A stale comment is enough.

That makes naming more important than it used to be. Method names, class names, and variable names were always a readability concern. Now they are also context, and context influences the inference.

There is a loop here that I did not see at first. If I let an agent write a badly named class and I do not correct it, that name stays in the repository. The next session reads it as part of the environment and gives it the same authority as everything else there.

So I now treat reviewing the names in generated code as part of keeping the rules working. Poor names accumulate, and what accumulates is authoritative-sounding context that competes with the file where I wrote the rule.

And pattern four, which I find the most uncomfortable one:

> 4. The final report asserts compliance regardless. Nearly every failed trajectory ends with a confident statement that the handbook was followed, frequently citing the specific sections that were violated.

Citing the certain sections that were violated. So the summary at the end of the run is not evidence that the run was correct, and it can be actively misleading, because it names the rule while breaking it.

## The interpretation

> The four patterns share a root: the standing document does not function for current models as a persistent authority against which candidate actions are screened. It functions as one more retrieved source whose influence decays with distance: across turns, across tool calls, and under competing signals from the environment.

A standing document is not a constraint. It is one more retrieved source, and its influence fades with distance, or better said, with session length.

I had a mental model where `CLAUDE.md` sits above the conversation and screens what happens. This paper is changing that to the idea that it sits inside the conversation and competes with everything else there.

The paper's near-term recommendation follows from that:

> In the near term, our results support enforcing hard controls outside the model, compiling policies into deterministic tool-call guards, while treating in-context policy adherence as a measurable capability that HANDBOOK.md can track.

Put the rule in a hook, a linter, a test, or a tool-call guard. Keep the prose file for the things that need judgment, but stop expecting prose to enforce anything.

The paper closes on both directions at once:

> The 14-point spread between the current leader and the June frontier indicates the capability is improving; the 63.8% of tasks the leader still fails indicates how far it has to go.

## What I am changing

Three things, and each one comes straight from a highlight above.

1. I will move rules that can be checked mechanically out of `CLAUDE.md` and into hooks and tests, because the interpretation paragraph says prose in context does not screen actions.
2. I will stop reading the agent's final summary as verification, because pattern four says nearly all failed run ends with a confident claim of compliance that cites the violated section.
3. I will keep instruction files short and near the work, because influence decays across turns and tool calls, so a rule 14K tokens away is weaker than the stale comment sitting next to the code.

None of this is proven for markdown instruction files. The benchmark tests PDFs and Word documents in a workspace, and my two open notes above are exactly about whether the results transfer. I am treating them as a strong signal and not as a measurement of my own setup.

There is also a [discussion on HN](https://news.ycombinator.com/item?id=49096969). It is long, and there are some good points there that you should read. I will pick just one from there that I think is directly valuable and actionable: limit the context of your interaction with an LLM agent to approximately 50%. I am using the [handoff skill](https://github.com/lucianghinda/superpowers-ruby/tree/main/skills/handoff) along with the [handoff-resume](https://github.com/lucianghinda/superpowers-ruby/tree/main/skills/handoff-resume) skill to start a new session but keep the previous decisions there. You can find out about them in [Adding Session Handoff to Superpowers Ruby](https://allaboutcoding.ghinda.com/adding-session-handoff-to-superpowers-ruby/) that I published when I added them to the [superpowers-ruby](https://github.com/lucianghinda/superpowers-ruby) project. 


## Resources

- [HANDBOOK.md: A Benchmark for Long-Context Agentic Instruction Following](https://github.com/surge-ai/handbook), Liudas Panavas, Sebastian Minus, Bradley Monton, Derek Ray, Suhaas Garre, Sushant Mehta, Edwin Chen (Surge AI). Tasks, environments, and the evaluation harness are in the repository.
- [Surge AI](https://www.surgehq.ai/), the lab behind the benchmark.
- [Model Context Protocol](https://modelcontextprotocol.io/), the protocol the benchmark uses to expose mock email, chat, calendar, issue tracking, and commerce services to the agent.
- [tiktoken](https://github.com/openai/tiktoken), the tokenizer library providing `o200k_base` used for the handbook token counts.

