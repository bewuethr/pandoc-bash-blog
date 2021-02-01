# Pandoc Bash Blog

![Lint code base](https://github.com/bewuethr/pandoc-bash-blog/workflows/Lint%20code%20base/badge.svg)
![Testing](https://github.com/bewuethr/pandoc-bash-blog/workflows/Testing/badge.svg)
![Move release tags](https://github.com/bewuethr/pandoc-bash-blog/workflows/Move%20release%20tags/badge.svg)

Pandoc Bash Blog provides `pbb`, a simple generator for static blog sites based
on Pandoc and Bash. Progress is chronicled at
<https://www.benjaminwuethrich.dev>.

## Installation

Use

```bash
make install
```

to install the executable, the tab completion, the stylesheet, the Lua filter,
and the syntax highlighting theme. Installation follows the [XDG Base Directory
Specification]; this means:

- `~/.local/bin` has to be in in your `$PATH` (as per [systemd file hierarchy])
- Bash completion has to be configured such that it dynamically looks up
  completions in `$XDG_DATA_HOME/bash-completion/completions`; `$XDG_DATA_HOME`
  defaults to `~/.local/share`
- Assets such as the stylesheet are installed to `$XDG_DATA_HOME/pbb`
- The man page gets installed to `$XDG_DATA_HOME/man`; make sure your `man`
  finds it there
- The Lua filter for dot graphs is installed to the default location at
  `$XDG_DATA_HOME/pandoc/filters`
- The syntax highlighting theme is installed to `$XDG_DATA_HOME/pandoc`

There is an option to create symlinks instead of copying files; this is useful
for development so changes to the original are immediately effective. To do so,
set the `DEVMODE` variable:

```bash
make install DEVMODE=1
```

  [XDG Base directory Specification]: <https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html>
  [systemd file hierarchy]: <https://www.freedesktop.org/software/systemd/man/file-hierarchy.html>

## Dependencies

These are the versions I use on my development machine; some things might break
for older versions. `make install` checks if the executables exist, but not
their versions.

- Bash 5.0.17
- Pandoc 2.10
- Git 2.30.0
- GNU Coreutils 8.32: `cat`, `cp`, `mkdir`, `ln`, `rm`, `tac`
- GNU Sed 4.7
- ImageMagick 6.9.10-23 (for favicon)
- Python 3.8.6 (for `pbb serve`)
- inotify-tools 3.14 (for hot-reloading during `pbb serve`)
- Bats 1.2.1 (for test suite)
- bash-completion 2.11 (for tab completion)
- graphviz 2.43.0 (for dot graphs)

In the Makefile, additionally:

- GNU Make 4.3
- GNU Awk 5.0.1
- `column`
- GNU Coreutils 8.32: `install`, `rmdir`

## Usage

The authoritative source for usage instructions is `man pbb`.

Initialize a new blog with title "My blog" in an empty Git repository:

```bash
git init
pbb init 'My blog'
```

If you later want to change the title, use

```bash
pbb title 'My blog with a new title'
```

`pbb init` creates a sample blog post. Blog posts are written in [Pandoc
Markdown] (see also [my post about it]), with filenames formatted like
`YYYY-MM-DD-post-title.md`.

The first heading of a post has to be a level-one heading:

```markdown
# A blog post
```

Images must be stored in the `images` directory.

To build your blog, run `pbb build`. This extracts all the titles into an index
file; the index file links to all files following the naming convention above
and lists them in reverse alphabetical order, with the newest post at the top.

To have a look at your freshly built blog, use `pbb serve` and point your
browser to <http://localhost:8000>. While `pbb serve` is running, any changes
to `.md` files or files in the `images` directory trigger a rebuild or copy of
that file, allowing to preview a post by just reloading it in the browser
instead of building the whole site over and over again.

Once you think your opus magnum is ready to be published, run `pbb deploy`. This
pulls the generated HTML files into the `master` branch, commits  and then
pushes them to a remote. This works for GitHub pages deploying the `master`
branch.

You might have to set the Git remote first:

```bash
git remote add origin https://github.com/<yourname>/<repo-name>.git
```

  [Pandoc Markdown]: <https://pandoc.org/MANUAL.html#pandocs-markdown>
  [my post about it]: <https://www.benjaminwuethrich.dev/2020-05-04-everything-pandoc-markdown.html>

### Table of contents

To get a table of contents for a post, start it with a YAML document that sets
the `toc` variable to `true`:

```yaml
---
toc: true
...
```

### Math

To use MathJax to render inline and display math, turn the `math` feature on:

```bash
pbb enable math
```

### Bibliography

To use the [`pandoc-citeproc`] filter to get citations and bibliographies,
enable the `bibliography` feature:

```bash
pbb enable bibliography
```

  [`pandoc-citeproc`]: <https://pandoc.org/MANUAL.html#citations>

### dot graphs

Code blocks with class `.dot` are replaced by the [dot] graph they describe. To
additionally get a caption, use a `caption` attribute; to include the graph
description as an HTML comment in the output, add the `.includeSource` (or
`.include-source`) class.

<!-- markdownlint-disable code-fence-style -->

~~~markdown
``` {.dot .includeSource caption="A dot graph"}
digraph G {
    a -> b
}
```
~~~

<!-- markdownlint-restore -->

Like for other fenced code blocks, if `.dot` is the only class, the opening
line can be just ` ```dot `.

<!-- Fix syntax highlighting: `` -->

  [dot]: <https://graphviz.org/doc/info/lang.html>

### Favicon

To get a favicon, `pbb build` checks the `assets` directory for a file named
`favicon.*` and resizes it to a 32x32 PNG image. If there is no such file, more
than one, or if it is not an image file ImageMagick can handle, `pbb` warns
about this and continues.

### Analytics

Pbb integrates with [GoatCounter], a pretty awesome simple web statistics
solution. Open an account, add your site and set your code with

```bash
pbb gccode <yourcode>
```

Consider paying for a custom domain or [sponsoring] the author.

  [GoatCounter]: <https://www.goatcounter.com>
  [sponsoring]: <https://github.com/sponsors/arp242>

## Subcommands

There are eight subcommands (nine, if you count `pbb help`); when properly
installed, they should tab-autocomplete.

### `pbb init <title>`

- Creates new `source` branch and checks it out
- Adds artifacts directory to `.gitignore`
- Creates the `includes`, `images` and `assets` directories
- Symlinks the stylesheet from `$XDG_DATA_HOME/pbb/pbb.css`
- Creates header files in `includes` that are used on every page, for blog
  title link, favicon, Google web font links and GoatCounter analytics
- Creates an example post

### `pbb title <new title>`

- Sets a new blog title for an existing blog

### `pbb enable <feature>`

- Turns on a feature
- Options are `math` and `bibliography`

### `pbb disable <feature>`

- Turns off a feature

### `pbb gccode <code>`

- Includes a snippet with tracking code for [GoatCounter] on each page, where
  the code for the account is `<code>`
- To turn tracking off, set code to empty with `pbb gccode ''`

### `pbb build`

- Cleans the `artifacts` directory, then copies the `images` directory in there
- Checks for a favicon image and, if there is one, generates the favicon from
  it (see [Favicon](#favicon))
- Generates the index file, `index.md`
- Converts the markdown files with datestamps in their names and `index.md` to
  HTML, copies the results into `artifacts`

### `pbb serve`

- Serves the blog on <http://localhost:8000> to preview
- Listens to file changes in `.md` files and the `images` directory and
  rebuilds/copies the corresponding files as long as `pbb serve` is running

### `pbb deploy`

- Checks out the `master` branch
- Deletes everything but the `artifacts` directory (and the `CNAME` file, if
  you have one)
- Copies the contents of `artifacts` into the repository root directory
- Adds, commits and pushes everything to the remote
- Checks out the previous branch
