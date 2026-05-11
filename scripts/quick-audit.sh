#!/usr/bin/env bash
# quick-audit.sh — run the automated portion of the Anti-Vibe Checklist
#
# Usage:
#   bash scripts/quick-audit.sh                 # audit current directory
#   bash scripts/quick-audit.sh path/to/project # audit a specific project
#
# What it checks:
#   1. Secrets leaking into client-side / committed files (Right-Click Test, mechanical part)
#   2. Dependency existence — if Node/Python project, verify packages
#   3. .env file not committed to git
#   4. Common insecure patterns in code (string-level checks only — best-effort)
#
# What it does NOT do:
#   - The Negative Test (requires running the live app — that's still on you)
#   - Authorization audit (no static tool can check this reliably)
#   - Replace human review
#
# Exit code: 0 if no findings, 1 if findings, 2 if scan was incomplete.

set -uo pipefail

PROJECT_DIR="${1:-.}"
if [[ ! -d "$PROJECT_DIR" ]]; then
  echo "ERROR: directory not found: $PROJECT_DIR"
  exit 2
fi

cd "$PROJECT_DIR"

FINDINGS=0

echo "================================================="
echo " vibe-coding-safety: quick audit"
echo " project: $(pwd)"
echo "================================================="
echo ""

# ---- 1. Secret patterns in code ----
echo "[1/4] Scanning for secrets in code..."
echo ""

SECRET_PATTERNS=(
  "sk_live_[0-9a-zA-Z]{20,}"      # Stripe live secret keys
  "sk_test_[0-9a-zA-Z]{20,}"      # Stripe test secret keys (still bad in client)
  "AKIA[0-9A-Z]{16}"              # AWS access keys
  "AIza[0-9A-Za-z_\\-]{35}"       # Google API keys
  "ghp_[0-9a-zA-Z]{36}"           # GitHub personal access tokens
  "ghs_[0-9a-zA-Z]{36}"           # GitHub server tokens
  "xox[baprs]-[0-9a-zA-Z\\-]+"    # Slack tokens
  "eyJ[A-Za-z0-9_\\-]{20,}\\.[A-Za-z0-9_\\-]{20,}\\.[A-Za-z0-9_\\-]{20,}"  # JWT-shaped (3 base64 parts)
)

# Find candidate files (excluding common ignore paths)
FILES_TO_SCAN=$(find . \
  -type f \
  \( -name "*.js" -o -name "*.jsx" -o -name "*.ts" -o -name "*.tsx" \
     -o -name "*.py" -o -name "*.rb" -o -name "*.go" -o -name "*.rs" \
     -o -name "*.html" -o -name "*.vue" -o -name "*.svelte" \
     -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.env*" \) \
  -not -path "./node_modules/*" \
  -not -path "./.git/*" \
  -not -path "./dist/*" \
  -not -path "./build/*" \
  -not -path "./.next/*" \
  -not -path "./venv/*" \
  -not -path "./.venv/*" \
  -not -path "./__pycache__/*" \
  2>/dev/null || true)

if [[ -z "$FILES_TO_SCAN" ]]; then
  echo "  No source files found to scan."
else
  for pattern in "${SECRET_PATTERNS[@]}"; do
    MATCHES=$(echo "$FILES_TO_SCAN" | xargs grep -lE "$pattern" 2>/dev/null || true)
    if [[ -n "$MATCHES" ]]; then
      echo "  [FINDING] Pattern '$pattern' matched in:"
      echo "$MATCHES" | sed 's/^/    /'
      FINDINGS=$((FINDINGS + 1))
    fi
  done
fi

if [[ $FINDINGS -eq 0 ]]; then
  echo "  No common secret patterns matched."
fi
echo ""

# ---- 2. .env file not in git ----
echo "[2/4] Checking that .env files are not committed..."
echo ""

if [[ -d .git ]]; then
  COMMITTED_ENV=$(git ls-files 2>/dev/null | grep -E '(^|/)\.env($|\.|\b)' || true)
  if [[ -n "$COMMITTED_ENV" ]]; then
    echo "  [FINDING] These .env-style files are committed to git:"
    echo "$COMMITTED_ENV" | sed 's/^/    /'
    echo "  ACTION: Remove from history, rotate any secrets they contain."
    FINDINGS=$((FINDINGS + 1))
  else
    echo "  No .env files committed to git. Good."
  fi
else
  echo "  Not a git repo. Skipping."
fi
echo ""

# ---- 3. Dependency existence (Node) ----
echo "[3/4] Verifying dependencies (Node.js)..."
echo ""

if [[ -f package.json ]]; then
  if command -v npm >/dev/null 2>&1; then
    # Extract dependency names from package.json (no jq dependency)
    DEPS=$(node -e "
      const pkg = require('./package.json');
      const all = Object.assign({}, pkg.dependencies || {}, pkg.devDependencies || {});
      Object.keys(all).forEach(d => console.log(d));
    " 2>/dev/null || true)

    if [[ -z "$DEPS" ]]; then
      echo "  No dependencies declared, or could not parse package.json."
    else
      MISSING=""
      for dep in $DEPS; do
        # npm view returns non-zero if package doesn't exist
        if ! npm view "$dep" name >/dev/null 2>&1; then
          MISSING="$MISSING\n    $dep"
        fi
      done
      if [[ -n "$MISSING" ]]; then
        echo "  [FINDING] These packages could not be verified on the npm registry:"
        printf "$MISSING\n"
        echo "  ACTION: Verify each manually. If a package doesn't exist, the AI hallucinated it."
        FINDINGS=$((FINDINGS + 1))
      else
        echo "  All declared dependencies exist on the npm registry."
      fi
    fi
  else
    echo "  npm not installed. Skipping dependency verification."
  fi
else
  echo "  No package.json found. Skipping."
fi
echo ""

# ---- 4. Common insecure patterns ----
echo "[4/4] Scanning for known insecure patterns..."
echo ""

INSECURE_PATTERNS_FOUND=0

# 4a: Reading user_id directly from URL params (likely BOLA)
BOLA_HITS=$(echo "$FILES_TO_SCAN" | xargs grep -lE "req\.(params|query|body)\.user_?[iI]d" 2>/dev/null || true)
if [[ -n "$BOLA_HITS" ]]; then
  echo "  [FINDING] req.params/query/body.user_id used (likely BOLA risk):"
  echo "$BOLA_HITS" | sed 's/^/    /'
  echo "  ACTION: Audit each. user_id should come from req.session.user.id, not the client."
  INSECURE_PATTERNS_FOUND=$((INSECURE_PATTERNS_FOUND + 1))
fi

# 4b: eval() usage
EVAL_HITS=$(echo "$FILES_TO_SCAN" | xargs grep -lE "(^|[^a-zA-Z_])eval[[:space:]]*\\(" 2>/dev/null || true)
if [[ -n "$EVAL_HITS" ]]; then
  echo "  [FINDING] eval() found in:"
  echo "$EVAL_HITS" | sed 's/^/    /'
  echo "  ACTION: Refactor. eval() is almost always a security risk."
  INSECURE_PATTERNS_FOUND=$((INSECURE_PATTERNS_FOUND + 1))
fi

# 4c: dangerouslySetInnerHTML
DSIH_HITS=$(echo "$FILES_TO_SCAN" | xargs grep -lE "dangerouslySetInnerHTML" 2>/dev/null || true)
if [[ -n "$DSIH_HITS" ]]; then
  echo "  [FINDING] dangerouslySetInnerHTML found in:"
  echo "$DSIH_HITS" | sed 's/^/    /'
  echo "  ACTION: Verify inputs are sanitized. This is an XSS vector if user-controlled."
  INSECURE_PATTERNS_FOUND=$((INSECURE_PATTERNS_FOUND + 1))
fi

if [[ $INSECURE_PATTERNS_FOUND -eq 0 ]]; then
  echo "  No common insecure patterns matched."
else
  FINDINGS=$((FINDINGS + INSECURE_PATTERNS_FOUND))
fi
echo ""

# ---- Summary ----
echo "================================================="
echo " Summary"
echo "================================================="
if [[ $FINDINGS -eq 0 ]]; then
  echo " No automated findings."
  echo ""
  echo " IMPORTANT: This script only catches mechanical issues."
  echo " You still need to run the manual checklist for:"
  echo "   - The Negative Test (visit URLs, change IDs, try invalid input)"
  echo "   - The full Right-Click Test (live page source inspection)"
  echo "   - Authorization logic review (no static tool can do this reliably)"
  echo ""
  echo " See checklist.md and scoring.md for the full audit."
  exit 0
else
  echo " $FINDINGS finding(s). Review the output above."
  echo ""
  echo " After fixing, re-run this script AND complete the manual checklist."
  echo " See checklist.md and scoring.md."
  exit 1
fi
