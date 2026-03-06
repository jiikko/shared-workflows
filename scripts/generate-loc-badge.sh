#!/usr/bin/env bash
# Generate Lines-of-Code SVG badge using cloc
# Usage: ./scripts/generate-loc-badge.sh [source_dir] [output_path]
set -euo pipefail

SRC_DIR="${1:-src}"
OUTPUT="${2:-docs/loc-badge.svg}"
mkdir -p "$(dirname "$OUTPUT")"

# Count lines with cloc (code only, excludes comments and blanks)
CLOC_JSON=$(cloc "$SRC_DIR" --json --quiet 2>/dev/null)
TOTAL=$(echo "$CLOC_JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['SUM']['code'])")

# Format with comma separator
FORMATTED=$(printf "%'d" "$TOTAL")

# Badge dimensions
LABEL="lines of code"
LABEL_WIDTH=80
VALUE_WIDTH=$((${#FORMATTED} * 7 + 16))
TOTAL_WIDTH=$((LABEL_WIDTH + VALUE_WIDTH))

cat > "$OUTPUT" << SVGEOF
<svg xmlns="http://www.w3.org/2000/svg" width="${TOTAL_WIDTH}" height="20" role="img" aria-label="${LABEL}: ${FORMATTED}">
  <title>${LABEL}: ${FORMATTED}</title>
  <linearGradient id="s" x2="0" y2="100%">
    <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
    <stop offset="1" stop-opacity=".1"/>
  </linearGradient>
  <clipPath id="r"><rect width="${TOTAL_WIDTH}" height="20" rx="3" fill="#fff"/></clipPath>
  <g clip-path="url(#r)">
    <rect width="${LABEL_WIDTH}" height="20" fill="#555"/>
    <rect x="${LABEL_WIDTH}" width="${VALUE_WIDTH}" height="20" fill="#007ec6"/>
    <rect width="${TOTAL_WIDTH}" height="20" fill="url(#s)"/>
  </g>
  <g fill="#fff" text-anchor="middle" font-family="Verdana,Geneva,DejaVu Sans,sans-serif" text-rendering="geometricPrecision" font-size="11">
    <text aria-hidden="true" x="$((LABEL_WIDTH / 2))" y="15" fill="#010101" fill-opacity=".3">${LABEL}</text>
    <text x="$((LABEL_WIDTH / 2))" y="14">${LABEL}</text>
    <text aria-hidden="true" x="$((LABEL_WIDTH + VALUE_WIDTH / 2))" y="15" fill="#010101" fill-opacity=".3">${FORMATTED}</text>
    <text x="$((LABEL_WIDTH + VALUE_WIDTH / 2))" y="14">${FORMATTED}</text>
  </g>
</svg>
SVGEOF

echo "Badge generated: ${OUTPUT} (${FORMATTED} lines)"
