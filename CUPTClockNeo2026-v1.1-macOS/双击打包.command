#!/bin/bash
# CUPTClockNeo 2026 · macOS 一键打包
# 用法：双击本文件；若提示"无法打开"，右键 → 打开。
# 需要联网（只下载一次 Electron 运行时，约 115 MB）。

set -e
cd "$(dirname "$0")"

V="45.3.2"
ARCH="$(uname -m)"
if [ "$ARCH" = "arm64" ]; then EARCH="arm64"; else EARCH="x64"; fi

echo "=============================================="
echo " CUPTClockNeo 2026 · macOS 打包"
echo " 本机架构：$ARCH（下载 darwin-$EARCH）"
echo "=============================================="
echo ""

URL="https://npmmirror.com/mirrors/electron/$V/electron-v$V-darwin-$EARCH.zip"
echo "[1/5] 下载 Electron $V ..."
curl -L --fail --progress-bar -o electron.zip "$URL"

echo ""
echo "[2/5] 解压 ..."
rm -rf Electron.app "CUPTClockNeo2026-v1.1.app"
unzip -q electron.zip
mv Electron.app "CUPTClockNeo2026-v1.1.app"
APP="CUPTClockNeo2026-v1.1.app"

echo "[3/5] 装入程序 ..."
rm -f "$APP/Contents/Resources/default_app.asar"
mkdir -p "$APP/Contents/Resources/app"
cp -R app/. "$APP/Contents/Resources/app/"

if [ -f icon.icns ]; then
  cp icon.icns "$APP/Contents/Resources/electron.icns"
fi

echo "[4/5] 写入应用信息 ..."
PB=/usr/libexec/PlistBuddy
PL="$APP/Contents/Info.plist"
$PB -c "Set :CFBundleName CUPTClockNeo 2026" "$PL" 2>/dev/null || $PB -c "Add :CFBundleName string CUPTClockNeo 2026" "$PL"
$PB -c "Set :CFBundleDisplayName CUPTClockNeo 2026" "$PL" 2>/dev/null || $PB -c "Add :CFBundleDisplayName string CUPTClockNeo 2026" "$PL"
$PB -c "Set :CFBundleIdentifier com.torchwood.cuptclockneo" "$PL" 2>/dev/null || $PB -c "Add :CFBundleIdentifier string com.torchwood.cuptclockneo" "$PL"
$PB -c "Set :CFBundleShortVersionString 1.0.0" "$PL" 2>/dev/null || $PB -c "Add :CFBundleShortVersionString string 1.0.0" "$PL"
$PB -c "Set :CFBundleVersion 1.0.0" "$PL" 2>/dev/null || $PB -c "Add :CFBundleVersion string 1.0.0" "$PL"

echo "[5/5] 清理并解除隔离标记 ..."
xattr -cr "$APP" 2>/dev/null || true
rm -f electron.zip

echo ""
echo "=============================================="
echo " 完成：$(pwd)/$APP"
echo ""
echo " 双击即可运行。若系统提示「无法验证开发者」，"
echo " 请右键点击 app → 选择「打开」。"
echo " 也可以把它拖进「应用程序」文件夹。"
echo "=============================================="
echo ""
open .
