"""Renders the Quiz-It logo and every app icon from one SVG design.

    python3 tool/logo.py        # needs rsvg-convert (brew install librsvg)

Writes assets/logo.svg (the master), assets/launcher.png, the web icons, the
iOS app icons and the Android launcher icons (legacy + adaptive).
"""

import json
import os
import subprocess
import tempfile

TOP, BOTTOM = '#8357FF', '#5221C2'   # background gradient
GLYPH = '#FFFFFF'
SPARK = '#FFC94D'


def glyph(scale):
    # Designed on a 1024 canvas, centred on (512, 512).
    return f'''
  <g transform="translate(512 512) scale({scale}) translate(-512 -512)">
    <g filter="url(#shadow)">
      <circle cx="476" cy="540" r="226" fill="none" stroke="{GLYPH}" stroke-width="112"/>
      <path d="M552 616 L716 780" stroke="{GLYPH}" stroke-width="112" stroke-linecap="round"/>
    </g>
    <path transform="translate(784 236)" fill="{SPARK}"
          d="M0 -112 C14 -30 30 -14 112 0 C30 14 14 30 0 112 C-14 30 -30 14 -112 0 C-30 -14 -14 -30 0 -112 Z"/>
  </g>'''


def svg(mode):
    """mode: rounded (squircle), full (edge to edge), glyph (no background)."""
    scale = {'rounded': 1.0, 'full': 0.86, 'maskable': 0.72, 'glyph': 0.68}[mode]
    radius = 230 if mode == 'rounded' else 0
    background = '' if mode == 'glyph' else \
        f'<rect width="1024" height="1024" rx="{radius}" fill="url(#bg)"/>'
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <defs>
    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{TOP}"/>
      <stop offset="1" stop-color="{BOTTOM}"/>
    </linearGradient>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="18" stdDeviation="18" flood-color="#2A0E73" flood-opacity="0.35"/>
    </filter>
  </defs>
  {background}{glyph(scale)}
</svg>
'''


def render(mode, size, path):
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    with tempfile.NamedTemporaryFile('w', suffix='.svg', delete=False) as f:
        f.write(svg(mode))
    subprocess.run(['rsvg-convert', '-w', str(size), '-h', str(size), f.name, '-o', path], check=True)
    os.unlink(f.name)


def flatten(path):
    """Drops the alpha channel (App Store icons must be opaque). macOS only."""
    jpeg = path + '.jpg'
    subprocess.run(['sips', '-s', 'format', 'jpeg', '-s', 'formatOptions', '100',
                    path, '--out', jpeg], check=True, capture_output=True)
    subprocess.run(['sips', '-s', 'format', 'png', jpeg, '--out', path],
                   check=True, capture_output=True)
    os.unlink(jpeg)


def main(out='.'):
    p = lambda *parts: os.path.join(out, *parts)
    os.makedirs(p('assets'), exist_ok=True)
    with open(p('assets', 'logo.svg'), 'w') as f:
        f.write(svg('rounded'))
    render('rounded', 512, p('assets', 'launcher.png'))

    # Web
    render('rounded', 48, p('web', 'favicon.png'))
    render('rounded', 192, p('web', 'icons', 'Icon-192.png'))
    render('rounded', 512, p('web', 'icons', 'Icon-512.png'))
    render('maskable', 192, p('web', 'icons', 'Icon-maskable-192.png'))
    render('maskable', 512, p('web', 'icons', 'Icon-maskable-512.png'))

    # iOS: opaque, edge to edge; the system rounds the corners.
    ios = p('ios', 'Runner', 'Assets.xcassets', 'AppIcon.appiconset')
    if os.path.isdir(ios):
        for image in json.load(open(os.path.join(ios, 'Contents.json')))['images']:
            size = float(image['size'].split('x')[0]) * int(image['scale'][0])
            path = os.path.join(ios, image['filename'])
            render('full', round(size), path)
            flatten(path)

    # Android: legacy squircle icons plus an adaptive icon (gradient background
    # drawable + glyph foreground) for Android 8+.
    res = p('android', 'app', 'src', 'main', 'res')
    if os.path.isdir(res):
        densities = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
        for name, factor in densities.items():
            render('rounded', round(48 * factor), os.path.join(res, f'mipmap-{name}', 'ic_launcher.png'))
            render('glyph', round(108 * factor), os.path.join(res, f'mipmap-{name}', 'ic_launcher_foreground.png'))
        os.makedirs(os.path.join(res, 'mipmap-anydpi-v26'), exist_ok=True)
        with open(os.path.join(res, 'mipmap-anydpi-v26', 'ic_launcher.xml'), 'w') as f:
            f.write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
    <monochrome android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
''')
        os.makedirs(os.path.join(res, 'drawable'), exist_ok=True)
        with open(os.path.join(res, 'drawable', 'ic_launcher_background.xml'), 'w') as f:
            f.write(f'''<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient
        android:angle="315"
        android:startColor="{TOP}"
        android:endColor="{BOTTOM}" />
</shape>
''')


if __name__ == '__main__':
    import sys
    main(sys.argv[1] if len(sys.argv) > 1 else '.')
