# Pandoc Bash Blog

![Linting](https://github.com/bewuethr/pandoc-bash-blog/workflows/Linting/badge.svg)

Pandoc Bash Blog provides `pbb`, a simple generator for static blog sites based
on Pandoc and Bash. Progress is chronicled at <https://bewuethr.github.io>.

## Usage

`pbb` expects to be run in the same directory as blog posts written in [Pandoc
Markdown][pandocmd], with filenames formatted like `YYYY-MM-DD-post-title.md`.

[pandocmd]: https://pandoc.org/MANUAL.html#pandocs-markdown

The first line of a file has to be a level-one heading:

```markdown
# A blog post
```

This is then extracted to generate the index file. The index file links to all
files following the naming convention above and lists them in reverse
alphabetical order, with the newest post at the top.

Images must be stored in the `images` directory.

To deploy, the script assumes that it is in a Git repository in a branch other
than `master`; the generated HTML files are pulled into the `master` branch,
committed and then pushed to a remote. This works for GitHub pages deploying
the `master` branch.

### Favicon

To get a favicon, `pbb build` checks the `assets` directory for a file name
`favicon.*` and resizes it to a 32x32 PNG image. If there is no such file, more
than one, or if it is not an image file ImageMagick can handle, `pbb` warns
about this and continues.

## Subcommands

There are four subcommands (five, if you count `pbb help`):

### `pbb init 'Title of the blog'`

- Creates new `source` branch and checks it out
- Add artifacts directory to `.gitignore`
- Creates the `includes`, `images` and `assets` directories
- Creates header files in `includes` that are used on every page, for blog
  title link, favicon Google web font links
- Creates an example post

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
- Deletes everything but the `artifacts` directory
- Copies the contents of `artifacts` into the repository root directory
- Adds, commits and pushes everything to the remote
- Checks out the previous branch
