import os

root_dir = r"d:\Clenzy-main_1\Clenzy-main"
output_file = r"d:\Clenzy-main_1\Clenzy-main\full_project_prompt.txt"

included_extensions = {".py", ".dart", ".yaml", ".json", ".md", ".txt", ".html", ".css", ".js"}
excluded_dirs = {"venv", ".venv", "build", ".dart_tool", ".git", "__pycache__", "node_modules", ".idea", "assets", "linux", "macos", "windows", "ios", "android", "web"}

def should_include(filepath):
    # Exclude binaries and some large lock files
    if "yarn.lock" in filepath or "package-lock.json" in filepath or "pubspec.lock" in filepath:
        return False
    return any(filepath.endswith(ext) for ext in included_extensions)

def generate_prompt():
    print(f"Generating prompt to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as outfile:
        outfile.write("Project: Clenzy\n")
        outfile.write("="*80 + "\n\n")
        
        # Write Tree
        outfile.write("Directory Structure:\n")
        for dirname, dirs, files in os.walk(root_dir):
            dirs[:] = [d for d in dirs if d not in excluded_dirs]
            level = dirname.replace(root_dir, '').count(os.sep)
            indent = ' ' * 4 * (level)
            outfile.write(f"{indent}{os.path.basename(dirname)}/\n")
            subindent = ' ' * 4 * (level + 1)
            for f in files:
                if should_include(f):
                    outfile.write(f"{subindent}{f}\n")
                    
        outfile.write("\n" + "="*80 + "\n\n")
        
        # Write File Contents
        outfile.write("File Contents:\n")
        for dirname, dirs, files in os.walk(root_dir):
            dirs[:] = [d for d in dirs if d not in excluded_dirs]
            for f in files:
                if should_include(f):
                    filepath = os.path.join(dirname, f)
                    try:
                        with open(filepath, 'r', encoding='utf-8') as infile:
                            content = infile.read()
                            
                        outfile.write("\n" + "-"*80 + "\n")
                        relative_path = filepath.replace(root_dir + os.sep, '').replace('\\', '/')
                        outfile.write(f"File: {relative_path}\n")
                        outfile.write("-" * 80 + "\n")
                        outfile.write(content)
                        outfile.write("\n")
                    except Exception as e:
                        outfile.write(f"\nCould not read {filepath}: {e}\n")
    print("Done!")

if __name__ == "__main__":
    generate_prompt()
