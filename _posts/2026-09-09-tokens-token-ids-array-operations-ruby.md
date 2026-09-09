---
layout: post
title: "Tokens, token IDs and array operations in Ruby"
date: '2026-09-09 09:13:10 +0000'
slug: tokens-token-ids-array-operations-ruby
tags:
- ruby
- llm
- ai
- tokenizer
- openai
- rubygems
description: "LLMs work with the numbers behind your text rather than the text itself. Two Rails class definitions one word apart encode to arrays of 5 token IDs that differ in a single position, so subtracting one from the other returns the class name."
image: "/assets/images/posts/tokens-token-ids-array-operations-ruby/og.png"
last_modified_at: '2026-09-09 09:13:10 +0000'
---

When working at the [Good Enough Agents workshop](https://goodenoughagents.com), I wanted a more practical way to talk about tokens and tokenizing. 

The main idea is that LLMs don't work with text; they work with tokens. We know this, but it is important to be specific: LLMs don't work directly with tokens as text chunks, but with numbers associated with those chunks. I'll call them token IDs here. 

[OpenAI](https://openai.com) published its tokenizing algorithm, [Tiktoken](https://github.com/openai/tiktoken), and I found a gem called [tiktoken_ruby](https://rubygems.org/gems/tiktoken_ruby) that wraps Tiktoken. 

## Here is a simple demo from text to numbers and back 

```rb
require 'tiktoken_ruby'
enc = Tiktoken.encoding_for_model('gpt-4o')

token_ids = enc.encode('Ruby is great!')
# => [134047, 382, 2212, 0]

token_ids.map { |id| enc.decode([id]) }
# => ["Ruby", " is", " great", "!"]

enc.decode(token_ids)
# => "Ruby is great!"
```

Let’s try that on code too: 

```rb
author_token_ids  = enc.encode('class Author < ApplicationRecord')
# => [1444, 10764, 464, 12493, 6721]

session_token_ids = enc.encode('class Session < ApplicationRecord')
# => [1444, 17681, 464, 12493, 6721]
```

You can notice that the token ID arrays have the same length and only one element differs. 

## Operations on arrays

Now that you have the text as an array, you can do operations with it. 

Let’s try array difference: 

```rb
enc.decode(author_token_ids - session_token_ids)
# => " Author"

enc.decode(session_token_ids - author_token_ids)
# => " Session"
```

And then here is array intersection: 

```rb
enc.decode(author_token_ids.intersection(session_token_ids))
# => "class < ApplicationRecord"
```

I like this because it makes the tokens visible and shows a glimpse of how operations on an array of numbers representing text chunks could return something meaningful. 
Of course, this is not an LLM, just some array operations. 

## Token IDs 

These integers don't mean anything on their own. They are just IDs associated with those text chunks in a vocabulary. 

You can see this by switching models and noticing it returns different numbers. 

```rb
Tiktoken.encoding_for_model('gpt-4o').encode('class Author < ApplicationRecord')
# => [1444, 10764, 464, 12493, 6721]

Tiktoken.encoding_for_model('gpt-3.5-turbo').encode('class Author < ApplicationRecord')
# => [1058, 7030, 366, 55926]
```

This Tiktoken algorithm is specific to OpenAI. Claude or other LLMs might use a different algorithm. So again, these numbers don’t represent anything outside the algorithm they were produced with.
