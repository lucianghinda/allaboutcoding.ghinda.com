---
layout: post
title: "Re-reading A Philosophy of Software Design"
date: '2026-11-23 08:08:48 +0000'
slug: re-reading-a-philosophy-of-software-design
tags:
- software-design
- architecture
- code-review
- ai
- llm
description: "Re-reading John Ousterhout's book with my old highlights, I now highlight different things. In the age of LLMs we should review architecture and the interactions between modules, not only small classes and small PRs."
image: "/assets/images/posts/re-reading-a-philosophy-of-software-design/og.png"
last_modified_at: '2026-11-23 08:08:48 +0000'
---

Re-reading A Philosophy of Software Design by John Ousterhout after seeing it recommended by Matt Pocock. Have to say, looking at an older PDF with my old highlights, I now highlight different things.

For example, I had an older note debating his idea about smaller classes. But now I think we should all re-evaluate our priors in the context of AI engineering.

We need to move to a higher level where, even if we still need to understand the code, we focus on how to shape it so it is easier to understand and combine, by people and AI. In the age of LLMs the direction might be different than before. Smaller classes were maybe better when code was written and approved by a human, but now we need to look at it more like architecture: review the architecture and the interactions between modules.

The same goes when thinking about a changeset or PR. Before, I believed in the Cookpad approach (from when I worked there 5 years ago): keep PRs under 100 additions, the best way to get quick reviews and a great flow of incremental changes.

Now the number of PRs/MRs is getting bigger and we are exploring how to unblock this part. I am not sure reading each line of a diff is still the best way to review such changes. If the approval remains manual (and there are industries where it will), then I think the way we review a changeset should shift toward seeing its impact on the system: complexity, interactions with other modules, or something in this direction.
