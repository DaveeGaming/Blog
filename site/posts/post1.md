# Making an RSS feed with soupault
**Date:** <time id="post-date">2025-09-12T12:00:00Z</time>


<p id="post-excerpt">
    Let's look at how to create an RSS feed using a lua plugin for soupault!
</p>

<h3> Motivation </h3>

I always had a slight itch to get into blogging, and when I found the static site generator Soupault, I instantly fell in love. It's simplicity made the tool extremely easy to use and expand upon, one of these features are the metadata processor and json dump.
Before getting into the middle of things, let's check out how the soupault tool works, and what you can do with it.

<h3> Preparation </h3>

The tool provides some built in plugins that scrape your html based on a css filter, and extracts it for you. Let's look at an example:

<pre><code class="language-toml">[index.fields.title]
  selector = ["h1"]

[index.fields.date]
  selector = ["time#post-date"]
  extract_attribute = "datetime"
  fallback_to_content = true

[index.fields.excerpt]
  selector = ["p#post-excerpt"]
</code></pre>

The **index.fields** defines what widget we want to use, and the last name can be completely arbitrary. Selectors use the same format just as if you were writing a css file. Having multiple filters makes it try them in order, this allows you to set defaults.

<pre><code class="language-toml">[index.fields.title]
  # We could try to find the h1 specifically set as the title,
  # or fall back to the first h1 it finds
  selector = ["h1#title", "h1"]
</code></pre>

One place where I use these extracted metadatas is the post and projects list, using another built in widget type called views.

<h3> Using metadata </h3>

Once we extracted our index fields, all of our fields will be available cached in the tool. The built in view widget uses these metadataas in an Ocaml jingoo template to auto fill a completely different html element.

<pre><code class="language-toml">[index.views.blog]
  section = "posts/"
  index_selector = "#blog-index"
  index_item_template = """
    &#x3C;div class=&#x22;post&#x22;&#x3E; 
        &#x3C;a href={{url}}&#x3E;
        &#x3C;h3 align=&#x22;center&#x22;&#x3E;{{title}}&#x3C;/h3&#x3E;
        &#x3C;/a&#x3E;
        &#x3C;p&#x3E;{{excerpt}}&#x3C;/p&#x3E;
        &#x3C;time&#x3E;{{date}}&#x3C;/time&#x3E;
    &#x3C;/div&#x3E;
    """
</code></pre>

This widget will scan all our files in the **posts/** folder, get their metadata, and then generate html code at another given css selector, which is **#blog-index** in this instance.

As a fun fact, let me show what the **posts/index.html** looks like before building.

<pre><code class="language-html"> &#x3C;div id=&#x22;blog-index&#x22;&#x3E;&#x3C;/div&#x3E;
</code></pre>
That's it!

Okay not completely, there is visibly a lot more content on the page, let me get to that. 
Every page also uses a template, with the same system as the metadata, but here, we aren't extracting any specific info, but the whole html.
This is my simple template as of writing this post:
<pre><code class="language-html">&#x3C;html lang=&#x22;en&#x22;&#x3E;
  &#x3C;head&#x3E;
    &#x3C;title&#x3E;&#x3C;/title&#x3E;
    &#x3C;meta charset=&#x22;utf-8&#x22;&#x3E;
  &#x3C;/head&#x3E;
  &#x3C;body&#x3E;
    &#x3C;div id=&#x22;main-page&#x22;&#x3E;
      &#x3C;div id=&#x22;main-profile&#x22;&#x3E;&#x3C;/div&#x3E;
      &#x3C;div id=&#x22;side-menu&#x22;&#x3E;
        &#x3C;a href=&#x22;/&#x22;&#x3E;Home&#x3C;/a&#x3E;
        &#x3C;a href=&#x22;/posts&#x22;&#x3E;Posts&#x3C;/a&#x3E;
        &#x3C;a href=&#x22;/projects&#x22;&#x3E;Projects&#x3C;/a&#x3E;
        &#x3C;button id=&#x22;kaomoji&#x22; onClick=&#x22;random_kaomoji()&#x22;&#x3E;d(o.o)b&#x3C;/button&#x3E;
      &#x3C;/div&#x3E;
      &#x3C;div id=&#x22;main-content&#x22;&#x3E;&#x3C;/div&#x3E;
    &#x3C;/div&#x3E;
  &#x3C;/body&#x3E;
&#x3C;/html&#x3E;
</code></pre>

Our **posts=index.html** simply gets inserted into the **main-content** div and voila! A whole page.

<h3>Finally, RSS</h3>

Knowing all the tiny simple magic behind soupault, I hope you can appreciate how fun it is to set a simple setting flag, and all the metadata info gets generated into a json dump file!

<pre><code class="language-toml">[index]
  dump_json = "dump/dump.json"
</code></pre>

Let's quickly look at one of these json entries


<pre><code class="language-json">  {
    "url": "/posts/post1/",
    "page_file": "site\\posts\\post1.md",
    "nav_path": [
      "posts"
    ],
    "excerpt": "Let's look at how to create an RSS feed using a lua plugin for soupault!",
    "date": "2025-09-12T12:00:00Z",
    "title": "Making an RSS feed with soupault"
  },
</code></pre>

We can see that, just as with the template language, this reuses that arbitrary name we specified in the toml config file.
Meaning you can extract absolutely any part of the html and use it for anything

Now all that's left is to process the json and write the rss xml.
I could have most definitely found a third party program for this, but with
such a simple xml format, I really didn't find the need to. This was also a good
opportunity to pull our beloved lua into the project.
