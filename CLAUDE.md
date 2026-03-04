# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Educational repository for the talk "Applied AI in Sport Management" by Tyreal Qian (LSU, yqian@lsu.edu). Contains Jupyter notebooks designed for Google Colab, research PDFs, and curated resource lists targeting sport management researchers learning to integrate AI tools. Three companion YouTube tutorials exist: From Chatbots to Agents (Claude Code & agentic workflows), NLP101, and LLM for NLP101.

## Repository Structure

```
Basic-NLP/Basic_NLP.ipynb          — Sentiment analysis, NER, summarization, topic modeling
Basic-Multimodal/Basic_Multimodal.ipynb — Image classification, speech recognition
LLM-Implementation/LLM_Implementation.ipynb — OpenAI API: ABSA, TGL classification, Scholar extraction
AI-Ethics/                         — 8 research PDFs on hallucinations, bias, privacy, trust
Resources/README.md                — Curated links organized by learning journey:
                                     Programming Fundamentals → AI & ML Foundations →
                                     LLMs & AI Agents → Research Tools → Reference Materials →
                                     Teaching & Learning
```

Each directory has its own README.md describing that section.

## Runtime & Dependencies

**Target environment**: Google Colab (Python 3.11, Linux). Notebooks use `!pip install` inline — no `requirements.txt` or `pyproject.toml` exists.

**Core dependencies by notebook**:
- Basic-NLP: `transformers`, `datasets`, `scikit-learn`, `vaderSentiment`, `tqdm`
- Basic-Multimodal: `transformers`, `PIL`, `pandas`, `requests`
- LLM-Implementation: `openai`, `datasets`, `tqdm`, `pandas`, `ipywidgets`

**Local file references**: Notebooks reference Google Drive paths (`/content/drive/MyDrive/...`) for images, audio files, Excel data, and output files. These paths won't resolve outside Colab with a mounted Drive.

## Code Patterns

### Hugging Face Pipeline API
All Basic-NLP and Basic-Multimodal tasks use `transformers.pipeline()` with pre-trained models:
- Sentiment: `cardiffnlp/twitter-roberta-base-sentiment-latest`, `clapAI/modernBERT-base-multilingual-sentiment`
- NER: `xlm-roberta-large-finetuned-conll03-english` with `aggregation_strategy="simple"`
- Summarization: `google/pegasus-xsum` with beam search (`num_beams=4`)
- Image classification: `nateraw/baseball-stadium-foods`
- Speech recognition: `openai/whisper-large-v3-turbo` with `return_timestamps=True`

### OpenAI API (LLM-Implementation)
- Client initialized via `OpenAI(api_key=userdata.get('GPT_KEY'))` from Colab secrets
- GPT-4o used for TGL classification with `temperature=0`, `response_format={"type": "json_object"}`
- GPT-4o-mini used for Scholar extraction with `response_format={"type": "text"}` (then manually strip markdown fences)
- VADER used as a lexicon-based baseline alongside transformer models

### Evaluation Pattern (Basic-NLP)
- Dataset: `tyrealqian/Stadium_RoBERTa_eval` — 500 college football stadium reviews, labels 0/1/2 (negative/neutral/positive)
- Metrics via `sklearn.metrics`: accuracy, precision, recall, F1 (weighted average)
- Batch processing with `tqdm` progress bars

### ScholarAnalyzer Class (LLM-Implementation)
- Interactive widget-based input (`ipywidgets.Textarea`)
- Extracts publication metadata via GPT-4o-mini → JSON
- Matches against ABDC journal rankings loaded from a local markdown table
- Outputs ranked analysis to markdown file

## Hugging Face Datasets

- `tyrealqian/Stadium_RoBERTa_eval` — 500-sample test set (stadium reviews with sentiment labels)
- `tyrealqian/TGL_content_classification` — YouTube video metadata for TGL relevance classification

## Related Repositories

- [TyrealQ/Experience-is-all-you-need_SMR](https://github.com/TyrealQ/Experience-is-all-you-need_SMR) — ABSA for game day experience (referenced from LLM-Implementation)
- [TyrealQ/Twitter-Perceptions-Esports-2023-Asian-Games_HICSS-58](https://github.com/TyrealQ/Twitter-Perceptions-Esports-2023-Asian-Games_HICSS-58) — BERTopic modeling demo (referenced from Basic-NLP topic modeling section)

## Planned Extensions

Noted in notebook cells as "Next" steps:
- Fine-tune a text classification model (Basic-NLP)
- Develop a custom multi-agent system (LLM-Implementation)
