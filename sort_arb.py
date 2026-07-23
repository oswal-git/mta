import json
import os
import sys

def sort_arb(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Keep special @@ keys first
    special_keys = {k: v for k, v in data.items() if k.startswith('@@')}
    other_data = {k: v for k, v in data.items() if not k.startswith('@@')}
    
    # Get unique base names for everything else
    base_names = set()
    for k in other_data.keys():
        if k.startswith('@'):
            base_names.add(k[1:])
        else:
            base_names.add(k)
            
    sorted_bases = sorted(list(base_names))
    
    final_data = {}
    # Add special keys first (sorted)
    for k in sorted(special_keys.keys()):
        final_data[k] = special_keys[k]
        
    # Add grouped keys
    for base in sorted_bases:
        if base in other_data:
            final_data[base] = other_data[base]
        if f'@{base}' in other_data:
            final_data[f'@{base}'] = other_data[f'@{base}']
            
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(final_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    sort_arb(sys.argv[1])
