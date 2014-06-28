# encoding: utf-8

$:.push '.'
require 'randomstring'

class HtmlRandomizer

  attr_accessor :texter

  # Provide the new HtmlRandomizer with a text generator
  # like a StringRandomizer instance. 
  # Using duck typing vs. interfaces make sure that the parameter
  # implements the instance methods random_word, random_title, 
  # random_sentence, random_paragraph, all of which return a
  # String according to their names.
  def initialize( textgenerator = StringRandomizer.new() )
    @texter = textgenerator
  end

  # Return a paragraph, i.e. a p-start-tag, some text, and a
  # p-end-tag.
  def random_p
    "<p>#{texter.random_paragraph}</p>"
  end

  # Return a random list (by default unordered, use 'ul' or 'ol'
  # as first parameter to change this. If the list items should
  # contain paragraphs (between p-tags) instead of plain text
  # set argument 2 to 'true'. The number of list item can be
  # provided as 3rd argument. By default it is a random number.
  def random_list( type = 'ul', paragraphs = false, item_num = 2 + rand(7) )
    items = (1..item_num).collect do
      "<li>" + (paragraphs ? self.random_p : @texter.random_sentence) + "</li>"
    end
    "<#{type}>\n" + items.join("\n") + "\n</#{type}>"
  end

  # Return a header. By default this is an h1 element,
  # the argument can be a number from 1 to 6 for h1 to h6.
  def random_h( level = 1 )
    "<h#{level}>#{texter.random_title}</h#{level}>"
  end

  # Return a definition list (HTML dl element). Number of
  # items can be defined via argument, otherwise it is a
  # random number.
  def random_dl( item_num = 2 + rand(10) )
    items = (1..item_num).collect do
      "<dt>#{texter.random_word.capitalize}</dt>" +
      "<dd>#{texter.random_paragraph}</dd>"
    end
    "<dl>\n" + items.join("\n") + "\n</dl>"
  end

  # Generate block content, composed by paragraph or
  # list elements, but not headers.
  def random_block
    type = %w(p p p p ul ol dl).sample
    case type
      when 'p'
        self.random_p
      when 'ul'
        self.random_list( 'ul', (rand(2) == 1) )
      when 'ol'
        self.random_list( 'ol', (rand(2) == 1) )
      when 'dl'
        self.random_dl
    end
  end

end

