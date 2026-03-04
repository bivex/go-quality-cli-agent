# go-quality-cli-agent

Three specialized [Claude Code](https://code.claude.com) subagents for Go (Golang) code analysis — the CLI alternative to SciTools Understand for Go projects.

No CI/CD setup. No SaaS dashboards. Pure terminal.

---

## Agents

### `golang-compliance` — Code Quality & Linting

> *"Check my code quality"* / *"Run linters"* / *"Find bugs"*

Equivalent to `und codecheck`. Runs `golangci-lint`, `staticcheck`, `go vet`, `revive` and triages findings by severity.

```bash
# What it runs by default:
go mod verify && go build ./... && go vet ./... && golangci-lint run ./... && staticcheck ./...
```

**Tools:** `golangci-lint` · `staticcheck` · `go vet` · `revive` · `errcheck`

---

### `golang-architecture` — Dependencies & Architecture

> *"Show me the dependency tree"* / *"Find circular imports"* / *"Visualize architecture"*

Equivalent to `und export -dependencies`. Maps package relationships, detects cycles, measures dependency weight.

```bash
# Human-readable terminal output:
goda list ./...:all      # flat list of all deps
goda tree ./...:all      # dependency tree in terminal
goda cut  ./...:all      # heaviest packages by binary weight

# SVG only when explicitly needed:
goda graph ./... | dot -Tsvg > deps.svg
```

**Tools:** `goda` · `go-callvis` · `go list` · `go mod graph` · `graphviz`

---

### `golang-metrics` — Complexity & Code Size

> *"How complex is this?"* / *"Find the hardest functions to read"* / *"Lines of code breakdown"*

Equivalent to `und metrics`. Measures cyclomatic and cognitive complexity, counts LOC, ranks refactoring candidates.

```bash
gocognit -top 10 ./...   # top 10 hardest-to-read functions
gocyclo  -top 10 ./...   # top 10 structurally complex functions
gocloc ./                # lines of code breakdown
```

| Metric | Attention | Must Refactor |
|--------|-----------|--------------|
| Cyclomatic (gocyclo) | > 15 | > 20 |
| Cognitive (gocognit) | > 15 | > 25 |
| File LOC | > 500 | > 1000 |

**Tools:** `gocyclo` · `gocognit` · `gocloc`

---

### `golang-profiling` — Performance Profiling

> *"Why is this slow?"* / *"Find memory leaks"* / *"Run benchmarks"* / *"Compare performance"*

Covers the full pprof toolchain: CPU profiling, memory profiling, goroutine analysis, execution tracing, and statistical benchmark comparison.

```bash
# Benchmarks with allocation stats
go test -bench=. -benchmem -count=5 ./...

# CPU hotspots
go test -bench=. -cpuprofile=cpu.out ./pkg/...
go tool pprof -top cpu.out

# Memory allocations
go test -bench=. -memprofile=mem.out ./pkg/...
go tool pprof -alloc_objects -top mem.out

# Compare before/after
benchstat bench-before.txt bench-after.txt

# Live service profiling
go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
```

**Tools:** `go test -bench` · `go tool pprof` · `go tool trace` · `benchstat`

---

## SciTools Understand → Go CLI mapping

| `und` command | Agent | Go CLI |
|---|---|---|
| `und analyze` | compliance | `go build ./...` + `golangci-lint run` |
| `und codecheck` | compliance | `golangci-lint run` / `staticcheck ./...` |
| `und metrics` | metrics | `gocyclo`, `gocognit`, `gocloc` |
| `und export -dependencies` | architecture | `goda list/tree/cut ./...:all` |
| `und list` | architecture | `go list ./...` / `go list -json ./...` |
| Performance analysis | **profiling** | `go tool pprof`, `go test -bench`, `benchstat` |

---

## Installation

```bash
# Compliance
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install github.com/mgechev/revive@latest

# Metrics
go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
go install github.com/uudashr/gocognit/cmd/gocognit@latest
go install github.com/hhatto/gocloc/cmd/gocloc@latest

# Architecture
go install github.com/loov/goda@latest
go install github.com/ofabry/go-callvis@latest
brew install graphviz   # macOS — for SVG rendering only

# Profiling
go install golang.org/x/perf/cmd/benchstat@latest
```

## Usage

Copy `.claude/` into any Go project, or install user-level at `~/.claude/agents/`.  
Claude Code picks the right agent automatically based on your request.

```
# Direct invocation:
/golang-compliance
/golang-architecture
/golang-metrics
/golang-profiling
```
