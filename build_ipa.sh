#!/bin/bash
#
# build_ipa.sh - 编译 GG Modifier 并打包成 IPA
#
# 用法:
#   chmod +x build_ipa.sh
#   ./build_ipa.sh
#

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "========================================="
echo "  GG Modifier - IPA 构建脚本"
echo "========================================="
echo ""

# 检查 Theos 环境
if [ -z "$THEOS" ]; then
    echo "[!] 未设置 THEOS 环境变量"
    echo "    请执行: export THEOS=~/theos"
    exit 1
fi

if [ ! -d "$THEOS" ]; then
    echo "[!] Theos 目录不存在: $THEOS"
    exit 1
fi

echo "[1/4] 清理旧构建..."
make clean
rm -rf packages .theos/ipa
mkdir -p packages

echo ""
echo "[2/4] 编译源码..."
make stage -j$(sysctl -n hw.ncpu)

echo ""
echo "[3/4] 打包 IPA..."
BUILD_DIR=".theos/obj/arm64"
APP_BUNDLE="$BUILD_DIR/GGMod.app"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "[!] 错误: 未找到编译产物 $APP_BUNDLE"
    echo "    请检查编译日志"
    exit 1
fi

# 创建 IPA 目录结构
IPA_DIR=".theos/ipa_build"
rm -rf "$IPA_DIR"
mkdir -p "$IPA_DIR/Payload"

# 复制 app bundle
cp -r "$APP_BUNDLE" "$IPA_DIR/Payload/"

# 用 ldid 签名（越狱设备可用）
if command -v ldid &> /dev/null; then
    echo "[+] 使用 ldid 签名..."
    ldid -S "$IPA_DIR/Payload/GGMod.app/GGMod"
else
    echo "[!] 未找到 ldid，跳过签名"
    echo "    注意: 未签名的 IPA 需要用 TrollStore / 越狱侧载安装"
fi

# 打包成 IPA
cd "$IPA_DIR"
zip -r "../../packages/GGMod.ipa" Payload
cd "$PROJECT_DIR"

echo ""
echo "[4/4] 完成！"
echo "========================================="
echo "  IPA 路径: $PROJECT_DIR/packages/GGMod.ipa"
echo "========================================="
echo ""
echo "安装方式:"
echo "  1. TrollStore: 直接导入 GGMod.ipa 安装"
echo "  2. 越狱设备: 用 Filza 打开 ipa 安装，或用 dpkg 转换"
echo "  3. 侧载工具: AltStore / Sideloadly 签名后安装"
echo ""
echo "注意: 内存修改功能需要越狱环境才能正常工作！"
