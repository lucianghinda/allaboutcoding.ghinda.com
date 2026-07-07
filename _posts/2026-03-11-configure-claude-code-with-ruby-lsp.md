---
layout: post
title: How to Enable Ruby LSP in Claude Code and OpenCode
date: '2026-03-11 10:53:20 +0000'
slug: configure-claude-code-with-ruby-lsp
tags:
- ruby
- lsp
- claudeai
- llm
description: Enable the Ruby LSP plugin in Claude Code/OpenCode to get hover info,
  go-to-definition, and project-wide symbol search. Quick
image: "/assets/images/posts/configure-claude-code-with-ruby-lsp/2d6d331a-a8b1-409e-a999-f4e76069e913.png"
last_modified_at: '2026-03-11 11:25:51 +0000'
---

RubyLSP plugin was officially added to Claude Code. See [this commit](https://github.com/anthropics/claude-plugins-official/commit/80a2049c5de75236cf8ec5c6521a0c60c95ae92f)

This way you can use [Ruby LSP](https://shopify.github.io/ruby-lsp/) as a real tool inside Claude Code, and the setup takes just a few steps.

## What is Ruby LSP and Why Does It Matter in Claude Code

[Ruby LSP](https://shopify.github.io/ruby-lsp/) is a language server for Ruby built by Shopify. It provides go-to-definition, document symbols, hover information, and diagnostics. In your editor - VS Code, Neovim, Zed - you probably already use it and do not even notice because it just works.

In Claude Code, having LSP support means Claude can ask for things like:

*   List classes/methods/constants in a file
    
*   Jump to where a symbol is defined
    
*   Find all usages of a symbol
    
*   Get type info/docs for a symbol
    
*   Search symbols across the whole project
    
*   Find implementations of an interface
    
*   Trace call hierarchy
    

Think about the difference: reading a Ruby file and guessing the structure vs. asking "what are all the methods in this class?" and getting back exact symbol names, kinds, and line numbers. The second is more reliable, especially in larger codebases.

## Step 1: Install the ruby-lsp Gem

Make sure the `ruby-lsp` gem is installed in your Ruby environment for your specific Ruby version:

```shell
gem install ruby-lsp
```

Verify it is available:

```shell
which ruby-lsp
# => /Users/yourname/.gem/ruby/3.3.0/bin/ruby-lsp
```

If you use a version manager like `rbenv` or `asdf`, install it for the Ruby version you use in your projects.

## Step 2: Install the Plugin

The Ruby LSP team published their plugin in the official Claude plugin directory. This means you no longer need to add a third-party marketplace first - one command is enough.

Run this in your terminal or directly inside Claude Code with the `/plugin` prefix:

```shell
# In terminal
claude plugin install ruby-lsp@claude-plugins-official
```

Or inside Claude Code:

```shell
# inside Claude Code session
/plugin install ruby-lsp@claude-plugins-official
```

The `@`claude-plugins-official suffix tells Claude Code to look up the plugin in the official directory. No need to add an extra marketplace.

## Step 3: Enable the LSP Tool via Environment Variable

Claude Code requires an explicit opt-in to expose LSP tools. Add this to `~/.claude/settings.json` under the `env` key:

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  }
}
```

## The Complete settings.json

Here is what the relevant parts of `~/.claude/settings.json` look like after all steps:

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1"
  },
  "enabledPlugins": {
    "ruby-lsp@claude-plugins-official": true
  }
}
```

## Step 4: Restart and Verify

To load the LSP plugin you need to restart Claude Code completely, not just run `/reload-plugins`.

Then navigate to a Ruby project and test it. Ask Claude:

> list symbols in app/models/user.rb using LSP

Here is what you should see (of course the symbols might vary, here I have a simple User object):

```markdown
⏺ LSP(operation: "documentSymbol", file: "app/models/user.rb")
  ⎿  Found 2 symbols
     Document symbols:
     User (Class) - Line 1
       has_many :sessions (Method) - Line 3

| Symbol | Kind | Line |
|---|---|---|
| User | Class | 1 |
| has_many :sessions | Method | 3 |
```

## Summary

Here are the steps, in order:

1.  Install the gem: `gem install ruby-lsp`
    
2.  Install the plugin: `claude plugin install ruby-lsp@claude-plugins-official`
    
3.  Add `ENABLE_LSP_TOOL: "1"` to `~/.claude/settings.json` under `env`
    
4.  Restart Claude Code
    

## Resources

*   [Ruby LSP](https://shopify.github.io/ruby-lsp/) - the official Ruby language server by Shopify and [Ruby LSP GitHub repository](https://github.com/Shopify/ruby-lsp)
    
*   [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code/overview)
    
*   [Claude Code plugins](https://docs.anthropic.com/en/docs/claude-code/plugins)
    
*   [Claude code official plugins Github repository](https://github.com/anthropics/claude-plugins-official)
