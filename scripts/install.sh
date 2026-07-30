#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
skill=
dest=
dry_run=0
force=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --skill) skill=$2; shift 2 ;;
    --dest) dest=$2; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    --force) force=1; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

case "$skill" in
  generate-wiki) selected_skills="generate-wiki spec-to-wiki code-to-wiki" ;;
  spec-to-wiki|code-to-wiki) selected_skills=$skill ;;
  *) echo "Unknown or missing --skill" >&2; exit 2 ;;
esac
test -n "$dest" || { echo "Missing --dest" >&2; exit 2; }

metadata_dir=$(mktemp -d)
trap 'rm -rf "$metadata_dir"' EXIT
revision=$(git -C "$ROOT" rev-parse HEAD 2>/dev/null || printf 'unknown')

sources=()
outputs=()
labels=()
owners=()
relatives=()

checksum() {
  cksum "$1" | awk '{ print $1 ":" $2 }'
}

for selected in $selected_skills; do
  source_dir="$ROOT/skills/$selected"
  test -f "$source_dir/SKILL.md" || {
    echo "Missing source skill: $selected" >&2
    exit 1
  }
  echo "INSTALL $selected"

  while IFS= read -r source_file; do
    relative=${source_file#"$source_dir/"}
    sources+=("$source_file")
    outputs+=("$dest/$selected/$relative")
    labels+=("$selected/$relative")
    owners+=("$selected")
    relatives+=("$relative")
  done < <(find "$source_dir" -type f ! -name install-manifest.txt | sort)

  while IFS= read -r shared_path; do
    case "$shared_path" in ''|\#*) continue ;; esac
    test -f "$ROOT/$shared_path" || {
      echo "Missing shared source: $shared_path" >&2
      exit 1
    }
    relative=${shared_path#shared/}
    sources+=("$ROOT/$shared_path")
    outputs+=("$dest/$selected/shared/$relative")
    labels+=("$selected/shared/$relative")
    owners+=("$selected")
    relatives+=("shared/$relative")
  done < "$source_dir/install-manifest.txt"

  metadata="$metadata_dir/$selected"
  {
    echo "generated-install: true"
    echo "canonical-source: shared/"
    echo "repository-revision: $revision"
    for index in "${!sources[@]}"; do
      if [ "${owners[$index]:-}" = "$selected" ]; then
        value=$(checksum "${sources[$index]}")
        checksum_value=${value%%:*}
        size_value=${value#*:}
        echo "file-checksum: $checksum_value $size_value ${relatives[$index]}"
      fi
    done
  } > "$metadata"
  sources+=("$metadata")
  outputs+=("$dest/$selected/.wiki-skill-install")
  labels+=("$selected/.wiki-skill-install")
  owners+=("$selected")
  relatives+=(".wiki-skill-install")
done

for index in "${!sources[@]}"; do
  source_file=${sources[$index]}
  output_file=${outputs[$index]}
  relative=${relatives[$index]}
  if [ "$relative" = ".wiki-skill-install" ]; then
    continue
  fi
  if [ -e "$output_file" ] && ! cmp -s "$source_file" "$output_file" && [ "$force" -ne 1 ]; then
    prior_metadata="$dest/${owners[$index]}/.wiki-skill-install"
    expected=
    if [ -f "$prior_metadata" ]; then
      expected=$(awk -v wanted="$relative" \
        '$1 == "file-checksum:" && $4 == wanted { print $2 ":" $3 }' \
        "$prior_metadata")
    fi
    actual=$(checksum "$output_file")
    if [ -z "$expected" ] || [ "$actual" != "$expected" ]; then
      echo "REFUSE modified file: $output_file" >&2
      exit 1
    fi
  fi
done

for index in "${!sources[@]}"; do
  source_file=${sources[$index]}
  output_file=${outputs[$index]}
  echo "COPY ${labels[$index]} -> $output_file"
  [ "$dry_run" -eq 1 ] && continue
  mkdir -p "$(dirname "$output_file")"
  cp "$source_file" "$output_file"
  if [ -x "$source_file" ]; then
    chmod +x "$output_file"
  fi
done
