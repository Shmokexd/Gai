# Проект Дорога

Браузерная игра про патрульного: езда по трассе, радар, остановки, погони, проверка документов на планшете,
протокол, алкотестер, осмотр машины, эвакуатор. Вся игра — **один файл `index.html`** (HTML + CSS + JS,
картинки и музыка вшиты внутрь). Android-приложение — тонкая обёртка WebView, которая открывает этот файл.

## Как запустить
- **В браузере:** открыть `index.html` (двойной клик) или онлайн через GitHub Pages.
- Вертикальная раскладка 9:16 — по умолчанию. Старая альбомная 16:9: `index.html?land`.
- В главном меню есть кнопка **DEV · сразу к остановленной машине** — для быстрых тестов досмотра.
- Прогресс хранится в браузере (localStorage). «Сбросить прогресс» — в главном меню.

## Структура
| Путь | Что это |
|---|---|
| `index.html` | **Вся игра.** Правки делаются здесь. |
| `media/` | Исходники: музыка басовой машины (2 трека), значки штраф/арест/суд, иконка 512 px. В игре они уже вшиты в `index.html` (base64). |
| `tools/prepare_html.py` | Готовит `index.html` для APK: шрифты Google Fonts → локальные из `assets/fonts`. |
| `android-sdk-build/` | Сборка APK **без Gradle** — скрипт `build.sh` (проверен, именно так собирались все версии). |
| `android-studio/` | Тот же проект для **Android Studio / Gradle** (подпись уже настроена). |
| `keystore/` | Ключ подписи, `keystore.properties` с паролями, `KEYSTORE.txt`. **Только в ZIP, в git не кладётся.** |
| `apk/` | Последний готовый APK. В git не кладётся. |
| `legacy-portrait/` | Старая вертикальная версия v101 (до перехода на 16:9): html, обёртка, APK. |

## Сборка APK

### Вариант 1: скрипт (без Gradle) — проверенный
Нужно: JDK 17+, Python 3, Android SDK с `build-tools` (34/35) и `platforms;android-35`.
```bash
export ANDROID_HOME=~/Android/Sdk          # путь к SDK
cd android-sdk-build
./build.sh 27                              # 27 — новый versionCode, каждый раз +1
# результат: android-sdk-build/out/smena-patrulnogo-2-v27.apk
```
Ключ и пароли берутся из `keystore/keystore.properties`. В клоне с GitHub этой папки нет — положи её из ZIP-архива.

### Вариант 2: Android Studio
1. File → Open → папка `android-studio`.
2. Студия сама предложит скачать Gradle/SDK — согласиться.
3. Build → Build APK(s). Подпись подхватывается из `keystore/keystore.properties` (папка keystore рядом с `android-studio`).
4. Перед сборкой задача `prepareGameHtml` сама копирует свежий `index.html` в assets (нужен `python3` в PATH;
   если его нет — запусти вручную `python3 tools/prepare_html.py index.html android-studio/app/src/main/assets`).
5. `versionCode` в `app/build.gradle` увеличивай на 1 перед каждой новой сборкой.

> Gradle-вариант собран по стандартному шаблону, но в рабочем окружении не прогонялся — если Студия попросит
> обновить версию Android Gradle Plugin, соглашайся.

### Важно про подпись
Пакет `ru.patrol.smena2`, ключ `keystore/patrol.keystore`; пароли — в `keystore/keystore.properties` и `KEYSTORE.txt` (только в ZIP).
Обновление ставится поверх старой версии только с **тем же ключом** и **большим versionCode**.

## Онлайн-тест через GitHub Pages
Settings → Pages → Source: *Deploy from a branch* → Branch `main`, папка `/ (root)` → Save.
Через минуту игра доступна по адресу `https://<логин>.github.io/<репозиторий>/`.

## Где что в коде (`index.html`)
- `PORT` — вертикальная/альбомная раскладка; блоки CSS `html.port …` — вертикальная вёрстка.
- `spawn()` — машины на дороге (шансы: `BASS_CHANCE`, `HONEST_CHANCE`, `RACER_CHANCE` …).
- `update()` / `draw()` — игровой цикл и отрисовка; `drawMirror()` — зеркало заднего вида; `drawTow()` — эвакуатор.
- `openInspect()` → `openExt()` (внешний вид) → `openHands()` (документы на планшете) → лист проверок `renderInspect()`.
- `ARTS`, `openProto()` — протокол остановки (нарушения отмечает игрок).
- `doAct()` — решение (штраф/арест/отпустить/взятка), `logStop()` — запись в итог смены.
- `GB`, `smartShift()` — коробка передач; `setWheel()` — руль.
