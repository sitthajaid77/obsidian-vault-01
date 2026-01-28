#!/bin/bash
# combine-to-markdown.sh - With version support

VAULT="$HOME/Documents/obsidian/jung01"
OUTPUT_DIR="$HOME/Documents/obsidian/jung01/to-notebooklm"
VERSION_FILE="$HOME/Documents/obsidian/jung01/.version"

# Get current version
if [ -f "$VERSION_FILE" ]; then
    VERSION=$(cat "$VERSION_FILE")
else
    VERSION=1
    echo "1" > "$VERSION_FILE"
fi

VERSION_STR=$(printf "jung%02d" $VERSION)

# Timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_ONLY=$(date '+%Y-%m-%d')

# Create output directory
mkdir -p "$OUTPUT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 NotebookLM Markdown Generator"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📅 Date: $DATE_ONLY"
echo "🕐 Time: $(date '+%H:%M:%S')"
echo "🔢 Version: $VERSION_STR"
echo "📂 Vault: $VAULT"
echo "📂 Output: $OUTPUT_DIR"
echo ""

cd "$VAULT"

# =====================================================
# Function: Create markdown with header
# =====================================================

create_header() {
    local file=$1
    local title=$2
    
    cat > "$file" << EOF
# $title

**Version:** $VERSION_STR  
**Generated:** $TIMESTAMP  
**Source:** Obsidian Vault (jung01)  
**Author:** Yashiro

---

EOF
}

# =====================================================
# Source 1: Technical KB
# =====================================================

echo "📚 Creating Technical KB..."

create_header "$OUTPUT_DIR/${VERSION_STR}-technical.md" "Technical Knowledge Base ($VERSION_STR)"

cat >> "$OUTPUT_DIR/${VERSION_STR}-technical.md" << 'EOF'

## Contents

This document contains technical knowledge from all kb-* folders:

EOF

# List all kb-* folders
kb_folders=(kb-*)
if [ ${#kb_folders[@]} -gt 0 ]; then
    for kb_dir in "${kb_folders[@]}"; do
        [ ! -d "$kb_dir" ] && continue
        echo "- ${kb_dir%/}" >> "$OUTPUT_DIR/${VERSION_STR}-technical.md"
    done
fi

cat >> "$OUTPUT_DIR/${VERSION_STR}-technical.md" << 'EOF'

---

EOF

# Process all kb-* folders
total_kb_files=0
for kb_dir in kb-*/; do
    [ ! -d "$kb_dir" ] && continue
    
    file_count=$(find "$kb_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        echo "   📁 ${kb_dir%/}: Empty"
        continue
    fi
    
    echo "   📁 ${kb_dir%/}: Processing $file_count files..."
    total_kb_files=$((total_kb_files + file_count))
    
    cat >> "$OUTPUT_DIR/${VERSION_STR}-technical.md" << EOF

# ${kb_dir%/}

EOF
    
    find "$kb_dir" -name "*.md" -type f | sort | while read file; do
        if [[ "$(basename "$file")" == "README.md" ]]; then
            continue
        fi
        
        cat >> "$OUTPUT_DIR/${VERSION_STR}-technical.md" << EOF

## $(basename "$file" .md)

**File:** \`$file\`

$(cat "$file")

---

EOF
    done
done

echo "   ✅ Total: $total_kb_files files from ${#kb_folders[@]} folders"

# =====================================================
# Source 2: WorkLog
# =====================================================

echo "📝 Creating WorkLog..."

create_header "$OUTPUT_DIR/${VERSION_STR}-worklog.md" "Work Logs ($VERSION_STR)"

cat >> "$OUTPUT_DIR/${VERSION_STR}-worklog.md" << 'EOF'

## Overview

Personal work logs by Yashiro documenting daily tasks, progress, and issues.

- **Format:** Weekly logs (YYYY-MM-DD to YYYY-MM-DD)
- **Content:** Completed tasks, ongoing work, blockers, decisions

---

EOF

log_count=$(find WorkLog/ -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$log_count" -gt 0 ]; then
    echo "   Processing $log_count work logs..."
    
    find WorkLog/ -name "*.md" -type f 2>/dev/null | sort -r | while read file; do
        cat >> "$OUTPUT_DIR/${VERSION_STR}-worklog.md" << EOF

# $(basename "$file" .md)

**Period:** $(basename "$file" .md)

$(cat "$file")

---

EOF
    done
else
    echo "   No work logs found"
fi

# =====================================================
# Source 3: WorkAssignment
# =====================================================

echo "📋 Creating WorkAssignment..."

create_header "$OUTPUT_DIR/${VERSION_STR}-workassignment.md" "Work Assignments ($VERSION_STR)"

cat >> "$OUTPUT_DIR/${VERSION_STR}-workassignment.md" << 'EOF'

## Overview

Work assignments by Yashiro to team members.

- **Content:** Assignment details, assignee, deadlines, status tracking
- **Updates:** All updates include date stamps

---

EOF

assignment_count=$(find WorkAssignment/ -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')

if [ "$assignment_count" -gt 0 ]; then
    echo "   Processing $assignment_count assignments..."
    
    find WorkAssignment/ -name "*.md" -type f 2>/dev/null | sort -r | while read file; do
        cat >> "$OUTPUT_DIR/${VERSION_STR}-workassignment.md" << EOF

# $(basename "$file" .md)

**Period:** $(basename "$file" .md)

$(cat "$file")

---

EOF
    done
else
    echo "   No assignments found"
fi

# =====================================================
# Summary
# =====================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Markdown Generation Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 Created files (Version: $VERSION_STR):"
echo ""

for md_file in "$OUTPUT_DIR"/${VERSION_STR}-*.md; do
    if [ -f "$md_file" ]; then
        size=$(stat -f%z "$md_file" 2>/dev/null || stat -c%s "$md_file" 2>/dev/null)
        size_kb=$((size / 1024))
        lines=$(wc -l < "$md_file" | tr -d ' ')
        
        printf "   📄 %-35s %6s KB  %5s lines\n" \
            "$(basename "$md_file")" \
            "$size_kb" \
            "$lines"
    fi
done

echo ""
echo "📈 Content Statistics:"
echo "   • KB folders: ${#kb_folders[@]}"
echo "   • KB files: $total_kb_files"
echo "   • WorkLog entries: $log_count"
echo "   • WorkAssignment entries: $assignment_count"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 Location"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Output folder:"
echo "$OUTPUT_DIR"
echo ""
echo "Files created:"
echo "  1. ${VERSION_STR}-technical.md"
echo "  2. ${VERSION_STR}-worklog.md"
echo "  3. ${VERSION_STR}-workassignment.md"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Upload to NotebookLM:"
echo ""
echo "1. 🌐 Open: https://notebooklm.google.com"
echo "2. ➕ Add source → Upload"
echo "3. 📤 Upload these files:"
echo "   • ${VERSION_STR}-technical.md"
echo "   • ${VERSION_STR}-worklog.md"
echo "   • ${VERSION_STR}-workassignment.md"
echo "4. ✅ Start querying!"
echo ""
echo "💡 Note: Files are named $VERSION_STR to avoid conflicts with old sources"
echo ""

# Open folder
echo "📂 Opening output folder..."
open "$OUTPUT_DIR"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏰ Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""