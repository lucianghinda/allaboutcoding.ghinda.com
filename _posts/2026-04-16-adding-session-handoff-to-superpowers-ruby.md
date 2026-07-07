---
layout: post
title: Adding Session Handoff to Superpowers Ruby
date: '2026-04-16 03:19:06 +0000'
slug: adding-session-handoff-to-superpowers-ruby
tags:
- ai
- llm
- superpowers
- ruby
- ruby-on-rails
description: Capture the session state before compaction and restores it after. Not
  a summary. A structured handoff document that any session, agent, or person ca
image: "/assets/images/posts/adding-session-handoff-to-superpowers-ruby/df541b7a-3591-4ad9-aba8-0faba094dfb5.png"
last_modified_at: '2026-04-16 03:19:06 +0000'
---

The problem that made me build this feature: I was in the middle of a long implementation session, Claude Code compacted the context, and everything I had been working toward was gone. The branch, the modified files, the git state all of that was recoverable. But the decisions, the failed approaches, the reasoning behind why I chose one design over another - that lived only in the conversation.

I also sometimes switch between Claude Code and Codex and I want to have a way to handoff sessions between them. Somehow, this is even more of a strong case (for me) to have this handoff.

Context compaction is necessary. The alternative is hitting the context window limit and getting a hard stop. But when compaction happens it sometimes discards the parts of your session that are hardest to reconstruct. Or at least I prefer to be in control of what is shared between sessions.

I wanted something that captures the session state before compaction and restores it after. Not a summary. A structured handoff document that any session, agent, or person can pick up and continue from.

## The shape of the problem

When you work in a long coding session with an AI agent, the conversation accumulates state that is not in the code:

*   The goal you are trying to achieve and why
    
*   Design decisions you made and the trade-offs you considered
    
*   Approaches you tried that did not work
    
*   What you plan to do next
    
*   Open questions that still need answers
    

All of this disappears on compaction. The compacted summary might preserve some of it, but in my experience, it loses the nuance. "We decided to use a hybrid hook+skill approach" becomes just "implemented hooks" in a summary.

The code and the git history survive compaction, of course. But if you have ever tried to reconstruct the reasoning behind a half-finished feature just from a diff, you know how much context is missing.

## The design: a hybrid hook+skill approach

I looked at several existing handoff implementations before building mine. The [pi-handoff plugin](https://github.com/layerborn/claude-code-handoff) by Layerborn, the [claude-handoff](https://github.com/davidteren/claude-handoff) by David Teren, [Shawn Wang's gist](https://gist.github.com/swyxio/2e5e0c0f8e02e5cd1e20e5ae0a1db562), and a few more that showed up in [a Hacker News discussion](https://news.ycombinator.com/item?id=43732592).

The pattern I found across all of them: capture state to a markdown file on disk, then read it back when the next session starts.

What they differ on is what triggers the capture and how much of the document the LLM fills in versus what is gathered mechanically.

I chose a hybrid approach:

1.  **Bash hook scripts** handle the parts about git state, modified files, plan file references. These run as Claude Code hooks or OpenCode events on the `PreCompact` and `PostCompact` events.
    
2.  **Skill files** handle the semantic parts: goals, decisions, failed approaches, next steps. These are filled in by the LLM from conversation context when you manually invoke the skill.
    

When compaction triggers automatically, the hook creates a skeleton with sections filled in and `<!-- to be enriched by LLM -->` markers for the rest. After compaction restores the document, the agent fills in the markers from whatever compacted context it has. Not perfect, but much better than nothing.

When you manually invoke the skill before ending a session, the LLM fills in everything from the full conversation.

## What the handoff document looks like

Here is the structure of a handoff document written to `docs/handoffs/`:

```markdown
---
created: 2026-04-14T10:30:00+00:00
branch: lg/handoff
trigger: manual
restored: false
topic: handoff-skill-implementation
---

# Handoff: handoff-skill-implementation

## Goal
Building a session handoff system for superpowers-ruby...

## Current State
- Hook scripts created and tested
- Skills written for create, resume, list
- OpenCode plugin updated with compacting events

## Key Decisions
- Hybrid hook+skill approach - hooks for mechanical capture,
  skills for semantic enrichment
- Topic-based naming instead of timestamps alone -
  easier to scan in a directory listing

## Modified Files
- hooks/handoff-create
- hooks/handoff-restore
- skills/handoff/SKILL.md

## Failed Approaches
- (none in this session)

## Files to Read
- `.claude/plans/recursive-hopping-quokka.md` (Claude Code plan)

## Next Steps
1. Test the full compaction cycle end-to-end
2. Update CHANGELOG.md

## Open Questions
- Should Cursor hooks support PreCompact/PostCompact?
```

The YAML frontmatter tracks metadata: when it was created, which branch, whether it was triggered by compaction or manually, and whether it has been restored yet.

The `restored: false` flag is the key. When a session resumes from this document, the restore script sets it to `true`, adds a `restored_at` timestamp, and moves the file to `docs/handoffs/_archive/`. This way you never accidentally resume from a stale handoff.

## Three commands

The feature ships as three skills:

`/superpowers-ruby:handoff` - Create a handoff document manually. The LLM fills every section from conversation context. Use this before ending a session, switching context, or handing off to someone.

`/superpowers-ruby:handoff-resume` - Resume from the latest unrestored handoff. Reads the document, presents a summary, marks it restored, archives it, and starts working from the Next Steps section.

`/superpowers-ruby:handoff-list` - List all handoffs, active and archived, in a table. Good for when you have multiple handoffs from different branches.

## The hook scripts

The automatic capture lives in `hooks/handoff-create`. It is a bash script that:

1.  Detects the current branch via `git branch --show-current`
    
2.  Collects modified files from `git status --porcelain`
    
3.  Scans for plan files in `.claude/plans/`, `docs/superpowers/specs/`, and `docs/superpowers/plans/`
    
4.  Generates a topic slug from the branch name
    
5.  Writes the handoff document with mechanical sections filled and LLM sections marked for enrichment
    

The restore script, `hooks/handoff-restore`, finds the latest unrestored handoff, reads it, marks it as restored, moves it to the archive, and outputs the content as JSON that the agent can consume.

The hooks are registered in `hooks/hooks.json`:

```json
{
  "PreCompact": [{
    "matcher": "manual|auto",
    "hooks": [{
      "type": "command",
      "command": "hooks/handoff-create --trigger compact",
      "async": false
    }]
  }],
  "PostCompact": [{
    "matcher": "manual|auto",
    "hooks": [{
      "type": "command",
      "command": "hooks/handoff-restore",
      "async": false
    }]
  }]
}
```

The `async: false` is important. The `PreCompact` hook must finish writing the document before compaction discards the context. The `PostCompact` hook must finish restoring before the agent starts responding.

## Cross-platform support

Claude Code uses `PreCompact`/`PostCompact` hook events. OpenCode uses `experimental.session.compacting` and `session.compacted` events in its plugin system. Codex has no compaction hooks at all.

For OpenCode, I added two event handlers to the existing `.opencode/plugins/superpowers.js`:

```javascript
// Capture handoff document before compaction
'experimental.session.compacting': async () => {
  try {
    execSync(`bash "${hookScript}" --trigger compact`, {
      cwd: directory || process.cwd(),
      timeout: 10000
    });
  } catch (_e) {
    // Best-effort - don't block compaction on failure
  }
},

// Restore handoff document after compaction
'session.compacted': async () => {
  try {
    const output = execSync(`bash "${hookScript}"`, { ... });
    const parsed = JSON.parse(output.trim());
    if (parsed.additionalContext) {
      return { additionalContext: parsed.additionalContext };
    }
  } catch (_e) { }
}
```

Both handlers are wrapped in try-catch. Handoff capture and restore are best-effort and if they fail, the session continues. This is important because you do not want a bug in the handoff system to prevent compaction or block a session from starting.

For Codex, you use the skills manually. There are no compaction events to hook into.

## Cross-agent handoff

The handoff document is a plain markdown file. Any agent that can read the filesystem can resume from it. This means:

*   **Claude Code to OpenCode**: Create a handoff in Claude Code, switch to OpenCode, run `/superpowers-ruby:handoff-resume`.
    
*   **Agent to human**: A developer opens `docs/handoffs/` and reads what the agent was working on. The document is plain markdown - it does not require any special tooling to understand.
    
*   **Human to agent**: A developer writes a handoff document following the template, then starts a new agent session. The agent picks it up with `handoff-resume`.
    
*   **Subagent to parent**: A subagent creates a handoff before finishing, so the orchestrating agent can dispatch a new subagent with the full context. I have not tested this yet, but I see it as a future possibility.
    

The handoff document is the contract. It does not depend on any agent's memory, context window, or session state. I think this is a more robust pattern than trying to pass context through tool outputs or environment variables.

Install or update:

```bash
claude plugin uninstall superpowers-ruby@superpowers-ruby
claude plugin install superpowers-ruby@superpowers-ruby
```

If you try the handoff feature and find it captures too little or too much, I would be glad to hear about it.

## Resources

*   [superpowers-ruby on GitHub](https://github.com/lucianghinda/superpowers-ruby) - the plugin this feature was added to
    
*   [PR #10: Session handoff skill](https://github.com/lucianghinda/superpowers-ruby/pull/10) - the pull request with all the changes
    
*   [obra/superpowers upstream](https://github.com/obra/superpowers) - the original project by Jesse Vincent
    
*   [pi-handoff plugin](https://github.com/layerborn/claude-code-handoff) by Layerborn - one of the implementations I studied
    
*   [claude-handoff](https://github.com/davidteren/claude-handoff) by David Teren - another approach to the same problem
    
*   [Shawn Wang's handoff gist](https://gist.github.com/swyxio/2e5e0c0f8e02e5cd1e20e5ae0a1db562) - a minimal take on session continuity
    
*   [HN discussion on agent handoffs](https://news.ycombinator.com/item?id=43732592) - community thread where several approaches were compared
    
*   [Claude Code hooks documentation](https://docs.anthropic.com/en/docs/claude-code/hooks) - official docs for PreCompact/PostCompact events
