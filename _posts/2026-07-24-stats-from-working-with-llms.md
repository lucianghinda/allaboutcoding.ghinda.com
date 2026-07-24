---
layout: post
title: Stats from two months of agent-first development using backoffs 
date: '2026-05-02 16:59:15 +0000'
slug: stats-from-two-months-agent-first-development-using-backoffs 
tags:
- ai
- llm
- ruby
- ruby-on-rails
description: "Real stats from two months of agent-first development: four coding agents (Claude, Codex, Cursor, Amp) competing on every feature across 951 sessions" 
image: "/assets/images/posts/stats-from-two-months-agent-first-development-using-backoffs/og.png"
last_modified_at: '2026-05-04 04:28:26 +0000'
---

Stats from two months of agent-first development

After spending last year focused on verification and generating replicable test cases with AI, I spent the first half of this year immersed in developing with LLMs and understanding how SDLC changes when you use them throughout the full development lifecycle.

I will start writing more about this year's experience. Let me begin with something concrete: stats from June and July where I worked on a project using agent-first development with human-in-the-loop.

## The workflow

1. Four agents (Claude, Codex, Cursor, Amp) each implement the same feature independently in a bake-off session orchestrated by a Claude session
2. I read all implementations and run automated comparison
3. Pick one as the main PR and cherry-pick important pieces from the others
4. Before final review, run multi-panel agent review: four agents checking idiomatic Ruby and Rails patterns, codebase conventions, test design, security, observability, and adversarial scenarios
5. An orchestrator combines reviews, matches common issues, and prioritizes them
6. I read the final report and decide what changes to accept
7. Final round where I read the code and give feedback
8. All PRs were reviewed by colleagues before merging.

## The numbers

Here is June, my first full month working this way:

![Agent usage stats for June 2026 across Claude, Codex, Cursor and Amp](/assets/images/posts/stats-from-two-months-agent-first-development-using-backoffs/stats-june-2026.webp)

550 interactive sessions across the four agents in 30 days, split Claude 362, Codex 76, Cursor 108. On top of that, 175 automated runs: the bake-offs and review panels from the workflow above. 14,494 skill invocations across 436 sessions. On a typical day I had 6 agent sessions open at once, and at least two were open 74% of the time.

Then July, and this is only the first 20 days:

![Agent usage stats for July 2026 across Claude, Codex, Cursor and Amp](/assets/images/posts/stats-from-two-months-agent-first-development-using-backoffs/stats-june-2026.webp)

401 interactive sessions in two-thirds of a month, so the interactive pace held steady. What changed is the automation. Automated runs went from 175 to 530, review runs from 260 to 619, and peak concurrency from 23 sessions open at once to 56. The typical day went from 6 open sessions to 9, and at least two were open 87% of the time.

The shift I did not expect was how much work moved off my own hands and onto the orchestration. Codex review runs alone went from 124 in June to 476 in July. I was reviewing far more, and almost none of it by hand.

Two months, four agents: 951 interactive sessions, 705 automated bake-offs and reviews, and over 24,000 skill invocations.

## Working with the agents

Claude won most often, Codex came second, occasionally Cursor or Amp had the best implementation. But almost always, no matter who won, the others found important things I added to the final version.

My personal rule: try 3-4 prompt iterations with an agent before switching to manual editing. This saves time when the codebase has solid tests.

## Two persistent problems

1. Excessive comments: All agents, especially Claude, added too many comments. I created a skill specifically to remove most of them and still got a lot more than I would have expected in the final PR that I needed to manually delete.

2. Abstract concepts: They invented terms like "grafting cases" or "sticky clause" instead of using clear domain names. I fought this constantly to ensure PRs were readable without conversation context.

## Open questions I am still working through

What types of work does this approach NOT work for? So far I found it struggles with deep architectural decisions that need sustained context across multiple sessions.

What is the cost vs time trade-off? Running 4+ agents in parallel plus multi-panel reviews has real API costs. Will write more about this part as it is important to keep in mind. 

How does this scale to teams? This workflow is optimized for solo or very small teams. Coordinating multiple developers all running competing agents will need a different structure probably.  

The comment and abstraction problems reveal something deeper: LLMs optimize for explicitness and abstraction while human maintainers want conciseness and clarity. This tension might be fundamental, not something we can prompt away with ease.

These numbers come from one project and one person's habits over two months, so read them as a data point and not a benchmark. 

If you are running agents this way and seeing something different, I would be glad to hear about it.
