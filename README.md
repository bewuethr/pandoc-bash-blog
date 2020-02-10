# Pandoc Bash Blog

Pandoc Bash Blog provides `pbb`, a simple generator for static blog sites based
on Pandoc and Bash. Progress is chronicled at <https://bewuethr.github.io>.

## Usage

`pbb` is currently hardcoded to use the title of my own blog.

It expects to be run in the same directory as blog posts written in [Pandoc
Markdown][pandocmd], with filenames formatted like `YYYY-MM-DD-post-title.md`.

[pandocmd]: https://pandoc.org/MANUAL.html#pandocs-markdown

The first line of a file has to be a level-one heading:

```markdown
# A blog post
```

This is then extracted to generate the index file. The index file links to all
files following the naming convention above and lists them in reverse
alphabetical order, with the newest post at the top.

To deploy, the script assumes that it is in a Git repository in a branch other
than `master`; the generated HTML files are pulled into the `master` branch,
committed and then pushed to a remote. This works for GitHub pages deploying
the `master` branch.
