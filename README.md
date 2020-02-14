# Pandoc Bash Blog

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

To deploy, the script assumes that it is in a Git repository in a branch other
than `master`; the generated HTML files are pulled into the `master` branch,
committed and then pushed to a remote. This works for GitHub pages deploying
the `master` branch.

## Subcommands

There are three subcommands:

### `pbb init`

- Creates new `source` branch and checks it out
- Add artifacts directory to `.gitignore`
- Prompts for the blog title
- Creates the `includes` and `images` directories
- Creates a header file with the blog title in `includes` which is used on
  every page
- Creates an example post

### `pbb build`

- Cleans the `artifacts` directory, then copies the `images` directory in there
- Generates the index file, `index.md`
- Converts the markdown files with datestamps in their names and `index.md` to
  HTML, copies the results into `artifacts`

### `pbb deploy`

- Checks out the `master` branch
- Deletes everything but the `artifacts` directory
- Copies the contents of `artifacts` into the repository root directory
- Adds, commits and pushes everything to the remote
- Checks out the previous branch
