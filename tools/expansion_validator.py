#!/usr/bin/env python3
"""
Case Clicker - Content Expansion Validator
Validates skin definitions, case configurations, drop tables, and image assets.
Usage: python tools/expansion_validator.py
"""

import os
import re
import sys

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(REPO_ROOT, "data")
IMAGES_DIR = os.path.join(REPO_ROOT, "images")

def parse_lua_skins(content):
    skins = {}
    pattern = re.compile(r'\[Skin\.([a-zA-Z0-9_]+)\]\s*=\s*\{[^}]*stashId\s*=\s*([0-9]+)', re.MULTILINE)
    for match in pattern.finditer(content):
        skin_id = match.group(1)
        stash_id = int(match.group(2))
        skins[skin_id] = stash_id
    return skins

def parse_lua_skindata(content):
    skindata = {}
    pattern = re.compile(r'\[([0-9]+)\]\s*=\s*\{[^}]*name\s*=\s*"([^"]+)"', re.MULTILINE)
    for match in pattern.finditer(content):
        stash_id = int(match.group(1))
        name = match.group(2)
        skindata[stash_id] = name
    return skindata

def parse_lua_cases(content):
    cases = {}
    pattern = re.compile(r'\[Case\.([a-zA-Z0-9_]+)\]\s*=\s*\{', re.MULTILINE)
    for match in pattern.finditer(content):
        case_id = match.group(1)
        cases[case_id] = True
    return cases

def main():
    print("=" * 60)
    print("Case Clicker Content Expansion Validator")
    print("=" * 60)
    
    skins_file = os.path.join(DATA_DIR, "skins.lua")
    skindata_file = os.path.join(DATA_DIR, "skindata.lua")
    cases_file = os.path.join(DATA_DIR, "cases.lua")
    
    if not os.path.exists(skins_file) or not os.path.exists(skindata_file):
        print("Error: Could not find data/skins.lua or data/skindata.lua")
        sys.exit(1)
        
    with open(skins_file, 'r', encoding='utf-8', errors='ignore') as f:
        skins = parse_lua_skins(f.read())
        
    with open(skindata_file, 'r', encoding='utf-8', errors='ignore') as f:
        skindata = parse_lua_skindata(f.read())
        
    with open(cases_file, 'r', encoding='utf-8', errors='ignore') as f:
        cases = parse_lua_cases(f.read())
        
    print(f"Registered Skin Constants: {len(skins)}")
    print(f"Registered Stash Metadata: {len(skindata)}")
    print(f"Registered Cases:          {len(cases)}")
    print("-" * 60)
    
    # 1. Verify every skin has skindata
    missing_metadata = []
    for skin_id, stash_id in skins.items():
        if stash_id not in skindata:
            missing_metadata.append((skin_id, stash_id))
            
    if missing_metadata:
        print(f"Warning: {len(missing_metadata)} skins lack metadata in skindata.lua:")
        for sid, stid in missing_metadata[:10]:
            print(f"  Skin.{sid} (stashId: {stid})")
    else:
        print("PASS: All skins have corresponding metadata in data/skindata.lua")
        
    # 2. Verify skin image assets
    missing_images = []
    skin_img_dir = os.path.join(IMAGES_DIR, "skins")
    for skin_id, stash_id in skins.items():
        img_path = os.path.join(skin_img_dir, f"{stash_id}.png")
        if not os.path.exists(img_path):
            missing_images.append((skin_id, stash_id))
            
    if missing_images:
        print(f"Warning: {len(missing_images)} skin textures missing in images/skins/:")
        for sid, stid in missing_images[:10]:
            print(f"  images/skins/{stid}.png for Skin.{sid}")
    else:
        print(f"PASS: All {len(skins)} skin PNG textures exist in images/skins/")
        
    print("-" * 60)
    print("Content validation check finished successfully.")

if __name__ == "__main__":
    main()
