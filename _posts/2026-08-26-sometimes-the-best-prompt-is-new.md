---
layout: post
title: "Sometimes the Best Prompt Is /new"
date: '2026-08-26 09:34:44 +0000'
slug: sometimes-the-best-prompt-is-new
tags:
- ai
- llm
- coding-agents
- developer-tools
- prompting
- context-management
description: "Once a chat takes a wrong turn, the model gets lost and does not recover. Multi-turn performance drops 39% on average across 200,000+ simulated conversations. Restarting a conversation beats steering a lost one."
image: "/assets/images/posts/sometimes-the-best-prompt-is-new/og.png"
last_modified_at: '2026-08-26 09:34:44 +0000'
note: >-
  I wrote this article. I used Grammarly to proofread it. 
---

`/new` or `/clear` is sometimes the best "prompt" you can give to an agent to fix a change going bad.

Once a chat with an LLM gets far enough or has multiple turns of interaction, it can trigger an effect called ["Lost in Conversation"](https://arxiv.org/abs/2505.06120), and it will be very hard to drive it out of the chosen path.

There are multiple mechanisms for this, but one useful thing to remember is that at each turn the next token is conditioned on everything already generated.

A multi-turn conversation can be represented like this: 

```md
answer₁ = f(prompt₁)

answer₂ = f(prompt₁, answer₁, _prompt₂_)

answer₃ = f(prompt₁, answer₁, prompt₂, answer₂, _prompt₃_)
```

Each turn, the LLM does not consider your prompt independently; it considers it in the context of everything else that has been generated. That is the current context.

There is also in-context learning, where the model responds to statistical patterns in conversations that affect direction.

When you go into a multi-turn conversation, you have something like: 

You might think that in a multi-turn conversation, if you ask the LLM to change direction to an alternative, the interaction might be: 

```md
LLM + original question 
+ 
new direction
```

But actually what is happening looks more like this: 

```md
LLM
 +
original question
 +
20 previous interpretations
 +
20 previous conclusions
 +
implicit assumptions
 +
terminology established during the conversation
+ 
new direction
```

It will be everything else + `new direction`, in the context of everything else, which has much more and stronger information about all the other direction(s) than the new one.  

This is how transformers work. 

Your job is to recognize when you are lost in conversation and act on it. Restart the chat or shift to a different agent or model to get a fresh perspective on the same problem.

Another strategy to win time is to have multiple different agent harnesses and models implement the same task in parallel. You will pay extra tokens _AND_ cognitive load, but you will get multiple shapes of the same implementation.

So your decision will be faster.

On my personal account, when I reach the limits for one agent/model, I create variations of the prompt and parallel implementations for each.
To make this work, you have to make sure that you use few-shot prompting so you give different directions for building.

None of these bakeoffs or prompt-variant strategies eliminate the back-and-forth required to make code production-ready. That is still your job.

What it does is give you more options to evaluate and a clearer view of the trade-offs in each approach.

Understanding matters more than speed.
