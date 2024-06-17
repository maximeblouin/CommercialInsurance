import os
import re

def read_sas_files_recursive(directory):
    """
    Recursively reads .sas files in the specified directory and its subdirectories.
    """
    try:
        # List all files and directories in the current directory
        with os.scandir(directory) as entries:
            for entry in entries:
                # If entry is a directory, recursively call the function
                if entry.is_dir():
                    read_sas_files_recursive(entry.path)
                # If entry is a file and ends with .sas, read and check its content
                elif entry.is_file() and entry.name.endswith('.sas'):
                    try:
                        with open(entry.path, 'r', encoding='utf-8') as file:
                            content = file.read()
                            find_pattern_in_content(content, entry.path)
                    except Exception as e:
                        print(f'Error reading {entry.path}: {e}')
    except Exception as e:
        print(f'Error accessing directory {directory}: {e}')

def find_pattern_in_content(content, file_path):
    """
    Finds SQL table names prefixed with "PZCDIAP1Q." in the given content.
    """
    pattern = r'PZCDIAP1Q\.\s*(\w+)'
    matches = re.findall(pattern, content)
    
    if matches:
        print(f'In file: {file_path}')
        for match in matches:
            print(f'Found table name: {match}')
        print('\n' + '='*80 + '\n')

# Example usage:
# Replace 'your_directory_path' with the path to your directory containing .sas files
if __name__ == "__main__":
    directory_path = "your_directory_path"
    read_sas_files_recursive(directory_path)