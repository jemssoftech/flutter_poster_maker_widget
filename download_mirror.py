import os
import json
import requests
import shutil
import sys
import threading
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor

# --- CONFIGURATION ---
INPUT_DIR = "element"
OUTPUT_DIR = "Fotor_Mirror_Data"
ZIP_FILENAME = "Fotor_Assets_Full"
BASE_DOMAIN = "https://pub-static.fotor.com"
MAX_WORKERS = 50  # Ek sath kitni files download hongi (increase for speed)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    "Referer": "https://www.fotor.com/"
}

# Global counters for progress
total_files_found = 0
files_downloaded = 0
print_lock = threading.Lock()

def get_save_path(relative_url):
    """Generates local save path from URL"""
    clean_path = relative_url.split('?')[0]
    if clean_path.startswith("http"):
        parsed = urlparse(clean_path)
        local_structure = parsed.path
    else:
        if not clean_path.startswith("/"):
            clean_path = "/" + clean_path
        local_structure = clean_path

    if local_structure.startswith("/"):
        local_structure = local_structure[1:]

    return os.path.join(OUTPUT_DIR, local_structure)

def get_full_url(relative_url):
    """Generates full URL"""
    clean_path = relative_url.split('?')[0]
    if clean_path.startswith("http"):
        return clean_path

    if not clean_path.startswith("/"):
        clean_path = "/" + clean_path
    return BASE_DOMAIN + clean_path

def download_task(task):
    """Single download task run by threads"""
    global files_downloaded
    url, save_path = task

    # Check if exists
    if os.path.exists(save_path):
        with print_lock:
            files_downloaded += 1
            print_progress(os.path.basename(save_path))
        return

    try:
        # Create dir
        os.makedirs(os.path.dirname(save_path), exist_ok=True)

        # Download
        response = requests.get(url, headers=HEADERS, stream=True, timeout=20)
        if response.status_code == 200:
            with open(save_path, 'wb') as f:
                response.raw.decode_content = True
                shutil.copyfileobj(response.raw, f)
    except:
        pass

    with print_lock:
        files_downloaded += 1
        print_progress(os.path.basename(save_path))

def print_progress(filename):
    """Thread-safe progress bar"""
    if len(filename) > 20:
        filename = filename[:17] + "..."

    percent = (files_downloaded / total_files_found) * 100 if total_files_found > 0 else 0

    msg = f"\r🚀 Progress: {files_downloaded}/{total_files_found} ({percent:.1f}%) | ⚡ Threads: {MAX_WORKERS} | 📄 {filename}"
    sys.stdout.write(msg.ljust(100))
    sys.stdout.flush()

def main():
    global total_files_found

    print(f"🔍 Scanning JSON files in '{INPUT_DIR}/'...")

    # 1. Collect all download tasks first
    tasks = []
    json_files = [os.path.join(INPUT_DIR, f"e{i}.json") for i in range(1, 50) if os.path.exists(os.path.join(INPUT_DIR, f"e{i}.json"))]

    for json_file in json_files:
        try:
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                stickers = data.get('data', {}).get('data', [])

                for sticker in stickers:
                    # Main URL
                    if sticker.get('url'):
                        tasks.append((get_full_url(sticker['url']), get_save_path(sticker['url'])))
                    # Thumb URL
                    if sticker.get('thumb'):
                        tasks.append((get_full_url(sticker['thumb']), get_save_path(sticker['thumb'])))
        except Exception as e:
            print(f"❌ Error reading {json_file}: {e}")

    total_files_found = len(tasks)
    print(f"📋 Found {total_files_found} files to download.")
    print(f"⚡ Starting Multi-threaded Download (Workers: {MAX_WORKERS})...\n")

    # 2. Execute in Parallel
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        executor.map(download_task, tasks)

    # 3. Zip
    print(f"\n\n📦 Zipping '{OUTPUT_DIR}'...")
    shutil.make_archive(ZIP_FILENAME, 'zip', OUTPUT_DIR)

    print(f"\n✨ DONE! All files downloaded and zipped.")
    print(f"   • Location: {ZIP_FILENAME}.zip")

if __name__ == "__main__":
    main()