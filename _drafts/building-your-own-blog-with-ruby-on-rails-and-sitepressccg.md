---
layout: post
title: Building your own blog with Ruby on Rails and Sitepress.ccg
date: '2024-07-10 11:09:47 +0000'
published: false
hashnode_draft_id: 65c8d44ca8be5e8788f45fba
---

This is a guide for creating a blog using [Ruby on Rails](https://rubyonrails.org) and [Sitepress.cc](https://sitepress.cc).

I chose this because I am working on a project about email courses, and I wanted to have both the blog and the web app in the same repository.

This will be a step by step guide to create a blog, including adding a sitemap and configure a way to serve open graph images.

The current guide is tested on the following versions of Rails and Sitepress:

```ruby
ruby "3.3.0"
gem "rails", "~> 7.1.3"
```

## Creating a new Rails project

Skip this section if you already have a Rails application and just want to add a blog to it.

Here is the command that I used to create my new project:

`rails new rails-and-sitepress-blog css=tailwind -a propshaft`

I choose propshaft because it will probably be the default in Rails 8 and I choose Tailwind because I want the blog to look a bit nice and it is easier to get some nice templates on Tailwind.

I wrote [a more detailed article](https://learn.shortruby.com/blog/tech-stack) about the tech stack that I use to build my side projects.

## Add sitepress

To add sitepress just [follow the instructions](https://sitepress.cc/getting-started/rails) on the main sitepress website:

```bash
bundle add sitepress-rails
bin/rails generate sitepress:install
```

This will create the folder `app/content` with some files inside and add some routes to `config/routes.rb` while updating `config/tailwind.config.js` to include `app/content` when deciding which classes to include when compiling.

If you run now `bin/dev` you should see the following page that shows that Sitepress is running inside your Rails app:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1707798988352/49e6cf48-1c2d-4051-9483-8c1595cd8821.png)

## Add a blog structure

Sitepress is loading all content from `app/content/pages` and I would like to have my blog on `/blog/<article-slug`. To make this happen I will need to create a folder under `app/content/pages` called `blog`

```bash
mkdir app/content/pages/blog
```

And let's create a first blog post there to have something to work on:

```bash
touch app/content/pages/blog/hello-world.html.md
```

Notice the extension here that is: `.html.md`

Let's add something inside:

```markdown
---
title: Hello world - my first blog post 
---

Hello,

This is my first blog post.

## Quotes that inspire me to write content

Here are two quotes that inspires me to write content:

A quote from [why the lucky stiff](https://en.wikipedia.org/wiki/Why_the_lucky_stiff): 

> When you don't create things, you become defined by your tastes rather than ability.
> your tastes only narrow & exclude people. 
> so create

A quote from [Tim Minchin](https://en.wikipedia.org/wiki/Tim_Minchin):

> We have a tendency to define ourselves in opposition to stuff; as a comedian, I make a living out of it. 
> But try to also express your passion for things you love. 
> Be demonstrative and generous in your praise of those you admire. 
> Send thank-you cards and give standing ovations. 
> Be pro-stuff, not just anti-stuff.

I hope you find these quotes as inspiring as I do.
```

I tried to add there a quote and a link and some headings to see how they will be displayed.

If you try to direct your browser to [`http://localhost:3000/blog/hello-world`](http://localhost:3000/blog/hello-world) you will notice it does not work.

That is because Rails does not know how to handle this extension `.html.md` so we need to configure it.

## Make Rails and Sitepress render `.html.md` extension

To make this work, follow [the guide from Sitepress about Markdown](https://sitepress.cc/basics/markdown)

```bash
bundle add markdown-rails
bin/rails g markdown_rails:install
```

After adding this and restarting the server (stop `bin/dev` and run it again `bin/dev`) you will see something like this when you try to open [`http://localhost:3000/blog/hello-world`](http://localhost:3000/blog/hello-world)

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1707815053206/e6c91c96-e938-40fc-92ac-adadc6872edd.png)

That is because there is the following code in the `application.html.erb`:

```erb
  <body>
    <main class="container mx-auto mt-28 px-5 flex">
      <%= yield %>
    </main>
  </body>erb
```

That `flex`

## Homepage layout

I like to have things look good when I work on a project, so let's do a small change to the `app/views/layouts/application.html.erb`:

```diff
-    <title><%= content_for(:title) || "BlogStarterKitWithRailsAndSitepress" %></title>
+    <title><%= content_for(:title) || "My own blog" %></title>
```

```diff
   <body>
-    <main class="container mx-auto mt-28 px-5 flex">
-      <%= yield %>
+    <main>
+      <%= render partial: "layouts/header" %>
+      <div class="container mx-auto mt-10">
+        <div class="px-5 mx-auto lg:px-0 max-w-7xl">
+          <%= yield %>
+        </div>
+      </div>
     </main>
   </body>
```

Then add a new file called `layouts/_header.html.erb` with the following content:

```erb
<div class="container relative mx-auto">
  <header data-controller="menu" class="max-w-4xl mx-auto mt-8 md:mt-10">
    <nav class="flex flex-col px-5 lg:px-0 md:flex-row">
      <div class="flex items-center justify-between w-full md:px-0">
        <%= link_to root_path, class: "w-14 lg:w-18" do %>
          <%= image_tag("shortruby-logo.webp", class: "object-contain", alt: "Short Ruby Logo", width: "144px", height: "144px", loading: "lazy") %>
        <% end %>
        <div class="md:hidden">
          <button id="menuButton" class="p-4 rounded-md ring-1 ring-gray-100">
            <span class="block w-5 h-0.5 bg-black mb-1"></span>
            <span class="block w-5 h-0.5 bg-black mb-1"></span>
            <span class="block w-5 h-0.5 bg-black"></span>
          </button>
        </div>
      </div>
      <div id="menuItems" class="flex-col hidden mt-5 space-x-0 space-y-1 border border-gray-200 rounded-md md:mt-0 md:min-w-fit md:items-center md:flex md:flex-row md:space-y-0 md:space-x-4 md:px-0 md:rounded-none md:border-none" data-menu-target="items">
        <%= link_to page_path("blog"), class: "inline-block no-underline font-bold text-base uppercase x-2.5 py-1 px-2 leading-6 align-baseline antialiased hover:bg-blue-200 hover:rounded-lg0" do %>
          Blog
        <% end %>
        <%= link_to page_path("about"), class: "inline-block no-underline font-bold text-base uppercase mt-5 md:mt-0 x-2.5 py-1 px-2 leading-6 align-baseline antialiased hover:bg-blue-200 hover:rounded-lg0" do %>
          About
        <% end %>
      </div>
    </nav>
  </header>
</div>
```

This is a simple header with a logo on the left and two links on the right. It is mobile (the menu will be under a burger menu) but the burger menu does not open.

### Making the mobile menu open

Making that menu open will be
