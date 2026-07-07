---
layout: post
title: A project to be implemented with Action Cable
subtitle: Defining requirements for a project where we will use Action Cable
date: '2021-12-08 16:49:34 +0000'
published: false
hashnode_draft_id: 61b0de38ccd13f578941e901
---

I am writing here a series of articles about how to create an Action Cable App in Rails and then how to use it outside Rails. There are a lot of articles about using Rails, but I found few about how to use it outside Rails. 

# What problem do we want to solve

Let's define here a project that we want to create: 

> Creating a backend application that supports a virtual tour of a museum and allows users that are in the same area to chat ask questions to one of the available guides. 

## How it should work

Users are scanning some QR codes available in various areas of the museum and then join a chat room dedicated to that area where they can ask questions and receive answers. 

Guides will need to have a general page and see questions asked from everywhere and decide to join or not a chat room to answer a question. 

## Tasks to be done in our Backend

**First**, we will need to create an API that will be accessed by a visitor when scanning a QR code. 

Let's define it as being `GET /chats/area_id` and will need to return all info required to connect to a Channel dedicated to that area. 

The response will be something like: 

```json
{
  "url": "ws://example.com/cable",
  "token": "auth_token",
  "channel": "Channel"
}
```  

Then let's assume the user has a kind of mobile app created by the museum that will open a WebSocket and connect to that Channel.

We will then need to define a way for the user to send chat messages and receive replies. All this will happen via ActionCable and will define the format when we get there. 

Second, we will also need to have a way for the guides to get all current active questions. And then connect to one of the chat rooms and write a message there. 

For this first we will define a REST endpoint like `GET /questions/active` and then we will define the Action Cable messages when we will arrive at that part. 

Of course, we will not create the whole backend for this, nor the entire frontend. 

My purpose is to create only the part that is required to make the Web Sockets work and also do a small demo in JavaScript.
