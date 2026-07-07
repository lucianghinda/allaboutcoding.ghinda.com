---
layout: post
title: How to handle technical debt in a product
subtitle: Short notes about a high-level process to handle technical debt in a product
date: '2023-02-09 07:09:54 +0000'
published: false
hashnode_draft_id: 63da1e2d7aa97c0008053e14
---

The idea for this post started with [Drew Bragg](https://www.drbragg.dev) asking the following question:

> Medium-ish sized dev teams.
> 
> What is your team's approach to organizing tech debt projects?

I think there are two problems with managing technical debt:

1. *How to manage the information* about technical debt: how to gather it, where to report it, what format, what tools to use to share the data in a team
    
2. *How and when to pay or fix the technical debt*
    

I will focus here on describing a process for how to fix the technical debt.

## How to fix the technical debt - a simple process

Fixing technical debt should have two main active components:

1. Small refactoring
    
2. Intentional effort
    

## Small refactoring

**What is it?**

Small refactoring is about "leaving the code better than you found it".

Every time you change a method/object to fix a bug or implement a new feature, you should also improve the code there even if it is not directly related to what you are working on.

Of course, do this in a separate PR if you like to keep the scope of your current PR small and on point.

But here the main idea is that you already loaded that specific context in your mind (the object or method) so now is the best time to make it a bit better.

**Examples**

Examples (not a comprehensive list, mostly thinking about Ruby):

* renaming a method or an object
    
* renaming params
    
* transforming params from positional to keyword
    
* extracting one or more methods to an object
    
* transforming from if/else to guard clause
    

The list can be extended. But in general, this category is about minor refactoring while doing your everyday work.

**Why this is important**

This small refactoring is essential because it can happen constantly and the mental overhead to deal with it is reduced.

It is also a smooth way to ensure that the code that is changed often (which might be the most important one) is in the best shape.

**How to organize**

There is no need to organize this in a specific way from a process point of view.

Just make sure you have two things in place:

* You have clear guidelines about what is good code
    
* You make this small refactoring a principle in your team (and have the technical leadership talk about it)
    

In general, I like the advice from a [paper published by Google](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/37755.pdf), called "Searching for Build Debt: Experiences Managing Technical Debt at Google"

[![](https://cdn.hashnode.com/res/hashnode/image/upload/v1675923939477/ff0a2c8a-6e1e-4674-ac14-8e74ecabd5aa.png)](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/37755.pdf)

*Advice for developers:*

* When doing code review try to support your colleagues to make this refactoring by providing guidance and feedback about it
    

*Advice for leadership:*

* Try to make it so that there is time for this. This cannot be estimated nor can the future be planned ahead. The simplest advice is: don't put time pressure on your team, so they have time for this.
    

**Warning**

When time pressure is on, this will be the first thing dropped, along with introducing more small technical debt.

If developers don't have time or support to do this small refactoring then the technical debt will increase exponentially and will soon be hard to address.

## Intentional effort

**What is this intentional effort?**

It means that there should be a planned process that gives time and decision to the developers to pay off technical debt.

**The process**

For the process, I like the main idea from [ShapeUp](https://basecamp.com/shapeup) where the work is split between periods of business focus (Cycles) and periods of technical focus (Cooldowns).

Cooldown is [described](https://basecamp.com/shapeup/2.2-chapter-08#cool-down) in ShapeUp like this:

[![What is cool-down from ShapeUp book](https://cdn.hashnode.com/res/hashnode/image/upload/v1675320282865/c9f4c652-922d-44ce-ba19-e442b974ad77.png)](https://basecamp.com/shapeup/2.2-chapter-08#cool-down)

Thus my proposal for a process to handle technical debt is simple: use the cool-down for this.

**How to use the cool-down to pay technical debt**

Once per 6 weeks (or once every 3 sprints), there should be 2 weeks where work is driven by technical people - your developers, DevOps, DevSecOps, Infra, Platform team.

**The scope** of the cooldown should be: make improvements that can be shipped during those two weeks.

**The method** (or at least a proposal)

At the beginning of the cooldown developers should compile a list of improvements they want to work on. This list could contain items type like:

1\. Bugs (focus on the ones that are due to technical debt)

2\. Refactoring

3\. Improvements

Then a review of this list happened together with the team. The output of this review would contains a 3 part prioritized list:

1\. Ready for work: containing tasks that we want to handle this cooldown

2\. Maybe: tasks that might be tackled if there will be time)

3\. Not for this cooldown

Of course, just to mention: Cooldown tasks do not happen in a vacuum.

They should have a way to prioritize that still takes into consideration current bugs and future business needs, along with areas that are highligh used.

It is also important, I think to have this dev dedicated cycle repeated every 6 weeks:

\- It puts the developers in charge thus they will start having their own agenda that they can plan

\- It creates predictability about when a technical improvement can be added

It creates the right balance between fast shipping features and having time to make the code right.

The cooldown will be used to pay a technical debt that was just created =&gt; thus, it is the best t time to pay it - as close as possible to the moment of creation

To make this work two thing are really important:

1\. During the 6 weeks, developers should focus to ship business value.

2\. Then during cooldown, developers \_should be allowed\_ to work on the task they choose.

A concrete example from a company I worked a while ago:
