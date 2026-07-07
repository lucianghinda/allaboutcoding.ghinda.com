---
layout: post
title: How to use Fastly VCL to serve another URL based on a header
date: '2023-12-19 04:14:33 +0000'
published: false
hashnode_draft_id: 61d530e9220e98797766a269
---

# Context

You are working on a REST API and using [Fastly](https://www.fastly.com) to cache requests to your API.

## Problem you are trying to solve

You have some older clients connecting to your API that cannot be updated right now and you want to introduce new functionality in your API without affecting your existing clients.

## Solution A: Use versioning

If you can use versioning then this problem is solved. Just add a new version for your API and implement the new functionality there. If you can add the new feature without changing the request/response of the older version of your API then do also that.

## A more complicated problem

What if your endpoint is serving a static file and you don't have the possibility to bump versioning.

So basically you want the older clients of your endpoint to receive the same file as response and some updated clients of your endpoint to receive another file and do this transparently and without changing the URL of your endpoint?

## Solution B: Using Fastly to redirect URL based on a header

What you can do is just ask new clients of your API to send a custom header while doing the request to the existing endpoint and based on that header you will make Fastly redirect to the new or the old file.

## Implementation in Fastly

First I think it is best to know that Fastly offers a live playground to write and debug your VCL code here: https://fiddle.fastlydemo.net

This is great because it is very hard to debug your VCL code directly live.

https://fiddle.fastlydemo.net also directly supports logging with `log` while for the live version you will need to configure or set up a logging service.

### The code

Let's first think about the logic of what we want to implement, it might be something like this:

```ruby
Check if the header is present
Validate the header against a regexp to make sure it is something valid
If header is present and valid, then redirect to the newly formed URL
```
