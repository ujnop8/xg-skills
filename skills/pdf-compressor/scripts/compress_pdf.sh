#!/usr/bin/env bash

set -u

usage() {
  echo "Usage: $0 <pdf-file-or-directory> <level>"
  echo "  level: 1 (light), 2 (balanced), 3 (strong)"
}

log() {
  echo "[pdf-compressor] $*"
}

err() {
  echo "[pdf-compressor][error] $*" >&2
}

get_size_bytes() {
  local path="$1"
  if [[ "$(uname -s)" == "Darwin" ]]; then
    stat -f%z "$path"
  else
    stat -c%s "$path"
  fi
}

format_bytes() {
  local bytes="$1"
  awk -v b="$bytes" 'BEGIN {
    split("B KB MB GB TB", units, " ");
    i=1;
    while (b >= 1024 && i < 5) {
      b = b / 1024;
      i++;
    }
    printf("%.2f %s", b, units[i]);
  }'
}

install_ghostscript() {
  if command -v gs >/dev/null 2>&1; then
    return 0
  fi

  log "Ghostscript not found. Trying automatic installation."

  case "$(uname -s)" in
    Darwin)
      if ! command -v brew >/dev/null 2>&1; then
        err "Homebrew is required on macOS for auto-install."
        return 1
      fi
      brew install ghostscript || return 1
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y ghostscript || return 1
      elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y ghostscript || return 1
      elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y ghostscript || return 1
      elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm ghostscript || return 1
      else
        err "Unsupported Linux package manager. Install Ghostscript manually."
        return 1
      fi
      ;;
    *)
      err "Unsupported OS for auto-install. Install Ghostscript manually."
      return 1
      ;;
  esac

  if ! command -v gs >/dev/null 2>&1; then
    err "Ghostscript installation finished but 'gs' is still unavailable."
    return 1
  fi

  log "Ghostscript installation succeeded."
  return 0
}

compress_setting_from_level() {
  local level="$1"
  case "$level" in
    1) echo "/printer" ;;
    2) echo "/ebook" ;;
    3) echo "/screen" ;;
    *)
      return 1
      ;;
  esac
}

is_generated_file() {
  local filename="$1"
  local lower
  lower=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
  if [[ "$lower" =~ -[0-9]{8}-[0-9]{6}(-[0-9]{4})?\.pdf$ ]]; then
    return 0
  fi
  return 1
}

build_output_path() {
  local input_pdf="$1"
  local dir base stem ts candidate suffix

  dir=$(dirname "$input_pdf")
  base=$(basename "$input_pdf")
  stem="${base%.*}"
  ts=$(date +"%Y%m%d-%H%M%S")
  candidate="$dir/$stem-$ts.pdf"

  while [[ -e "$candidate" ]]; do
    suffix=$(printf "%04d" $((RANDOM % 10000)))
    candidate="$dir/$stem-$ts-$suffix.pdf"
  done

  echo "$candidate"
}

compress_one() {
  local input_pdf="$1"
  local setting="$2"
  local output_pdf before after ratio

  output_pdf=$(build_output_path "$input_pdf")
  before=$(get_size_bytes "$input_pdf")

  if ! gs -sDEVICE=pdfwrite \
    -dCompatibilityLevel=1.4 \
    -dPDFSETTINGS="$setting" \
    -dNOPAUSE -dQUIET -dBATCH \
    -sOutputFile="$output_pdf" \
    "$input_pdf"; then
    err "Failed: $input_pdf"
    return 1
  fi

  after=$(get_size_bytes "$output_pdf")
  if [[ "$before" -eq 0 ]]; then
    ratio="0.00"
  else
    ratio=$(awk -v a="$after" -v b="$before" 'BEGIN { printf("%.2f", (1 - a/b) * 100) }')
  fi

  echo "INPUT=$input_pdf"
  echo "OUTPUT=$output_pdf"
  echo "ORIGINAL=$before"
  echo "COMPRESSED=$after"
  echo "RATIO=$ratio"
  return 0
}

if [[ $# -ne 2 ]]; then
  usage
  exit 1
fi

target_path="$1"
level="$2"

if [[ ! -e "$target_path" ]]; then
  err "Path does not exist: $target_path"
  exit 1
fi

setting=$(compress_setting_from_level "$level") || {
  err "Invalid level: $level. Use 1, 2, or 3."
  usage
  exit 1
}

install_ghostscript || {
  err "Cannot continue without Ghostscript."
  exit 1
}

total_before=0
total_after=0
success_count=0
failure_count=0
failed_files=()

run_and_record() {
  local file="$1"
  local result

  result=$(compress_one "$file" "$setting") || {
    failure_count=$((failure_count + 1))
    failed_files+=("$file")
    return 1
  }

  local in out before after ratio
  in=$(echo "$result" | awk -F= '/^INPUT=/{print $2}')
  out=$(echo "$result" | awk -F= '/^OUTPUT=/{print $2}')
  before=$(echo "$result" | awk -F= '/^ORIGINAL=/{print $2}')
  after=$(echo "$result" | awk -F= '/^COMPRESSED=/{print $2}')
  ratio=$(echo "$result" | awk -F= '/^RATIO=/{print $2}')

  total_before=$((total_before + before))
  total_after=$((total_after + after))
  success_count=$((success_count + 1))

  log "Compressed: $in"
  log "  -> $out"
  log "  Size: $(format_bytes "$before") -> $(format_bytes "$after") (${ratio}% reduction)"
  return 0
}

if [[ -f "$target_path" ]]; then
  lower_file=$(echo "$target_path" | tr '[:upper:]' '[:lower:]')
  if [[ ! "$lower_file" =~ \.pdf$ ]]; then
    err "Input file is not a PDF: $target_path"
    exit 1
  fi
  run_and_record "$target_path" || true
elif [[ -d "$target_path" ]]; then
  found_any=0
  while IFS= read -r -d '' pdf_file; do
    found_any=1
    if is_generated_file "$(basename "$pdf_file")"; then
      log "Skip generated file: $pdf_file"
      continue
    fi
    run_and_record "$pdf_file" || true
  done < <(find "$target_path" -type f \( -iname "*.pdf" \) -print0)

  if [[ "$found_any" -eq 0 ]]; then
    err "No PDF files found in directory: $target_path"
    exit 1
  fi
else
  err "Path is neither a file nor a directory: $target_path"
  exit 1
fi

if [[ "$success_count" -gt 0 && "$total_before" -gt 0 ]]; then
  total_ratio=$(awk -v a="$total_after" -v b="$total_before" 'BEGIN { printf("%.2f", (1 - a/b) * 100) }')
else
  total_ratio="0.00"
fi

log "Summary"
log "  Success: $success_count"
log "  Failed: $failure_count"
if [[ "$success_count" -gt 0 ]]; then
  log "  Total size: $(format_bytes "$total_before") -> $(format_bytes "$total_after") (${total_ratio}% reduction)"
fi

if [[ "$failure_count" -gt 0 ]]; then
  log "Failed files:"
  for f in "${failed_files[@]}"; do
    log "  - $f"
  done
fi

if [[ "$success_count" -eq 0 ]]; then
  exit 1
fi

exit 0
