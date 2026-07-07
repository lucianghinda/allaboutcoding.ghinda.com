---
layout: post
title: The pitch for Email Course
subtitle: Reasons an email course can be an effective learning method
date: '2024-01-03 05:00:09 +0000'
published: false
hashnode_draft_id: 659105866056f2eb23bb724a
---

Here is why I decided to build this platform and some high-level plans of what I am trying to do with it.

## The problem

Staying up to date with the evolution of technology is among the core tasks of a software developer. There are multiple ways to achieve this: reading social media, subscribing to a newsletter, watching videos, reading articles, or reading books.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1704170421001/a107e90c-5649-49dd-ab8a-4ae2cb2e6e23.png)

There is a missing product that should fit into the mix of deep dive with less effort than reading a book.

## The solution

For lack of a better word, I will call this solution an email course.

A series of emails are sent periodically. Usually, they are sent every week, but the user can choose to receive them more often.

There can be other media to share the knowledge this way - split in chunks and consumed over time. My proposal is email because it is a means of communication that works well but leaves the reader's attention and decision. It does not need to be read now; the reader can choose when and how to read it.

The same can, of course, be said about a series of articles or YouTube videos. They all have their purpose and fit well within a diverse group. I like email because it is a two-way communication: it can be read, but I can reply quickly. It creates a communication channel. But I also like it because it is text, and text is an amazing way to express ideas and to discover new concepts.

Any email course should be able to be restarted as many times as possible.

### Novelty

This idea is not new. This idea has various forms - some more similar and some a bit different.

I plan to focus on making it the best learning experience and, in the case of the content, to focus on Ruby and Ruby on Rails content. I will explore this as I build the platform and write the content.

### An example of an email course

Here is one example of how I would split an email course into topics:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1704172744801/a5ce8cc8-d08d-4d26-bf28-de5f11da30ba.png)

Of course, the actual content of each week might change based on the feedback and what I discovered while creating each week's email.

### The interface

As the primary medium is email, the interface should allow passwordless login via email.

The user should be able to see the running and finished courses and restart any of them at any point. At the end of a course, there will be the option to download a PDF version containing the same content as the course.

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1704175338108/0ae29181-cf80-4818-ab18-1039dca3fa37.png)

### Composing emails

For composing emails, I will either use the default editor from Rails and send emails as they are formatted by Trix or compose the emails in any other email delivery service and then, from the app, trigger the end of that email from there. I will these two solutions and pick one that first best the initial workflow.

## No Gos

I will not build my email editor/composer.

I will use an email delivery service - probably Postmark - and will only try implementing some email delivery-related tasks myself.

The focus will be on the content and providing a simple way to configure when the emails will be sent.

## Conclusion

This is the initial pitch about what I want to create and why I want to create it.

I will try to post as often as possible about how I think about building this product.
