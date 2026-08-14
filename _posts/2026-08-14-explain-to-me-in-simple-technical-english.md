---
layout: post
title: Explain to me in Simple Technical English
date: '2026-08-14 06:12:41 +0000'
slug: explain-to-me-in-simple-technical-english
tags:
- ai
- llm
- coding-agents
- developer-tools
- prompting
- technical-writing
description: "Both phrases cut Claude's sentences in half when explaining code. The vague Simple Technical English loses 8.5% of the facts, and the real standard ASD-STE100 loses 46.8%."
image: "/assets/images/posts/explain-to-me-in-simple-technical-english/og.png"
last_modified_at: '2026-08-14 06:12:41 +0000'
---

Last week I read something about a standard for writing technical documentation in plain, unambiguous English. I did not save the link and could not remember the exact name, nor did I have time to search for it. 

This week, I made changes to a part of the codebase I wasn't very familiar with, so I had to chat with Claude and Codex to understand it better. 

I observed something that had been bothering me for a while: Claude keeps reaching for complicated words, abstractions, and slightly fancy descriptions instead of simple domain terms. Thus I half-remembered this idea, and I started saying: 

> Explain to me in Simple Technical English

I have typed this phrase many times this week, and I felt it worked very well for me, so I have put it in the user memory or in the system instructions for all agents. 

Last night I remembered to search for fuzzy thing that I was rememering and found it: **ASD-STE100 Simplified Technical English**.

But this got me thinking: I wrote “Simple Technical English,” and this standard is called “ASD-STE100 Simplified Technical English”. If so, would my output be better if I had used the proper term? 

Thus, I did some research about it.  You can see the entire experiment I run on Claude and Codex [here](https://github.com/lucianghinda/llm-experiments) where I shared the prompts used, the code that I used for testing and the full results. 

## What is ASD-STE100

[Simplified Technical English](https://www.asd-ste100.org/about_STE.html) is a controlled natural language. It began in the late 1970s as AECMA Simplified English and was first released in 1986. The European airline industry wanted aircraft maintenance manuals that a non-native English speaker could not misread.

It is maintained by the ASD Simplified Technical English Maintenance Group, and it has two parts:

1. **53 writing rules in 9 sections**, because grammar and sentence shape carry as much ambiguity as vocabulary does.
2. **A dictionary of about 900 approved words**, because a small vocabulary removes choice, and choice is where ambiguity enters.

The rule I like most is this one: each approved word has **one meaning and one part of speech**. As a non-native English speaker, this feels very good to me in interactions with LLMs. 

I also liked the hard limits, such as the requirement that descriptive sentences be no more than 25 words. This is because the official goal is for STE to "make technical texts easier to understand for all readers" and "reduce Human Factor risks."

It sounds great to me. If a maintenance manual is ambiguous, an aircraft is repaired incorrectly. The standard exists because vague technical prose has a body count.

LLMs are producing a lot of text, and reading it takes a lot of effort. Because of the fancy language they sometimes use (looking at you, Claude), there is a risk of misunderstanding or, even worse, a kind of understanding fatigue, and the chances of approving or going on with something wrong are increasing. 

## How I tested this

I chose 4 pieces of code from two of my own projects, and for each one I wanted to test 3 cases: 

1. **Control**: no style clause at all. It defaults to all my skills and what I have installed. It is not a clean environment, but all the other experiments will have the same environment
2. **Simple Technical English**: this is the phrase that I used which is not naming the proper standard
3. **ASD-STE100 Simplified Technical English**: the standard name


Nothing else was added, removed, or changed in the entire system prompt, harness, or context. All agents got the same prompts in the same context and were running on the same setup I have. 

I orchestrated all this via Claude, which ran the agents (including its own): three Claude and three Codex for each piece of code for each experiment. I ran two full sessions so we could we collected more data. I stopped after two sessions because this is not a rigorous study but rather something I intended to check. 

The code that they got was looking like this: 

| # | Target | Size | Why this one |
|---|---|---|---|
| 1 | A Rails `Idempotency` concern | 95 lines | Control-flow complexity: callback ordering and a hand-dispatched rescue handler |
| 2 | A single method, `build_blocks` | 11 lines | Smallest unit, and dense with domain words already in the code |
| 3 | A single method, `count_transpositions` | 12 lines | Same size as #2 but with **no** domain vocabulary, pure algorithm for similarity |
| 4 | A whole query object, `DraftQuery` | 130 lines | Same size as #1, but data shaping instead of control flow |

My main complaint was that the model was “inventing” or picking abstractions that obscure real understanding, so I wanted to offer a couple of situations that could push the model in that direction. 

## One example of a run and the output

I will not write about each example run here, as it would become a very long article. But you can read all of [them in the repo that I published at github.com/lucianghinda/llm-experiments](https://github.com/lucianghinda/llm-experiments).

### The output
So allow me share the first one, as it is a simple concern for a controller that implements a idempotent write, and it includes a part that calls something like `rescue_with_handler` because `rescue_from` runs outside the `around_action`. 

Here is the part that I give to LLMs to explain: why is there a `begin` block here: 

```ruby
# `rescue_from` runs at the controller level, *outside* this around_action,
# so any post-yield code is skipped when the action raises.
begin
  yield
rescue StandardError => error
  raise unless rescue_with_handler(error)
end

write_idempotency_entry(cache_key, body_hash) if response.status >= 200 && response.status < 500
``` 

I sent this to Claude and Codex with the same instructions for each agent. The prompts are a bit different between agents, but as the purpose was not to compare Claude with Codex but to compare them with themselves in terms of how they behave, I think it is good enough.

Here is Claude with no style instruction:

> The problem is a layering one. `rescue_from` handlers registered by `ErrorResponder` are installed at the controller level, which is outside this `around_action`. If the action raises, the exception propagates out of the around block first, and everything after `yield` is skipped.

Here is Claude asked for Simple Technical English:

> This block looks strange. The comment in the file describes the reason.
>
> Rails runs `rescue_from` handlers at the controller level. That level is outside the `around_action`. If the action raises an error, Rails immediately leaves the wrapper. The code after `yield` never runs. The save step is lost.

And here is Claude asking for ASD-STE100:

> Rails keeps the `rescue_from` handlers at the controller level. These handlers operate outside of the `around_action` callback. If the action raises an error, Rails goes directly to a handler. Thus, the code after the `yield` does not run.

I think I prefer the second one, but it depends on the person. 

I have shared only a small part of the entire response here. You can read all of them here.

![The same explanation with and without the format instruction](/assets/images/posts/explain-to-me-in-simple-technical-english/screenshot-same-code.png)

## The numbers 
I stripped the code fences, tables, and headings from every output and measured only the text; for me,e is the explanation the agent returned. 

I have created this table. Each cell holds two separate measurements, run 1 then run 2, so `18.6 / 17.4` means the first run averaged 18.6 words per sentence and the second run 17.4.

```
target                 Claude ctrl    Claude STE    Claude ASD     Codex ctrl
-----------------------------------------------------------------------------
01 concern             18.6 / 17.4    8.1 / 8.3     9.7 / 9.8     11.7 / 13.9
02 method, domain      16.9 / 19.3    9.1 / 8.8    10.2 / 10.3    10.7 / 13.8
03 method, algorithm   17.5 / 16.3    9.3 / 9.9     9.0 / 10.3    11.9 / 10.5
04 query object        19.6 / 17.0   10.7 /  9.4   11.0 / 10.6    12.2 / 15.0
```


My reading of these results is: 

1. Claude with no style instructions, 8 runs: **16.3 to 19.6** words per sentence.
2. Claude with either style: **8.1 to 10.7** words per sentence.

I will also share the results below for Codex, but I included the control here to show that, by default, even in the control experiment, Codex outputs fewer words. 

![Average words per sentence across all four experiments](/assets/images/posts/explain-to-me-in-simple-technical-english/screenshot-numbers.png)

I did not expect the control number to be that stable between the two runs, and maybe I should have run more runs, but that was the time I had. But one thing to notice is that it appears not to be so dependent on the code itself. The averages and median are both very, very close: 

| set | values | average | median |
|---|---|---|---|
| first run | 18.6, 16.9, 17.5, 19.6 | **18.15** | **18.05** |
| second run | 17.4, 19.3, 16.3, 17.0 | **17.50** | **17.20** |
| all 8 pooled | — | **17.83** | **17.45** |

A second observation here is looking at the vocabulary that Claude used in the control group: 

```
explicit(2) tradeoff fingerprint corrupting degrades snapshot
deliberately deterministic contract essentially dispatches
propagates installed layering subtle reconstruction fingerprints
namespaced engages machinery quota consequence deliberate
convention encoded
```

All of these are English words, and some we might use in day-to-day interactions, but together they create a fog. 

Their usage went from 26 (the control) to 6 with the vague clause and to 1 with the strict one. In the second run, the same experiment gave 14, then 1, then 0.

While the numbers vary widely, I can see a trend I like: the use of those foggy words is decreasing. 

![The vocabulary Claude reaches for when nobody tells it not to](/assets/images/posts/explain-to-me-in-simple-technical-english/screenshot-fog.png)

## About Codex

I run Codex via orchestration with Claude, but I also replicated the results by running them from Codex (a kinda 3rd semi-run - just Codex form inside Codex).

```
| Target | Codex ctrl | Codex STE | Codex ASD | Claude ctrl |
|---|---|---|---|---|
| 01 concern | 11.7 / 13.9 | 10.7 / 11.4 | 9.6 / 8.3 | 18.6 / 17.4 |
| 02 method, domain | 10.7 / 13.8 | 15.1 / 19.4 | 9.3 / 9.9 | 16.9 / 19.3 |
| 03 method, algorithm | 11.9 / 10.5 | 13.9 / 11.1 | 8.3 / 8.9 | 17.5 / 16.3 |
| 04 query object | 12.2 / 15.0 | 11.0 / 11.5 | 8.3 / 8.3 | 19.6 / 17.0 |
```

Looking at the results, we can see that Codex by default writes succinct statements. “Simple Technical English” does not make it succinct; in some runs, it even made the statements longer than the control. 

By default, Codex is a better fit to explain code than Claude because it is shorter and simpler. 

| set | values | average | median |
|---|---|---|---|
| left number | 11.7, 10.7, 11.9, 12.2 | **11.63** | **11.80** |
| right number | 13.9, 13.8, 10.5, 15.0 | **13.30** | **13.85** |
| all 8 pooled | — | **12.46** | **12.05** |

And this makes the entire experiment more about Claude than Codex, as Codex is already brief by default. 

You can see here a comparison of the control run: 

| set | Claude ctrl | Codex ctrl |
|---|---|---|
| run 1 — values | 18.6, 16.9, 17.5, 19.6 | 11.7, 10.7, 11.9, 12.2 |
| run 1 — avg / median | **18.15** / **18.05** | **11.62** / **11.80** |
| run 2 — values | 17.4, 19.3, 16.3, 17.0 | 13.9, 13.8, 10.5, 15.0 |
| run 2 — avg / median | **17.50** / **17.20** | **13.30** / **13.85** |
| all 8 pooled — avg / median | **17.825** / **17.45** | **12.45** / **12.05** |

## What about understanding and facts

Style and vocabulary are just one side of using LLMs to understand codebases. The second part is making sure the explanation still tells me what I should know or pay attention to. 


Thus, I went through each of the four source files and wrote six facts about each. Things like: “there is no lock, so two concurrent first requests both execute” or "`created_at` is stored but never read", "this `until` loop would spin forever if the invariant from `count_matches` ever broke”. 

For experiments 2, 3, and 4, I picked those facts from the source before reading a single output. For experiment 1, I had already read the control run, so that row is weaker evidence than the other three.

Then I checked which one of those facts show up in which output and gave it a score. 

Run 1:

| Target | Claude ctrl | Claude STE | Claude ASD | Codex ctrl | Codex STE | Codex ASD |
|---|---|---|---|---|---|---|
| 01 concern | 6 | 6 | 3 | 4 | 2 | 2 |
| 02 method, domain | 5 | 6 | 2 | 3 | 1 | 1 |
| 03 method, algorithm | 6 | 3 | 5 | 4 | 2 | 4 |
| 04 query object | 6 | 6 | 4 | 6 | 2 | 3 |
| **total out of 24** | **23** | **21** | **14** | **17** | **7** | **10** |

Run 2:

| Target | Claude ctrl | Claude STE | Claude ASD | Codex ctrl | Codex STE | Codex ASD |
|---|---|---|---|---|---|---|
| 01 concern | 6 | 6 | 4 | 3 | 1 | 3 |
| 02 method, domain | 6 | 6 | 1 | 4 | 1 | 1 |
| 03 method, algorithm | 6 | 4 | 4 | 4 | 3 | 2 |
| 04 query object | 6 | 6 | 2 | 2 | 5 | 2 |
| **total out of 24** | **24** | **22** | **11** | **13** | **10** | **8** |

Or to see this in some other way:

![The same six facts scored against two explanations of the same file](/assets/images/posts/explain-to-me-in-simple-technical-english/screenshot-cost.png)

Here I calculated averages and medians of missed facts: 

| Comparison | avg missed | median missed | min | max | total lost | relative loss |
|---|---|---|---|---|---|---|
| Claude ASD − ctrl | **2.75** | **2.5** | +1 | +5 | 22 of 47 | **46.8%** |
| Codex ASD − ctrl | **1.50** | **2.0** | 0 | +3 | 12 of 30 | **40.0%** |
| Claude STE − ctrl | **0.50** | **0.0** | −1 | +3 | 4 of 47 | **8.5%** |
| Codex STE − ctrl | **1.63** | **2.0** | −3 | +4 | 13 of 30 | **43.3%** |

A couple of conclusions from this: 

1. Seems like while Codex's default output is much better than Claude's from the perspective of foggy words, it also misses some facts by default. So being brief does not mean deeper understanding
2. For Claude: the ASD-STE100 explanation, while being short and clean, they do miss some facts. The same seems to happen for Codex too, so from the perspective of code explanations, the standard does not improve the accuracy of understanding facts about the code. 
3. For Claude: The “Simple Technical English” has an average of `0.50` and a median of `0.0` with even a case where it got an extra fact that the control did not provide. 
4. For Codex: The “Simple Technical English” performed the same or even worse than “ASD-STE100,” and in the end I would not suggest using any of them but rely on the default (no style specification)


To summarize: 
For Claude, “Simple Technical English” (shortened to STE in the tables I shared) performs better than “ASD-STE100” for explanations that include code-based facts. While for Codex both “Simple Technical English”  and “ASD-STE100” perform worse, and by default Codex responds with fewer facts about code than Claude, but the answer is short. 


## Two assumptions I had that were proven wrong

I thought that the documented algorithm (ASD-STE100) would perform better because it has explicit instructions to follow. But it seems the more blurry instruction “Simple Technical English” performed better. 

I also believed that when I asked for “Simple Technical English,” it would also remain brief, but this was not the case in all runs. 


## Conclusion


I have added this to the Claude user memory: 

> When explaining code or systems to me, use Simple Technical English. Short sentences. One idea per sentence. Use the domain words that already exist in the code instead of inventing abstractions for them.

I am keeping “Simple Technical English” because the experiment showed it performs well when removing “foggy words”. 

I added “use domain words that already exist” to instruct it to reuse those concepts we use elsewhere in the codebase. This also could be an experiment on its own when I have time. 

I am putting this in the user memory cause I want it for all my interactions with Claude. 

I am not making any changes to Codex, as it seems to be already doing so from a "foggy" or "brief" perspective. Do they have a system prompt in the harness about this? I did not have time to dig deeper. 


## Resources

- [ASD-STE100 Simplified Technical English, official site](https://www.asd-ste100.org/about_STE.html)
- [ASD-STE100 Issue 9 specification, PDF](https://www.asd-ste100.org/assets/files/ASD-STE100_ISSUE9.pdf)
- [ASD Europe, Simplified Technical English](https://www.asd-europe.org/standards-specifications/simplified-technical-english/)
- [Simplified Technical English on Wikipedia](https://en.wikipedia.org/wiki/Simplified_Technical_English)
- [TechScribe, ASD Simplified Technical English](https://www.techscribe.co.uk/techw/asd-simplified-technical-english.htm)
- [Boeing Simplified English Checker](https://www.boeing.com/company/simplified-english-checker)
- [ASD-STE100 rules repackaged as a Claude Code skill](https://github.com/danyuchn/asd-ste100-skill)
- [Stripe API, idempotent requests](https://docs.stripe.com/api/idempotent_requests)

All 60 raw outputs, the exact prompts used for every run, and the measurement scripts are in the [`experiments/`](https://github.com/lucianghinda/llm-experiments) folder next to this article. What the independent Codex arm does and does not control is written up in [`RUN-NATIVE-PROVENANCE.md`](https://github.com/lucianghinda/llm-experiments/blob/main/simplified-technical-english/RUN-NATIVE-PROVENANCE.md).
