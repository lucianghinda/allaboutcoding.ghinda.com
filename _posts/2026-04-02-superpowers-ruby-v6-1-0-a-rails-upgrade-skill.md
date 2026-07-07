---
layout: post
title: 'superpowers-ruby v6.1.0: a Rails upgrade skill'
date: '2026-04-02 12:27:23 +0000'
slug: superpowers-ruby-v6-1-0-a-rails-upgrade-skill
tags:
- ruby
- ruby-on-rails
- upgrade
- ai
- llm
description: Automate Rails upgrades with superpowers-ruby v6.1.0 — the rails-upgrade
  skill enforces green test suites, resolves defaults, and requires explicit ap
image: "/assets/images/posts/superpowers-ruby-v6-1-0-a-rails-upgrade-skill/555014f0-146d-4240-9cef-edf8c96da592.png"
last_modified_at: '2026-04-02 12:27:23 +0000'
---

One new skill in this release: `rails-upgrade`.

## Why I built this

Seeing the skills for upgrading a Rails app released in the last months with the one from OmbuLabs/FastRuby.io being released last week:

*   [OmbuLabs/FastRuby.io](https://github.com/ombulabs/claude-code_rails-upgrade-skill): detection patterns, gem compatibility data, upgrade methodology
    
*   [maquina-app/rails-upgrade-skill](https://github.com/maquina-app/rails-upgrade-skill) by Mario Alberto Chávez Cárdenas: breaking changes reference tables, deprecation timeline
    

I got thinking that maybe it is time for superpowers-ru[superpowers-ruby](https://github.com/lucianghinda/superpowers-ruby)by to have such a skill.

## The workflow

The skill runs a six-step process, but three of those steps are hard gates: the agent cannot proceed past them unless a condition is met.

The first gate is a green test suite. The agent runs the tests before touching anything. If tests are failing before the upgrade starts, failures after the upgrade are ambiguous. You cannot tell what you broke from what was already broken. I have made that mistake before.

The second gate checks `config.load_defaults`. If there is a `new_framework_defaults_*.rb` file from a previous upgrade with unresolved settings, that needs to be resolved before starting another upgrade. Stacking unresolved defaults makes the transition plan unreliable.

The third gate is explicit approval. Before the agent touches any files, it compiles an upgrade report: configuration changes, code issues by severity, gem updates, and a load\_defaults transition plan. I have to approve that report before anything is modified. Some upgrades are a few dependency bumps. Others involve weeks of work. I want to know which one I am starting before it has already begun.

Between the gates, the skill fetches a live configuration diff from GitHub:

```plaintext
https://api.github.com/repos/railsdiff/rails-new-output/compare/v{FROM}...v{TO}
```

This is the data behind railsdiff.org. Every config file added, modified, or removed between two Rails versions, fetched on each run. I did not want to maintain a static list that would go stale the moment a new version shipped.

For code-level detection, the agent searches the codebase directly with Grep. It looks for things like `Rails.application.secrets`, `params ==` comparisons, `config.cache_classes`, `ActiveRecord::Base.connection` without a block. No script generation, no round-trip. Findings come back with file:line references.

## Reference files

I included seven reference files in the `references/` directory:

*   **breaking-changes.md**: HIGH/MEDIUM/LOW tables for all seven version pairs from 5.2 through 8.1
    
*   **detection-patterns.md**: Grep and Glob patterns organized by version pair
    
*   **gem-compatibility.md**: ~50 popular gems with the minimum required version for each Rails release
    
*   **load-defaults-guide.md**: every `config.load_defaults` setting from 5.2 through 8.1 with risk tiers
    
*   **deprecation-timeline.md**: when features were deprecated, when they were removed, what replaced them
    
*   **dual-boot-guide.md**: complete `next_rails` setup including the `NextRails.next?` pattern and CI config
    
*   **troubleshooting.md**: common upgrade errors and their fixes
    

I originally considered splitting the load\_defaults guide and dual-boot setup into separate companion skills. I decided against it. Having everything in one place means there is nothing extra to install, and the reference material stays in sync with the skill itself.

## The fetch-changelogs script

There is also a small utility at `scripts/fetch-changelogs.sh`. It fetches CHANGELOG entries for a specific Rails version from GitHub and writes them to files, one per component and a consolidated version.

```bash
./scripts/fetch-changelogs.sh 8.1.0
./scripts/fetch-changelogs.sh 8.1.0 ./changelogs
./scripts/fetch-changelogs.sh --list-versions
```

Rails keeps separate CHANGELOGs per component: Action Cable, Active Record, Action Pack, and nine others. The script fetches all twelve and extracts just the section relevant to the requested version. I find it useful to read the raw changelog before running the upgrade workflow.

## Attribution

I want to be clear about where this came from. Two existing skills did the hard work of organizing the reference material I use here:

*   [OmbuLabs/FastRuby.io](https://github.com/ombulabs/claude-code_rails-upgrade-skill): detection patterns, gem compatibility data, upgrade methodology
    
*   [maquina-app/rails-upgrade-skill](https://github.com/maquina-app/rails-upgrade-skill) by Mario Alberto Chávez Cárdenas: breaking changes reference tables, deprecation timeline
    

Both are MIT-licensed and both are excellent. If you are looking for a Rails upgrade skill, I genuinely recommend looking at them first and using them directly. At the moment they are more battle tested than this skill and also those are skills from people with a long track record. Ombulabs/FastRuby are having the biggest experience with Rails upgrades so I think their skill is the best one so far.

Here is what I added/changed in this skill:

1.  **Self-contained, no external dependencies.** OmbuLabs requires three companion skills installed. My version works anywhere Claude Code works.
    
2.  **Live config diffs from railsdiff.org.** Neither source skill fetches configuration changes from the actual railsdiff.org data. The GitHub API call on every run means the diff is always current.
    
3.  **No script generation, no MCP dependencies.** Nothing extra to install or configure.
    
4.  **Three hard gates.** Green test suite, clean `config.load_defaults`, and explicit approval before any execution. Not soft suggestions but actual stops.
    
5.  **A pragmatic version range.** Mario covers 7.0+, OmbuLabs goes back to 2.3. I chose 5.2 through 8.1 because that is the practical range for most apps still being upgraded today.
    
6.  **A linear six-step workflow.** OmbuLabs has eight steps with numbering gaps. I wanted a clear sequence with no ambiguity about what comes next.
    
7.  **An integrated upgrade report.** railsdiff config data, codebase detection findings, and an effort estimate in a single template, before any approval is requested.
    
8.  **Cross-references to the official Rails upgrade guide.** Neither source skill does this explicitly.
    

If my version does not fit your workflow, **their skills are the right starting point for building your own or use them as they are**.

I think this is one of the more interesting things about working with LLMs on developer tooling. You can take reference material that other people have carefully organized, mix it with your own workflow preferences, and get something that fits exactly how you work. The raw material was already there. I just combined it differently.

My additions are small compared to what both teams built. I am grateful to them for releasing it all under MIT.

## No migration needed

Purely additive release. If you are on 6.0.x, reinstall the plugin or update it to pick up the new skill. Or wait until you actually need to upgrade Rails.

If you try it and find something that does not work well, I would love to hear about it.

## Resources

*   [superpowers-ruby v6.1.0](https://github.com/lucianghinda/superpowers-ruby)
    
*   [OmbuLabs/FastRuby.io rails-upgrade-skill](https://github.com/ombulabs/claude-code_rails-upgrade-skill)
    
*   [maquina-app/rails-upgrade-skill](https://github.com/maquina-app/rails-upgrade-skill) by Mario Alberto Chávez Cárdenas
    
*   [railsdiff.org](https://railsdiff.org): the config diff tool the skill uses
