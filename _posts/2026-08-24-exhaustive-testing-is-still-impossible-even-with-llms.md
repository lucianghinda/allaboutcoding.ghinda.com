---
layout: post
title: "Exhaustive Testing Is Still Impossible, Even with LLMs"
date: '2026-08-24 07:20:00 +0000'
slug: exhaustive-testing-is-still-impossible-even-with-llms
tags:
- software-testing
- verification
- llm
- ai
- software-quality
description: "LLMs are finding bugs in mature, stable software. More confirmation that exhaustive testing was never possible. Risk-based testing is still the right approach, and verification and validation need context that lives outside the code."
image: "/assets/images/posts/exhaustive-testing-is-still-impossible-even-with-llms/og.png"
last_modified_at: '2026-08-24 07:20:00 +0000'
note: >-
  I wrote this article. I used Claude Code to proofread it and to generate
  the social media assets.
---

I think we are about to find out (yet again) that exhaustive testing is impossible. Or at least impractical.
LLMs are already discovering bugs in mature, stable software. That is confirmation that exhaustive testing was never possible and still is not possible.

But the real price is probably coming. We (as industry that moves ahead with adopting full LLMs in SDLC) are creating, reviewing, and merging LLM-generated code at full speed without understanding how it works.
No mental model. No risk assessment. Just speed.

I am not saying here don't use AI/LLMs. I want to talk more about how can we create an environment that will guide an LLM toward a direction that is verifiable and we can trust the output. 

Coding is solved is true only if coding means producing a lot of code that runs. In case coding means engineering and quality and verification we still have a long way to go. What works is that we can throw a lot to LLMs and as they are so great with working with text hey can help a lot. 

But they are not yet there to verify on their own: 

(1) If what we built is what was required to be built (verify it works as expected)

(2) If what we built is what is needed (validate solution fit for customer problem) 

Those require context thatis outside the code.

That's why I go back to some fundamentals of software and we have to revisit and see which principles are still standing and which not. 
Exhaustive testing is impossible is holding. LLMs are not solving it. Quantum computers maybe it will when they reach market scale. 

If exhaustive testing is impossible then a couple of consequences follow directly and testing remains a problem of selecting a finite set of observations from a much larger space of possible behaviours/inputs/outputs.

Testing based on risks is still the right approach. 

When I write testing here you are maybe thinking about tester. 
But you are a bit misguided if that is the case.
Developers are doing testing, product managers are doing testing, technical founder are doing testing and a wide range of people are doing testing. 

As it was the case before with automated testing it is now with generative test cases and automatic running: you should make sure your environment is generating the proper test cases that fit your business/product/market/risks and the solution is the correct one for you problem. 

LLMs can accelerate a lot of these findings but they cannot (yet) do it on their own. 
A field observation is that the more you delegate out of these decisions to LLMs the learning process that fuels these kind of decisions is lost and it becomes harder to steer.

