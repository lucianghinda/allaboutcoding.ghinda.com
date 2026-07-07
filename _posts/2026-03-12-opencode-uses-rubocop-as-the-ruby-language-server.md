---
layout: post
title: 'OpenCode Uses Rubocop as the Ruby Language Server

  '
date: '2026-03-12 06:01:17 +0000'
slug: opencode-uses-rubocop-as-the-ruby-language-server
tags:
- ruby
- opencode
- ai
- llm
description: OpenCode uses RuboCop's LSP (rubocop --lsp) for Ruby—auto-detecting projects
  and installing RuboCop safely without touching your Gemfile.
image: "/assets/images/posts/opencode-uses-rubocop-as-the-ruby-language-server/7975d221-f257-40ab-8dbd-3d2c85a411d3.png"
last_modified_at: '2026-03-12 06:01:46 +0000'
---

Yesterday I shared about how to configure Claude Code to use Ruby LSP. Today I will talk about [OpenCode](https://opencode.ai).

Here the things are simple: OpenCode automatically detects what LSP you need and will install it for you.

In case of Ruby OpenCode labels the LSP as *ruby-lsp* in the UI, but that label turns out to be a bit misleading.

## What Runs Under the Hood

When you open a `.rb` file in OpenCode, it automatically detects the extension, finds the nearest `Gemfile` as the project root, and sets up a language server for you.

The gem it installs and runs is **rubocop** in `--lsp` mode, not the [ruby-lsp](https://shopify.github.io/ruby-lsp/) gem from Shopify. These are two different projects. The UI still shows *ruby-lsp* as the label, but that is kept for backward compatibility. What is actually running underneath is `rubocop --lsp`.

If `rubocop` is not found in your PATH, OpenCode installs it automatically into its own managed directory. It does not touch your project's `Gemfile` or your system gems. You can opt out entirely by setting `OPENCODE_DISABLE_LSP_DOWNLOAD=true`.

## Why Rubocop Replaced ruby-lsp

This was not always the case. OpenCode originally used the ruby-lsp gem. There is a [pull request (#4543)](https://github.com/anomalyco/opencode/pull/4543) that explains exactly why it was replaced.

There were two problems with ruby-lsp. The first was a flag mismatch: ruby-lsp was being invoked with `--stdio`, a flag it does not actually recognize.

The second problem was more fundamental: **startup time**. OpenCode has a 3-second timeout for LSP servers to initialize. The ruby-lsp gem was taking around 2.65 seconds to start. That is technically within the limit, but in practice it was frequently timing out before delivering any diagnostics.

RuboCop's LSP mode initializes in about 0.58 seconds. That is 78% faster, and reliably within the timeout. According with the PR.

## A Sensible Match for an AI Coding Tool

The contributor who made the switch added a point I find worth thinking about.

> "rubocop doesn't include unnecessary IDE features: No autocomplete (LLM handles this), No go-to-definition (LLM provides context)"

In a traditional editor/IDE, autocomplete and go-to-definition are essential. In an AI coding tool, the LLM already handles both. What you actually want from a language server in this context probably is linting, warnings, and syntax error detection.

## The Label Mismatch

One thing worth knowing if you look at the OpenCode UI: the *ruby-lsp* label you see on the right side refers to the internal server ID, not the gem name. The ID was kept as `"ruby-lsp"` after the switch to avoid breaking existing configurations. So if you see that label and assume the Shopify ruby-lsp gem is running, it is not. It is rubocop.

It might be that I missed something or that there are edge cases I did not hit. If you have feedback or corrections, I would be glad to hear them.

## Resources

*   [OpenCode documentation - LSP](https://opencode.ai/docs/lsp/)
    
*   [OpenCode GitHub repository](https://github.com/anomalyco/opencode)
    
*   [PR #4543 - fix: replace ruby-lsp with rubocop for better LSP performance](https://github.com/anomalyco/opencode/pull/4543)
    
*   [RuboCop LSP support](https://docs.rubocop.org/rubocop/usage/lsp.html)
    
*   [ruby-lsp by Shopify](https://shopify.github.io/ruby-lsp/)
