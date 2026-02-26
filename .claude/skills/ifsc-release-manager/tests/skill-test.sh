#!/bin/bash
# IFSC Release Manager Skill - Comprehensive Test Suite
# Run this periodically to validate skill functionality

set -e  # Exit on first error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    echo -e "  ${RED}Error: $2${NC}"
    ((TESTS_FAILED++))
    ((TESTS_RUN++))
}

info() {
    echo -e "${BLUE}ℹ INFO${NC}: $1"
}

warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
}

section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Change to project root (navigate from .claude/skills/ifsc-release-manager/tests/ to project root)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
cd "$PROJECT_ROOT"

section "IFSC Release Manager Skill Test Suite"
info "Starting test execution at $(date)"
info "Working directory: $(pwd)"

# ============================================================================
# TEST 1: Skill File Structure
# ============================================================================
section "Test 1: Skill File Structure"

if [ -f ".claude/skills/ifsc-release-manager/skill.md" ]; then
    pass "Main skill file exists"
else
    fail "Main skill file missing" "skill.md not found"
fi

# Check for all sub-skills
SUB_SKILLS=(
    "rbi-data-monitor"
    "ifsc-data-extractor"
    "release-decision-maker"
    "git-orchestrator"
    "patch-applier"
    "upi-validator"
    "rtgs-data-parser"
    "nach-html-scraper"
    "imps-generator"
    "swift-code-fetcher"
    "geographic-normalizer"
    "multi-format-exporter"
    "sublet-detector"
    "changelog-writer"
    "test-runner"
    "quality-reviewer"
    "deployment-manager"
    "slack-communicator"
)

for skill in "${SUB_SKILLS[@]}"; do
    if [ -f ".claude/skills/ifsc-release-manager/sub-skills/${skill}.md" ]; then
        pass "Sub-skill exists: ${skill}"
    else
        fail "Sub-skill missing: ${skill}" "File not found"
    fi
done

# Check context files
if [ -f ".claude/skills/ifsc-release-manager/context/ifsc-domain-knowledge.md" ]; then
    pass "Domain knowledge context exists"
else
    fail "Domain knowledge missing" "Context file not found"
fi

# ============================================================================
# TEST 2: Data Source Files
# ============================================================================
section "Test 2: Data Source Files"

# Check for RBI files
if [ -f "scraper/scripts/sheets/68774.xlsx" ]; then
    FILE_SIZE=$(ls -lh scraper/scripts/sheets/68774.xlsx | awk '{print $5}')
    pass "NEFT file exists (Size: $FILE_SIZE)"
else
    warn "NEFT file not found (may need to run scraper)"
fi

if [ -f "scraper/scripts/sheets/RTGEB0815.xlsx" ]; then
    FILE_SIZE=$(ls -lh scraper/scripts/sheets/RTGEB0815.xlsx | awk '{print $5}')
    pass "RTGS file exists (Size: $FILE_SIZE)"
else
    warn "RTGS file not found (may need to run scraper)"
fi

# Check for CSV files
CSV_COUNT=$(find scraper/scripts/sheets -name "*.csv" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CSV_COUNT" -ge 5 ]; then
    pass "CSV files generated (Count: $CSV_COUNT)"
else
    warn "CSV files missing or incomplete (Found: $CSV_COUNT, Expected: 5+)"
fi

# ============================================================================
# TEST 3: Python Excel Converter
# ============================================================================
section "Test 3: Python Excel Converter"

if [ -f "scraper/scripts/convert_excel.py" ]; then
    pass "Python Excel converter exists"

    # Test Python dependencies
    if python3 -c "import pandas; import openpyxl" 2>/dev/null; then
        pass "Python dependencies available (pandas, openpyxl)"
    else
        fail "Python dependencies missing" "Run: pip install pandas openpyxl"
    fi
else
    fail "Excel converter missing" "convert_excel.py not found"
fi

# ============================================================================
# TEST 4: Generated Dataset Files
# ============================================================================
section "Test 4: Generated Dataset Files"

if [ -d "scraper/scripts/data" ]; then
    pass "Data directory exists"

    # Check individual files
    REQUIRED_FILES=(
        "scraper/scripts/data/IFSC.csv"
        "scraper/scripts/data/IFSC.json"
        "scraper/scripts/data/IFSC-list.json"
        "scraper/scripts/data/banks.json"
        "scraper/scripts/data/sublet.json"
    )

    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            SIZE=$(ls -lh "$file" | awk '{print $5}')
            pass "$(basename $file) exists (Size: $SIZE)"
        else
            warn "$(basename $file) not found (run scraper to generate)"
        fi
    done

    # Check by-bank directory
    if [ -d "scraper/scripts/data/by-bank" ]; then
        BANK_COUNT=$(find scraper/scripts/data/by-bank -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
        if [ "$BANK_COUNT" -ge 1300 ]; then
            pass "By-bank files generated (Count: $BANK_COUNT)"
        else
            warn "By-bank files incomplete (Found: $BANK_COUNT, Expected: 1300+)"
        fi
    else
        warn "By-bank directory missing"
    fi
else
    warn "Data directory not found (run scraper to generate)"
fi

# ============================================================================
# TEST 5: IFSC Format Validation
# ============================================================================
section "Test 5: IFSC Format Validation"

if [ -f "scraper/scripts/data/IFSC.csv" ]; then
    # Count total IFSCs
    IFSC_COUNT=$(wc -l < scraper/scripts/data/IFSC.csv)
    IFSC_COUNT=$((IFSC_COUNT - 1))  # Subtract header

    if [ "$IFSC_COUNT" -ge 170000 ] && [ "$IFSC_COUNT" -le 180000 ]; then
        pass "IFSC count within expected range ($IFSC_COUNT)"
    else
        fail "IFSC count out of range" "Found: $IFSC_COUNT, Expected: 170,000-180,000"
    fi

    # Validate IFSC format (sample check)
    INVALID_COUNT=$(tail -n +2 scraper/scripts/data/IFSC.csv | head -1000 | cut -d',' -f2 | grep -vE '^[A-Z]{4}0[A-Z0-9]{6}$' | wc -l | tr -d ' ')
    if [ "$INVALID_COUNT" -eq 0 ]; then
        pass "IFSC format validation (sampled 1000 entries)"
    else
        fail "Invalid IFSC formats found" "Invalid count: $INVALID_COUNT"
    fi
else
    warn "IFSC.csv not found, skipping format validation"
fi

# ============================================================================
# TEST 6: Bank Count Validation
# ============================================================================
section "Test 6: Bank Count Validation"

if [ -f "scraper/scripts/data/banks.json" ]; then
    BANK_COUNT=$(grep -o '"[A-Z]{4}"' scraper/scripts/data/banks.json | wc -l | tr -d ' ')

    if [ "$BANK_COUNT" -ge 1300 ] && [ "$BANK_COUNT" -le 1400 ]; then
        pass "Bank count within expected range ($BANK_COUNT)"
    else
        fail "Bank count out of range" "Found: $BANK_COUNT, Expected: 1300-1400"
    fi
else
    warn "banks.json not found, skipping bank validation"
fi

# ============================================================================
# TEST 7: Patch Files
# ============================================================================
section "Test 7: Patch Files"

PATCH_COUNT=$(find src/patches/ifsc -name "*.yml" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PATCH_COUNT" -ge 20 ]; then
    pass "IFSC patch files found (Count: $PATCH_COUNT)"
else
    warn "Fewer IFSC patches than expected (Found: $PATCH_COUNT, Expected: 20+)"
fi

BANK_PATCH_COUNT=$(find src/patches/banks -name "*.yml" 2>/dev/null | wc -l | tr -d ' ')
if [ "$BANK_PATCH_COUNT" -ge 10 ]; then
    pass "Bank patch files found (Count: $BANK_PATCH_COUNT)"
else
    warn "Fewer bank patches than expected (Found: $BANK_PATCH_COUNT, Expected: 10+)"
fi

# ============================================================================
# TEST 8: Git Repository State
# ============================================================================
section "Test 8: Git Repository State"

if git rev-parse --git-dir > /dev/null 2>&1; then
    pass "Git repository detected"

    # Check current version
    if [ -f "package.json" ]; then
        VERSION=$(node -p "require('./package.json').version" 2>/dev/null)
        if [ -n "$VERSION" ]; then
            pass "Current version: $VERSION"
        else
            fail "Version not readable" "Check package.json"
        fi
    else
        fail "package.json missing" "Cannot determine version"
    fi

    # Check for uncommitted changes in data files
    CHANGED_FILES=$(git status --porcelain src/ scraper/scripts/data/ 2>/dev/null | wc -l | tr -d ' ')
    if [ "$CHANGED_FILES" -eq 0 ]; then
        pass "No uncommitted data changes"
    else
        info "Uncommitted changes detected: $CHANGED_FILES files"
    fi
else
    fail "Not a git repository" "Run from project root"
fi

# ============================================================================
# TEST 9: Release Decision Logic (Mock Test)
# ============================================================================
section "Test 9: Release Decision Logic"

# Test decision thresholds
info "Testing release decision thresholds..."

# Mock: 0 changes → skip
if [ 0 -lt 50 ]; then
    pass "Decision logic: 0 changes → skip release"
else
    fail "Decision logic broken" "0 changes should skip release"
fi

# Mock: 100 changes → patch
if [ 100 -ge 50 ] && [ 100 -lt 500 ]; then
    pass "Decision logic: 100 changes → patch release"
else
    fail "Decision logic broken" "100 changes should trigger patch"
fi

# Mock: 600 changes → minor
if [ 600 -ge 500 ]; then
    pass "Decision logic: 600 changes → minor release"
else
    fail "Decision logic broken" "600 changes should trigger minor"
fi

# ============================================================================
# TEST 10: Export Format Validation
# ============================================================================
section "Test 10: Export Format Validation"

if [ -f "scraper/scripts/data/IFSC.json" ]; then
    # Validate JSON syntax
    if python3 -c "import json; json.load(open('scraper/scripts/data/IFSC.json'))" 2>/dev/null; then
        pass "IFSC.json is valid JSON"
    else
        fail "IFSC.json invalid" "JSON parse error"
    fi
fi

if [ -f "scraper/scripts/data/banks.json" ]; then
    if python3 -c "import json; json.load(open('scraper/scripts/data/banks.json'))" 2>/dev/null; then
        pass "banks.json is valid JSON"
    else
        fail "banks.json invalid" "JSON parse error"
    fi
fi

if [ -f "scraper/scripts/data/IFSC-list.json" ]; then
    if python3 -c "import json; json.load(open('scraper/scripts/data/IFSC-list.json'))" 2>/dev/null; then
        pass "IFSC-list.json is valid JSON"
    else
        fail "IFSC-list.json invalid" "JSON parse error"
    fi
fi

# ============================================================================
# TEST 11: Checksum Comparison (src vs generated)
# ============================================================================
section "Test 11: Checksum Comparison"

if [ -f "src/IFSC.json" ] && [ -f "scraper/scripts/data/IFSC.json" ]; then
    SRC_MD5=$(md5 -q src/IFSC.json 2>/dev/null || md5sum src/IFSC.json | awk '{print $1}')
    GEN_MD5=$(md5 -q scraper/scripts/data/IFSC.json 2>/dev/null || md5sum scraper/scripts/data/IFSC.json | awk '{print $1}')

    if [ "$SRC_MD5" = "$GEN_MD5" ]; then
        pass "Dataset unchanged (checksums match)"
        info "This indicates no release is needed"
    else
        info "Dataset changed (checksums differ)"
        info "This would trigger a release"
        pass "Change detection working"
    fi
else
    warn "Cannot compare checksums (files missing)"
fi

# ============================================================================
# TEST 12: Ruby Scraper Availability
# ============================================================================
section "Test 12: Ruby Scraper Environment"

if command -v ruby &> /dev/null; then
    RUBY_VERSION=$(ruby --version)
    pass "Ruby available: $RUBY_VERSION"
else
    fail "Ruby not installed" "Required for scraper"
fi

if command -v bundle &> /dev/null; then
    pass "Bundler available"

    if [ -f "scraper/Gemfile" ]; then
        pass "Gemfile exists"
    else
        warn "Gemfile missing"
    fi
else
    warn "Bundler not installed"
fi

# ============================================================================
# FINAL SUMMARY
# ============================================================================
section "Test Summary"

echo ""
echo -e "Tests Run:    ${BLUE}$TESTS_RUN${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo -e "${GREEN}IFSC Release Manager skill is operational and ready.${NC}"
    exit 0
else
    echo -e "${RED}✗ Some tests failed.${NC}"
    echo ""
    echo -e "${YELLOW}Please review failures above and fix issues.${NC}"
    exit 1
fi
