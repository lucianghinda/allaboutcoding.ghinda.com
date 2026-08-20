---
layout: post
title: Setting the status line for all projects in Codex
date: '2026-08-20 10:32:14 +0000'
slug: setting-the-status-line-for-all-projects-in-codex
tags:
- codex
- claude-code
- coding-agents
- developer-tools
- ai
- configuration
description: "Codex builds the status line from an ordered list of built-in item names. The 26 identifiers are in the source and not in the docs, and a name that does not exist still passes codex doctor."
image: "/assets/images/posts/setting-the-status-line-for-all-projects-in-codex/og.png"
last_modified_at: '2026-08-20 10:32:14 +0000'
note: >-
  I wrote this article and used Grammarly to proofread and fix it.  
---

After writing about [setting Claude Code status line with Ruby](https://allaboutcoding.ghinda.com/you-can-use-ruby-to-set-the-status-line-in-claude-code/), I wanted to see if the same thing is possible for Codex and dig a bit more. 

First, all 3 let you set the status line globally, at the user level, or locally per project. 

Second, the way they work is different, and only Claude accepts a command as I described it in [the previous article](https://allaboutcoding.ghinda.com/you-can-use-ruby-to-set-the-status-line-in-claude-code/).

Here is a summary of the findings so far: 

| Tool | Global file | Setting | What it accepts |
| --- | --- | --- | --- |
| Claude Code | `~/.claude/settings.json` | `statusLine` | a command, so any executable |
| Codex | `~/.codex/config.toml` | `[tui] status_line` | an ordered list of built-in item names |
| opencode | `~/.config/opencode/tui.json` | `plugin` | a TUI plugin with a JS or TS entry |

Thus, a Ruby script can be used directly only in Claude Code, while Codex only allows specific items to be displayed there, and opencode will need a JavaScript entry point that can run a Ruby script if you want it to. 

## Codex 

Codex will read the global config from `~/.codex/config.toml` and then load it if it exists in `.codex/config.toml` from the project folder where it runs. 

The settings can be defined as: 

```toml
[tui]
status_line = ["model-with-reasoning", "current-dir", "five-hour-limit", "weekly-limit", "git-branch", "context-used", "context-window-size", "fast-mode"]
status_line_use_colors = true
```

You cannot define a custom script (or maybe I could not find it quickly, but as Codex is open source, you can dig more if you want in their source code), so you have to pick from what Codex allows you to choose and then put those in the order that you want to see them. 

The [config documentation](https://learn.chatgpt.com/docs/config-file/config-reference) says this about the status line: 

> Ordered list of TUI footer status-line item identifiers. `null` turns off the status line.


### List of names you can use in Codex status line 

I could not find in the documentation the exact list of identifiers, so I dug it in the Codex source and found this list of possible status line items at [`StatusLineItem`](https://github.com/openai/codex/blob/rust-v0.146.1/codex-rs/tui/src/bottom_pane/status_line_setup.rs#L50-L135) from version 0.146.1 with 26 items: 

```
approval-mode          branch-changes        codex-version
context-remaining      context-used          context-window-size
current-dir            fast-mode             five-hour-limit
git-branch             model                 model-with-reasoning
permissions            project-name          pull-request-number
raw-output             reasoning             run-state
task-progress          thread-id             thread-title
total-input-tokens     total-output-tokens   used-tokens
weekly-limit           workspace-headline
```

Please consider this a discovery from the source code. Since there is no official documentation for this,  there is no interface contract to keep it as it is

### Codex will not check the strings you add to status_line configuration 

I made a config with a non-existing name `totally-bogus-item`: 

```toml
[tui]
status_line = ["current-dir", "git-branch", "totally-bogus-item"]
```

and then I run the doctor command: 

```bash
CODEX_HOME=/tmp/codexhome codex doctor --summary
```

And the configuration section came back happy:

```
Configuration
  ✓ config       loaded
```

This may be a bug, but I don't know. But you should not rely on `codex doctor` to verify that the names you added there are correct. 

Just check what the status line looks like, and may I suggest adding items incrementally, one by one. 

## Practical ideas from this

I like the Claude Code approach more in this case than Codex because you can do a lot more with status line processing than Codex can by default.

For example, having the session_id there, I already changed my `statusline.rb` file to read the session and tell me the last tool that was executed, how many prompts I have written so far, and the context used in the last turn. 

Codex does not give this option. You mostly get what the team already implemented. Of course, as it is open source, you can always fork and implement what you need and then make a PR back to the upstream. What they offer is more performant than computing things from the session file. 

I would still like to have something like `status_line_command` in Codex that behaves similarly to how Claude Code does.
