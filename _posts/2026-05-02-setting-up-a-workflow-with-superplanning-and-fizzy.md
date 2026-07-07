---
layout: post
title: Setting up a workflow with superplanning and fizzy
date: '2026-05-02 16:59:15 +0000'
slug: setting-up-a-workflow-with-superplanning-and-fizzy
tags:
- ai
- llm
- ruby
- ruby-on-rails
description: Documenting a weekend experiment with codex /goal command, using superplanning
  for initial planning and fizzy cli skill for task management. A straightforward
  workflow for implementing newsletter features.
image: "/assets/images/posts/setting-up-a-workflow-with-superplanning-and-fizzy/43e1ac53-75c1-4a62-9efe-ef8b2171af54.png"
last_modified_at: '2026-05-04 04:28:26 +0000'
---

I'm trying the `/goal` [command in codex](https://simonwillison.net/2026/Apr/30/codex-goals/) this weekend.

![](/assets/images/posts/setting-up-a-workflow-with-superplanning-and-fizzy/4c7134a4-0d48-4387-9bca-6398bbbdfa94.png)

Here's the workflow I set up:

1\. First, I used superplanning to create the initial plan. Then, using the fizzy cli skill, I created each task with all the details in fizzy.

2\. The implementation approach is straightforward:

```markdown
/goal Implement all the features for the newsletter from Fizzy cards that starts with `Feat: Newsletter/<N> - <Subject>`

Treat `<N>` as the card’s sequence/order. Work through the matching cards one by one, in ascending `<N>` order unless the card details clearly require a different dependency order.

For each card:
1. Open and read the full card details.
2. Move the card to `in progress` before starting implementation.
3. Implement only the requested change for that card.
4. Keep the diff small, scoped, and consistent with the repository’s existing patterns.
5. Verify the change with the appropriate tests, lint, or manual/manual checks.
6. After each card is verified, make a focused git commit before moving the card to done.
6. After committing move the card to `done`.
7. Start the next matching card only after the current card is done.

Follow `AGENTS.md`. Try to keep existing behavior unless the card explicitly asks to change it. Stop only if there is a real blocker, missing critical information, destructive risk, or an external dependency.
```

3\. Of course, codex has superpowers-ruby installed to support this workflow.

Let's see where this will go.
