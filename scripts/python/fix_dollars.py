import os

def fix_escaped_dollars(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replacements for dart variable interpolations
    replacements = [
        ('\\$e', '$e'),
        ('\\${', '${'),
        ('\\$timestamp', '$timestamp'),
        ('\\$outputFileName', '$outputFileName'),
        ('\\$outName', '$outName'),
        ('\\$generatedName', '$generatedName'),
    ]

    new_content = content
    for old, new in replacements:
        new_content = new_content.replace(old, new)

    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk('lib/modules/document'):
    for file in files:
        if file.endswith('.dart'):
            fix_escaped_dollars(os.path.join(root, file))
