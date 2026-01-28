#!/bin/bash
# archive-and-increment.sh - Archive old data and increment version

VAULT="$HOME/Documents/obsidian/jung01"
ARCHIVE_DIR="$HOME/Documents/obsidian/jung01/archive"
VERSION_FILE="$HOME/Documents/obsidian/jung01/.version"

# Create archive directory
mkdir -p "$ARCHIVE_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Archive & Increment Version"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$VAULT"

# =====================================================
# Get current version
# =====================================================

if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
else
    CURRENT_VERSION=1
fi

NEXT_VERSION=$((CURRENT_VERSION + 1))

echo "📊 Version Info:"
echo "   Current: jung0$CURRENT_VERSION"
echo "   Next:    jung0$NEXT_VERSION"
echo ""

# =====================================================
# Create timestamped archive folder
# =====================================================

ARCHIVE_TIMESTAMP=$(date '+%Y%m%d-%H%M%S')
ARCHIVE_FOLDER="$ARCHIVE_DIR/jung0${CURRENT_VERSION}_${ARCHIVE_TIMESTAMP}"

mkdir -p "$ARCHIVE_FOLDER"

echo "📂 Archive Location:"
echo "   $ARCHIVE_FOLDER"
echo ""

# =====================================================
# Archive KB folders
# =====================================================

echo "📚 Archiving KB folders..."

kb_archived=0
for kb_dir in kb-*/; do
    [ ! -d "$kb_dir" ] && continue
    
    # Count files
    file_count=$(find "$kb_dir" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$file_count" -eq 0 ]; then
        echo "   📁 ${kb_dir%/}: Empty (skipped)"
        continue
    fi
    
    echo "   📁 ${kb_dir%/}: Archiving $file_count files..."
    
    # Create archive folder
    mkdir -p "$ARCHIVE_FOLDER/$kb_dir"
    
    # Move all .md files to archive
    find "$kb_dir" -name "*.md" -type f -exec mv {} "$ARCHIVE_FOLDER/$kb_dir" \;
    
    # Move attachments folder if exists
    if [ -d "$kb_dir/attachments" ]; then
        mv "$kb_dir/attachments" "$ARCHIVE_FOLDER/$kb_dir/"
    fi
    
    kb_archived=$((kb_archived + file_count))
done

echo "   ✅ Archived: $kb_archived KB files"
echo ""

# =====================================================
# Archive WorkLog
# =====================================================

echo "📝 Archiving WorkLog..."

if [ -d "WorkLog" ]; then
    worklog_count=$(find WorkLog/ -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$worklog_count" -gt 0 ]; then
        echo "   Archiving $worklog_count work logs..."
        
        mkdir -p "$ARCHIVE_FOLDER/WorkLog"
        find WorkLog/ -name "*.md" -type f -exec mv {} "$ARCHIVE_FOLDER/WorkLog/" \;
        
        echo "   ✅ Archived: $worklog_count work logs"
    else
        echo "   No work logs to archive"
    fi
else
    echo "   WorkLog folder not found"
fi

echo ""

# =====================================================
# Archive WorkAssignment
# =====================================================

echo "📋 Archiving WorkAssignment..."

if [ -d "WorkAssignment" ]; then
    assignment_count=$(find WorkAssignment/ -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$assignment_count" -gt 0 ]; then
        echo "   Archiving $assignment_count assignments..."
        
        mkdir -p "$ARCHIVE_FOLDER/WorkAssignment"
        find WorkAssignment/ -name "*.md" -type f -exec mv {} "$ARCHIVE_FOLDER/WorkAssignment/" \;
        
        echo "   ✅ Archived: $assignment_count assignments"
    else
        echo "   No assignments to archive"
    fi
else
    echo "   WorkAssignment folder not found"
fi

echo ""

# =====================================================
# Save new version number
# =====================================================

echo "$NEXT_VERSION" > "$VERSION_FILE"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Archive Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Summary:"
echo "   • KB files archived: $kb_archived"
echo "   • WorkLog entries archived: $worklog_count"
echo "   • WorkAssignment entries archived: $assignment_count"
echo ""
echo "   Archive location:"
echo "   $ARCHIVE_FOLDER"
echo ""
echo "   Version updated: jung0$CURRENT_VERSION → jung0$NEXT_VERSION"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Next Steps"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1. ✅ Vault is now clean (only folder structure remains)"
echo "2. 📝 Start adding new content to folders"
echo "3. 🔄 Run: ./combine-to-markdown.sh"
echo "4. 📤 Upload jung0${NEXT_VERSION}-*.md files to NotebookLM"
echo ""
echo "Note: Old files are safely archived and can be restored if needed"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⏰ Completed at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""