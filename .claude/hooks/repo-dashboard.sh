#!/usr/bin/env bash
# SessionStart dashboard for the Applied AI in Sport Management repo.
# Prints repo state and the link-hygiene checks this repo keeps drifting on.
# Read-only: touches no tracked file.
# Wired from .claude/settings.json -> hooks.SessionStart.

set -uo pipefail
REPO="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$REPO" 2>/dev/null || exit 0

today=$(date +%Y-%m-%d)
days_since() {  # YYYY-MM-DD -> whole days before today, or empty
  [ -n "${1:-}" ] || return 0
  local then now
  then=$(date -j -f "%Y-%m-%d" "$1" "+%s" 2>/dev/null) || return 0
  now=$(date -j -f "%Y-%m-%d" "$today" "+%s" 2>/dev/null) || return 0
  echo $(( (now - then) / 86400 ))
}

# --- portfolio contents -------------------------------------------------
notebooks=$(find . -name '*.ipynb' -not -path './.git/*' | wc -l | tr -d ' ')
pdfs=$(find AI-Ethics -maxdepth 1 -name '*.pdf' 2>/dev/null | wc -l | tr -d ' ')
section_readmes=$(find . -mindepth 2 -maxdepth 2 -name 'README.md' -not -path './.git/*' | wc -l | tr -d ' ')

# --- README: the resource tables are the substance of this repo ---------
tutorials=$(grep -c 'img.youtube.com/vi/' README.md 2>/dev/null | tr -d ' ')
links=$(grep -c '^| \[' README.md 2>/dev/null | tr -d ' ')
sections=$(awk '/^## Learning Journey/{f=1;next} /^## /{f=0} f&&/^### /{n++} END{print n+0}' README.md 2>/dev/null)
footer=$(grep -m1 -oE 'Last updated: .*' README.md 2>/dev/null | sed 's/Last updated: //')

# --- changelog ----------------------------------------------------------
log_date=$(grep -m1 -oE '^## \[[0-9]{4}-[0-9]{2}-[0-9]{2}\]' CHANGELOG.md 2>/dev/null | tr -d '#[] ')
log_age=$(days_since "$log_date")
log_entry=$(awk '/^## \[/{n++} n==1&&/^- /{print substr($0,3); exit}' CHANGELOG.md 2>/dev/null \
            | sed -E 's/\[([^]]*)\]\([^)]*\)/\1/g' \
            | awk '{print (length($0)>72) ? substr($0,1,71) "\xe2\x80\xa6" : $0}')

# --- git ----------------------------------------------------------------
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
unpushed=$(git log @{upstream}..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')

# --- link hygiene -------------------------------------------------------
# Every URL that appears in a markdown link, one per line.
urls_of() { grep -hoE '\]\([^)]+\)' "$@" 2>/dev/null | sed 's/^](//; s/)$//' | grep -v '^#'; }
join_list() { sort -u | awk '{printf "%s%s", sep, $0; sep=", "}'; }

all_urls=$(urls_of $(find . -name '*.md' -not -path './.git/*'))

# A link written as "apxml.com/tools" renders as a relative path on GitHub and
# silently 404s; only a scheme (or a genuine in-repo path) is safe.
noscheme=$(printf '%s\n' "$all_urls" \
           | grep -vE '^(https?://|mailto:|\./|\.\./|/)' | grep -v '^$' \
           | join_list | cut -c1-160)

# The same resource added twice under different section headings. Only the
# README is checked: the changelog restates README links by design.
dupes=$(urls_of README.md | grep -E '^https?://' | sort | uniq -d \
        | sed 's|https\?://||' | join_list | cut -c1-160)

# The README footer is hand-edited and drifts from the newest changelog entry.
month_mismatch=""
if [ -n "$log_date" ] && [ -n "$footer" ]; then
  expected=$(date -j -f "%Y-%m-%d" "$log_date" "+%B, %Y" 2>/dev/null)
  [ -n "$expected" ] && [ "$expected" != "$footer" ] && \
    month_mismatch="README footer reads \"$footer\", newest changelog entry is $log_date"
fi

# --- alerts -------------------------------------------------------------
# One "  ! <message>" line per condition worth interrupting the user at
# session start. Silent when the repo is in good shape.
render_alerts() {
  [ -n "$noscheme" ]       && echo "  ! link(s) with no scheme, will 404 on GitHub: ${noscheme}"
  [ -n "$dupes" ]          && echo "  ! duplicate link(s): ${dupes}"
  [ -n "$month_mismatch" ] && echo "  ! ${month_mismatch}"
  [ "${unpushed:-0}" -gt 0 ] && echo "  ! ${unpushed} commit(s) not pushed to origin"
  return 0
}

# --- render -------------------------------------------------------------
{
  echo "Applied AI in Sport Management${branch:+ · $branch}"
  echo "  Portfolio: ${notebooks} notebooks · ${pdfs} ethics PDFs · ${section_readmes} section READMEs"
  echo "  README: ${tutorials} tutorials · ${links} resource links across ${sections} Learning Journey sections"
  [ -n "$footer" ] && echo "  README footer: ${footer}"
  [ -n "$log_date" ] && echo "  Last changelog: ${log_date}${log_age:+ (${log_age}d ago)}${log_entry:+ — ${log_entry}}"
  [ "$dirty" -gt 0 ] && echo "  Uncommitted: ${dirty} file(s)"
  alerts=$(render_alerts)
  [ -n "$alerts" ] && printf '%s\n' "$alerts"
} > /tmp/.repo-dashboard.$$ 2>/dev/null

board=$(cat /tmp/.repo-dashboard.$$); rm -f /tmp/.repo-dashboard.$$
printf '%s' "$board" | jq -Rs '{
  systemMessage: .,
  hookSpecificOutput: { hookEventName: "SessionStart", additionalContext: . }
}'
