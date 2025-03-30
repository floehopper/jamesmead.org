---
title: Configuring Zed editor to use HTML Beautifier as a formatter in ERB templates
description:
created_at: 2025-03-30 17:05:00 +00:00
updated_at: 2025-03-30 17:05:00 +00:00
guid: 097d2eef-e198-4274-8d7e-bdfcd4aeb145
---

Following on from my previous post about [configuring Zed editor to use ERB Lint as a formatter][previous-post], here's how to configure [Zed] to use [Paul][]'s excellent [HTML Beautifier][] as a formatter in ERB templates.

Configure HTML Beautifier as [a formatter][zed-editor-formatter] for ERB files as well as HTML files by adding the following JSON to your Zed settings, either global or project-specific:

<pre>
  <code class="prettyprint">
    {
      "languages": {
        "ERB": {
          "formatter": [
            {
              "external": {
                "command": "bundle",
                "arguments": ["exec", "htmlbeautifier", "--keep-blank-lines", "1"]
              }
            }
          ]
        },
        "HTML": {
          "formatter": [
            {
              "external": {
                "command": "bundle",
                "arguments": ["exec", "htmlbeautifier", "--keep-blank-lines", "1"]
              }
            }
          ]
        }
      }
    }
  </code>
</pre>

Note that I've added the HTML Beautifier formatter configuration *after* the ERB Lint formatter configuration for ERB files and that seems to work well.

[previous-post]: /blog/2025-03-30-configuring-zed-editor-to-use-erb-lint-as-formatter
[Zed]: https://zed.dev/
[Paul]: https://po-ru.com/
[HTML Beautifier]: https://github.com/threedaymonk/htmlbeautifier
[zed-editor-formatter]: https://zed.dev/docs/configuring-languages?highlight=formatter#configuring-formatters
