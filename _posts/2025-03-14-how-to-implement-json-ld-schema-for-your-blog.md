---
layout: post
title: How to implement JSON-LD Schema for your blog
date: '2025-03-14 09:28:56 +0000'
slug: how-to-implement-json-ld-schema-for-your-blog
subtitle: Simple steps to incorporate JSON-LD Schema in your blog
tags:
- blogging
- seo-for-developers
- marketing
- programming-blogs
description: Learn to implement JSON-LD schema on your blog for better SEO, richer
  search results, and improved content understanding by search engines
image: "/assets/images/posts/how-to-implement-json-ld-schema-for-your-blog/fe0c7401-235b-4cf3-b95d-8630f5fad31a.png"
last_modified_at: '2025-04-14 07:45:22 +0000'
---

I will concentrate on how to implement JSON-LD schema for your blog; however, you can apply the examples here to enhance your product or service website.

## **What is JSON-LD?**

JSON-LD stands for JavaScript Object Notation for Linked Data. One use is adding it to web pages, allowing search engines or crawlers to understand the content structure and context better.

It is usually added in the `<head>` html element like this:

```xml
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "url": "http://example.com/"
}
</script>
```

## **Why use JSON-LD Schema in your blog**

* Your content may show up as rich snippets in search results.
    
* Helps search engines to understand the data related to your blog post as you intend and with the required context.
    
* It may help AI to get structured data about the context of your blog post.
    
* Around 30% (source: [searchenginejournal.com](https://searchenginejournal.com/)) of websites are using JSON-JD schema and adding it will improve your SEO results.
    
* When adding `sameAs` attribute for your `author` it might improve your presence online
    

But there are better blog posts that describes why is good to add JSON-LD schema:

* [https://www.semrush.com/blog/schema-markup](https://www.semrush.com/blog/schema-markup)
    
* [https://www.schemaapp.com/schema-markup/benefits-of-schema-markup/](https://www.schemaapp.com/schema-markup/benefits-of-schema-markup/)
    

Here is a screenshot from [https://www.semrush.com/blog/schema-markup](https://www.semrush.com/blog/schema-markup):

[![Screenshot about why JSON-LD schema is important](/assets/images/posts/how-to-implement-json-ld-schema-for-your-blog/f105849b-73f7-4484-b15a-6180e1a32127.png)](https://www.semrush.com/blog/schema-markup)

Google also [recommends using JSON-LD schema](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data#supported-formats):

[![https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data#supported-formats](/assets/images/posts/how-to-implement-json-ld-schema-for-your-blog/1ca5402e-7717-42a4-810f-deb6aa6a2a81.png)](https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data#supported-formats)

## **Adding a JSON-LD schema for every page**

We should start by adding a schema for every page on your blog. [https://schema.org/WebSite](https://schema.org/WebSite) is a schema specification that you should add on every page of your blog (remember this should be inside `<script type="application/ld+json">` but to make the code highlight nicer I will only show the JSON part)

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Lucian Ghinda - Notes",
  "url": "https://allaboutcoding.ghinda.com",
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
  }
}
```

### **Add \`url\` to the author**

Including an `url` in the author section helps identify the author's page on your website and aids search engines in recognizing the author's presence on your site, which could enhance the visibility of their content:

```diff
{
  // the other JSON-LD keys
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
+    "url": "https://allaboutcoding.ghinda.com/authors/lucian-ghinda"
  }
}
```

### **Add \`sameAs\` if you want to connect your website with other places**

Utilize sameAs to show that two entities are fundamentally identical. Within the context of an author section, it links the author's profile on your website to their profiles on other platforms, such as social media or other locations where you maintain a page:

```diff
{
  // the other JSON-LD keys
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
    "url": "https://allaboutcoding.ghinda.com/authors/lucian-ghinda",
+    "sameAs": [
+      "https://bsky.app/profile/lucianghinda.com",
+      "https://www.linkedin.com/in/lucianghinda"
+    ]
  }
}
```

### A recommended example of the schema for every page on your blog:

```json
{
  "@context": "https://schema.org",
  "@type": "WebSite",
  "name": "Lucian Ghinda - Notes",
  "url": "https://allaboutcoding.ghinda.com",
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
    "sameAs": [
       "https://bsky.app/profile/lucianghinda.com",
        "https://www.linkedin.com/in/lucianghinda"
    ]
  }
}
```

## **JSON-LD Schema for inside the blog post / article**

You can add multiple JSON-LD script tags in your website. You should keep the main one that is about WebSite and add inside the blog posts one about **\`BlogPosting\` -** [**https://schema.org/BlogPosting**](https://schema.org/BlogPosting)

```xml
<script type="application/ld+json">
{ 
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://allaboutcoding.ghinda.com/post-url"
  },
  "headline": "Why add JSON+LD to your blogpost",
  "datePublished": "2025-03-11T13:22:00+02:00",
  "dateModified": "2025-03-11T14:30:00+02:00",
}
</script>
```

### **A bit about datePublished and dateModified**

Values for these two fields can be Date or DateTime. Choose one that fits you bets or that you can generate easily.

In case you usually don't update your articles, then only add \`datePublished\`

```diff

{ 
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://allaboutcoding.ghinda.com/post-url"
  },
  "headline": "Why add JSON+LD to your blogpost",
+  "datePublished": "2025-03-11T13:22:00+02:00",
+  "dateModified": "2025-03-11T14:30:00+02:00"
}
```

### **Then add author**

You can use the same snippet as you used in the WebSite schema:

```json
{
  // the other JSON-LD keys
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
    "url": "https://allaboutcoding.ghinda.com/authors/lucian-ghinda",
    "sameAs": [
      "https://bsky.app/profile/lucianghinda.com",
      "https://www.linkedin.com/in/lucianghinda"
    ]
  }
}
```

If you have multiple authors, then make the "author" key an array:

```json
{
  // the other JSON-LD keys
  "author": [
    { 
      "@type": "Person", 
      "name": "Lucian Ghinda",
      // other attributes
    },  
    { 
      "@type": "Organization", 
      "name": "Short Ruby",
      // other attributes
    }  
  ]
}
```

### **JSON-LD Schema for a blog post - add publisher**

The `publisher` key identifies the publisher of the creative work. If you have your own blog, you can list yourself as the publisher. However, if you're writing for an organization, make sure to include the organization's name instead:

```json
{
  // the other JSON-LD keys
  "publisher": {
    "@type": "Organization",
    "name": "Short Ruby",
    "logo": {
      "@type": "ImageObject",
      "url": "https://shortruby.com/assets/logo-d8627cb3e82564f3328709589c3c1ce34b81d0afed316a0b58d27ab93bcaa9d4.png"
    }
  },
}
```

### The final JSON-LD for the blog post

Here is how the JSON-LD schema for a blog post might look like:

```json
{ 
  "@context": "https://schema.org",
  "@type": "BlogPosting",
  "mainEntityOfPage": {
    "@type": "WebPage",
    "@id": "https://allaboutcoding.ghinda.com/post-url"
  },
  "headline": "Why add JSON+LD to your blogpost",
  "datePublished": "2025-03-11T13:22:00+02:00",
  "dateModified": "2025-03-11T14:30:00+02:00",
  "author": {
    "@type": "Person",
    "name": "Lucian Ghinda",
    "url": "https://allaboutcoding.ghinda.com/authors/lucian-ghinda",
    "sameAs": [
      "https://bsky.app/profile/lucianghinda.com",
      "https://www.linkedin.com/in/lucianghinda"
    ]
  },
  "publisher": {
    "@type": "Organization",
    "name": "Short Ruby",
    "logo": {
      "@type": "ImageObject",
      "url": "https://www.exampleblog.com/logo.png"
    }
  }
}
```

## Tools

There are many more variations of how to combine various items and this way communicate to a crawler or search engine what you want them to know about your blog.

Here are some tools you can use to validate your JSON-LD schema and check how Google parses rich snippets:

[https://search.google.com/test/rich-results](https://search.google.com/test/rich-results)

[https://validator.schema.org](https://validator.schema.org)

## Further reading

Avo published a very nice article about how to add the schema markup on a Rails app → [**Adding Structured Data to a Rails application**](https://avohq.io/blog/structured-data-rails)

---

If you like this article:

👐 Interested in learning how to improve your developer testing skills? Join my live online workshop about [**goodenoughtesting.com**](http://goodenoughtesting.com/) **\- to learn test design techniques for writing effective tests**

👉 Join my [**Short Ruby Newsletter**](https://newsletter.shortruby.com/) for weekly Ruby updates from the community and visit [**rubyandrails.info**](http://rubyandrails.info/)**, a directory with learning content about Ruby.**

🤝 Let's connect on [**Bluesky**](https://bsky.app/profile/lucianghinda.com), [**Ruby.social**](http://ruby.social/)**,** [**Linkedin**](https://linkedin.com/in/lucianghinda)**,** [**Twitter**](https://x.com/lucianghinda) **where I post mostly about Ruby and Ruby on Rails.**

🎥 Follow me on [**my YouTube channel**](https://www.youtube.com/@shortruby) for short videos about Ruby/Rails
