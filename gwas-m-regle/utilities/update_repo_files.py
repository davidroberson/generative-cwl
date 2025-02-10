#!/usr/bin/env python3
"""
Parser Script for Applying changes.txt

This script reads a changes.txt file that documents new or modified files,
including a header with instructions, a directory structure section, a user
requested changes section, and file sections with the complete file content.
For each file section, the script creates any required directories and writes
the provided content to the specified file.
"""

import os
import sys
import argparse

def parse_changes_file(changes_file_path):
    """
    Parse the changes file and extract file sections.

    Returns a list of tuples: (file_path, file_content)
    """
    try:
        with open(changes_file_path, 'r') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading changes file: {e}")
        sys.exit(1)

    # Skip the instructions block (between BEGIN and END markers)
    content_lines = []
    in_instructions = False
    instructions_done = False
    for line in lines:
        if line.strip().startswith("----- BEGIN INSTRUCTIONS"):
            in_instructions = True
            continue
        if in_instructions and line.strip().startswith("----- END INSTRUCTIONS"):
            in_instructions = False
            instructions_done = True
            continue
        if not in_instructions and instructions_done:
            content_lines.append(line)
    
    # Parse file sections by detecting lines that start with "File:"
    file_sections = []
    current_file = None
    current_content = []
    state = 'search'
    separator = "--------------------------------------------------"
    
    for line in content_lines:
        stripped = line.strip()
        # Look for the beginning of a file section.
        if stripped.startswith("File:"):
            # If we're already processing a file section, save it.
            if current_file:
                file_sections.append((current_file, ''.join(current_content).rstrip('\n')))
                current_file = None
                current_content = []
            # Extract the file path (everything after "File:")
            current_file = stripped[len("File:"):].strip()
            state = 'content'
        else:
            # If in content state, check for a separator indicating the end of the section.
            if state == 'content':
                if stripped == separator:
                    # End of current file section.
                    if current_file:
                        file_sections.append((current_file, ''.join(current_content).rstrip('\n')))
                    current_file = None
                    current_content = []
                    state = 'search'
                else:
                    current_content.append(line)
    # If we have a file still being processed at the end, add it.
    if current_file and current_content:
        file_sections.append((current_file, ''.join(current_content).rstrip('\n')))
    
    return file_sections

def apply_changes(changes_file_path):
    """
    Apply changes as defined in the changes file.
    For each file section, create the necessary directory (if not exists) and write the content.
    """
    file_sections = parse_changes_file(changes_file_path)
    if not file_sections:
        print("No file sections found in the changes file.")
        return

    for file_path, content in file_sections:
        # Create directory structure if necessary.
        directory = os.path.dirname(file_path)
        if directory and not os.path.exists(directory):
            print(f"Creating directory: {directory}")
            try:
                os.makedirs(directory, exist_ok=True)
            except Exception as e:
                print(f"Error creating directory {directory}: {e}")
                continue

        # Write or overwrite the file with the new content.
        try:
            with open(file_path, 'w') as f:
                f.write(content)
            print(f"Updated file: {file_path}")
        except Exception as e:
            print(f"Error writing file {file_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Apply changes from a changes.txt file to the repository.")
    parser.add_argument("changes_file", help="Path to the changes.txt file")
    args = parser.parse_args()
    
    apply_changes(args.changes_file)

if __name__ == '__main__':
    main()
