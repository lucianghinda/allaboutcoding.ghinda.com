---
layout: post
title: 'Shortfix: When updating Dockerfile to use ruby3.0.3-alpine pin alpine to alpine3.13'
date: '2021-11-29 08:44:12 +0000'
slug: shortfix-when-updating-dockerfile-to-use-ruby303-alpine-pin-alpine-to-alpine313
tags:
- ruby
- ruby-on-rails
- docker
- bugs-and-errors
- howtos
description: "If you update your Dockerfile to use ruby:3.0.3-alpine and notice the
  following error while building the image: \nERROR:  While executing gem ... (Gem::FilePermissionError)\n
  \   You don't have write permissions for the /usr/local/bundle directory.\nFirs..."
image: ''
---

If you update your Dockerfile to use `ruby:3.0.3-alpine` and notice the following error while building the image: 

```
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /usr/local/bundle directory.
```

First know that `3.0.3-alpine` actually is using `alpine3.14`.

The fix is to pin the alpine version to 3.13 so use in your Dockerfile: 

```
FROM ruby:3.0.3-alpine3.13
``` 

### Why this happens: 

Seems like something changed in `alpine3.14` and `bundle` cannot write
in `/usr/local/bundle`.

Multiple people had this issue:
- Gitlab https://gitlab.com/gitlab-org/gitlab/-/issues/335641
- Ruby Official Docker Library: https://github.com/docker-library/ruby/issues/354

It seems to be related to Docker Version running the Dockerfile:
- https://github.com/docker-library/ruby/issues/351
