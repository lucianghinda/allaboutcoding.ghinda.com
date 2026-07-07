---
layout: post
title: Using ChatGPT, Github Copilot and Phind to generate Tailwind config for width
  classes
date: '2023-10-20 11:00:07 +0000'
slug: using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes
subtitle: Examining the results of ChatGPT 4, Github Copilot and Chat and Phind in
  generating Tailwind width configurations utilizing the golden ratio.
tags:
- ruby
- tailwind-css
- ruby-on-rails
- chatgpt
- ai
description: Compare ChatGPT & Github Copilot's methods for creating custom Tailwind
  width classes with golden ratio; evaluate effectiveness and accuracy
image: "/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/e065a4e3-a08d-4097-9299-8f4b89de16e5.png"
last_modified_at: '2024-01-11 09:29:03 +0000'
---

In this article, I will show how I used ChatGPT, Github Copilot and Phind to generate a custom Tailwind config for width classes up to 800px for desktop resolution.

These language models can serve as helpful conversation partners, providing different solutions to the same problem.

Here, we'll compare their responses to a specific request involving the golden ratio and discuss their effectiveness.

## Problem

As this was a personal project, I did not have a complete design, just some inspirational ideas that I wanted to try.

I wanted to add some custom width-sized in a Tailwind config for a web app up until about 800px for the desktop resolution.

I asked both Chat GPT 4 and Github Copilot Chat the same question and got different answers.

## Chat GPT 4

Here is what I asked Chat GPT 4:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/92c6083a-5624-458c-81c2-9bbe8c750f70.png)

Here is what it suggested:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/adf0a679-7f42-4889-a216-7b01c26e8181.png)

As you can notice it used the constraint that I added (to use the golden ratio) to calculate the actual size from the last one provided by me (384px) to reach the 800px that I asked for and then tried to create a series of width utilities matching a bit how Tailwind does it - by spacing them out.

Did not check all of the utilities proposed, but the first one and the last one are calculated ok from the rem to px ratio.

## Github Copilot

I then tried to use Github Copilot via VSCode to generate this list.

Here is the prompt and the response:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/e86239e8-0d0c-4f4c-bdbe-50c94230ae4a.png)

It has some fine-grained steps, it reaches the 800 px and it correctly started from 400 (as Tailwind already defined 384px) but I don't see how it used the golden ratio (which is around 1.61).

It ignored the request to use the golden ratio: did not use it for spacing the utilities, nor used it for calculating the distance in rem or pixels between two utility classes.

## Github Copilot Chat

I then tried Github Copilot Chat:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/c7e90baf-7c0b-4d1b-82fd-65b38659b935.png)

And it replied with the following:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/133df7c4-652b-40d4-8c12-f6d35166614d.png)

It seems that it was not aware that Tailwind already has width classes up until 384px. But it did apply with an approximation of the golden ratio when spacing the width classes.

## Phind

I asked [Phind](https://www.phind.com) the same question and here is the answer:

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/4c884fb9-62bc-4655-87b5-673d1eccccc0.png)

![](/assets/images/posts/using-chatgpt-github-copilot-and-phind-to-generate-tailwind-config-for-width-classes/722b2e88-d14f-42e6-bff8-7e728a9884f3.png)

I find the Phind answer better. It explains how it did the calculation, it used the golden ratio for each step and it also provides the Tailwind config and shows how to use it.

---

Enjoyed this article?

👉 Join my [**Short Ruby News**](https://shortruby.com/) **newsletter** for weekly Ruby updates from the community and visit [**rubyandrails.info**](http://rubyandrails.info)**,** a directory with learning content about Ruby.

👐 Subscribe to my Ruby and Ruby on rails courses over email at [learn.shortruby.com](https://learn.shortruby.com) - effortless learning anytime, anywhere

🤝 Let's connect on [**Ruby.social**](https://ruby.social/@lucian) or [**Linkedin**](https://linkedin.com/in/lucianghinda) or [**Twitter**](https://x.com/lucianghinda) where I post mainly about Ruby and Rails.

🎥 Follow me on [**my YouTube channel**](https://www.youtube.com/@shortruby) for short videos about Ruby
