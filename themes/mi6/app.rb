# Use the app.rb file to load Ruby code, modify or extend the models, or
# do whatever else you fancy when the theme is loaded.

module Nesta
  class App
    # Uncomment the Rack::Static line below if your theme has assets
    # (i.e images or JavaScript).
    #
    # Put your assets in themes/[themename]/public/[themename]/
    #
    use Rack::Static, :urls => ["/mi6"], :root => "themes/mi6/public"

    configure do
      # Configuring sass
      sass_options = Hash.new

      #     Making the generated css easier to read an debug
      sass_options[:line_numbers] = true        # Other interesting options:
                                                # :debug_info => true   # if using FireBug
                                                # :style => :nested     # Can sometimes make the generated css easier to read
                                                # Options documentation:
                                                # http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#options
      set :sass, sass_options
      set :scss, sass_options
    end

    configure :development do
      enable :logging, :dump_errors
      set :raise_errors, true
    end

    helpers do

      def on_section(href)
        if href.is_a?(Array)
          href.any? { |link| /\A(\/){0,1}#{link}(\/|$){1}/.match(request.path_info) } ? 'is-active' : nil
        else
          /\A(\/){0,1}#{href}(\/|$){1}/.match(request.path_info) ? 'is-active' : nil
        end
      end

      def a_link(opt)
        if opt.has_key?(:href) && opt.has_key?(:text)
          haml_tag :a, opt[:text], :class => opt[:class], :id => opt[:id], :href => opt[:href]
        else
          haml_tag :p, 'There was a problem returning your link', :class => 'is-error'
        end
      end

      def showcase_item(article)
        unless article.metadata('thumbnail') && article.metadata('link text') && article.metadata('description')
          haml_tag :p, 'There was a problem rendering the showcase item', :class => 'subtle-text'
          haml_tag :p, 'No Thumbnail', :class => 'is-error' unless article.metadata('thumbnail')
          haml_tag :p, 'No Link Text', :class => 'is-error' unless article.metadata('link text')
          haml_tag :p, 'No summary', :class => 'is-error' unless article.metadata('description')
        end

        haml_tag :div, :class => 'showcase-item' do
          haml_tag :a, :class => 'showcase-item-gfx', :href => article.abspath do
            haml_tag :img, :src => article.metadata('thumbnail'), :alt => article.metadata('link text')
          end
          haml_tag :div, :class => 'showcase-item-content' do
            haml_tag :h3 do
              haml_tag :a, article.metadata('link text'), :href => article.abspath
            end
            haml_tag :p, article.metadata('description')
          end
        end
      end

      def showcase_in_grid(items)
        haml_tag :div, :class => 'column-grid columns-2' do

          haml_tag :div, :class => 'column-1' do
            items.each_with_index do |itm, index|
              if index % 2 == 0
                showcase_item(itm)
              end
            end
          end

          haml_tag :div, :class => 'column-2' do
            items.each_with_index do |itm, index|
              if index % 2 != 0
                showcase_item(itm)
              end
            end
          end

        end
      end

      # def author_biography(name = nil)
      #   name ||= @page.metadata('author')
      #   if name
      #     short_name = name.downcase.gsub(/\W+/, '_').to_sym
      #     avatar_path = File.join(['images', 'authors', "#{short_name}.jpg"])
      #     html = ""
      #     locals = { :has_avatar => false }
      #     if File.exist?(File.join(Nesta::App.root, 'public', avatar_path))
      #       html += capture_haml do
      #         haml_tag :img, :src => "/#{avatar_path}", :class => 'avatar'
      #       end
      #       locals[:has_avatar] = true
      #     end
      #     html << haml(short_name.to_sym, :layout => false, :locals => locals)
      #   end
      # end

      def list_articles(articles)
        haml_tag :ol, :class => 'bare' do
          articles.each do |article|
            haml_tag :li do
              haml_tag :i, :class => 'fa fa-file-text-o'
              haml_tag :a, article.heading, :href => url(article.abspath)
            end
          end
        end
      end

      def article_years
        articles = Page.find_articles
        last, first = articles[0].date.year, articles[-1].date.year
        (first..last).to_a.reverse
      end

      def archive_by_year
        article_years.each do |year|
          haml_tag :li, :class => 'box' do
            haml_tag :h3, year
            articles = Page.find_articles.select { |a| a.date.year == year }
            list_articles(articles)
          end
        end
      end

      def age(dob)
        now = Time.now.utc.to_date
        now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
      end

      # No slashes in path.
      def find_articles_by_path(path, count = nil)
        a = Nesta::Page.find_articles.select { |article| /^(\/#{path}\/).*/.match(article.abspath) }

        unless count.nil?
          a = a[0..count-1]
        end

        a
      end

    end # end helpers

    before do

      @scripts = {
        :libs => [
          '//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min.js',                           # Core
          # '//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js',                     # UI
          # '//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore-min.js',                # Core
          # '//cdnjs.cloudflare.com/ajax/libs/underscore.string/2.3.3/underscore.string.min.js',     # String
          # '//cdnjs.cloudflare.com/ajax/libs/coffee-script/1.7.1/coffee-script.min.js',             # Core
          # '//cdnjs.cloudflare.com/ajax/libs/backbone.js/1.1.2/backbone-min.js',                    # Core
          # '//cdnjs.cloudflare.com/ajax/libs/backbone.marionette/1.8.0/backbone.marionette.min.js', # Marionette
          # '//cdnjs.cloudflare.com/ajax/libs/modernizr/2.8.1/modernizr.min.js',                     # Core
          # '//cdnjs.cloudflare.com/ajax/libs/hammer.js/1.0.10/hammer.min.js'                        # Hammer, multitouch library
        ],
        :plugins => [
          '/mi6/js/jquery.magnific-popup-0.9.9-min.js'
        ],
        :apps => [
          '/mi6/js/main.js'
        ]
      }

      @xp_data = [
        { :id => 'backbone',  :label => 'Backbone.js', :kn => 40, :xp => 40, :ps => 100, :content => 'I\'m a fan of structure and speed on the web, needless to say I love working with Backbone. I\'ve had to jump in and dig through hundreds of lines of poorly structured JavaScript more times than I can remember, when I hop on a project built on Backbone there\'s a comfort in already knowing how the project is structured and how to keep it in good shape.' },
        { :id => 'jasmine',   :label => 'Jasmine',     :kn => 30, :xp => 30, :ps => 80, :content  => 'Since I\'m rooted in the Ruby world, my preferred js testing framework is Jasmine, Jasmine should be quite easy to get into for anyone familiar with RSpec. Writing js test doesn\'t just ease your heart when adding to your codebase, but it helps you get into a pattern of writing better code - testable code. This is something I believe is important for the health of the project, and for personal growth of the developer.' },
        { :id => 'jquery',    :label => 'jQuery',      :kn => 80, :xp => 90, :ps => 60, :content  => 'As for most Front-End developers, jQuery has been a part of my life for quite some time now, it\'s for me what the utility belt is for Batman. The super-power isn\'t about the belt, but it makes a lot of stuff much easier.' },
        { :id => 'sass',      :label => 'Sass',        :kn => 100,:xp => 90, :ps => 70, :content  => 'For me Sass is more than an aid to strucure, re-use and calculate styles - it enables me to be more creative in the way I write my code. I get to adhere to a programmatical mindset as opposed to just writing declarations, which makes writing styles really enjoyable, especially with tools like Compass or Bourbon.' },
        # { :id => 'compass',   :label => 'Compass',     :kn => 90, :xp => 90, :ps => 70, :content  => '5' },
        { :id => 'less',      :label => 'Less',        :kn => 60, :xp => 10, :ps => 50, :content  => 'I\'m using Less on a few of my current projects, even though I prefer Sass for CSS preprocessing I think Less\' approach is interesting and from a CSS-authoring point of view probably healthier than Sass.' },
        { :id => 'responsive',:label => 'Responsive',  :kn => 80, :xp => 80, :ps => 80, :content  => 'These days, responsiveness for a web-site goes without saying, there is more to building responsive web applications than that though. If breakpoints doesn\'t give the right experience or feel intuitive enough - then there a lot of room for improvements. Truly responsive applications that feels right from phone to desktop, that just gives a really professional impression.' }
      ]
    end

    before '/articles' do
      @articles_from_path = find_articles_by_path('articles')
    end

    # Redbet, Whitebet, Heypoker
    before %r{^\/?showcase\/(redbet|heypoker|whitebet)$} do |brand|
      @related_links = []
      @related_links << { :text => 'The Redbet i-gaming platform', :href => '/showcase/redbet', :title => 'The Redbet i-gaming platform' } unless brand == 'redbet'
      @related_links << { :text => 'Whitebet, theme running on the Redbet platform', :href => '/showcase/whitebet', :title => 'Whitebet.com built on the Redbet platform' } unless brand == 'whitebet'
      @related_links << { :text => 'Heypoker, theme running on the Redbet platform', :href => '/showcase/heypoker', :title => 'Heypoker.com built on the Redbet platform' }  unless brand == 'heypoker'
    end

    before '/articles/dry-selectors' do
      @related_links = [
        { :text => 'join-instance_method', :href => 'http://sass-lang.com/documentation/Sass/Script/Functions.html#join-instance_method', :title => 'SASS_REFERENCE' },
        { :text => 'nth-instance_method', :href => 'http://sass-lang.com/documentation/Sass/Script/Functions.html#nth-instance_method', :title => 'SASS_REFERENCE' }
      ]
    end

  end
end
