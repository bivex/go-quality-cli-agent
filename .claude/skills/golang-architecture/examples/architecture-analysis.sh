#!/bin/bash
# architecture-analysis.sh
# Полный анализ архитектуры Go-проекта (аналог und export -dependencies)
# Запуск: bash architecture-analysis.sh [optional-module-path]
# Требования: goda, go-callvis, graphviz (dot)

set -e

MODULE=${1:-$(go list -m 2>/dev/null || echo "")}
if [ -z "$MODULE" ]; then
  echo "ERROR: could not determine Go module name. Run from project root or pass module path."
  exit 1
fi

echo "=============================="
echo "  ARCHITECTURE ANALYSIS"
echo "  Module: $MODULE"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "=============================="

# --- Tool checks ---
MISSING=0
for tool in goda go-callvis dot; do
  if ! which "$tool" > /dev/null 2>&1; then
    echo "WARNING: $tool not found"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo ""
  echo "Install missing tools:"
  echo "  go install github.com/loov/goda@latest"
  echo "  go install github.com/ofabry/go-callvis@latest"
  echo "  brew install graphviz  # macOS"
  echo ""
fi

echo ""
echo "--- 1. PACKAGE LIST ---"
go list ./... | sort

echo ""
echo "--- 2. DEPENDENCY GRAPH (text) ---"
if which goda > /dev/null 2>&1; then
  goda graph -short ./...
else
  echo "(goda not installed — run: go install github.com/loov/goda@latest)"
fi

echo ""
echo "--- 3. CYCLE CHECK ---"
if which goda > /dev/null 2>&1; then
  CYCLES=$(goda graph ./... 2>&1 | grep -i cycle || true)
  if [ -z "$CYCLES" ]; then
    echo "✓ No circular dependencies detected"
  else
    echo "⚠ CYCLES FOUND:"
    echo "$CYCLES"
  fi
fi

echo ""
echo "--- 4. EXTERNAL DEPENDENCIES ---"
go list -json ./... | \
  python3 -c "
import json, sys
deps = set()
for line in sys.stdin:
    try:
        data = json.loads(line)
        for imp in data.get('Imports', []):
            if not imp.startswith('$(go list -m)') and '.' in imp:
                deps.add(imp.split('/')[0] + '/' + imp.split('/')[1] if '/' in imp else imp)
    except: pass
for d in sorted(deps): print(d)
" 2>/dev/null || go list -json ./... | grep -o '"[a-z][a-z0-9_.-]*/[a-z][^"]*"' | sort -u | head -30

echo ""
echo "--- 5. VISUALIZATIONS ---"
if which goda > /dev/null 2>&1 && which dot > /dev/null 2>&1; then
  goda graph ./... > /tmp/deps.dot 2>/dev/null
  dot -Tsvg /tmp/deps.dot -o deps.svg 2>/dev/null && echo "✓ deps.svg generated" || echo "dot rendering failed"
fi

if which go-callvis > /dev/null 2>&1; then
  go-callvis -nostd -group pkg,dom -file callgraph.svg "$MODULE" 2>/dev/null && \
    echo "✓ callgraph.svg generated" || \
    echo "go-callvis: could not generate graph (ensure project builds cleanly)"
fi

echo ""
echo "=============================="
echo "  ANALYSIS COMPLETE"
echo "=============================="
