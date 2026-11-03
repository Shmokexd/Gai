#!/usr/bin/env bash
# Сборка APK без Gradle — только Android SDK (build-tools + platform) и JDK.
# Использование:  ./build.sh 26        (26 — новый versionCode, должен расти с каждой сборкой)
# Нужно: ANDROID_HOME (или ANDROID_SDK_ROOT), установленные build-tools (любые 34/35) и platforms;android-35, JDK 17 (javac, keytool).
set -e
cd "$(dirname "$0")"
ROOT="$(cd .. && pwd)"
V="${1:?укажите versionCode, например ./build.sh 26}"
SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
BT="${BUILD_TOOLS:-$(ls -d "$SDK"/build-tools/* 2>/dev/null | sort -V | tail -1)}"
JAR="${ANDROID_JAR:-$SDK/platforms/android-35/android.jar}"
[ -x "$BT/aapt2" ] || { echo "Не найден aapt2. Задайте ANDROID_HOME или BUILD_TOOLS=путь/к/build-tools/35.0.0"; exit 1; }
[ -f "$JAR" ] || { echo "Не найден android.jar. Установите platforms;android-35 или задайте ANDROID_JAR"; exit 1; }
KP="$ROOT/keystore/keystore.properties"
[ -f "$KP" ] || { echo "Нет $KP — положи папку keystore из ZIP-архива"; exit 1; }
prop(){ grep "^$1=" "$KP" | cut -d= -f2-; }
KS="$ROOT/keystore/$(prop storeFile)"; PASS="$(prop storePassword)"; ALIAS="$(prop keyAlias)"; KPASS="$(prop keyPassword)"
python3 "$ROOT/tools/prepare_html.py" "$ROOT/index.html" app/assets
sed -i.bak -E "s/versionCode=\"[0-9]+\" android:versionName=\"[^\"]+\"/versionCode=\"$V\" android:versionName=\"2.$V\"/" app/AndroidManifest.xml && rm -f app/AndroidManifest.xml.bak
rm -rf out && mkdir -p out/flat out/classes out/dex
"$BT/aapt2" compile --dir app/res -o out/flat/
"$BT/aapt2" link -o out/base.apk -I "$JAR" --manifest app/AndroidManifest.xml -A app/assets out/flat/*.flat --min-sdk-version 21 --target-sdk-version 35
javac -source 8 -target 8 -nowarn -bootclasspath "$JAR" -cp "$JAR" -d out/classes app/src/ru/patrol/smena2/MainActivity.java
"$BT/d8" --min-api 21 --lib "$JAR" --output out/dex $(find out/classes -name "*.class")
cp out/base.apk out/unsigned.apk && (cd out/dex && zip -q ../unsigned.apk classes.dex)
"$BT/zipalign" -f -p 4 out/unsigned.apk out/aligned.apk
"$BT/apksigner" sign --ks "$KS" --ks-key-alias "$ALIAS" --ks-pass "pass:$PASS" --key-pass "pass:$KPASS" --out "out/smena-patrulnogo-2-v$V.apk" out/aligned.apk
"$BT/apksigner" verify "out/smena-patrulnogo-2-v$V.apk" && echo "Готово: android-sdk-build/out/smena-patrulnogo-2-v$V.apk"
