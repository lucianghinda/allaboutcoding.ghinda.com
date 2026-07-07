---
layout: post
title: Using RubyMine AI and ChatGPT to get the source code website for a list of
  gems
date: '2023-11-28 07:19:03 +0000'
published: false
hashnode_draft_id: 656581eda71e5c1187c2ad78
---

I asked both ChatGPT and Ruby Mine AI the following question:

````markdown
I want to create a Ruby class that will accept a list of gems 
in one of the following formats:

Format one gem per line:
```
ruby-openai
avo
addressable
```

Gemfile format:
```
gem "ruby-openai", "~> 6.3"
gem "avo"
gem "addressable", "~> 2.8", ">= 2.8.5"
```
Gemfile format:
```
gem 'ruby-openai', '~> 6.3'
gem 'avo', '~> 3.0', '>= 3.0.6'
gem 'addressable'
```

It should work with double quotes or single quotes.

Assume the class would be `GemList::Parser` and will have the following 
methods: 

```ruby
def initialize(list_as_string)
# initializer code
end

# returns Array<RubyGems::Gem>
def parse
# code to parse
end
```

Assume there exists the following: 
- `RubyGems::Client#info(gem)` a client that will query RubyGems and will return a Gem object 
- `RubyGems::Gem` is a data object defined as:
```ruby
module RubyGems
  Gem = Date.define(
    :name,
    :version,
    :info,
    :project_uri,
    :author,
    :gem_uri,
    :homepage_uri,
    :wiki_uri,
    :documentation_uri,
    :mailing_list_uri,
    :source_code_uri
  )
end
```

The objective of `GemList::Parser` is to parse the list as input and return a list of Gem objects.

First let's start by creating tests using Rails default test framework (Minitest) that should contain the requirements listed here.
Do not implement the `GemList::Parser`.

Regarding tests: 
- You should mock the `RubyGems::Client#info` as it would do external HTTP requests. 
- You should include have both positive and negative tests
- The tests should cover the possible cases for input format. 
- Use Minitest standard format not the spec DSL
- As much as possible do not include other gems
````

## RubyMine AI

The response from RubyMine AI is the following:

```ruby
require 'minitest/autorun'
require 'ostruct'
require 'mock_gem_list_parser'

module RubyGems
  Gem = Struct.new(
    :name,
    :version,
    :info,
    :project_uri,
    :author,
    :gem_uri,
    :homepage_uri,
    :wiki_uri,
    :documentation_uri,
    :mailing_list_uri,
    :source_code_uri
  )
end

class GemListParserTest < Minitest::Test
  def setup
    # Mocked client
    @client = Minitest::Mock.new

    # This is the mocked response from the RubyGems::Client
    @mock_gem_info = RubyGems::Gem.new('name', 'version', 'info', 'project_uri', 'author', 'gem_uri', 'homepage_uri',
                                       'wiki_uri', 'documentation_uri', 'mailing_list_uri', 'source_code_uri')

    # Assume that all gems have the same info for the purpose of the test
    @client.expect(:info, @mock_gem_info, ['avo'])
    @client.expect(:info, @mock_gem_info, ['ruby-openai'])
    @client.expect(:info, @mock_gem_info, ['addressable'])
  end

  def test_parse_single_line_format
    parser = MockGemListParser.new("ruby-openai\navo\naddressable", @client)
    assert_equal [@mock_gem_info, @mock_gem_info, @mock_gem_info], parser.parse
  end

  def test_parse_gemfile_format_double_quotes
    gemfile = %Q{
      gem "ruby-openai", "~> 6.3"
      gem "avo"
      gem "addressable", "~> 2.8", ">= 2.8.5"
    }

    parser = MockGemListParser.new(gemfile, @client)
    assert_equal [@mock_gem_info, @mock_gem_info, @mock_gem_info], parser.parse
  end

  def test_parse_gemfile_format_single_quotes
    gemfile = %Q{
      gem 'ruby-openai', '~> 6.3'
      gem 'avo', '~> 3.0', '>= 3.0.6'
      gem 'addressable'
    }
    
    parser = MockGemListParser.new(gemfile, @client)
    assert_equal [@mock_gem_info, @mock_gem_info, @mock_gem_info], parser.parse
  end

  def test_parser_with_invalid_format
    bad_string = "This is a invalid format!"

    assert_raises(StandardError) do
      MockGemListParser.new(bad_string, @client).parse
    end
  end
end
```

It also added the following explanation:

```markdown
You can then use these tests to implement the actual parsing in your 
GemList::Parser class.

Note: The implementation of GemList::Parser could use regular expression 
or string manipulation methods to extract the gem names and version specification from 
the input string. Depending on regex matching, we can certain whether to consider the 
line as a valid gem entry or not.
The choice between the two would likely depend on the complexity of the input format 
and the performance requirements of the parser.
```
