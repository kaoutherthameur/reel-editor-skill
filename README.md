# reel-editor

Claude Code skill that edits talking-head reels (Tunisian Derja) with HyperFrames: voice enhancement, local transcript, captions, SFX, grade, motion kit. Behaviour and workflow live in [SKILL.md](SKILL.md).

## Install

```bash
git clone <this repo> ~/Content-Creator/.claude/skills/reel-editor   # or any project's .claude/skills/
python3 .claude/skills/reel-editor/scripts/setup.py
```

`setup.py` asks, step by step:

1. **Auphonic API key** (voice enhancement) and **HeyGen API key** (SFX search). Typed hidden, stored in `.env` next to the skill (chmod 600, gitignored). Skip either and that feature stays off.
2. **Tunisian Whisper model**: only after you say yes. 3.1 GB weights ([TuniSpeech-AI/whisper-tunisian-dialect](https://huggingface.co/TuniSpeech-AI/whisper-tunisian-dialect), CC-BY-NC-4.0, non-commercial) + a ~1 GB Python venv, under `models/` (gitignored). Needs ~5 GB free RAM when running.

`python3 scripts/setup.py --check` shows what is missing without changing anything.

## Needs
macOS, `ffmpeg`, Python 3.10+, Node, and the HyperFrames skills.

## Not in this repo
API keys, the Whisper weights/venv, the HeyGen download cache, and `references/motion/apple-liquid-glass.mov` (over GitHub's 100 MB limit).
