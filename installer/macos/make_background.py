#!/usr/bin/env python3
"""Draws the artwork behind the disk image window.

The two icon slots are where create-dmg is told to put the app and the
Applications alias (see the release workflow); the numbers here and the
--icon coordinates there have to move together. Run with Pillow installed:

    python3 installer/macos/make_background.py

It writes dmg-background.png and dmg-background@2x.png next to itself; the
workflow folds the pair into one hidpi TIFF with tiffutil.
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

WIDTH, HEIGHT = 660, 420
APP_SLOT = (170, 232)
APPS_SLOT = (490, 232)
ICON = 128

HERE = Path(__file__).resolve().parent
FONTS = HERE.parent.parent / "assets" / "fonts"

MINT = (242, 251, 246)
CREAM = (253, 246, 231)
INK = (43, 58, 53)
MUTED = (122, 140, 132)
ACCENT = (53, 185, 139)


def draw(scale: int) -> Image.Image:
    w, h = WIDTH * scale, HEIGHT * scale
    img = Image.new("RGB", (w, h), MINT)
    d = ImageDraw.Draw(img, "RGBA")

    # Diagonal wash from the mint of the app icon to its cream corner.
    for y in range(h):
        for_x = y / max(h - 1, 1)
        row = tuple(
            round(MINT[c] + (CREAM[c] - MINT[c]) * for_x * 0.85) for c in range(3)
        )
        d.line([(0, y), (w, y)], fill=row)

    # A pale halo under each icon so the slots read as places to drop into.
    for cx, cy in (APP_SLOT, APPS_SLOT):
        r = int(ICON * 0.78 * scale)
        d.ellipse(
            [cx * scale - r, cy * scale - r, cx * scale + r, cy * scale + r],
            fill=(255, 255, 255, 90),
        )

    title = ImageFont.truetype(str(FONTS / "Nunito-ExtraBold.ttf"), 30 * scale)
    lead = ImageFont.truetype(str(FONTS / "Nunito-SemiBold.ttf"), 15 * scale)
    d.text((w / 2, 58 * scale), "The Sims Mod Manager", font=title, fill=INK, anchor="mm")
    d.text(
        (w / 2, 90 * scale),
        "Drag the app into your Applications folder",
        font=lead,
        fill=MUTED,
        anchor="mm",
    )

    # The arrow between the slots, drawn rather than typed so it keeps its
    # weight at both scales.
    y = APP_SLOT[1] * scale
    x0, x1 = 288 * scale, 372 * scale
    bar = max(3 * scale, 3)
    d.rounded_rectangle([x0, y - bar, x1 - 14 * scale, y + bar], bar, fill=ACCENT)
    d.polygon(
        [(x1, y), (x1 - 26 * scale, y - 18 * scale), (x1 - 26 * scale, y + 18 * scale)],
        fill=ACCENT,
    )
    return img


for s, name in ((1, "dmg-background.png"), (2, "dmg-background@2x.png")):
    draw(s).save(HERE / name)
    print("wrote", name)
