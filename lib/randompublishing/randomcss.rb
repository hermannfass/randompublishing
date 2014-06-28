# encoding: utf-8

require 'pp'

$:.push('.')
require 'color'

# Class to generate a basic CSS.
class CssRandomizer

  # Font family sets that are supported on most platforms.
  FontFamilySets = [
    %q(Arial,Helvetica,sans-serif),
    %q("Courier New",monospace),
    %q("Comic Sans MS",cursive),
    %q(Georgia,serif),
    # %q(Impact,sans-serif),
    %q("Lucida Console",Monaco,monospace),
    %q("Lucida Sans Unicode","Lucida Grande",sans-serif),
    %q("Palatino Linotype","Book Antiqua",Palatino,serif),
    %q(Tahoma,Geneva,sans-serif),
    %q("Times New Roman",Times,serif),
    %q("Trebuchet MS",sans-serif),
    %q(Verdana,Geneva,sans-serif)
  ]

  # Font styles (normal, italic, oblique).
  FontStyles = %w(normal italic oblique)

  # Font weights (normal, bold).
  FontWeights = %w(normal bold)

  TextDecorations = ['none', 'underline', 'overline', 'underline overline']

  def css_property( name, value )
    "#{name}: #{value};"
  end

  def random_font_family
    FontFamilySets[rand(FontFamilySets.length)]
  end

  # Will pick a font-style from FontStyles, giving an increased likelihood
  # to the first element of FontStyles.
  def random_font_style
    if ( rand(100) > 20 )
      FontStyles[0]
    else
      FontStyles[1 + rand(FontStyles.length + 1)]
    end
  end

  def random_font_size_px( min = 10, max = 48 )
    min + rand(max - min + 1).round
  end

  def random_font_weight( bold_likelihood_percentage = 5 )
    rand(100) < bold_likelihood_percentage ? 'bold' : 'normal'
  end
    
  def css_for_selector( selector, properties = [] )
    selector + '{' + "\n" +
    properties.collect { |css| "  #{css}" }.join("\n") +
    "\n}"
  end

  # Returns a randomly composed style sheet that can be used for example
  # in a Style section of an HTML file or ina CSS file.
  def random_css
    colorgen = ColorRandomizer.new
    # Backgrund color for this CSS (its body).
    bgcolor = colorgen.random_color
    # Color of default elements (p, li, dd, dl)
    basecolor = colorgen.contrasting_random_color(bgcolor)
    # Color that may or may not be used for headers
    altcolor = colorgen.contrasting_random_color(bgcolor)
    # Font family of standard text elements.
    basefontfamily = random_font_family
    # Font family randomly replacing basefontfamily in headers or not.
    altfontfamily = random_font_family
    basefontsize = random_font_size_px( 9, 14 )
    basefontcssset = [ "font-family: #{basefontfamily}",
                       "font-size: #{basefontsize}" ]
    element_css = {}
    element_css['body'] = [ css_property('background-color', bgcolor),
                            css_property('color', basecolor) ]
    element_css['p, li, dt, dl'] = [
        css_property('color', basecolor),
        css_property('font-family', basefontfamily),
        css_property('font-size', basefontsize)
      ]
    element_css['a'] = [
        css_property('color', colorgen.contrasting_random_color(bgcolor)),
        css_property('font-style', FontStyles.sample),
        css_property('font-weight',
                     rand(100)>30 ?
                        FontWeights[0] :
                        FontWeights[1 + rand(FontWeights.length - 1)]
                    ),
        css_property('text-decoration', TextDecorations.sample)
      ]
                                   
    # Build CSS for h1 to h6:
    previous_fontsize = basefontsize
    [6, 5, 4, 3, 2, 1].each do |i|
      fontfamily = (rand(100) > 30) ? basefontfamily : altfontfamily
      fontsize = previous_fontsize + rand( (8-i)*2 )
      fontweight = (fontsize / previous_fontsize > 1.2) ?
                   FontWeights[0] :
                   FontWeights[1 + rand(FontWeights.length - 1)]
      fontstyle = (fontweight == FontWeights[0]) ?
                  FontStyles[1 + rand(FontStyles.length)] :
                  FontStyles[0]
      color = [basecolor, altcolor].sample
      element_css["h#{i}"] = [
        css_property('font-family', fontfamily),
        css_property('font-size', "#{fontsize}px"),
        css_property('font-weight', fontweight),
        css_property('font-style', fontstyle),
        css_property('color', color)
      ]
      previous_fontsize = fontsize
    end
    result = ''
    element_css.each do |sel, css_list|
      result = result + css_for_selector(sel, css_list) + "\n"
    end
    result
  end

end

