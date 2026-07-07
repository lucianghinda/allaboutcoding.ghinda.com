---
layout: post
title: Using GPT-4 to refactor a simple HTML page
date: '2023-09-13 03:10:33 +0000'
slug: using-gpt-4-to-refactor-a-simple-html-page
subtitle: Utilizing Cursor IDE and GPT-4 for logo placement, spacing adjustment, equal
  column height, and group hover element display
tags:
- ruby
- rails
- gpt-4
- ai
- programming-blogs
description: Utilizing Cursor IDE and GPT-4 for logo placement, spacing adjustment,
  equal column height, and group hover element display.
image: "/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/55baa478-5296-4967-a60c-e0df5ec37063.png"
last_modified_at: '2023-09-13 13:00:03 +0000'
---

Continuing with my endeavour of publishing more about using GPT-4 while coding, here I am going to show you how I refactored some HTML when writing the homepage for [ShortRuby.com](https://shortruby.com)

*Note: When I am writing in this text GPT-4 I want to say that I am using Cursor IDE with GPT-4 option.*

First, this is the result. I am pretty happy with it as I spent little time making it and it was a small iteration. This will probably evolve over the next weeks thus it is better to capture here how it looks like at the end of this coding session:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/d6915a8a-0bdc-4842-add9-8e27366d4995.png)

## Adding the logo to the top left

After I created a very simple hero section that contained the title and a description I wanted to add a logo to the left side.

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/948b509e-a6ff-4cd4-80a7-9cc2c2bf27f8.png)

The prompt here is simple, it includes a reference to the hero partial (I am using Cursor IDE) and I asked it as clearly as I could what to do.

I received a good enough response along with an explanation of the solution. I was pleased to notice that the logo was indeed on the left side.

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/78925f19-aa04-4912-a9db-932299e32973.png)

The only thing is that I asked for a "square with rounded corners" but I received a full-circle image. I kept it because I liked how it looked. Yet I appreciated that it told me how to make the corners "less rounded"

## Decreasing the top and bottom space

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/2aca0dc3-9bea-4763-92fe-2266b96b80cd.png)

You cannot see it in the final form of the website but you can see in the above image that the vertical padding on the second div is quite big `py-32` or `py-40` depending on the screen size.

Thus as you can notice I asked it to decrease the spacing while choosing the appropriate Tailwind dimension. Notice that here I tried to be explicit but did not use any Tailwind (like asking for a specific utility class) or CSS-specific terms (like padding or margin ...)

The response was again good enough:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/2a2a0dbc-8ea4-435f-8a33-f4ae9c38c99f.png)

I like the explanation about how it arrived to transform `py-32` to `py-20` (reducing in this case to about 62.5%) and `py-40` to `py-28` (reducing in this case to about 70%). I found them pretty close to the 1/3 that I asked for and they looked good enough to keep this change.

## Making the columns the same height

I then had a page with 3 columns (or cells) each one having a different height because the description had a different length. Thus I asked GPT-4 to change it:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/720ae96e-fcca-480a-9b07-ef287818d563.png)

Here I tried again to be as descriptive as possible without giving into what solution I am looking for.

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/4f5d8783-00e8-4980-bcb3-15e906ab4aca.png)

I received a response that uses `flex-grow` to achieve this result. It worked, but in the end, I needed to edit more. After seeing the result I also added height to the title of the column.

## Replacing a `div` with `a`

After playing a bit with the design I figured out that I wanted to make the entire column clickable and not only the small button to visit.

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/ecf8a008-a729-4849-ae33-d5a0513a7980.png)

This time I used the in-editor chat and selected one column that I asked to be transformed. What you can notice in the above prompt is that I ask specifically to keep the format/layout of the column. I asked this based on previous experiences when I asked for changing tags and I noticed that it needs guidance on what to choose when merging styles.

Here is the diff that Cursor GPT-4 proposed:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/ad7c78fb-1dac-4e96-af33-a365b5ab3388.png)

It is a good result, it does do the job that I asked for. I noticed that it added a `bg-white` class that was not necessary, but I think it makes sense to add it so that it is clear what happens on `hover` - what background colour it transitions from.

## Making an element show when the column is hovered

I wanted to add a bit of colour on the entire page because it is a bit grey. Thus I added a small animated bullet in blue.

Thus my objective was to display that element only when the column is hovered:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/9cee199f-7ea1-44de-97f1-192c863a7d26.png)

In this case, because this is about show and hide, from my previous experiments I noticed it needs to know what to do when what is added will conflict (using `flex` and `block` or `hidden` and `block`). I added, *"when there is a conflict between added CSS classes please choose the ones that will achieve this functionality"*.

The result works and it uses `group` and `group-hover` to achieve the result:

![](/assets/images/posts/using-gpt-4-to-refactor-a-simple-html-page/6b8a327e-3b10-431d-8242-658937422e95.png)

It did the work and now I can have this:
{% include embed/youtube.html id="d7KgiMu0-bk" %}
## Conclusions

Here are some learning points from this experiment:

* GPT-4 is not aware of CSS classes that are doing similar things through different CSS rules. Thus it cannot act like a linter nor it can choose one or the other =&gt; it needs to be instructed on what to do in case such conflict occurs. I instructed it generally in the examples above asking to pick only classes that will achieve the functionality but you can also instruct it specifically like preferring `flex` or `grid` or something similar
    
* Among the most important learning for me - not only from this small experiment but for many others - is that the effort to write prompt forces you to put your thoughts in writing and this simple act will help to make some choices or be aware of some choices and thus will contribute to having a better code design.
    
* Even with better prompts and the results containing an explanation, the programmer still needs to be able to understand the solution and assess if it works and if they want to keep it.
    
* I still like more the side chat for Cursor IDE and prefer it over the inline chat. Probably it is a preference that comes from because I used it before for 1-2 months Github Copilot Chat and thus it probably was the start of a habit
    

---

Enjoyed this article?

Join my [**Short Ruby News**](https://shortruby.com/) **newsletter** for weekly Ruby updates from the community. For more Ruby **learning resources**, visit [**rubyandrails.info**](http://rubyandrails.info)**.** You can also find me on [**Ruby.social**](http://Ruby.social) or [**Linkedin**](https://linkedin.com/in/lucianghinda)
