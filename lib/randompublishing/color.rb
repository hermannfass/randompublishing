# encoding: utf-8

require 'pp'

class Color

  # Red portion (0..255) of this color.
  attr_accessor :r

  # Green portion (0..255) of this color.
  attr_accessor :g

  # Blue portion (0..255) of this color.
  attr_accessor :b

  # Constructor expects the Red, Green, and Blue value in a
  # 0 to 255 (0x00 to 0xFF) range.
  def initialize( r = 0, g = 0, b = 0 )
    if ( r.kind_of?(String) && r.match(/[0-9a-z]{6}/i) )
      r, g, b = r.scan(/\w\w/).collect{ |x| x.to_i(16) }
    end
    @r, @g, @b = r, g, b
  end

  # Test if this color is equal to another color.
  def ==( other_obj )
    if (other_obj.kind_of?(String))
      other_obj = Color.new(other_obj)
    end
    other_obj.kind_of?( self.class ) &&
    @r == other_obj.r && @g == other_obj.g && @b == other_obj.b
  end

  # Translate input to a new Color instance. The input can be an existing
  # Color instance or a String representing the hexadecimal RRGGBB value
  # for a color.
  def self.to_color( value )
    color = nil
    if (value.kind_of?(Color))
      color = value
    elsif ( value.kind_of?(String) && value.match(/[0-9a-z]{6}/i) )
      r, g, b = value.scan(/\w\w/).collect{ |x| x.to_i(16) }
      color = Color.new(r, g, b)
    else
      raise "Input required as Color instance or hexadecimal RGB color code."
    end
    color
  end

  # The brightness of this Color calculated by a formula from the W3C
  # (see http://www.w3.org/TR/AERT).
  def brightness
    ( (@r * 299 + @g * 587 + @b * 114) / 1000 ).round
  end

  # The brightness difference between the two color arguments
  # (Color instance or String representing the hexadecimal RRGGBB
  # values, e.g. "336699").
  def self.brightness_difference( value_a, value_b )
    color_a = self.to_color( value_a ) 
    color_b = self.to_color( value_b )
    (color_a.brightness >= color_b.brightness) ?
    (color_a.brightness - color_b.brightness) :
    (color_b.brightness - color_a.brightness)
  end 

  # The brightness difference between this Color and the color in the
  # argument (Color instance or String representing the hexadecimal RRGGBB
  # values, e.g. "336699").
  def brightness_difference( other_color )
    self.class.brightness_difference( self, other_color )
  end

  # Do these Colors' brightnesses differentiate enough for using them
  # e.g. as background and text color respectively.
  # Provide the color arguments as Color instances or String
  # representation of the hexadecimal values RRGGBB, e.g. "990033")
  def self.brightness_contrasting?( value_a, value_b )
    self.brightness_difference(value_a, value_b) > 125
  end

  # Does this Color's brightness differentiate enough from the
  # brightness provided as an argument (Color instance or String
  # representation of the hexadecimal values RRGGBB, e.g. "990033")
  # so they can be used e.g. as background and text color respectively.
  def brightness_contrasting?( other_color )
    self.class.brightness_contrasting?( self, other_color )
  end

  # The color tone difference between two Color instances or
  # Strings with RRGGBB values (e.g. "0033CC").
  def self.color_difference( value_a, value_b )
    color_a = self.to_color( value_a )
    color_b = self.to_color( value_b )
    [color_a.r, color_b.r].max - [color_a.r, color_b.r].min +
    [color_a.g, color_b.g].max - [color_a.g, color_b.g].min +
    [color_a.b, color_b.b].max - [color_b.b, color_b.b].min
  end

  # The color tone difference between this Color and the color in the
  # argument (Color instance or String representing the hexadecimal RRGGBB
  # values, e.g. "336699").
  def color_difference( other_color )
    self.class.color_difference( self, other_color )
  end

  # Do these Colors (arguments as Color instances or hexadecimal
  # RGB values RRGGBB (e.g. "00FF99") differentiate enough from each other
  # so they can be used as background and text color respectively.
  def self.color_contrasting?( value_a, value_b )
    self.color_difference( value_a, value_b ) > 500
  end

  # Does this Color differentiate enough from the color
  # provided in the argument as Color instance or hexadecimal
  # RGB value RRGGBB (e.g. "FF99FF") to use the two as background
  # and text color.
  def color_contrasting?( other_color )
    self.class.color_contrasting?( self, other_color )
  end

  # Check if two Colors provide sufficient contrast
  # so that e.g. text is readable if one color is used as background
  # and the other as text color.
  def self.contrasting?( value_a, value_b )
    self.color_contrasting?( value_a, value_b ) &&
    self.brightness_contrasting?( value_a, value_b)
  end

  # Does this Color provide sufficient (readable) contrast
  # when used with the color (argument) as background or
  # vice versa.
  def contrasting?( other_value )
    self.class.contrasting?( self, other_value )
  end

  # Brighten up the color by incrementing Red, Green, and Blue by the
  # same amount. Returns false for #FFFFFF (cannot be brightned further),
  # otherwise true.
  def brighten( delta = 0x10, max = 0xFF)
    return false if (self.to_hex == 'FFFFFF')
    @r = [ @r + delta, max ].min
    @g = [ @g + delta, max ].min
    @b = [ @b + delta, max ].min
    true
  end

  # Darken the color by decrementing Red, Green, and Blue by the
  # same amount. Returns false for #000000 (not possible to darken),
  # otherwise true.
  def darken( delta = 0x10, min = 0x00 )
    return false if (self.to_hex == '000000')
    @r = [ @r - delta, min ].max
    @g = [ @g - delta, min ].max
    @b = [ @b - delta, min ].max
    true
  end

  # Convert this Color into a String representing the
  # hexadecimal RGB value (e.g. "336699").
  def to_hex
    sprintf("%02X%02X%02X", self.r, self.g, self.b)
  end

  # Convert this Color into a STring representing the
  # hexadecimal RGB values prepended by a pound sign, like
  # used in Web CSS.
  def to_s
    '#' + self.to_hex
  end
  
end
    
class ColorRandomizer

  attr_accessor :bgcolor

  def initialize( bgcolor = Color.new(0xFF, 0xFF, 0xFF) )
    @bgcolor = bgcolor
  end

  # Create a Color instance with random RGB values.
  def random_color
    Color.new( rand(256), rand(256), rand(256) )
  end

  # Move one numeric value (first parameter) away from another
  # value (second parameter) by an increment/decrement of d (delta,
  # third parameter, 1 by default).
  # This move happens within a range
  # that can be specified by a minimum and maximum value (parameters
  # four and five, 0 and 255 by default).
  #
  # If the maximal spread achievable with the given delta is reached
  # this method returns a nil value.
  def spread_value(a, b, delta = 0x10, min = 0, max = 255)
    a_new = 0
    mid = (max-min)/2
    if (a <= b && b >= mid)
        # ..a.......M....b.....
        a_new = a - delta
    elsif (a <= b && b < mid)
        # ..a....b..M..........
        a_new = (a - delta > 0) ? (a - delta) : (b + b - a + delta)
    elsif (a > b && b > mid)
        # ..........M..b...a...
        a_new = (a + delta < max) ? (a + delta) : (b - (a - b) - delta)
    elsif (a > b && b <= mid)
        # ..b.......M..a.......
        a_new = a + delta
    end
    (a_new >= 0 && a_new <= max) ? a_new : nil
  end

  # Move the color values of a first color (argument 1) so that
  # the color contrast between this color and the second color
  # (argument 2) is increased. Returns true if any values were changed
  # and false if this was not possible, e.g. due to the difference
  # being already at a maximum.
  def spread_colors(color_a, color_b)
    # puts "Color spreading #{color_a} and #{color_b}"
    old_color_a = Color.new( color_a.r, color_a.g, color_a.b )
    diff_r = color_a.r - color_b.r
    diff_g = color_a.g - color_b.g
    diff_b = color_a.b - color_b.b
    if ( [diff_r, diff_g, diff_b].collect{|x| x.abs}.min == diff_r.abs )
      color_a.r = spread_value( color_a.r, color_b.r, 0x10 ) || color_a.r
    elsif ( [diff_r, diff_g, diff_b].collect{|x| x.abs}.min == diff_g.abs )
      color_a.g = spread_value( color_a.g, color_b.g, 0x10 ) || color_a.g
    elsif ( [diff_r, diff_g, diff_b].collect{|x| x.abs}.min == diff_b.abs )
      color_a.b = spread_value( color_a.b, color_b.b, 0x10 ) || color_a.b
    end
    (color_a != old_color_a)
  end

  # Move the color values of a first color (parameter 1) so that
  # the brightness contrast between this color and the second color
  # is increased.
  def spread_brightness(color_a, color_b)
    # puts "Brightness spreading #{color_a} and #{color_b}"
    done = false
    if (color_a.brightness < color_b.brightness)
      # Darken color_a if it can be darkened.
      # Return false if color is #000000.
      color_a.darken && done = true
    else
      color_a.brighten && done = true
    end
    done
  end

  # Create a Color instance with random RGB values that contrasts well on
  # the background color sent as a parameter.
  # Note that the W3C recommendation for color and brightness are not
  # implemented (yet), so that only the brightness aspect is taken into
  # consideration. Instead of Color#contrasting? the color spreading is
  # only based on Color#brighntess_contrasting?.
  #--
  # Otherwise a simple algorithm makes the brightness spread bringing
  # colors together again, so that colors (almost) ever met both the
  # color difference and the brightness difference based contrast
  # conditions.
  #++
  def contrasting_random_color( bgcolor = @bgcolor )
    c = random_color
    until( c.brightness_contrasting?(bgcolor) )
      spread_brightness( c, bgcolor ) || break
    end
    c
  end

  # Create a random pair of colors that has enough contrast
  # for making text in color 1 readable on a background in color 2.
  def random_color_pair
    color_a = random_color
    color_b = contrasting_random_color( color_a )
    [color_a, color_b]
  end

end

