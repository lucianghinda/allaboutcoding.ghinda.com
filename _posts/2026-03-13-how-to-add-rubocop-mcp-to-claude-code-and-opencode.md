---
layout: post
title: How to Add Rubocop MCP to Claude Code and OpenCode
date: '2026-03-13 05:36:42 +0000'
slug: how-to-add-rubocop-mcp-to-claude-code-and-opencode
tags:
- ruby
- rails
- ai
- llm
- mcp
description: Add RuboCop MCP to Claude Code and OpenCode—enable AI editors to call
  RuboCop via the Model Context Protocol for structured inspections and
image: "/assets/images/posts/how-to-add-rubocop-mcp-to-claude-code-and-opencode/8f73ad89-71a6-4baf-bb19-e568192efc2a.png"
last_modified_at: '2026-03-13 05:36:42 +0000'
---

I have been writing recently about Ruby tooling in AI coding editors. I covered [how to enable Ruby LSP in Claude Code](https://allaboutcoding.ghinda.com/configure-claude-code-with-ruby-lsp) and [how OpenCode automatically installs rubocop as a language server](https://allaboutcoding.ghinda.com/opencode-uses-rubocop-as-the-ruby-language-server). Today I want to share something that takes this a step further: RuboCop now ships with its own MCP server.

This means you can give Claude Code or OpenCode direct access to RuboCop as a structured tool, not just as a background linter.

## What Is RuboCop MCP

[MCP](https://modelcontextprotocol.io) stands for Model Context Protocol. It is an open standard for connecting AI applications to external systems. When RuboCop runs as an MCP server, the LLM can call it directly as a tool instead of running it as a command-line process and parsing its output.

RuboCop 1.85.0 (released 2026-02-26) added experimental MCP support via [PR #14911](https://github.com/rubocop/rubocop/pull/14911). The motivation from the contributor who built it:

> "everyone is using tools like Claude Code, Codex and Cursor"

The MCP server exposes two tools:

*   `rubocop_inspection` - inspect Ruby code for offenses. Accepts a `path` to check files on disk or `source_code` for inline code. Returns detected offenses as JSON.
    
*   `rubocop_autocorrection` - autocorrect offenses. Same inputs as inspection, plus a `safety` boolean (defaults to `true`). When `true`, only safe corrections are applied.
    

The server runs as a long-lived process over stdio, which is the same principle as RuboCop's Server Mode and LSP mode. The practical benefit for an LLM: instead of parsing human-readable CLI output, it gets structured JSON with location information it can act on reliably.

You need at least RuboCop 1.85.0 to use this. Check your version with `bundle exec rubocop --version`.

## How to Add Rubocop MCP for Claude Code

Here is how to install Rubocop MCP for Claude Code:

1.  Go to the project where you want to have the MCP enabled
    
2.  Execute the following from command line:
    

```bash
claude mcp add rubocop -- bundle exec rubocop --mcp
```

You can then check the configuration at `~/.claude.json` (this is not `~/.claude/settings.json`) where you will see a line like this:

```json
{
  "<absolute path to your project>": {
    "mcpServers": {
      "rubocop": {
        "type": "stdio",
        "command": "bundle",
        "args": [
          "exec",
          "rubocop",
          "--mcp"
        ],
        "env": {}
      }
    }
  }
}
```

Check that Rubocop MCP works by asking something like this to Claude:

```plaintext
Tell me Rubocop offenses for test/models/user_test.rb
```

You should see something like:

![](/assets/images/posts/how-to-add-rubocop-mcp-to-claude-code-and-opencode/768e7488-3c44-48d0-ab11-d9ebd5823957.png)

## How to Add Rubocop MCP for OpenCode

Here is how to configure Rubocop MCP for OpenCode:

1.  Go to the project where you want to have the MCP enabled
    
2.  Create a file if you don't already have one called `opencode.json`
    
3.  Add the following to that file:
    

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "rubocop": {
      "type": "local",
      "command": ["bundle", "exec", "rubocop", "--mcp"],
      "enabled": true
    }
  }
}
```

Check that Rubocop MCP works by asking something like this to OpenCode:

```plaintext
Tell me Rubocop offenses for test/models/user_test.rb
```

You should see something like:

![](/assets/images/posts/how-to-add-rubocop-mcp-to-claude-code-and-opencode/2ec7ac28-043c-46c7-b79a-0172240050aa.png)

It might be that I got some details wrong or that there are edge cases I did not hit. If you have feedback or corrections, I would be glad to hear them.

## Resources

*   [RuboCop MCP documentation](https://docs.rubocop.org/rubocop/usage/mcp.html)
    
*   [PR #14911 - Support built-in MCP server](https://github.com/rubocop/rubocop/pull/14911)
    
*   [RuboCop 1.85.0 changelog](https://github.com/rubocop/rubocop/blob/master/CHANGELOG.md#1850-2026-02-26)
    
*   [Model Context Protocol](https://modelcontextprotocol.io)
    
*   [MCP clients list](https://modelcontextprotocol.io/clients)
    
*   [Claude Code MCP documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)
    
*   [OpenCode documentation](https://opencode.ai/docs)
