---
layout: post
title: My Tech Stack for Side Projects in 2026
date: '2026-02-11 08:54:19 +0000'
published: false
hashnode_draft_id: 698c3de0ed87e15e2649f399
---

Over the last few years, working on side projects, I've learned that the biggest enemy of shipping is complexity. Not technical complexity in the product itself, but operational complexity in the tools, frameworks, and infrastructure I choose.

In 2026, I'm doubling down on a simple principle: choose tools that get out of the way and let me focus on building the actual product. Every technology in my stack needs to justify its existence by either making me more productive or reducing the operational overhead of running the application.

Here's the tech stack I'm using for all my side projects this year and the reasoning behind each choice.

## Ruby: Still the most productive language for me

I'm sticking with Ruby as my primary programming language. After years of working with different languages, Ruby remains the one where I can express ideas most clearly and move fastest from concept to working code.

The expressiveness of Ruby matters more than raw performance for side projects. When I come back to a project after weeks or months, I can read the code and understand what it does without spending hours reconstructing my mental model. The language reads almost like pseudocode, which means less cognitive load and faster iteration.

Ruby lets me think about the problem I'm solving, not about managing types, fighting with the compiler, or navigating verbose syntax. For side projects where time is limited and context switching is frequent, this matters tremendously.

## Ruby on Rails: Zero build configuration

Rails has always been my go-to web framework, but Rails 8 changed the game for side projects with its embrace of importmaps as the default approach for JavaScript.

No build step. No node\_modules folder. No webpack configuration. No watching processes. No build pipeline that breaks when you update dependencies.

I write code, refresh the browser, and see the changes. That's it.

This might sound like a small thing, but the cognitive overhead of maintaining a build system adds up. Every time I need to add a JavaScript library, I'm not thinking about bundlers, transpilers, or configuration files. I add an import, pin the package, and keep working.

For deployment, this simplicity is even more valuable. No need to compile assets, no separate build step in the CI/CD pipeline. The Rails app is just Ruby code and static assets. Deploy and run.

## Avo: Production-ready admin panels in minutes

Every application needs an admin interface. Users need support, data needs corrections, and someone needs to monitor what's happening in the system.

Building admin interfaces from scratch takes days or weeks. CRUD screens, form validation, permissions, search, filtering, bulk actions. It's necessary work, but it's not the unique value proposition of the product.

Avo solves this by generating beautiful, functional admin panels automatically from Rails models. I configure what fields to show, define some basic permissions, and I have a production-ready admin interface.

This lets me focus development time on the parts of the product that make it unique. The admin panel is table stakes, Avo takes care of it so I can work on the features that matter to users.

## Tailwind CSS: Utility-first styling

I'm using Tailwind for all styling. The utility-first approach works perfectly with Rails views because I can style components directly in the template without context switching between files.

No more jumping between HTML, CSS, and JavaScript files to change how a button looks. The styles are right there in the view, which makes iteration fast and debugging straightforward.

The consistency Tailwind provides across projects is another benefit. When I switch between side projects, the utility classes are familiar. I'm not remembering custom class names or hunting through stylesheets to figure out how something was styled.

## Hotwire: Modern UI without a separate frontend

Hotwire, which combines Turbo and Stimulus, gives me the reactive, modern UI experience users expect without building a separate frontend application.

The architecture is simple: server-rendered HTML with just enough JavaScript to make interactions feel smooth and responsive. Turbo handles the navigation and updates, Stimulus adds behavior where needed. No API layer, no state management library, no complex frontend build system.

This approach is fast to develop and easy to maintain. The entire application lives in one codebase. When I need to change a feature, I'm not coordinating between frontend and backend repos, updating API contracts, or managing version compatibility.

For side projects where I'm often the only developer, this matters. I can ship features quickly and the codebase stays manageable.

## SQLite: The database that's just a file

For side projects, SQLite is the perfect database. It's a single file. Backup is copying that file. Restore is copying it back. No separate database server to install, configure, secure, monitor, or update.

SQLite is fast enough for most applications. Unless you're building something with extreme concurrency requirements or massive write loads, SQLite will handle it. And the honest truth is that most side projects never reach the scale where SQLite becomes a limitation.

I can always migrate to PostgreSQL later if a project needs it, but in practice, I rarely do. The simplicity of SQLite is worth more than the theoretical benefits of a client-server database for projects that are just starting out.

## Minitest with VCR and Webmock: Reliable, fast tests

I use Minitest for testing because it's simple, fast, and built into Rails. No additional framework to learn, no complex setup, no magic.

For tests that interact with external services, I use VCR to record HTTP interactions. The first time a test runs, it makes the real request and records it. Every subsequent run uses the recorded response. This makes tests fast, deterministic, and runnable without network access.

Webmock ensures that no unexpected external calls happen during tests. If I forget to stub an HTTP request or set up a VCR cassette, the test fails loudly instead of making a real request and potentially affecting external systems.

This combination keeps the test suite reliable without making it complicated. Tests run fast, they don't flake due to network issues, and I can trust that they're testing what I think they're testing.

## Kamal: Deploy anywhere without platform lock-in

Kamal is my deployment tool of choice. It packages Rails apps as Docker containers and deploys them to any server with SSH access.

No platform lock-in. No proprietary configuration. No complex orchestration system to learn. I can deploy to a $5 VPS just as easily as to a cloud provider. The deployment process is the same regardless of where the server lives.

Zero-downtime deployments work out of the box. Kamal handles the rolling restart, health checks, and traffic switching. I get the benefits of professional deployment practices without the complexity of Kubernetes or other orchestration platforms.

For side projects, this flexibility matters. I can start cheap and move to different hosting as needs change without rewriting deployment scripts or learning new platforms.

## Cloudflare R2: S3-compatible storage without egress fees

When I need to store user uploads, images, or any files, I use Cloudflare R2. It's S3-compatible, which means the API is familiar and well-documented. Most libraries that work with S3 work with R2 without modification.

The key advantage is no egress fees. With traditional cloud storage, you pay to retrieve your data. For applications that serve images or files to users, these egress costs can add up quickly. R2 eliminates this concern with straightforward pricing.

## SolidCache: Database-backed caching

SolidCache provides Rails caching using the database instead of Redis. For side projects, this eliminates one service to deploy, configure, and monitor.

SQLite works as the cache store. It's fast enough for typical caching needs and keeps the infrastructure simple. One database for application data and caching. One backup to manage. One service to monitor.

The performance is good enough for side projects. If I need the extreme performance of Redis later, I can switch, but starting with SolidCache removes complexity from day one.

## SolidQueue: Database-backed background jobs

SolidQueue is the background job system I'm using. Like SolidCache, it uses the database instead of Redis.

All jobs live in the database. They're easy to inspect, query, and debug using standard SQL. No need to install Redis, configure Sidekiq, or manage a separate job queue system.

For side projects that don't need massive job throughput, SolidQueue is perfect. It handles the common cases, sending emails, processing uploads, running scheduled tasks, without adding operational complexity.

## The common theme: Simplicity and reduced overhead

Every choice is focused on reducing complexity or operational overhead.

No build step for JavaScript. No separate database server for development. No Redis for caching or background jobs. No complex deployment system.

When I work on side projects, I have limited time. I'm not building infrastructure, I'm building products. Every hour spent configuring tools, debugging deployment pipelines, or managing servers is an hour not spent on features that matter to users.

This stack lets me ship fast. I can go from idea to deployed application in hours or days, not weeks or months. And once it's deployed, it stays deployed without constant maintenance.

For anyone building side projects or starting new products, I recommend asking this question about every tool you add: Does this make me more productive, or does it add complexity I'll need to manage later?

In 2026, I'm choosing simplicity. The products I ship will prove whether this approach works.
