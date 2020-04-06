# Pandoc Bash Blog

![Markdown linting](https://github.com/bewuethr/pandoc-bash-blog/workflows/Markdown%20linting/badge.svg)
![Shell linting and testing](https://github.com/bewuethr/pandoc-bash-blog/workflows/Shell%20linting%20and%20testing/badge.svg)
![Move release tags](https://github.com/bewuethr/pandoc-bash-blog/workflows/Move%20release%20tags/badge.svg)

Pandoc Bash Blog provides `pbb`, a simple generator for static blog sites based
on Pandoc and Bash. Progress is chronicled at
<https://www.benjaminwuethrich.dev>.

## Installation

All manual, currently :confused:

These have to be in place for everything to work:

- The `pbb` script has to be in your `$PATH` somewhere
- The `pbb.css` stylesheet has to be in `/usr/local/include/pbb`
- To enable tab-completion, the file `completion/pbb` has to be sourced on
  startup; the canonical place for it to live is in
  `~/.local/share/bash-completion/completions`, which allows for dynamically
  loading it; the legacy location is in `/etc/bash_completion.d`; or, you could
  copy its contents into `~/.bash_completion`

## Dependencies

These are the versions I use on my development machine; some things break for
older versions.

- Bash 5.0.3
- Pandoc 2.9.1.1
- Git 2.23.0
- GNU coreutils 8.30: `cat`, `cp`, `mkdir`, `ln`, `rm`, `tac`
- GNU sed 4.7
- ImageMagick 6.9.10-23 (for favicon)
- Python 3.7.5 (for `pbb serve`)
- Bats 1.1.0 (for test suite)
- bash-completion 2.9 (for tab completion)

## Usage

Initialize a new blog with title "My blog" in an empty Git repository:

```sh
git init
pbb init 'My blog'
```

If you later want to change the title, use

```sh
pbb title 'My blog with a new title'
```

`pbb init` creates a sample blog post. Blog posts are written in [Pandoc
Markdown], with filenames formatted like `YYYY-MM-DD-post-title.md`.

The first line of a post has to be a level-one heading:

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

```sh
git remote add origin https://github.com/<yourname>/<repo-name>.git
```

  [Pandoc Markdown]: https://pandoc.org/MANUAL.html#pandocs-markdown

### Favicon

To get a favicon, `pbb build` checks the `assets` directory for a file named
`favicon.*` and resizes it to a 32x32 PNG image. If there is no such file, more
than one, or if it is not an image file ImageMagick can handle, `pbb` warns
about this and continues.

### Analytics

Pbb integrates with [GoatCounter], a pretty awesome simple web statistics
solution. Open an account, add your site and set your code with

```sh
pbb gccode <yourcode>
```

Consider paying for a custom domain or making a donation to the author.

  [GoatCounter]: https://www.goatcounter.com

## Subcommands

There are six subcommands (seven, if you count `pbb help`); when properly
installed, they should tab-autocomplete.

### `pbb init 'Title of the blog'`

- Creates new `source` branch and checks it out
- Adds artifacts directory to `.gitignore`
- Creates the `includes`, `images` and `assets` directories
- Symlinks the stylesheet from `/usr/local/include/pbb/pbb.css`
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
