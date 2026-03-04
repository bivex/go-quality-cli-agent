# go-quality-cli-agent

Ten specialized [Claude Code](https://code.claude.com) subagents for Go (Golang) code analysis, testing, security, and project structure — the CLI alternative to SciTools Understand and heavy CI/CD pipelines for Go projects.

No CI/CD setup. No SaaS dashboards. Pure terminal.

---

## Agents

### `golang-compliance` — Code Quality & Linting
> *"Check my code quality"* / *"Run linters"* / *"Find bugs"*

Runs `golangci-lint`, `staticcheck`, `go vet`, `revive` and triages findings by severity.
**Tools:** `golangci-lint` · `staticcheck` · `go vet` · `revive` · `errcheck`

### `golang-architecture` — Dependencies & Architecture
> *"Show me the dependency tree"* / *"Find circular imports"* / *"Visualize architecture"*

Maps package relationships, detects cycles, measures dependency weight.
**Tools:** `goda` · `go-callvis` · `go list` · `go mod graph` · `graphviz`

### `golang-metrics` — Complexity & Code Size
> *"How complex is this?"* / *"Find the hardest functions to read"* / *"Lines of code breakdown"*

Measures cyclomatic and cognitive complexity, counts LOC, ranks refactoring candidates.
**Tools:** `gocyclo` · `gocognit` · `gocloc`

### `golang-profiling` — Performance Profiling
> *"Why is this slow?"* / *"Find memory leaks"* / *"Run benchmarks"* / *"Compare performance"*

Covers the full pprof toolchain: CPU profiling, memory profiling, goroutine analysis, execution tracing, and statistical benchmark comparison.
**Tools:** `go test -bench` · `go tool pprof` · `go tool trace` · `benchstat`

### `golang-concurrency` — Concurrency Safety
> *"Check for data races"* / *"Find goroutine leaks"* / *"Check context usage"*

Enforces context propagation rules, goroutine lifecycle, channel patterns, and race detector usage.
**Tools:** `go test -race` · `go vet` · `golangci-lint`

### `golang-error-handling` — Error Patterns
> *"Check error wrapping"* / *"Find panics"* / *"Are errors handled correctly?"*

Enforces `%w` wrapping, `errors.Is/As`, sentinel error patterns, and forbids `panic` in production code.
**Tools:** `golangci-lint` (`errorlint`, `wrapcheck`) · `grep`

### `golang-testing` — Testing Standards
> *"Run tests"* / *"Check coverage"* / *"Generate mocks"*

Enforces table-driven tests, `t.Helper()`, test coverage thresholds, and `testify`/`mockgen` patterns.
**Tools:** `go test` · `go tool cover` · `mockgen` · `gotestsum`

### `golang-project-structure` — Project Layout
> *"Check project structure"* / *"Format imports"* / *"Find boundary violations"*

Enforces Standard Go Project Layout (`/cmd`, `/internal`, `/pkg`), import ordering, and cycle prevention.
**Tools:** `goimports` · `go list` · `goda`

### `golang-security` — Security Scanning
> *"Check for vulnerabilities"* / *"Find hardcoded secrets"* / *"Scan for SQL injection"*

Runs vulnerability scans, SAST analysis, and detects hardcoded credentials and `unsafe` usage.
**Tools:** `govulncheck` · `gosec`

### `golang-style-guide` — Styling & Idioms
> *"Format code"* / *"Check naming conventions"* / *"Fix comments"*

Enforces `gofmt`/`goimports`, Effective Go naming conventions, and godoc comment formats.
**Tools:** `gofmt` · `goimports` · `golangci-lint` (`revive`)

---

## SciTools Understand → Go CLI mapping

| `und` command | Agent | Go CLI |
|---|---|---|
| `und analyze` | compliance | `go build ./...` + `golangci-lint run` |
| `und codecheck` | compliance | `golangci-lint run` / `staticcheck ./...` |
| `und metrics` | metrics | `gocyclo`, `gocognit`, `gocloc` |
| `und export -dependencies` | architecture | `goda list/tree/cut ./...:all` |
| `und list` | architecture | `go list ./...` / `go list -json ./...` |
| Performance analysis | profiling | `go tool pprof`, `go test -bench`, `benchstat` |

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

# Profiling & Testing
go install golang.org/x/perf/cmd/benchstat@latest
go install go.uber.org/mock/mockgen@latest
go install gotest.tools/gotestsum@latest

# Security & Style
go install golang.org/x/vuln/cmd/govulncheck@latest
go install github.com/securego/gosec/v2/cmd/gosec@latest
go install golang.org/x/tools/cmd/goimports@latest
```

## Usage

Copy `.claude/` into any Go project, or install user-level at `~/.claude/agents/`.  
Claude Code picks the right agent automatically based on your request.

```bash
# Direct invocation:
/golang-compliance
/golang-architecture
/golang-metrics
/golang-profiling
/golang-concurrency
/golang-error-handling
/golang-testing
/golang-project-structure
/golang-security
/golang-style-guide
```
