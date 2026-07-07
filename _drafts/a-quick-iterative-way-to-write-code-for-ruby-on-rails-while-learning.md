---
layout: post
title: A quick-iterative way to write code for Ruby on Rails while learning
date: '2023-09-11 11:53:51 +0000'
published: false
hashnode_draft_id: 64fdab4192c4b2000fc0f7e3
---

I usually talk with a lot of people who are learning Ruby and usually, I notice there are very few resources talking about the process of implementing a solution or coding a feature.

There are numerous resources related to TDD, BDD, and ATDD. However, when learning a new language or framework, the chances of being able to both grasp the technical content and effectively practice TDD are quite slim. Kudos to instructors who develop courses that teach programming languages using TDD. If you're someone seeking to learn a programming language, look for a course that incorporates TDD in its teaching approach.

But in case you either did not follow such a course or maybe you followed but don't want to fully embrace TDD (you should :) ) I will try to capture in writing a process that I used and sometimes still use in my side projects when I want to do fast progress.

Here is the gist of it:

1. First I write the simplest, fastest solution that I can. I will write it directly in a controller method if it is something that would be returned to the browser or close to the return point.
    
2. Then I write two tests: a success use case and a failure case. These should be simple and directly assess the main logic of the feature. Usually, I write these at system tests/feature tests or maybe controller tests. Why? Because there is no point in writing here tests. The code structure will change for sure. But my purpose here is to verify the output from the perspective of the end-user.
    
3. Then I refactor the code and follow SOLID principles, extracting the logic out of the controller and moving it to a model or PORO.
    
4. Then I expanded tests by trying to assess multiple other use-cases.
    
5. Then I refactor the code more
    

## Objective:
