---
title: Configuring Zed editor to use ERB Lint as a formatter
description:
created_at: 2025-03-30 15:46:00 +00:00
updated_at: 2025-03-30 15:46:00 +00:00
guid: c6548610-46c8-4f3d-853f-b28d5d389475
---

I've recently started using the [Zed editor][] instead of VS Code. It took me a
while to work out how to configure [ERB Lint][] as a formatter, so hopefully this
will save someone else some time.

Write a shell script to run ERB Lint as follows:

<pre>
  <code class="prettyprint">
    #!/usr/bin/env sh

    bundle exec erb_lint --autocorrect --stdin $1 2>/dev/null \
      | sed '1,/^================/d'
  </code>
</pre>

* Enable the option to automatically correct linting errors (`--autocorrect`)
* Read the file content from standard input and specify the path supplied in
  the first command-line argument (`--stdin $1`)
* Suppress irrelevant warnings & error messages (`2>/dev/null`)
* Remove the preamble from the output to make it suitable for a Zed editor
  formatter (`sed '1,/^================/d'`)
* Ensure the script is executable (`chmod +x erb-lint-formatter`)

Configure ERB Lint as [a formatter][zed-editor-formatter] by adding the
following JSON to your Zed settings, either global or project-specific,
replacing `$PATH_TO_FORMATTER` with the path to the shell script you created
above:

<pre>
  <code class="prettyprint">
    {
      "languages": {
        "ERB": {
          "formatter": [
            {
              "external": {
                "command": "$PATH_TO_FORMATTER/erb-lint-formatter",
                "arguments": ["{buffer_path}"]
              }
            }
          ]
        }
      }
    }
  </code>
</pre>

Zed sets the `{buffer_path}` placeholder to the path of the buffer currently
being edited.

[Zed editor]: https://zed.dev/
[ERB Lint]: https://github.com/Shopify/erb_lint
[zed-editor-formatter]: https://zed.dev/docs/configuring-languages?highlight=formatter#configuring-formatters
