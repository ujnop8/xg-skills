---
name: pdf-compressor
description: Compress PDF files with Ghostscript from a single file path or a directory path (batch recursive). Use when the user asks to reduce PDF size, optimize document storage, or run one-click compression with a simple quality level input (1 light, 2 balanced, 3 strong), including automatic Ghostscript installation when unavailable.
---

# PDF Compressor

Use this skill to run one-step PDF compression from a file path or a directory path.

## Workflow
1. Ask the user for a path.
2. Ask the user for compression level using only one input:
   - `1` for light (`/printer`)
   - `2` for balanced (`/ebook`, recommended default)
   - `3` for strong (`/screen`)
3. Run:

```bash
bash scripts/compress_pdf.sh "<path>" <level>
```

4. Return the command output summary:
   - output path(s)
   - original size
   - compressed size
   - compression ratio
   - success and failure counts in batch mode

## Behavior Rules
1. Accept either a single PDF file path or a directory path.
2. Process directory input recursively.
3. Keep outputs in the same directory as each source file.
4. Never overwrite source PDFs.
5. Name outputs with a timestamp suffix: `name-YYYYMMDD-HHMMSS.pdf`.
6. If Ghostscript is missing, run auto-install inside the script.
7. In batch mode, continue on per-file failures and report failed files at the end.
8. Skip files that already match the generated compressed filename pattern.

## Script Resource
- Main script: `scripts/compress_pdf.sh`
