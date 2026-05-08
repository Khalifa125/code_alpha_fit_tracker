import os
import re

def fix_withValues(directory):
    # Match .withValues(alpha: EXPRESSION) and replace with .withOpacity(EXPRESSION)
    # Handle both simple numbers and complex expressions
    pattern = re.compile(r'\.withValues\(alpha:\s*([^)]*(?:\([^)]*\)[^)]*)*)\)')
    replacement = r'.withOpacity(\1)'
    
    count = 0
    files_modified = 0
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    new_content = pattern.sub(replacement, content)
                    
                    if new_content != content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        files_modified += 1
                        # Count replacements
                        count += len(re.findall(pattern, content))
                        print(f'Fixed {len(re.findall(pattern, content))} occurrences in: {file}')
                except Exception as e:
                    print(f'Error processing {filepath}: {e}')
    
    print(f'\nTotal files modified: {files_modified}')
    print(f'Total occurrences fixed: {count}')

if __name__ == '__main__':
    fix_withValues(r'C:\code_alpha_fit_tracker\lib')
    print('\nDone!')
