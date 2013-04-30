# Cimino: Jekyll Blogging Like a Boss

Cimino is a powerful, Jekyll-based distribution full of burrito-eating and badassery. It combines some of the most useful plugins and contributions from the Jekyll community with some ridiculous ninja-hacks to turn Jekyll into an easy to use and easy to extend blogging platform. Because we all love platforms.

Still pretty experimental. If something in this readme doesn't work as promised, oops?

# Requirements

* Ruby 1.9.2. If it works in 1.8.7 or 1.9.3, thats cool.
* Python 2.7 for syntax highlighting via Pygments. Unnecessary if using default coderay highlighter
* Patience

# Installation

## Pre-installation

- Install Ruby 1.9.2 via your favorite installation method. Included are `.rbenv-version` and `.rvmrc` files which may help speed up switching between Ruby versions.
- Install Python 2.7. This comes default on Ubuntu 11.10, and is easily installable on OS X. You'll also want pip to install Python requirements. Unnecessary if using default coderay highlighter.

## Cimino Installation

	# Clone cimino into a working area
	cd path/to/your/working/area
	git clone git://github.com/josegonzalez/cimino.git

	# Install all of cimino's requirements
	cd cimino
    pip install -r requirements.txt # Unnecessary if using default coderay highlighter
    bundle install

    # Set cimino up the bomb
    rake setup

# Usage

Whenever you run `rake setup` from the `cimino` directory, the rake task will attempt to do the following:

- Setup all temporary directories
- Create your source directory with the apropriate directories
- Ask you for some configuration information
- Setup a custom `_config.yml` in your source directory
- Cache your configuration information for upgrades

Cimino includes a `.gitignore` file which ignores any created directories, such as `_site`, `_tmp`, and `source`. This means you can make your `source` directory a git repository by doing the following:

	cd path/to/your/cimino_install
	cd source
	git init
	git add .
	git commit -m "Initial commit"

Updating Cimino is quite simple. Simply issue a `git pull origin master` in your Cimino installation directory and run `rake update`. This will ensure your `_config.yml` file is up to date. It will also warn you that your Cimino theme is out of date if you happened to override a core theme in your `source` directory.

## Themes

Themes are central to how Cimino works. Cimino hates not being able to customize his blog, so he has the ability to switch between various themes at will. Not only does Cimino come with a few core themes out of the box, but it is also possible to include your own themes within your `source` directory.

Theming is simple. Normally you have `_includes` and `_layouts` directories and a slew of other template files in your `source` directory. This gets a bit messy when updating your blog, so Cimino has the ability to move all these files into a custom theme folder that lives in `_themes`. You'll notice that Cimino himself comes with a few themes, each of which can choose to implement or not various features. Most themes are interchangeable, but you may have a specific need for your own blog, so feel free to throw away what is unnecessary.

When customizing your Cimino installation, feel free to either create a new theme in `source/_themes`, or copy an existing theme from `_themes` to `source/_themes`. In doing so, you allow Cimino to be cleanly updated at a later date without merge conflicts or silly, potentially error-prone file movements.

Themes typically have the following folders and files:

    `-- source/
        `-- _themes/
            `-- theme_name/
                |-- _includes/
                |-- _layouts/
                |   |-- default.html
                |   |-- page.html
                |   `-- post.html
                |-- css/
                |-- images/
                |-- js/
                |-- 404.html
                |-- favicon.ico
                |-- humans.txt
                |-- robots.txt
                `-- sitemap.xml

You can copy many of these files from the `classic` theme, or you can choose to omit them. If you are extending an existing theme, Cimino is smart enough to try and get the themefile from it's Core whenever you omit it. Simply name your theme the same as one in the core and Cimino will do the rest.

You're also allowed to implement as many of the custom plugin layouts as necessary, or add any other theme-specific pages. Feel free to explore themes included with Cimino if you are confused as to what goes and what does not go in a theme.

## Plugins

Because Cimino LOVES to mess around with cool stuff, he includes many useful plugins and Jekyll extensions. If you find something super #dagital you want Cimino to know about, feel free to issue a pull request with the plugin in hand.

All included plugins have been attributed to their original creators where possible. If you feel slighted in any way and would like your work removed, feel free to let me know and we'll split half of all the money Cimino makes off of your hard work ;)

### Converters

For the time being, these converters do **NOT** work on anything in `_layouts`. This is a limitation in Jekyll which I hope to ~~hack~~ fix.

- `coffee`: Converts `.coffee` files to `.js`
- `haml`: Converts `.haml` files to `.html`
- `sass`: Converts `.sass` and `.scss` files to `.css`
- `styl`: Converts `.styl` files to `.css`
- `upcase`: Converts `.upcase` files to uppercase

### Extensions

- `iterator`: Add an iterator for posts into the categories and tags properties of the `site` object. You can use this to automatically generate a tag cloud and a category page listing. <em>e.g. [Tag Cloud on Sidebar](http://josediazgonzalez.com/categories/cakephp)</em>
- `liquid_exception_handler`: When creating there is a liquid exception, this will suppress the exception during jekyll's generation step. DANGEROUS
- `post_filter`: Allows filtering of Post methods, AOSP style
- `themes`: Add theme support to Jekyll

### Filters

- `extended_filters`
  - `date_to_month`
  - `date_to_month_abbr`
  - `date_to_utc`
  - `html_truncatewords`
  - `preview`
  - `markdownify`

### Generators

- `archive`: creates archive pages by `year`, `year/month`, and `year/month/day`. Automatically generate archive pages for dates like 2010/, 2010/01/, and 2010/01/12 using files in <em>_layouts</em> to specify what each page will look like. <em>e.g. Posts for [January 2010](http://josediazgonzalez.com/2010/01)</em>
- `atom`: creates an `atom.xml` feed
- `generic_index`: creates generic index pages, like `tag` and `category` pages. Automatically generate index pages for each of the site.config `index_pages`. Currently iterates over collections already in the site, meaning all you need to do to have index pages for tags and categories is add them to the `index_pages` `site.config` key. Creates specific collection pages from layouts in <em>_layouts</em> to specify what each page will look like. <em>e.g. [CakePHP](http://josediazgonzalez.com/categories/cakephp)</em>. Also creates a listing of all of a particular collection. <em>e.g. [Categories](http://josediazgonzalez.com/categories)</em>. If the yaml maps to a boolean `true`, related collection items will appear in `page.related`
- `post_type`: Allows you to create generic post type landing pages and sub-pages, like `portfolios` or `galleries`. Allows the creation of a series of posts based on a type. Useful if you want to create a portfolio or gallery from an `_post_types/gallery` or `_post_types/portfolio` directory.
- `sitemap`: creates a `sitemap.xml` file

### Tags

- `backtick`: Allow placing codeblocks within three ```, github-style
- `highlight`: Write highlights with semantic HTML5 <figure> and <figcaption> elements and optional syntax highlighting — all with a simple, intuitive interface.
- `quote`: Allows the usage of blockquotes with attribution within your application by doing:

        {% blockquote John Hancock %}
        Content
        {% endblockquote %}
Also adds support for pullquotes:

        {% pullquote John Hancock %}
        Content
        {% endpullquote %}
- `rainbow`: Wraps codeblocks in `rainbow` compliant html tags
- `raw`: Raw tag for jekyll. Keeps liquid from parsing text betweeen {% raw %} and {% endraw %}
- `render_time`: Sample `render_time` tag

### Utilities

- `highlight_code`: Remove need for built-in Pygments syntax highlighting in favor of ruby gem implementations of syntax highlighting
- `template_wrapper`: This is useful for preventing Markdown and Textile from being too aggressive and incorrectly parsing in-line HTML.

# Todo

- ~~Include plugins within themes~~
- ~~More themes~~
- ~~Add the ability to comment and share posts/pages~~
- ~~Cleanup plugin documentation~~
- Tests for plugins
- ~~Add template for `_config.yml`~~
- ~~Split up Rakefile into separate tasks~~
- Include common deployment scenarios - Github, Heroku, Amazon, ~~Rsync~~
- Steal more stuff from Octopress and other distributions
- ~~Sleep~~ #willnotfix
- ~~Unknown bug fixes~~

# License

License valid for all new code, design/html that isn't directly attributable to a known source, hacks on hacks, and things generally written by me. Serp-a-derp, please don't sue me.

## MIT

Copyright (c) 2012 Jose Diaz-Gonzalez

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
