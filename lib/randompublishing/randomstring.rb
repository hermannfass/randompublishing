# encoding: utf-8

# Class to generate random strings in a pseudo language.
class StringRandomizer

  Vowels = %w(
    a a a a
    au
    e e e e
    ei
    i i i
    ie
    o o o
    u u u
  )
  Consonants = %w(
    b b b
    c c c
    d d d
    f f f
    g g g
    h h h
    j
    k k k
    l l l
    m m m
    n n n
    p p p
    q
    r r r
    s s s
    t t t
    v v
    w w w
    x
    y
    z z
  )

  # Blocks of consonants at the beginning of a word
  PreVowelStarters  = %w( bl ch dr fl fr gr kn kr pr sch schl scht st tr
                        ) + Consonants

  # Blocks of consonants that follows a vowel at the beginning of a word
  PostVowelStarters = %w( ch cht ck ff kt mm nd nn pp rt sch ss st str
                           tr tt ttr tz zt
                        ) + Consonants

  # Blocks of consonants between vowels
  InterVowelMidParts = %w( ch cht ck ff kt lv mm nd nn pp rt sch ss st str
                          tr tt ts tz 
                        ) + Consonants

  # Block of consonants at the end of a word
  PostVowelEndings  = %w( ch ck ckt ff kt lf mm nd nn rd rt sch ss st sst 
                          ts tsch tt tts tzt zt 
                        ) + Consonants

  # Punctuation used at the end of sentences
  EndPunctuation = %w( . . . . . . . . . . . ? ! : )

  # Punctuation used inside sentences
  InPunctuation = %w( , , , , , , , , , , , ; : )

  # Maximum for letters per words where the number of letters is
  # defined at random (i.e. not provided by the caller of word
  # generation methods).
  # This is handled with a tolerance for
  # finishing consonant blocks at the end of words (e.g. 'ck'
  # or 'st' must not be broken apart).
  attr_accessor :max_letters_per_word

  # Maximum for words per sentence where the number of words is
  # defined at random (i.e. not provided by the caller of sentence
  # generation methods).
  attr_accessor :max_words_per_sentence

  # Maximum for sentences per paragraph where the number of sentences is
  # defined at random (i.e. not provided by the caller of paragraph
  # generation methods).
  attr_accessor :max_sentences_per_paragraph

  # Capitalize first word of new sentences.
  attr_accessor :capitalize_sentence_initial

  # Likelihood of capitalization (noun). Use 0 for all lower case
  # and 1 to get all in upper case.
  attr_accessor :capitalization_likelihood

  # Likelihood of a space between words to get filled
  # with a punctuation sign.
  attr_accessor :punctuation_likelihood

  def initialize()
    @max_letters_per_word = 10
    @max_words_per_sentence = 20
    @max_sentences_per_paragraph = 10
    @capitalize_sentence_initial = true
    @capitalization_likelihood = 0.2 
    @punctuation_likelihood = 0.2
  end

  # Create a random word
  # The length can be specified as argument 1 or will be set 
  # depending on @max_letters_per_word. Note that it can be a few
  # characters longer than that when ending with a
  # multi-consonant part.
  def random_word( letters = 2 + rand(@max_letters_per_word + 1 - 2) )
    vowel_next = (rand(2) == 0)
    result = ''
    letter_counter = 0
    if (vowel_next)
      result << Vowels[rand(Vowels.length)]
      letter_counter += 1
      if (letter_counter < letters)
        addition = PostVowelStarters[rand(PostVowelStarters.length)]
        result << addition
        letter_counter += addition.length
      end
    else
      addition = PreVowelStarters[rand(PreVowelStarters.length)]
      result << addition
      letter_counter += addition.length
      vowel_next = vowel_next ^ true
    end
    while ( letter_counter < (letters - 1) )
      addition = vowel_next ?
                 Vowels[rand(Vowels.length)] :
                 InterVowelMidParts[rand(InterVowelMidParts.length)]
      result << addition
      letter_counter += addition.length
      vowel_next = vowel_next ^ true
    end
    if (vowel_next)
      result << Vowels[rand(Vowels.length)]
    else
      result << PostVowelEndings[rand(PostVowelEndings.length)]
    end
  end

  # Create a title, i.e. some words with no punctuation.
  def random_title( word_num = 2 + rand(@max_words_per_sentence +1-2) )
    old_punctuation_likelihood = @punctuation_likelihood
    @punctuation_likelihood = 0 
    result = random_sentence( word_num )
    @punctuation_likelihood = old_punctuation_likelihood
    result
  end

  def random_sentence( word_num = 2 + rand(@max_words_per_sentence +1-2).round )
    # High value means low likelihood for capitalization.
    # Value 1 means all capitalize all, 5 means about every 5th word.
    # Value 0 to be handled separately (never capitalize).
    capitalization_random_base = (@capitalization_likelihood == 0) ?
                                 0 :
                                 ( (1 / @capitalization_likelihood).round )
    punctuation_random_base = (@punctuation_likelihood == 0) ?
                              0 :
                              ( (1 / @punctuation_likelihood).round )
    result = ''
    (1..word_num).each do |n|
      word = random_word( 2 + rand(@max_letters_per_word + 1 - 2).round )
      if ( (@capitalize_sentence_initial && (n==1)) ||
           ( (capitalization_random_base != 0) &&
             (rand(capitalization_random_base) == 0) ) )
        word.capitalize!
      end
      result << word
      if ( (n > 1) &&
           (n < (word_num - 2)) &&
           (punctuation_random_base != 0) &&
           (rand(punctuation_random_base) == 0) )
        result << InPunctuation[rand(InPunctuation.length)]
      end
      if (n < word_num)
        result << ' '
      else
        result << EndPunctuation[rand(EndPunctuation.length)] if
                  (@punctuation_likelihood > 0)
      end
    end
    result
  end

  # Create a paragraph with sentences at random. If the number of
  # sentences is not specified (first argument) this number will be
  # at random between 1 and @max_sentences_per_paragraph.
  # The number of words per sentence and letters per words (both
  # determined at random) is limited or set via the
  # @max_words_per_sentence and @max_letters_per_word properties.
  def random_paragraph(
        sentence_num = 1 + rand(@max_sentences_per_paragraph).round )
    sentences = []
    sentence_num.times do |n|
      sentence_length = 2 + rand(@max_words_per_sentence + 1 - 2).round()
      sentences << random_sentence( sentence_length )
    end
    return sentences.join(' ')
  end
      
end

