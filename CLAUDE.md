# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational repository for the talk "Applied AI in Sport Management" by Tyreal Qian (tyqian@iu.edu). Contains Jupyter notebooks designed for Google Colab, research PDFs, and curated resource lists targeting sport management researchers learning to integrate AI tools. Three companion YouTube tutorials exist: From Chatbots to Agents (Claude Code & agentic workflows), NLP101, and LLM for NLP101.

## Repository Structure

```
Basic-NLP/Basic_NLP.ipynb          — Sentiment analysis, NER, summarization, topic modeling
Basic-Multimodal/Basic_Multimodal.ipynb — Image classification, speech recognition
LLM-Implementation/LLM_Implementation.ipynb — OpenAI API: ABSA, TGL classification, Scholar extraction
AI-Ethics/                         — 8 research PDFs on hallucinations, bias, privacy, trust
README.md                          — Overview → Tutorials → Hands-On Portfolio →
                                     Learning Journey → Contact
                                     (Learning Journey: Programming Fundamentals →
                                     AI & ML Foundations → LLMs & AI Agents →
                                     Research Tools & Platforms → Reference Materials →
                                     Teaching & Learning)
CHANGELOG.md                       — Newest entry first; drives the README footer month
.claude/skills/intake/SKILL.md     — /intake workflow for filing new material
.claude/hooks/repo-dashboard.sh    — SessionStart dashboard (see Repository Conventions)
.claude/settings.json              — wires the SessionStart hook
.claude/settings.local.json        — private permission allowlist (not committed)
```

Each directory has its own README.md describing that section.

## Runtime & Dependencies

**Target environment**: Google Colab (Python 3.11, Linux). Notebooks use `!pip install` inline — no `requirements.txt` or `pyproject.toml` exists.

**No tooling**: there is no build, test, lint, or CI configuration and no `.gitignore`. Nothing runs locally; verification means opening the notebook in Colab.

**Local file references**: Notebooks reference Google Drive paths (`/content/drive/MyDrive/...`) for images, audio files, Excel data, and output files. These paths won't resolve outside Colab with a mounted Drive.

## Code Patterns

### OpenAI API (LLM-Implementation)
- The Colab secret is named `GPT_KEY`; the notebook reads it with `userdata.get('GPT_KEY')`
- GPT-4o used for TGL classification with `temperature=0`, `response_format={"type": "json_object"}`
- GPT-4o-mini used for Scholar extraction with `response_format={"type": "text"}` (then manually strip markdown fences)

## Related Repositories

- [TyrealQ/Experience-is-all-you-need_SMR](https://github.com/TyrealQ/Experience-is-all-you-need_SMR) — ABSA for game day experience (referenced from LLM-Implementation)
- [TyrealQ/Twitter-Perceptions-Esports-2023-Asian-Games_HICSS-58](https://github.com/TyrealQ/Twitter-Perceptions-Esports-2023-Asian-Games_HICSS-58) — BERTopic modeling demo (referenced from Basic-NLP topic modeling section)
- [TyrealQ/q-skills](https://github.com/TyrealQ/q-skills) — Agentic workflows, linked from the Hands-On Portfolio

## Repository Conventions

**Notebook outputs are committed.** `Basic_Multimodal.ipynb` is about 1.5 MB, mostly base64 image output, so notebook diffs are very large. Do not strip outputs to shrink a diff without asking; the rendered outputs are the teaching material.

**README resource links.** Every resource is a table row beginning `| [`; the dashboard counts rows by that pattern, so a link written any other way silently drops out of the tally. Links must carry an explicit `https://` scheme or GitHub renders them as relative paths and they return 404.

**AI-Ethics filenames.** PDFs follow `1 Author et al. Year_Title.pdf`. The leading `1 ` is part of the convention, and the spaces mean the paths need quoting in shell commands.

**Session dashboard**: `.claude/hooks/repo-dashboard.sh` runs at session start and prints repo state (notebook and PDF counts, README link and section tallies, the README footer date, the newest CHANGELOG entry, uncommitted file count, and one line per skill found in `.claude/skills/`). The skill list is discovered at run time, so a new skill appears without editing the script. It is read-only. It also raises alerts for markdown links written without a scheme, the same URL listed twice in README.md, a README footer month that disagrees with the newest CHANGELOG date, and commits not pushed to origin. Add a check by extending `render_alerts` in that script. It needs `jq` and uses the BSD `date -j -f` form, so it works on macOS and degrades silently elsewhere.

**Line endings**: All text files use LF, enforced via `.gitattributes` (`* text=auto eol=lf`). The repo was originally maintained on Windows and migrated to macOS; legacy CRLF endings were normalized in May 2026. When working on Windows, leave Git's `core.autocrlf` unset (or `false`) so `.gitattributes` controls the conversion.

**Adding new material**: use the `/intake` skill, which files the item, updates README, CHANGELOG, and the footer month together, and runs the dashboard checks before committing.
