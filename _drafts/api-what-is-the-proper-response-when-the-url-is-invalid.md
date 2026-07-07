---
layout: post
title: 'API: What is the proper response when the URL is invalid?'
date: '2022-07-15 03:40:20 +0000'
published: false
hashnode_draft_id: 62d04c4b6b0f8eeb0e067231
---

# Context

Say you are designing an API and are thinking about how you should respond when the URL is invalid.

Assume that we have an API that has the following structure:
`/api/v{version_number}/{resources routes}`

The system exists with the following specs: 

- `api` is the namespace for all API endpoints
- `v1` is the version number of the API. Only `v1` exists. No other version exists. 
- `users` is a resource that describes users. This exists
- `users/1` is an example of an URL for the user with id = 1
- `users/:user_id/downloads/:id` is the URL for a specific download identified by `:id` belonging to the user with id `user_id`
- the are 100 existing users and each one has at least one download

In this case, here are some examples of invalid URLs:

1. `/aapi/v1/users/1
