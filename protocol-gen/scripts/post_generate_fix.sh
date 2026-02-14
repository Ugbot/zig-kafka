#!/bin/bash
# Post-generation fix: Add dummy usage to prevent "unused" errors

cd "$(dirname "$0")"
GENERATED_DIR="../../src/codecs/kafka/generated"

echo "Applying post-generation fixes..."

for file in "$GENERATED_DIR"/*.zig; do
    if [ -f "$file" ]; then
        # Step 1: Remove any existing discard statements
        sed -i '' '/^[[:space:]]*_ = is_flexible;$/d' "$file"
        sed -i '' '/^[[:space:]]*_ = allocator;$/d' "$file"
        
        # Step 2: For nested types (inside pub const X = struct), add dummy sideeffect at end of encode/decode functions
        # This prevents "unused variable" errors while keeping variables available if needed
        awk '
        BEGIN { in_nested = 0; in_func = 0; }
        /^    pub const [A-Z]/ { in_nested = 1; }
        /^pub const [A-Z][a-zA-Z_0-9]*Response/ { in_nested = 0; }
        /^pub const [A-Z][a-zA-Z_0-9]*Request/ { in_nested = 0; }
        in_nested && /pub fn (encode|decode)\(/ { in_func = 1; }
        in_func && /^    \}$/ { 
            print "        if (false) { _ = is_flexible; _ = allocator; } // Suppress unused warnings in generated code";
            in_func = 0;
        }
        { print }
        ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
done

echo "✅ Post-generation fixes applied"
