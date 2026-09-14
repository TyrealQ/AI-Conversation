---
name: intake
description: Add new material to this repository — a resource link, a paper for AI-Ethics, or a notebook or new section — and update README, CHANGELOG, the footer month, and CLAUDE.md together, then run the dashboard checks and commit.
disable-model-invocation: true
---

# Intake

Takes one new item and leaves the repository consistent: the item filed, every
document that references it updated, the dashboard checks clean, and the change
committed and pushed.

The reason this is a skill rather than a single edit is that one addition
touches up to five files, and the ones people forget (the CHANGELOG entry, the
footer month, the PDF count in CLAUDE.md) are exactly the ones the session-start
dashboard complains about later.

Input: `$ARGUMENTS` — a URL, a path to a PDF, a path to a notebook, or a plain
description. If it is empty or you cannot tell which kind it is, ask before
doing anything else.

## Step 1: Identify the kind

| Input | Kind | Goes to |
|-------|------|---------|
| A URL to a video, course, article, tool, book, or dataset | Resource link | A Learning Journey table in `README.md` |
| A path to a `.pdf`, or a paper the user wants stored | Paper | `AI-Ethics/` |
| A path to a `.ipynb`, or a request for a new top-level directory | Notebook or section | A new or existing top-level directory |

## Step 2: Check whether it is already here

What counts as "already here" differs by kind, so run the check that matches.

**For a resource link**, search every markdown file, since the per-directory
READMEs carry links too:

```bash
grep -rn "example.com/path" --include='*.md' .
```

Three outcomes:

- Not found: continue to Step 3.
- Found, and the user did not name a section: stop. Tell them where it already
  appears, quoting the section and subsection, and do not add a second row.
- Found, and the user named a section other than the one it sits in: read this
  as a request to move, not to add. Naming a destination for something already
  listed is how people ask for a relocation. Do not add a second row, because
  the same URL in two sections trips the dashboard's duplicate check and
  confuses a reader. Move the single row, and record it in the CHANGELOG under
  `### Changed` rather than `### Added`. Rewrite the row's description only if
  it does not match the register of its new table, and say that you did.

Watch for near-misses. A bare domain and a deeper path on the same domain are
different pages and neither is a duplicate of the other. A project that has been
renamed is the harder case: the same resource can already be listed under an old
URL that redirects, so if the grep finds nothing, also search for the project
name before concluding it is new.

**For a paper**, the URL check is meaningless; the question is whether the same
work is already filed under a different spelling of its title:

```bash
ls AI-Ethics/*.pdf
```

Compare by author surname and year first, then by title. The folder already
holds two different papers with the same first author and year, so a surname and
year match is a prompt to compare titles, not proof of a duplicate.

**For a notebook or section**, check whether the directory or notebook already
exists before creating anything.

## Step 3: File the item

### Resource link

Read the current taxonomy rather than assuming it, since sections get added:

```bash
grep -n '^### \|^#### ' README.md
```

Choose the `###` section by subject:

- **Programming Fundamentals** — programming, the shell, SQL, developer tooling
- **AI & ML Foundations** — machine learning, NLP, computer vision, the models themselves
- **LLMs & AI Agents** — working with large language models, agents, prompting, context
- **Research Tools & Platforms** — datasets, repositories, and services used to do research
- **Reference Materials** — books, whitepapers, slide decks, YouTube channels
- **Teaching & Learning** — material about teaching with AI or teaching about it

Then choose the `####` subsection by what the reader does with it:

- Enrolls in it, or follows it week by week: **Courses**
- Runs it, installs it, or uses it as a tool: **Platforms & Tools**
- Reads or watches it once: **Guides & Articles**

Say in one sentence which you chose and why. Ask only when the item could
reasonably sit in two different `###` sections, because that is a judgment about
what the collection is for. Do not ask about a `####` choice inside one section;
make it and state it.

Insert a row at the end of that table, matching the column layout of the rows
already in it. Rows go at the end rather than in alphabetical order, because
these tables are ordered by when things were added. Requirements:

- The row begins `| [` — the dashboard counts resources by that pattern, and a
  row written any other way drops out of the tally without any error.
- The URL carries an explicit `https://` scheme. A scheme-less link renders as
  a relative path and returns 404 on GitHub. This has been fixed twice.
- The description is one sentence in the register of the neighboring rows: what
  the resource is and who made it.

### Paper

Read the first page of the PDF to get the authors, year, and exact title.
Download filenames are usually meaningless. `pdftotext -f 1 -l 1 "file.pdf" -`
is the quickest way. For a preprint, use the year printed on the title page.

Copy the PDF into `AI-Ethics/` under the existing convention,
`1 Author et al. Year_Title.pdf`. The leading `1 ` is part of the convention.
Quote the path in every shell command, since these filenames contain spaces.

Always copy, never move, and leave the original where the user had it. Removing
someone's download is a deletion they did not ask for, and the repository
instructions require confirmation before any file move or deletion. Say in your
report that the original is untouched, so they can clean it up themselves.

Then add a row to the `## Papers` table in `AI-Ethics/README.md`, in author
order, which is how that table is sorted. The link is a relative path with
spaces percent-encoded as `%20` and a leading `./`, which is what keeps it out
of the dashboard's scheme-less link alert:

```markdown
| [Exact title](./1%20Author%20et%20al.%20Year_Title.pdf) | Author et al. Year | One sentence on what the paper shows. |
```

Check whether the AI Ethics row in the README Hands-On Portfolio table needs a
new theme in its "Key Features" cell. Add one only if the paper covers ground
none of the existing themes name.

### Notebook or section

For a notebook added to an existing directory, update that directory's
`README.md` and the matching Hands-On Portfolio "Key Features" cell.

For a new top-level directory: create the directory, write its `README.md` in
the shape of the existing per-directory READMEs, add a Hands-On Portfolio row
to `README.md`, and add the directory to the Repository Structure block in
`CLAUDE.md`.

Notebook outputs are committed on purpose, so do not clear them to shrink the
diff. Expect a large diff and say so rather than treating it as a problem.

## Step 4: Update CHANGELOG.md

Add the entry under today's date, using the format already in the file. A
resource link cites the URL it was filed under and the section it went into:

```markdown
## [YYYY-MM-DD]

### Added
- [Title](https://example.com) — one-line description (Section > Subsection)
```

A paper cites a page where the paper can be read, such as its arXiv or
publisher page, and names the folder rather than a Learning Journey section:

```markdown
- [Title](https://arxiv.org/abs/NNNN.NNNNN) — Author et al. Year, one line on what it shows (AI-Ethics)
```

If a block for today's date already exists, add the bullet to it rather than
creating a second block for the same day.

CHANGELOG entries describe material a reader of the repository would notice.
Housekeeping that changes nothing visible (renaming an internal helper, path
cleanup, editing this skill) belongs in the commit message only.

## Step 5: Match the README footer month

The footer line at the bottom of `README.md` reads `Last updated: Month, YYYY`.
It must name the same month as the newest CHANGELOG date, or the dashboard
raises a mismatch alert. Two things to watch: it needs changing only when the
month itself changed, and if you added your entry to an older dated block rather
than today's, the newest date is not yours, so check the top of the file rather
than assuming.

## Step 6: Refresh CLAUDE.md if structure changed

Update the Repository Structure block only when a directory or notebook was
added, removed, or renamed. Update the PDF count in the `AI-Ethics/` line
whenever you file a paper. Adding a resource link changes nothing in CLAUDE.md.

## Step 7: Run the dashboard checks

```bash
.claude/hooks/repo-dashboard.sh </dev/null | jq -r '.hookSpecificOutput.additionalContext'
```

It is read-only. Read the alert lines and fix what it reports before committing.

Two things the alerts will not tell you, so check them yourself:

- The resource-link count it prints should be exactly one higher than before for
  a new link, and unchanged for a move. If it did not move, the row is not in
  the `| [` form and has silently dropped out of the tally.
- For a paper, the PDF count it prints should equal the number of rows in the
  Papers table of `AI-Ethics/README.md`. A mismatch means the intake stopped
  halfway.

If `jq` is missing the pipeline prints nothing rather than failing, so empty
output means check that `jq` is installed before concluding the repository is
clean.

## Step 8: Commit and push

Show the user `git status` and `git diff --stat` so they can see the shape of
the change before it is committed. If nobody is there to respond, note what you
showed and carry on rather than waiting.

Stage the files you touched by name. Do not use `git commit -a` or `git add -A`:
there is often unrelated work in progress in this repository, and sweeping it
into an intake commit mixes two changes that should stay separate. If you see
uncommitted work you did not make, leave it alone and say it is there.

Use a conventional message: `docs:` for content additions, `feat:` for a new
notebook or section, `chore:` for housekeeping.

Then push to `origin main`. If the push is rejected because the remote has moved
ahead, run `git pull --rebase origin main`, re-run the dashboard from Step 7 to
confirm the rebase did not reintroduce a problem, and push again. If it is
rejected a second time, stop and report it rather than forcing anything.
