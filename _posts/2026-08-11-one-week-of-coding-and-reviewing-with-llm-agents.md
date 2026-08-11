---
layout: post
toc: true
title: One Week of Building and Reviewing Code With LLM Agents
date: '2026-08-11 05:07:06 +0000'
slug: one-week-of-coding-and-reviewing-with-llm-agents
tags:
- ai
- llm
- ai-agents
- coding-agents
- code-review
- developer-tools
description: "One week of agent-first backend work in the logs: 2,200 session files across four tools, 350 prompts typed by hand, and which checks actually found real defects."
image: "/assets/images/posts/one-week-of-coding-and-reviewing-with-llm-agents/og.png"
last_modified_at: '2026-08-11 05:07:06 +0000'
---

I spent a week doing normal backend work: writing code, reviewing my own changes and other people’s changes, and writing tehnical specifications out of requirements. All this work using LLM agents and at the end of the week I reviewed (still with LLMs) those all sessions to understand what happened and what can I improve next week.

This is what the logs say. It is a story about what went wrong and what did not worked and I extracted some ideas about what I can improve this week. 

Everything here comes from one working week: five days, one backend engineer, one large Rails codebase.

## How I measured it

Four coding tools or better said agent harnesses ran that week and wrote a small Ruby scripts to walk all four stores and pull out, per session: the working directory, the git branch, start and end times, every prompt I typed, every tool call by name, token counts, and which of my own skills or workflows launched it. 

Then I sent six agents out to read the transcripts in depth and report back with some findings. 

Some terms I use below:

- **Agent**: one LLM session working on its own, with its own context, one session can start multiple agents when needed
- **Panel**: four different agents (Claude, Codex, Cursor, Amp) reviewing the same change independently, then one pass reconciling their findings and presenting what they found common and what was different.
- **Lens**: a review pass with one narrow job: test quality, observability, simplification, or "what have human reviewers repeatedly caught in this codebase before".
- **Hunk**: one contiguous block of changed lines in a diff.
- **Bake-off**: the same ticket given to four different agents at once, each in its own git worktree, from the same starting commit, with the same prompt. Then one of them is picked.
- **Graft**: taking one specific good idea from a losing bake-off entry and adding it to the winner.
- **Mutation analysis**: deliberately breaking the production code to confirm a test fails, then restoring it and confirming the test passes again. It proves the test can actually detect the bug it claims to cover. I did not run a full mutation testing just made sure the important tests that agents wrote are failing before commiting them.

## The numbers

| | |
|---|---|
| Session files across all four tools | 2200 |
| Of those, Claude Code session files | 730 |
| Claude Code sessions with me at the keyboard | 80 |
| Prompts I typed by hand | 350 |
| Characters I typed, all week | 90.000 (roughly 22.000 tokens) |
| Median prompt length | 83 characters. 47% were under 80 |
| Ratio | about 1,500 tokens produced for every token I typed |
| Wall-clock hours with a session live | 54 |
| Share of that time with two or more sessions running | 63% |

The number that surprised me most is the 80 sessions with a person at the keyboard: Claude Code wrote 730 session files that week and only 80 of them had me typing in them, while the other 650 were agents that other agents started.

The same spread can be found for other agents specifically for Codex where I typed in some sessions but most of them were automated running sessions started by other agents. In case of Cursor and Amp all sessions where driven by other agents. 

**Two things about how the numbers are counted and what does it mean**

I am counting **session files**, not agent runs. I cannot count agent runs consistently across these four tools, because they disagree about what a session is. Codex records a sub-agent it spawns as a separate session inside the same file: so around 1,100 of its 2,100 session records that week are sub-agent
threads, held in about 1,400 files. Claude Code does the opposite for part of its work: it writes a separate file for some sub-agents, and records others inside the parent file.  Cursor and Amp give me no visibility into their sub-agents at all or I could not yet find something that I could reliable count. 

So the true number of agent runs is higher than 2200, in every tool, by an amount I cannot measure. Anyone adding Codex's 2100 to Claude Code's 730 is adding two different things.

How I see last week so far? 

The week was not a conversation with a model it was closer to running a small operation: I start a robot, it reports back, and I decide what to do with what it says. Of the 773 messages that arrived in my Claude Code inbox that week, **329 were written by machines** like completion notifications and reports from other agent sessions and not by me.

So as I drive the machine I write shorter commands like `retry`, `apply`, `push with lease`, `post them`, `make a commit` and rely more on the setup I have: project agents instructions, skills, MCPs, prompts and context to do the heavy lifting while I drive shorter turns. 

### The four tools did different jobs

First let me say this that the main agent which is also the orchestrator of everything is Claude Code for me. So the analysis below is based on this. 

**Codex ran more sessions than every other tool put together.** I did not expect that, because I opened Codex directly less than I do Claude Code. 
1,200 of the 2,200 sessions (!55%), and 75% of Codex's output tokens, belong to a single workflow: the per-hunk reviewer. It also starts its own sub-agents 945 spawn calls and 1,716 wait calls.

Its opening prompts show what it was for: 946 of them begin with a line telling it to act as an adversarial, hunk-focused reviewer. Another 40 are whole-diff passes, 40 are verifiers checking other findings, 36 are panel reviewers, 8 are gate checks on a Claude turn, and 4 are bake-off entries.

**Cursor mostly reads.** 1,014 file reads and 951 searches against 149 edits. That matched its behaviour as a reviewer: it was the fastest of the four panel reviewers by a wide margin (median 283 seconds against Claude's 739) and it returned a fixed 87-byte "no bugs found" message on 6 of 14 runs. 


---

### Where the effort went

| Kind of work | Sessions | Prompts I typed | Output tokens |
|---|---:|---:|---:|
| Code review | 41 | 378 | 8.6M |
| Writing code | 16 | 157 | 4.0M |
| Bake-offs | 8 | 80 | 2.6M |
| My own tooling | 13 | 36 | 2.3M |
| Specifications and domain research | 12 | 67 | 1.5M |
| Test planning and running tests against staging | 4 | 46 | 1.2M |

Review was the largest single use at about 40% of the Claude spend — and that understates it, because
the whole 7.7 million tokens of Codex spend was also review.

The trend across the week is the part I would not have guessed:

| Day | Prompts typed | Claude output | Share spent by machines I started |
|---|---:|---:|---:|
| Monday | 56 | 2.0M | 7% |
| Tuesday | 69 | 6.7M | 29% |
| Wednesday | 102 | 9.2M | 35% |
| Thursday | 71 | 10.4M | 44% |
| Friday | 51 | 3.0M | 28% |

My own typing stayed roughly flat. What grew was how much work each prompt started.

---

## The work

### Code review

I reviewed 19 merge requests that week — some mine, most colleagues'. 16 four-tool panel runs produced
17 written reports. The verdicts were 11 request-changes and 5 approve-with-nits. I approved three
merge requests and posted 44 line-anchored comments across 10 of them.

56 findings had two or more of the four tools agree. A further 116 came from one tool only, and I
went through those one at a time.

#### Real defects it found

I am describing these without codebase detail, but they are all real and all were fixed.

- **A money total lost a penny.** A tax amount was rounded down to whole pence, which reversed a written acceptance criterion. Underneath that, the amount was accumulated as a floating-point number, so a sum of forty identical rows arrived slightly below the true value and rounded down to one penny less than the customer was charged. Two tools found the criterion problem. A third found the floating-point problem and reproduced it.
- **A database migration was missing a statement-timeout guard.** The identical migration on the same table had already failed in production three weeks earlier. The fix for that failure had been merged to a pre-production branch and never brought back to the main branch, so the main branch still held the broken template. **One tool out of four found this.** The same pass then found that of 54 commits sitting on the pre-production branch and not on main, three were genuine production fixes that had never been brought back — including half of an incident fix.
- **An unrelated change was hiding in a commit.** A one-time-password bypass value had been altered in a commit about something else, and that was why the pipeline was red. All four tools found it.
- **A first-occurrence lookup could permanently hide the right answer.** If the earliest matching record was invalid, the service returned that one and never looked at the later valid record. I measured the affected population before deciding it mattered: a few hundred cases, roughly a third of which had a valid later record.
- **A headline regression test could not fail.** The test existed to prove one specific behaviour. Its fixture wrote the same number into both of the fields being compared, so an implementation that simply returned the input would pass every positive example. A test-quality lens found this in a colleague's change; the fix was to make the fixture's two values differ.

#### The noise rate, honestly

**The per-hunk reviewer produced 59 candidate findings across three runs. 17 were confirmed. 42 were refuted — 71%.** The worst of the three runs spent 133 agents and about 50 minutes to produce four low-severity points out of 26 candidates.

The refutations were not lazy. Each one was a separate agent reading the real source and trying to break the claim. That step is what makes the output usable at all. But it means most of what the machinery reports is not real, and someone has to sort it.

**Two tools agreeing is not evidence, and that cost me time.** On one merge request, two different tools independently filed the same high-severity finding with accurate line citations. Both were reading a worktree that was eight commits out of date. The constant they cited had been deliberately deleted, in a decision already reviewed and recorded. Acting on it would have reintroduced deleted code and reopened five closed review threads. That run happened to be one of the ones where I had not supplied a summary of the current state of the target branch. I supplied that summary on 5 of 14 runs.

**Silence is not agreement either.** On one review, two tools reported nothing while the other two each raised real problems. The problems they raised were all of the form "the code does not do what the description says it does", which is invisible to a reviewer that has not read the description. Two tools finding nothing was not four-way agreement that the code was fine. It was two tools answering a different question.

**The panel missed a real production defect, and its own report says so.** A change relied on reading rows from a table to establish a historical fact. A scheduled job deletes those rows permanently every night once they expire. So the fact could not be recovered for any expired record — and the change's own test for exactly that case passed, because nothing deleted the row during the test. None of the eight reviewers and lenses on that change found it. A later separate pass did. The reconciled report names the missing question: every reviewer reasoned outward from the schema, and none asked "what else writes to or deletes from this table?"

#### What I actually contributed

The tools produce candidates. I decide. A pattern I did not realise was so consistent until I counted it: some version of *"in simple technical English, tell me the comments you plan to post, per file and per line"* appears **before every single posting — eleven times that week.** Nothing was posted without me reading it first.

I also overruled findings. I kept a comment a reviewer wanted deleted, because a comment explaining why some data is deliberately excluded from a query saves the next developer a dig. I rejected a refactor the reviewer had already applied, because it compressed a readable sequence of steps into two opaque methods. And twice I rejected findings simply because I could not understand what they were saying — which is a reviewer failure, not a code failure.

One thing worth copying: I gave the machine-generated comments a fixed format partway through the week — a header with a priority and a triage tag (blocking, concern, suggestion, question, nitpick), and a footer stating plainly that a machine wrote it and how. The reason is simple. A colleague opening 17 comments needs to know which three to read first, and needs to know a person did not write them.

### Writing code

Five pieces of work, three merged that week and two still open. Roughly 4,400 added lines.

**400 edit calls and 80 file writes, against 100 prompts**

About five file changes per prompt and I used four different approaches, chosen by how easy the work was to get wrong:

- **Bake-off then promotion** for implementing new features
- **Failing test first** for a bug fix. My opening prompt was literally to write a test that fails and shows the reported error before doing any more digging or fixing.
- **Written plan first** for the largest new service which was then handed over to a back-off after my review. 
- **Direct prompting** for the small changes or for driving various implementations. 

#### The verification habits were the most valuable thing I did

Out of 1,400 shell calls in the coding sessions: 157 test runs, 60 linter runs, 43 type-checker runs, 20 dependency-boundary checks, 5 security scans.

**Six mutation checks.** In each case I asked agents to broke the code (only locally), confirmed the exact expected tests failed, restored it, and confirmed the restore. One of them changed a rounding function and confirmed that exactly three examples failed and none of the others. Another deleted a filter from two query objects and confirmed both tests including one that had been passing without testing anything at all.

**One push I refused to make.** I said to amend the commit and push. The agent set up a monitor instead and waited for the test run, then reported that it was not green and gave the two failures. I saved this as a user memory for all projects. 


#### Where the models were clearly worth it

- **Refuting my premise and finding a different, real bug.** I brought a capture from staging and said some numbers where not adding up. The agent reconciled the arithmetic exactly, explained why the sum looked wrong and then found the genuine defect.
- **Answering business questions by reading the code instead of guessing.** I combined asking the agents to read the Slack threads, JIRA tickets with searcing the code and commits to answer questions about how the system should behave.
- **Root-causing a test that only failed at certain times of day**, and proving the cause was not on the main branch.
- **Reducing work in the database instead of in application code** without losing an answer: a query went from about 86,000 rows to about 1,200, keeping two rows per group so that two different questions could both still be answered.
- **Noticing cross-branch damage unprompted:** it told me a sibling branch would break when it rebased, named the two lines, and said explicitly that it had not touched them.
- **Refusing to run a destructive script blindly.** A setup script ended with a sweep that drops other worktrees' databases. It ran the script with that sweep disabled and said why.

### Bake-offs: four agents, one ticket

Four bake-offs that week, each with the same four tools. Three of the four started from an open, unmerged branch rather than from the main branch because I need to build upon previous code that was not yet merged. 

Claude is the main orchestrator and it prepares the bake-offs: 
- Create the wortrees
- Setup the databases
- Setup branches
- Prepare a folder (git ignored) with context and prompt
- Run a script to watch all the agents finish

I usually run this automatically and ask Claude to start other agents but I had some issues with timeouts and also I am a bit skeptic to run 4 agents on my system with bypassing all permissions. Thus now I run manually 4 agents with the benefit that I can watch them if I want to doing the implementation. But I don’t usually do I prefer to read the final output. 

When all are ready Claude has specific instructions see the differences between agents’ implementations and where does it diverge and it looks at implementation notes the agents leave during their work and one more important step it looking at the tests written. Then it picks a winner and proposed missing/blind spots that other agents got and will be a valuable addition to the winner implementation. 

I read this entire analysis and see if I agree with the proposal and let the orchestrator know what to do next. What this part misses it does not do any quality analysis on its own. That is on me to know assess the code quality and the solution fit. 

Three winners were chosen for test depth or for making a specific mistake structurally impossible; one was chosen because it was the only entry that satisfied two stated acceptance criteria, even though a different entry had the better internal design. That entry's design was grafted into the winner.

**The part a comparison cannot do.** Every run also included a check for things all four agents got wrong the same way. It found something all four times. On one run, all four omitted a contract test that a sibling endpoint in the same component already has. On another, all four wrote their own version
of a database join instead of reusing the canonical one, and **none of the four opened the definition of the view they were copying from**, a view already on its twentieth revision. Four agents agreeing is not always the best outcome, a defect in the prompt they were all given looks exactly like four agents making the same mistake.

**Winning did not mean ready, and this is the real cost.** The promoted winner of one run was heavily rewritten later in the week; four of its nine calculated figures turned out to be computed twice per request. On another run, two of the three grafts it recommended were later reversed when I manually reviewed the final code. And on the last run, the approach that two agents had independently converged on, which I read as a good sign, was thrown out one day later: routing through the existing path cost about 200 database reads on a screen a user opens interactively.

My honest split: one of the four bake-offs clearly earned its cost, through three grafts that each fixed something real and one divergence that exposed a defect with money consequences. One was mostly ceremony no graft was needed, three of the four entries produced nothing that shipped, and the run's most valuable output came from the winner's own notes and from the all-four check, not from comparing the entries.

### Asking the model to read the code instead of guessing

This was the cheapest high-value thing I did all week, and it is the pattern I would most recommend.

Five times I asked a business or pricing question and told the agent to answer it from the production code rather than from documentation or from what I had been told. **All five answers held up.** Two of them corrected what a human had told me, in one case a summary from a colleague named the wrong
database column and in another the answer settled an open question with another team.

The single highest-value session of the week was about six hours spent reading a hand-run business intelligence report. The output was nine specific defects in that report, each of which became an explicit rule in the specification. Those will not have affected the business because a human would always review that output but I needed to automate it and in this case I needed decisions for all those 9 unclear parts. 

I did read that via an interactive session with Claude Code asking it to get each piece that composed the report explain it to me and then use an MCP to a datawharehouse to get results and see each part and what results it returns. 

## Where the models were wrong

### The failure shape I would watch for

Three times that week, an agent gave me a confident negative answer backed by evidence that sounded thorough, and was wrong.

- It told me a directory did not exist, and listed the four roots it had searched to establish that. The directory exists. Its name is spelled with one letter different from the word I would expect, and the search pattern used the expected spelling.
- It told me the data I needed was in a database its tools could not reach, backed by "I searched all 800 tables plus four named schemas". I pushed back and said try the main application database to turn out that the table it there and the query can be run.
- It reported a rebase as done and verified, with a checks table, and said the result was byte-identical before and after. It had even written down the correct concern first  that a clean apply is not proof of a correct result when both sides edit the same methods and then chose a check that was, by construction, blind to exactly that. I found the problem four hours later when I got to read that diff.

The common thread is that the amount of evidence offered had no relationship to whether the answer was right. A four-root search and a checks table are equally easy to produce whether or not the conclusion holds. I now read negative answers more sceptically than positive ones, because a negative answer closes a line of inquiry and could be totally fake. 

### Tests that cannot fail

I found four separate instances that week: a parity test comparing a copied SQL expression against the view it was copied from, so it compared the view with itself; a "no extra queries" test built on a record with no work attached, so the code path never ran; an existing test that was already not finding any bugs that was updated and the regression test in a colleague's change whose fixture wrote the same number in both compared fields.

**Mutation analysis is the only method in my whole corpus that caught any of these, and it caught all four.** It is also the only check I ran with perfect precision every finding it produced was real. I used it four times in a week. That is too few.

### My own rules leaked

I have written rules about how I want code and prose produced: plain language, a specific set of banned words, and utility scripts in Ruby rather than Python and I also checked whether they were followed.

**Scripting language: 117 Python invocations against 2,287 Ruby.** So about 5% of the scripting, and 96 of the 117 were multi-line. Almost all of them are the same thing piping command output into a one-line Python JSON parser inside a shell pipeline. 

**Banned words: more interesting than a violation count.** I found 150 raw matches, but the large majority are the model *enforcing* the rule searching its own diffs for banned words before committing, writing the ban into the prompts it hands other agents, and filing a banned word in a colleague's test name as a review finding. It even found that my own older prompt files break rules my newer ones state.

**Rules I wrote on Monday were gone by Tuesday.** I saved the review-comment format to my instructions file one day, and the next day, in two separate sessions, the agent did not have it and told me so plainly. I had to paste the format back myself. 

### The interrupts

Nine times I stopped a model mid-response and out of those three were course corrections.

The three real ones: an agent answering a question about a file from memory instead of opening it; a review run I had configured with five hunks per call at maximum reasoning effort, which exceeded the output limit and produced only truncated fragments; and one where I stopped a command because I wanted to reword my own prompt.

## What it was worth

**The refutation step is the best part of the machinery, and its value is in deleting work.** Across the three per-hunk runs it removed 42 of 59 candidate findings. One workflow raised 13 candidates and none survived. Another refuted two of the three claims in a bug report I had written, which stopped me filing it at the wrong severity.

The sharpest example: a workflow overturned an analysis of my own that I had already accepted. All three refuting agents succeeded, because the variable I was using as a predictor had been measured *after* the outcome it was meant to predict, in every case I could check. I re-verified every claim the conclusion depended on, then retracted the conclusion rather than softening it. That is the single strongest argument I have for the using multi-panel review and verification workflow. 

**The four-tool panel was the best value per minute.** Twelve runs, about 11 minutes each, four different tools reading the same change independently, for roughly 4% of the week's token spend.

**Generating candidates and then refuting them is waste when the input is already good.** One run spent 13 agents and 85 minutes confirming 12 of 12 candidate comments with none refuted. I have added those comments after reviewing the code but I always ask agents to try to refute them with evidence before accepting them. Still I would say this is a step I will not change. Sometimes this will pay off because my review could also be wrong or not have the full context. 

**The harness itself lost real time.** 14 stall-and-retry events across two of 22 workflow runs. In one of them a single agent stalled five times in a row roughly 88 minutes of dead waiting inside a 100-minute run and two agents died outright, which is the only reason a follow-up run exists.

**I have 82 skills installed and this week I used 17.** Two were built that week and never invoked again. 

**The cost of checking.** 43% of the work was about validation and verification, and it is a floor, because it excludes every Codex, Cursor and Amp agent. Measured a different way: what share of my own typing was corrective rather than
forward that figure is around 15%. 

### Two things I would change

1. Improve the back-off review with some quality metrics focused on simplicity. 
2. Upgrade *mutation analysis** to be run automatically everytime is needed. 

### What this measurement cannot tell you

- **Session duration overstates time at the keyboard.** My longest session spanned 1400 minutes and contained 112 active minutes. Long sessions are mostly parked, not worked. If you measure engagement by session span you will be wrong by an order of magnitude.
- **"Model-written versus hand-written" is not measurable here.** Every change went through a tool call. The accurate statement is 100% model-typed and human-directed.
- **Attribution labels are not work counts.** The label that records which skill a message belongs to persists across every later message in that session, so a skill that writes one line to a file can show thousands of attributed messages.
- **One week, one engineer, one codebase.** Nothing here is a general claim about these tools. It is a description of one week that I can support with logs.

## What I take away from this

The findings above are observations. This section is what I think they mean. Several of them turn out to be the same thing seen from different sides.

### 1. Adding more agents does not improve reliability. Adding a different kind of check does.

Normal reliability engineering says: run several copies of a component, and if their failures are independent, reliability improves sharply. That is why four agents feels safer than one. **It does not hold for LLM agents, because their failures are not independent.** They share training data, they share priors, and they are usually given the same input.

Four separate results in my week say the same thing:

- Two tools independently filed the same high-severity finding. Both were reading a worktree eight commits out of date. Their agreement measured how obvious the finding was given that input, not whether it was true.
- All four bake-off agents omitted the same contract test. A comparison between them could never show that, because a comparison only shows difference.
- All four correctly added a country condition to a tax calculation even though the plan they were given said not to. That agreement was not four agents validating each other. It was one defect in one plan, showing up four times.
- Two agents converged on the same approach. I read that convergence as a good sign. It was discarded a day later once someone measured its cost.

Now look at what actually found defects:

- The missing migration guard: **one tool out of four**, on its own.
- The floating-point rounding loss: **one tool out of four**, on its own.
- The mismatch between a status check and the code that acts on it: **one tool**, on its own.
- The tests that could not fail: found by a **different kind of check entirely** — mutation testing, not review.

Every real find came from something the other agents were not doing. Four *different agents* helped because they have different training and different scaffolding around them. Running 133 agents through the same kind of pass produced four low-severity points.

And the part I find least intuitive but now believe: **when every agent agrees, check the input.** Unanimity is a reason to reread the prompt, not a reason to proceed and be skeptic that they did not found anyting. 

### 2. Checks that run an experiment are accurate. Checks that produce an opinion are not.

Ranked by how often the method was right:

| Method | Findings | Real | What it is |
|---|---:|---:|---|
| Mutation testing | 4 | 4 (100%) | An experiment on the real code |
| Reading the diff myself | 7 | 7 (100%) | Direct observation |
| Running the code, or CI | 2 | 2 | An experiment |
| A second model reviewing | 59 candidates | 17 (29%) | An opinion |

This is not "people beat models". The difference is that the accurate methods **change something and observe the result**, and the inaccurate one **produces a view about something without changing it**.

Mutation testing does not ask whether a test is any good. It deletes the filter, observes that the test still passes, and now the answer is known. There is no judgement that can be wrong. That is why it found all four tests that could not fail while every other method found none.

**What I would do: for anything that matters, turn the check into an experiment.** Instead of "does this test cover the bug", break the code and watch. Instead of "did the rebase keep both changes" compare the two outputs directly. Instead of "is this filter needed" delete it and run the suite. And when an agent hands me a verification, I now review **the design of the check** more carefully than the code it is checking, because that is the weaker artefact.

### 3. A wrong "no" costs more than a wrong "yes", and it looks thorough

Three times an agent gave me a confident negative answer, supported by evidence that read as complete.

**The consequences are not symmetric.** A wrong positive costs one investigation, and I find out at the end of it. A wrong negative **closes the question** I might stop looking, and nothing later tells me I was wrong.

**The supporting evidence is free to produce and says nothing about correctness.** "I searched 800 tables" costs the same to write whether the search was well-formed or misspelled. The amount of stated effort is not a signal, but it reads like one.

**What I would do: never accept a negative answer on its conclusion. Ask what the search was.** Not "did you find it" but "show me the exact pattern and where you ran it". In all three cases, one look at the actual search would have exposed the problem immediately => a misspelled pattern, the wrong
database, and a comparison between the wrong two things.

### 4. A bake-off is a list of the decisions the agents disagreed about, not a way to pick a winner

I ran four bake-offs in order to pick winners. Picking turned out to be the least valuable part.

- The design that won one bake-off did not survive the week.
- Two of the three ideas I carried across from losing entries were later removed one because the situation it handled never occurs in the real data, and checking for it cost an unindexed scan.
- The approach two agents converged on lasted one day.
- But the check for "what did all four get wrong the same way" **found something in every single run.**

If you run four different agents to obtain one good implementation, you pay four times for one result, and that
result then needs the same rework a single agent's would have needed. If you run four agents to find out **which decisions are contested**, you get something a single agent cannot give you at all.

**What I would do: read the divergence, and treat unanimity as a warning about the prompt.** Which entry wins is close to incidental.

### 5. Written instructions fade as the context fills. Mechanical checks do not.

Three results that are really one result:

- Rules I wrote one day were absent from the working context the next day, in two separate sessions and the agent said so plainly and I pasted them back.
- I asked for the same rule 27 times in one week, for a rule that is written down as standing.
- 117 Python calls against a rule that requires Ruby for utility scripts

None of these is the model disagreeing with me. It seems to me that the rule simply stops competing for attention once the context window is full and so a standing instruction holds early in a session and fails late.

Now notice which rule *was* followed. The banned-word rule was enforced hard the agent searched its own diff before committing, wrote the ban into prompts it handed to other agents, and filed a banned word in a colleague's test name as a review finding. That rule worked because **it had been turned into a search command.** A text search does not care how full the context window is.

And the one place that rule still leaked? Inside the wording of one of my own review checks a place no search was pointed at.

**What I would do: any standing rule I actually care about has to become a mechanical check.** If following it depends on the model remembering, it will hold at the start of a session and break at the end. Re-reading decisions into context at high context is the right instinct, but a check that greps
is stronger than a note that reminds.

### 6. What the person in the loop is actually for

I categorised all 350 prompts I typed. Only 4% ask for verification and 1% are corrections. My value was almost never in correcting the model.

It was in four things:

1. **Choosing which machinery to point at which problem.** One word starts 1,300 sessions.
2. **Supplying constraints the model cannot derive from the code**: that the change must not create a release dependency for the front end, that it is for one client only, that a speculative database index should be a separate change. None of that is in the repository and some of them are architectural decisions or tast or idiomatic 
3. **Deciding what reaches another person.**

The fourth is the only step I never automated, and I did it every time: some version of "show me the comments you plan to post" appears before **all eleven** postings. Nothing went to a colleague unread.

I think that generalises. **Machine output aimed at a person needs a priority, a triage tag, and a line saying a machine produced it** otherwise seventeen comments get ignored as a block. I introduced that format midweek for my colleagues. My own inbox needed it just as much: 330 of the 800 messages I
received that week were written by machines. Attention is the scarce resource now, and this machinery creates demands on it faster than one person can answer them.

### What would change my mind

Two gaps limit everything above, and I would rather name them than let the list read as settled.

**I never ran a control.** I did not put one careful single reviewer against the four-tool panel on the same change. 

**Mutation testing's perfect record rests on four findings.** I believe the accuracy is structural, because it is an experiment rather than a judgement, so the reasoning does not depend on the sample size. The experiment I would run next is to mutation-check every agent-written test on one ticket and count how many prove nothing. On this week's evidence I do not expect that number to be small.


## Instead of a conclusion

Still I look at the last week and I think the work I have done would not have been possible in such short period of time without LLMs. 
I did changes in a part of the codebase that I was not familiar with and in a domain that I just learned maybe 2 month ago. It is an area with high complexity and a lot of other parts of the codebase might have influence in its logic and the branching happenig while executing the code there.

With LLMs I was ablet o build a context, ask questions, understand what is happening in the code, formulate better questions for my colleagues for me to ask to understand more and manage a series of branches built on top of each other while keeping them in sync. Still there is a lot of effort that I had to put in to keep the LLM to do code changes that are brief and limit the amount of side effects.


This week was not the first one building a full feature with LLM but I just focused on its numbers now. Will try to share every week numbers, learnings and insights. 
