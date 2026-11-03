#!/usr/bin/env python3
"""Готовит index.html для APK: заменяет Google Fonts на локальные шрифты из assets/fonts
и оборачивает файл в полноценный HTML. Использование:
    python3 tools/prepare_html.py index.html <папка assets>
"""
import sys, os
src, assets = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8').read()
link = '<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Golos+Text:wght@400;600;800&family=Russo+One&display=swap">'
ff = []
for w in (400, 600, 800):
    for sub in ("cyrillic", "latin"):
        ff.append(f'@font-face{{font-family:"Golos Text";font-weight:{w};src:url(fonts/golos-text-{sub}-{w}-normal.woff2) format("woff2")}}')
for sub in ("cyrillic", "latin"):
    ff.append(f'@font-face{{font-family:"Russo One";src:url(fonts/russo-one-{sub}-400-normal.woff2) format("woff2")}}')
s = s.replace(link, '<style>' + "".join(ff) + '</style>')
if not s.lstrip().lower().startswith('<!doctype'):
    s = ('<!doctype html><html lang="ru"><head><meta charset="utf-8">'
         '<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover,user-scalable=no">'
         '<style>*{box-sizing:border-box}body{margin:0}[hidden]{display:none!important}</style></head><body>' + s + '</body></html>')
os.makedirs(assets, exist_ok=True)
open(os.path.join(assets, 'index.html'), 'w', encoding='utf-8').write(s)
print('ok ->', os.path.join(assets, 'index.html'))
