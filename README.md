# Pandoc Bash Blog

![Markdown linting](https://github.com/bewuethr/pandoc-bash-blog/workflows/Markdown%20linting/badge.svg)
![Shell linting and testing](https://github.com/bewuethr/pandoc-bash-blog/workflows/Shell%20linting%20and%20testing/badge.svg)
![Move release tags](https://github.com/bewuethr/pandoc-bash-blog/workflows/Move%20release%20tags/badge.svg)

Pandoc Bash Blog provides `pbb`, a simple generator for static blog sites based
on Pandoc and Bash. Progress is chronicled at
<https://www.benjaminwuethrich.dev>.

## Installation

Use

```bash
make install
```

to install the executable, the tab completion and the stylesheet. Installation
follows the [XDG Base Directory Specification]; this means:

- `~/.local/bin` has to be in in your `$PATH` (as per [systemd file hierarchy])
- Bash completion has to be configured such that it dynamically looks up
  completions in `$XDG_DATA_HOME/bash-completion/completions`; `$XDG_DATA_HOME`
  defaults to `~/.local/share`
- Assets such as the stylesheet are installed to `$XDG_DATA_HOME/pbb`
- The man page gets installed to `$XDG_DATA_HOME/man`; make sure your `man`
  finds it there

There is an option to create symlinks instead of copying files; this is useful
for development so changes to the original are immediately effective. To do so,
set the `DEVMODE` variable:

```bash
make install DEVMODE=1
```

  [XDG Base directory Specification]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  [systemd file hierarchy]: https://www.freedesktop.org/software/systemd/man/file-hierarchy.html

## Dependencies

These are the versions I use on my development machine; some things break for
older versions. `make install` checks if the executables exist, but not their
versions.

- Bash 5.0.3
- Pandoc 2.9.1.1
- Git 2.23.0
- GNU Coreutils 8.30: `cat`, `cp`, `mkdir`, `ln`, `rm`, `tac`
- GNU Sed 4.7
- ImageMagick 6.9.10-23 (for favicon)
- Python 3.7.5 (for `pbb serve`)
- Bats 1.1.0 (for test suite)
- bash-completion 2.9 (for tab completion)

In the Makefile, additionally:

- GNU Make 4.2.1
- GNU Awk 4.2.1
- `column`
- GNU Coreutils 8.30: `install`, `rmdir`

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
Markdown], with filenames formatted like `YYYY-MM-DD-post-title.md`.

The first heading of a post has to be a level-one heading:

```markdown
# A blog post
```

Images must be stored in the `images` directory.

To build your blog, run `pbb build`. This extracts all the titles into an index
file; the index file links to all files following the naming convention above
and lists them in reverse alphabetical order, with the newest post at the top.

To have a look at your freshly built blog, use `pbb serve` and point your
browser to <http://localhost:8000>.

Once you think your opus magnum is ready to be published, run `pbb deploy`. This
pulls the generated HTML files into the `master` branch, commits  and then
pushes them to a remote. This works for GitHub pages deploying the `master`
branch.

You might have to set the Git remote first:

```bash
git remote add origin https://github.com/<yourname>/<repo-name>.git
```

  [Pandoc Markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown

### Table of contents

To get a table of contents for a post, start it with a YAML document that sets
the `toc` variable to `true`:

```yaml
---
toc: true
...
```

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

  [GoatCounter]: https://www.goatcounter.com
  [sponsoring]: https://github.com/sponsors/arp242

## Subcommands

There are six subcommands (seven, if you count `pbb help`); when properly
installed, they should tab-autocomplete.

### `pbb init 'Title of the blog'`

- Creates new `source` branch and checks it out
- Adds artifacts directory to `.gitignore`
- Creates the `includes`, `images` and `assets` directories
- Symlinks the stylesheet from `$XDG_DATA_HOME/pbb/pbb.css`
- Creates header files in `includes` that are used on every page, for blog
  title link, favicon, Google web font links and GoatCounter analytics
- Creates an example post

### `pbb title 'New title'`

- Sets a new blog title for an existing blog

### `pbb gccode 'mycode'`

- Includes a snippet with tracking code for [GoatCounter] on each page, where
  the code for the account is `mycode`
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

### `pbb deploy`

- Checks out the `master` branch
- Deletes everything but the `artifacts` directory (and the `CNAME` file, if
  you have one)
- Copies the contents of `artifacts` into the repository root directory
- Adds, commits and pushes everything to the remote
- Checks out the previous branch
