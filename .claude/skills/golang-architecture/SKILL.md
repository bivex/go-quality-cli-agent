---
name: golang-architecture
description: >
  Go package dependency analysis and call graph visualization using goda, go-callvis,
  go mod graph, and go list. Use when asked to visualize architecture, understand package
  relationships, find circular dependencies, or map call flows in a Go project.
  Equivalent to "und export -dependencies" from SciTools Understand.
allowed-tools: Bash(go *), Bash(goda *), Bash(go-callvis *), Bash(dot *), Read
---

# Go Architecture & Dependency Analysis

This skill handles dependency graphs, call graphs, and package structure analysis — the Go equivalent
of `und export -dependencies` and the Architecture Diagrams view in SciTools Understand.

## Quick Reference

| Und Command | Go Equivalent |
|-------------|--------------|
| `und export -dependencies` | `goda graph ./...` |
| Architecture Diagrams | `go-callvis` (SVG/PNG) |
| Dependency Tree | `go mod graph` |
| `und list files` | `go list ./...` |
| `und list functions` | `go list -json ./...` |

## Tool Installation Check

```bash
# goda — package dependency analyzer
which goda || echo "MISSING: go install github.com/loov/goda@latest"

# go-callvis — call graph visualizer
which go-callvis || echo "MISSING: go install github.com/ofabry/go-callvis@latest"

# dot — graphviz renderer (for PNG/SVG from DOT files)
which dot || echo "MISSING: brew install graphviz  (macOS) / apt install graphviz (Linux)"
```

## Workflow A — Package Dependency Graph

### A1. Text Overview (fast, no rendering)

```bash
# Все зависимости пакетов в проекте (краткий формат)
goda graph -short ./...

# Только прямые зависимости (без транзитивных)
goda graph -nocolor ./... | head -50

# Зависимости конкретного пакета
goda graph github.com/myorg/myproject/cmd/server:...
```

### A2. DOT Export for Visualization

```bash
# Экспорт в DOT (формат Graphviz)
goda graph ./... > deps.dot

# Конвертация в PNG
dot -Tpng deps.dot -o deps.png

# Конвертация в SVG (масштабируемый, лучше для больших проектов)
dot -Tsvg deps.dot -o deps.svg

# Открыть результат
open deps.svg   # macOS
xdg-open deps.svg  # Linux
```

### A3. Find Circular (Cyclic) Dependencies

```bash
# Поиск циклических зависимостей — критично для архитектуры
goda graph ./... | grep -i "cycle" || echo "No cycles detected"

# Более детальный поиск через go list
go list -json ./... | jq -r 'select(.Error != null) | "\(.ImportPath): \(.Error.Err)"'
```

## Workflow B — Call Graph (go-callvis)

### B1. Basic Call Graph

```bash
# Визуализация графа вызовов для main пакета
# Замените 'github.com/myorg/myproject' на ваш модуль из go.mod
MODULE=$(go list -m)
go-callvis -group pkg,dom -file callgraph.svg $MODULE

# Граф для конкретного пакета (не main)
go-callvis -group pkg,dom -focus github.com/myorg/myproject/internal/service -file service-calls.svg $MODULE
```

### B2. Filtered Call Graph

```bash
# Исключить стандартную библиотеку (только проектный код)
go-callvis -nostd -group pkg,dom -file callgraph-noext.svg $MODULE

# Только внутренние пакеты
go-callvis -include "github.com/myorg/myproject" -group pkg -file internal-only.svg $MODULE

# Граф вызовов с группировкой по типу
go-callvis -group type,pkg -file type-graph.svg $MODULE
```

## Workflow C — Module Dependency Tree

```bash
# Встроенный граф зависимостей модулей Go (go.mod уровень)
go mod graph

# С фильтрацией (только прямые зависимости)
go mod graph | grep "^$(go list -m) " | sort

# Граф модулей в DOT (через внешний парсер)
go mod graph | awk '{ print $1 " -> " $2 }' | sort -u | \
  awk 'BEGIN { print "digraph {" } { print "  \"" $1 "\" -> \"" $3 "\"" } END { print "}" }' > modules.dot
dot -Tsvg modules.dot -o modules.svg
```

## Workflow D — Project Inventory (go list)

```bash
# Список всех пакетов в проекте (аналог und list files)
go list ./...

# Подробная информация в JSON (импорты, экспорт, ошибки)
go list -json ./...

# Только пакеты с ошибками компиляции
go list -json -e ./... | jq 'select(.Error != null) | {pkg: .ImportPath, err: .Error.Err}'

# Все внешние зависимости проекта
go list -json ./... | jq -r '.Imports[]' | sort -u | grep -v "^$(go list -m)"

# Статистика по импортам каждого пакета
go list -json ./... | jq '{pkg: .ImportPath, imports: (.Imports | length)}'
```

## Workflow E — Code Documentation (go doc)

```bash
# Документация конкретной функции (аналог und report)
go doc net/http.ListenAndServe

# Полная документация пакета
go doc -all ./internal/service

# Все экспортируемые символы в проекте
go list ./... | xargs -I{} go doc {} 2>/dev/null | grep "^func\|^type\|^var\|^const" | head -100
```

## Reading Architecture Output

When interpreting `goda graph` output:

- `A → B` means package A imports package B
- A node appearing many times as a TARGET is a core/shared package (potential bottleneck)
- A node appearing many times as a SOURCE is a high-coupling package (consider refactoring)
- Cycles (`A → B → A`) are architectural violations in Go — they prevent clean layering

Key architectural questions to answer:
1. Are there cycles? (`goda graph | grep cycle`)
2. Which packages have the most dependents? (high coupling)
3. Are internal packages properly isolated from cmd packages?
4. Does the dependency flow respect layering (cmd → internal → pkg)?

## Supporting Files

- See [examples/architecture-analysis.sh](examples/architecture-analysis.sh) for a complete analysis script.
