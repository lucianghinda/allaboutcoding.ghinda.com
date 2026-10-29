---
layout: post
title: "Superpowers Ruby is becoming RubyPowers"
date: '2026-10-29 09:12:49 +0000'
slug: superpowers-ruby-is-becoming-rubypowers
tags:
- ruby
- rails
- open-source
- developer-tools
- ai-agents
description: "Superpowers Ruby becomes RubyPowers in version 8.0.0. Existing users need to migrate their plugin installation and update saved skill references; existing plans and specs remain supported."
image: "/assets/images/posts/superpowers-ruby-is-becoming-rubypowers/og.png"
last_modified_at: '2026-10-29 09:12:49 +0000'
---

The creator of Superpowers gently asked those of us maintaining forks to give them their own names. 

I respect their work, and I respect their choice about how the Superpowers name is used.

So, with version 8.0.0, **Superpowers Ruby is becoming [RubyPowers](https://github.com/lucianghinda/rubypowers)**.

This gives our Ruby and Rails focused project its own identity while keeping its origins clear. 

RubyPowers builds on [obra/superpowers](https://github.com/obra/superpowers), and credit for that foundation stays with Jesse Vincent and the upstream contributors.

**If you already use the plugin, you need to migrate your installation:**

1. Uninstall the old `superpowers-ruby` plugin.
2. Install the new `rubypowers` plugin. Follow the [README migration guide](https://github.com/lucianghinda/rubypowers#migrating-from-superpowers-ruby) for the commands for your platform.
3. Update any saved instructions that invoke skills by their full names. For example, `superpowers-ruby:brainstorming` becomes `rubypowers:brainstorming`.

Your existing plans and specs under `docs/superpowers/` remain supported. You do not need to move them. New projects use `docs/rubypowers/`.

The repository has already moved to [lucianghinda/rubypowers](https://github.com/lucianghinda/rubypowers).


You can use a prompt like this for checking your skills about references to superpowers-ruby: 

```md
Search this project and my agent configuration for references to superpowers-ruby. Update skill names and plugin references to use rubypowers, following the migration guide:

https://github.com/lucianghinda/rubypowers#migrating-from-superpowers-ruby

Keep existing plans and specs under docs/superpowers/; they remain supported. Show me what you changed.
```

Thank you for using the project and making this small move with me.
