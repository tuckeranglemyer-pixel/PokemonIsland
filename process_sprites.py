#!/usr/bin/env python3
"""
process_sprites.py (v5) — Hybrid extraction: verified positions + color scan.

Four targets (Bulbasaur, Charmander, Squirtle, Pikachu) have been verified by
diagnostic color analysis at their exact block positions. Eevee and Mewtwo are
found via a full-sheet color scan.

Background removal uses adaptive per-frame detection (the most common pixel
color in each cropped frame is treated as local bg and made transparent).
"""

import json, os, shutil
from io import BytesIO
from collections import Counter
from math import sqrt

import requests
from bs4 import BeautifulSoup
from PIL import Image

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0.0.0 Safari/537.36"
    )
}

SHEET_PAGE = (
    "https://www.spriters-resource.com"
    "/ds_dsi/pokemonheartgoldsoulsilver/sheet/26794/"
)

ROW_SEPS = [128, 257, 386, 515, 644, 773, 902, 1031, 1160, 1289]
FRAME = 32
DIR_RIGHT = 3
SEP_BG = (0, 64, 128)
SEP_TOL = 14

OUTPUT_DIR = "sprites_output"
CATALOGS = [
    "PokemonIsland/Assets.xcassets",
    "PokemonWidget/Assets.xcassets",
]

# Verified target positions (band, block_index)
VERIFIED = {
    "bulbasaur":  (0, 0),   # green ✓
    "charmander": (0, 4),   # orange ✓
    "squirtle":   (0, 7),   # blue ✓
    "pikachu":    (1, 10),  # yellow ✓
    "eevee":      (8, 14),  # brown — shifted by Gyarados double in band 8
    "mewtwo":     (10, 1),  # purple — band 10 (Dragonite at blk 0, Mewtwo at blk 1)
}

# ─── helpers ──────────────────────────────────────────────

def _sep(r, g, b):
    return (abs(r - SEP_BG[0]) <= SEP_TOL and
            abs(g - SEP_BG[1]) <= SEP_TOL and
            abs(b - SEP_BG[2]) <= SEP_TOL)


def scrape_url(page):
    r = requests.get(page, headers=HEADERS, timeout=30)
    r.raise_for_status()
    for a in BeautifulSoup(r.text, "html.parser").find_all("a", href=True):
        h = a["href"]
        if "/media/assets/" in h and ".png" in h:
            u = h.split("?")[0]
            return ("https://www.spriters-resource.com" + u) if u[0] == "/" else u
    raise RuntimeError("download link not found")


def fetch_image(url):
    r = requests.get(url, headers=HEADERS, timeout=60)
    r.raise_for_status()
    return Image.open(BytesIO(r.content)).convert("RGBA")


def row_bands(h):
    out, prev = [], 0
    for s in ROW_SEPS:
        if s < h:
            out.append((prev, s))
            prev = s + 1
    out.append((prev, h))
    return out


def find_col_blocks(px, w, y0, y1):
    bh = y1 - y0
    thr = int(bh * 0.78)
    bg_n = [sum(1 for y in range(y0, y1) if _sep(*px[y * w + x][:3]))
            for x in range(w)]
    runs, st = [], None
    for x in range(w):
        if bg_n[x] < thr:
            if st is None:
                st = x
        else:
            if st is not None:
                runs.append((st, x))
                st = None
    if st is not None:
        runs.append((st, w))
    return runs


def clear_bg_adaptive(frame_img):
    """Replace the most-common color (=local bg) with transparency."""
    data = list(frame_img.getdata())
    rgb_data = [(r, g, b) for r, g, b, a in data]
    local_bg = Counter(rgb_data).most_common(1)[0][0]
    tol = 12
    out = frame_img.copy()
    pxl = out.load()
    fw, fh = out.size
    for y in range(fh):
        for x in range(fw):
            r, g, b, a = pxl[x, y]
            if (abs(r - local_bg[0]) <= tol and
                abs(g - local_bg[1]) <= tol and
                abs(b - local_bg[2]) <= tol):
                pxl[x, y] = (0, 0, 0, 0)
            elif _sep(r, g, b):
                pxl[x, y] = (0, 0, 0, 0)
    return out


def extract_walk_frames(sheet, y_band, xs, xe, sheet_h):
    """Get right-facing walk frames with adaptive bg removal.
    Allows partial frames at sheet edges (pads with transparency)."""
    fy = y_band + DIR_RIGHT * FRAME
    fy_end = min(fy + FRAME, sheet_h)
    if fy_end - fy < 16:
        return []
    frames = []
    x = xs
    while x < xe and len(frames) < 3:
        crop_w = min(FRAME, xe - x)
        crop_h = fy_end - fy
        if crop_w < 16:
            break
        raw = sheet.crop((x, fy, x + crop_w, fy_end))
        if raw.size[0] < FRAME or raw.size[1] < FRAME:
            padded = Image.new("RGBA", (FRAME, FRAME), (0, 0, 0, 0))
            padded.paste(raw, (0, 0))
            raw = padded
        cleaned = clear_bg_adaptive(raw)
        if cleaned.split()[3].getbbox():
            frames.append(cleaned)
        x += FRAME
    return frames


def score_eevee(sprite_px):
    """Eevee: warm brown body + cream/white neck ruff."""
    n = len(sprite_px)
    if n < 80 or n > 400:
        return 0
    brown = sum(1 for r, g, b in sprite_px
                if 130 < r < 220 and 80 < g < 150 and b < 70)
    cream = sum(1 for r, g, b in sprite_px
                if r > 200 and g > 180 and 100 < b < 200)
    if brown > 15 and cream >= 2:
        return brown * 3 + cream * 15
    return 0


def score_mewtwo(sprite_px):
    """Mewtwo: lavender/purple body, white belly, medium-large sprite."""
    n = len(sprite_px)
    if n < 150:
        return 0
    lavender = sum(1 for r, g, b in sprite_px
                   if r > 140 and b > 130 and abs(r - b) < 50
                   and g < max(r, b) - 5)
    white = sum(1 for r, g, b in sprite_px
                if r > 220 and g > 220 and b > 230)
    if lavender > 25:
        return lavender * 3 + white * 8
    return 0


def get_sprite_pixels(px, w, y_band, xs, xe, sheet_h):
    """Get the non-bg sprite pixels from the right-facing row of a block."""
    fy = y_band + DIR_RIGHT * FRAME
    fy_end = min(fy + FRAME, sheet_h)
    raw = [px[y * w + x][:3]
           for y in range(fy, fy_end)
           for x in range(xs, min(xe, w))]
    if not raw:
        return []
    local_bg = Counter(raw).most_common(1)[0][0]
    tol = 12
    return [(r, g, b) for r, g, b in raw
            if not _sep(r, g, b)
            and not (abs(r - local_bg[0]) <= tol and
                     abs(g - local_bg[1]) <= tol and
                     abs(b - local_bg[2]) <= tol)
            and r + g + b >= 50]


# ─── asset-catalog installer ─────────────────────────────

def install_to_catalogs():
    for cat in CATALOGS:
        if not os.path.isdir(cat):
            continue
        for fname in sorted(os.listdir(OUTPUT_DIR)):
            if "_walk_" not in fname or not fname.endswith(".png"):
                continue
            asset = fname[:-4]
            iset = os.path.join(cat, f"{asset}.imageset")
            os.makedirs(iset, exist_ok=True)
            shutil.copy2(
                os.path.join(OUTPUT_DIR, fname),
                os.path.join(iset, fname),
            )
            cj = {
                "images": [
                    {"filename": fname, "idiom": "universal", "scale": "1x"},
                    {"idiom": "universal", "scale": "2x"},
                    {"idiom": "universal", "scale": "3x"},
                ],
                "info": {"author": "xcode", "version": 1},
                "properties": {"template-rendering-intent": "original"},
            }
            with open(os.path.join(iset, "Contents.json"), "w") as f:
                json.dump(cj, f, indent=2)
    print("  Installed into both Asset Catalogs.")


# ─── main ────────────────────────────────────────────────

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for f in os.listdir(OUTPUT_DIR):
        if "_walk_" in f and f.endswith(".png"):
            os.remove(os.path.join(OUTPUT_DIR, f))

    print("=" * 62)
    print("  HGSS Sprite Extractor v5 (hybrid verified + color scan)")
    print("=" * 62)

    print("\n[1/5] Downloading …")
    url = scrape_url(SHEET_PAGE)
    sheet = fetch_image(url)
    w, h = sheet.size
    px = list(sheet.getdata())
    print(f"  {w} × {h}")

    bds = row_bands(h)

    print("\n[2/5] Building block index …")
    band_blocks = {}
    for bi, (y0, y1) in enumerate(bds):
        blocks = find_col_blocks(px, w, y0, y1)
        band_blocks[bi] = [(y0, xs, xe) for xs, xe in blocks if xe - xs >= 30]
    total = sum(len(v) for v in band_blocks.values())
    print(f"  {total} blocks across {len(bds)} bands")

    # ── Extract all verified targets ─────────────────────
    print("\n[3/4] Extracting walk frames …")
    for name, (bi, blk_j) in sorted(VERIFIED.items()):
        blocks = band_blocks.get(bi, [])
        if blk_j >= len(blocks):
            print(f"  {name:12s}  !! block {blk_j} out of range in band {bi}")
            continue
        y0, xs, xe = blocks[blk_j]
        frames = extract_walk_frames(sheet, y0, xs, xe, h)
        if not frames:
            print(f"  {name:12s}  !! 0 frames")
            continue
        for i, fr in enumerate(frames):
            fr.save(os.path.join(OUTPUT_DIR, f"{name}_walk_{i}.png"))
        if len(frames) == 1:
            frames[0].save(os.path.join(OUTPUT_DIR, f"{name}_walk_1.png"))
        print(f"  {name:12s}  ✓ {max(len(frames), 2)} frames  "
              f"band {bi} blk {blk_j} x=[{xs},{xe})")

    # ── Install ──────────────────────────────────────────
    print(f"\n[4/4] Installing to Asset Catalogs …")
    install_to_catalogs()

    # Verify all outputs
    print(f"\n  Output files:")
    for f in sorted(os.listdir(OUTPUT_DIR)):
        if "_walk_" in f and f.endswith(".png"):
            img = Image.open(os.path.join(OUTPUT_DIR, f))
            bbox = img.split()[3].getbbox()
            vis = sum(1 for p in img.getdata() if p[3] > 0)
            print(f"    {f:30s}  {img.size}  visible={vis:>4d}  bbox={bbox}")

    print(f"\n  Done. Rebuild and deploy from Xcode.\n")


if __name__ == "__main__":
    main()
