---
layout: post
title: Where to validate data when scheduling a job
date: '2022-05-13 11:55:08 +0000'
published: false
hashnode_draft_id: 627e470a2d79aee15d04375d
---

"There is one thing to take into consideration about sending params (like user_ids) from API to a Job:
When the job will be executed and what can happen with the state of the the app between the moment a job is scheduled and when it is executed.
Here are some examples:
- the user is deleted thus the user_id is invalid
- some other data that is linked to the user is changed between the time the job is scheduled and executed. Like for example the user will cancel an action in an interface but the job is already scheduled or for the user changes their mind like: "I want to receive marketing emails" to "I don't want to" 
- or the user scheduled for deleting an object that is linked to a resource and when deleting that object the external resource will be deleted. When job was scheduled, the external resource was used only by that object and can be deleted. But when the job is executed, the external resource for example is now linked to two objects and only one is scheduled for delete the other one is still used ... (as it was created in between)

There are many examples.
So my rules for this are like: 
- validate in API everything 
- revalidate in Job so that the state is the same as when the job was scheduled"
