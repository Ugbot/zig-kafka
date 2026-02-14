#!/bin/bash
# Generate all Kafka protocol messages using the standalone generator

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SPEC_DIR="$SCRIPT_DIR/../../Protocol specs"
OUTPUT_DIR="$SCRIPT_DIR/generated"
CLEAN_SCRIPT="$SCRIPT_DIR/clean_json.py"
GENERATOR="$SCRIPT_DIR/zig-out/bin/kafka-protocol-generator"

# Build the generator
echo "Building generator..."
cd "$SCRIPT_DIR"
zig build

# Create output directory
mkdir -p "$OUTPUT_DIR"

# List of core Kafka APIs to generate
MESSAGES=(
    "ApiVersionsRequest"
    "ApiVersionsResponse"
    "MetadataRequest"
    "MetadataResponse"
    "ProduceRequest"
    "ProduceResponse"
    "FetchRequest"
    "FetchResponse"
    "ListOffsetsRequest"
    "ListOffsetsResponse"
    "FindCoordinatorRequest"
    "FindCoordinatorResponse"
    "JoinGroupRequest"
    "JoinGroupResponse"
    "HeartbeatRequest"
    "HeartbeatResponse"
    "LeaveGroupRequest"
    "LeaveGroupResponse"
    "SyncGroupRequest"
    "SyncGroupResponse"
    "OffsetCommitRequest"
    "OffsetCommitResponse"
    "OffsetFetchRequest"
    "OffsetFetchResponse"
    "CreateTopicsRequest"
    "CreateTopicsResponse"
    "DeleteTopicsRequest"
    "DeleteTopicsResponse"
    "DescribeConfigsRequest"
    "DescribeConfigsResponse"
    "AlterConfigsRequest"
    "AlterConfigsResponse"
    "DescribeGroupsRequest"
    "DescribeGroupsResponse"
    "ListGroupsRequest"
    "ListGroupsResponse"
)

echo "Generating Kafka protocol messages..."
echo "===================================="

SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_MESSAGES=""

for msg in "${MESSAGES[@]}"; do
    JSON_FILE="$SPEC_DIR/${msg}.json"
    CLEAN_JSON="/tmp/${msg}_clean.json"
    OUTPUT_FILE="$OUTPUT_DIR/$(echo "$msg" | sed 's/\([A-Z]\)/_\L\1/g' | sed 's/^_//').zig"
    
    if [ -f "$JSON_FILE" ]; then
        echo -n "Generating $msg... "
        
        # Clean JSON (remove comments)
        if python3 "$CLEAN_SCRIPT" "$JSON_FILE" "$CLEAN_JSON" 2>/dev/null; then
            # Generate Zig code
            if "$GENERATOR" "$CLEAN_JSON" "$OUTPUT_FILE" 2>/dev/null; then
                echo "✅"
                ((SUCCESS_COUNT++))
            else
                echo "❌ (generation failed)"
                ((FAIL_COUNT++))
                FAILED_MESSAGES="$FAILED_MESSAGES $msg"
            fi
        else
            echo "❌ (JSON cleaning failed)"
            ((FAIL_COUNT++))
            FAILED_MESSAGES="$FAILED_MESSAGES $msg"
        fi
    else
        echo "⚠️  Skipping $msg (file not found)"
    fi
done

echo "===================================="
echo "Results:"
echo "  ✅ Success: $SUCCESS_COUNT"
echo "  ❌ Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -gt 0 ]; then
    echo "  Failed messages:$FAILED_MESSAGES"
fi

# Generate module index file
echo "Generating module index..."
cat > "$OUTPUT_DIR/mod.zig" << 'EOF'
//! Generated Kafka Protocol Messages
//! Auto-generated module index

// Core Protocol Messages
pub const ApiVersionsRequest = @import("api_versions_request.zig");
pub const ApiVersionsResponse = @import("api_versions_response.zig");
pub const MetadataRequest = @import("metadata_request.zig");
pub const MetadataResponse = @import("metadata_response.zig");
pub const ProduceRequest = @import("produce_request.zig");
pub const ProduceResponse = @import("produce_response.zig");
pub const FetchRequest = @import("fetch_request.zig");
pub const FetchResponse = @import("fetch_response.zig");

// Offset Management
pub const ListOffsetsRequest = @import("list_offsets_request.zig");
pub const ListOffsetsResponse = @import("list_offsets_response.zig");
pub const OffsetCommitRequest = @import("offset_commit_request.zig");
pub const OffsetCommitResponse = @import("offset_commit_response.zig");
pub const OffsetFetchRequest = @import("offset_fetch_request.zig");
pub const OffsetFetchResponse = @import("offset_fetch_response.zig");

// Group Management
pub const FindCoordinatorRequest = @import("find_coordinator_request.zig");
pub const FindCoordinatorResponse = @import("find_coordinator_response.zig");
pub const JoinGroupRequest = @import("join_group_request.zig");
pub const JoinGroupResponse = @import("join_group_response.zig");
pub const HeartbeatRequest = @import("heartbeat_request.zig");
pub const HeartbeatResponse = @import("heartbeat_response.zig");
pub const LeaveGroupRequest = @import("leave_group_request.zig");
pub const LeaveGroupResponse = @import("leave_group_response.zig");
pub const SyncGroupRequest = @import("sync_group_request.zig");
pub const SyncGroupResponse = @import("sync_group_response.zig");
pub const ListGroupsRequest = @import("list_groups_request.zig");
pub const ListGroupsResponse = @import("list_groups_response.zig");
pub const DescribeGroupsRequest = @import("describe_groups_request.zig");
pub const DescribeGroupsResponse = @import("describe_groups_response.zig");

// Topic Management
pub const CreateTopicsRequest = @import("create_topics_request.zig");
pub const CreateTopicsResponse = @import("create_topics_response.zig");
pub const DeleteTopicsRequest = @import("delete_topics_request.zig");
pub const DeleteTopicsResponse = @import("delete_topics_response.zig");

// Configuration Management
pub const DescribeConfigsRequest = @import("describe_configs_request.zig");
pub const DescribeConfigsResponse = @import("describe_configs_response.zig");
pub const AlterConfigsRequest = @import("alter_configs_request.zig");
pub const AlterConfigsResponse = @import("alter_configs_response.zig");

// Re-export types for convenience
pub const types = @import("../src/types.zig");
EOF

echo "✅ Generated module index: $OUTPUT_DIR/mod.zig"

# Copy generated files to src/codecs/kafka/generated
KAFKA_GEN_DIR="$SCRIPT_DIR/../../src/codecs/kafka/generated"
mkdir -p "$KAFKA_GEN_DIR"
cp -r "$OUTPUT_DIR"/*.zig "$KAFKA_GEN_DIR/"
echo "✅ Copied generated files to $KAFKA_GEN_DIR"

file_count=$SUCCESS_COUNT
echo "✅ Done! Generated ${file_count} protocol files"

# Post-processing: Fix lint errors in generated files
echo ""
echo "Running post-processing to fix lint errors..."

python3 << 'EOFPY'
import os
import re

generated_dir = "../../src/codecs/kafka/generated"

if not os.path.exists(generated_dir):
    print(f"Warning: Generated directory not found at {generated_dir}")
    exit(0)

files_fixed = 0
total_fixes = 0

for filename in os.listdir(generated_dir):
    if not filename.endswith('.zig') or filename == 'mod.zig':
        continue
    
    filepath = os.path.join(generated_dir, filename)
    
    with open(filepath, 'r') as f:
        content = f.read()
        original_content = content
    
    # Remove pointless discard statements
    content = re.sub(r'^\s+_ = is_flexible;\s*\n', '', content, flags=re.MULTILINE)
    content = re.sub(r'^\s+_ = allocator;\s*\n', '', content, flags=re.MULTILINE)
    
    # Prefix unused variables in nested structs
    lines = content.split('\n')
    in_nested_struct = False
    nested_level = 0
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Detect nested struct (4+ space indentation)
        if re.match(r'    pub const \w+ = struct \{', line):
            in_nested_struct = True
            nested_level = len(line) - len(line.lstrip())
        
        # Detect nested struct end
        if in_nested_struct and line.strip() == '};' and len(line) - len(line.lstrip()) == nested_level:
            in_nested_struct = False
        
        # Fix unused is_flexible in nested types
        if in_nested_struct and 'const is_flexible = isFlexibleVersion(version);' in line:
            # Check next 20 lines to see if is_flexible is used
            future = '\n'.join(lines[i+1:min(i+21, len(lines))])
            if 'if (is_flexible)' not in future and 'if (!is_flexible)' not in future:
                line = line.replace('const is_flexible', 'const _is_flexible')
                total_fixes += 1
        
        # Fix unused allocator parameters
        if in_nested_struct and ', allocator: std.mem.Allocator)' in line and 'pub fn decode' in line:
            # Look ahead to check if allocator is used
            func_lines = []
            j, braces = i + 1, 1
            while j < len(lines) and braces > 0:
                func_lines.append(lines[j])
                braces += lines[j].count('{') - lines[j].count('}')
                j += 1
            
            if 'allocator' not in '\n'.join(func_lines):
                line = line.replace(', allocator:', ', _allocator:')
                total_fixes += 1
        
        fixed_lines.append(line)
    
    content = '\n'.join(fixed_lines)
    
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        files_fixed += 1

print(f"✅ Post-processing complete: {total_fixes} fixes applied to {files_fixed} files")
EOFPY

echo "✅ Generation and post-processing complete!"
