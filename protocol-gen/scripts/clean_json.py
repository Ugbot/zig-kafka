#!/usr/bin/env python3
"""Remove comments from Kafka protocol JSON files"""

import json
import re
import sys
import os

def clean_json(input_file, output_file):
    """Clean comments from JSON file and ensure valid JSON output"""
    try:
        with open(input_file, 'r') as f:
            content = f.read()
        
        # Remove single-line comments (// ...)
        content = re.sub(r'//.*?\n', '\n', content)
        # Remove multi-line comments (/* ... */)
        content = re.sub(r'/\*.*?\*/', '', content, flags=re.DOTALL)
        
        # Parse and re-serialize to ensure valid JSON
        data = json.loads(content)
        
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=2)
            
        return True
        
    except json.JSONDecodeError as e:
        print(f"❌ Error parsing JSON {input_file}: {e}", file=sys.stderr)
        return False
    except Exception as e:
        print(f"❌ Error processing {input_file}: {e}", file=sys.stderr)
        return False

def main():
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <input.json> <output.json>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if not os.path.exists(input_file):
        print(f"❌ Input file not found: {input_file}", file=sys.stderr)
        sys.exit(1)
    
    if clean_json(input_file, output_file):
        print(f"✅ Cleaned {input_file} -> {output_file}")
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()
