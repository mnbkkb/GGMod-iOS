THEOS = /var/theos
export ARCHS = arm64 arm64e
export TARGET = iphone:clang:14.5:14.5

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = GGMod
GGMod_FILES = $(wildcard GGMod/*.m) $(wildcard GGMod/Models/*.m)
GGMod_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-deprecated-declarations
GGMod_FRAMEWORKS = UIKit CoreFoundation Foundation
GGMod_PRIVATE_FRAMEWORKS = GraphicsServices
GGMod_CODESIGN_IPA = ldid -S

include $(THEOS_MAKE_PATH)/application.mk

# ============================================
# 自定义 IPA 打包目标
# ============================================
IPA_NAME = GGMod
IPA_OUTPUT_DIR = ./packages

# 默认目标：编译 + 打包 IPA
all:: ipa

ipa:: stage
	@echo "[+] 正在打包 IPA..."
	@mkdir -p $(IPA_OUTPUT_DIR)
	@mkdir -p .theos/ipa/Payload
	@cp -r .theos/obj/$(THEOS_CURRENT_ARCH)/GGMod.app .theos/ipa/Payload/
	@# 用 ldid 签名（越狱设备用）
	@ldid -S .theos/ipa/Payload/GGMod.app/GGMod 2>/dev/null || true
	@# 打包成 ipa
	@cd .theos/ipa && zip -r ../../$(IPA_OUTPUT_DIR)/$(IPA_NAME).ipa Payload
	@echo "[✓] IPA 已生成: $(IPA_OUTPUT_DIR)/$(IPA_NAME).ipa"

# 清理
clean::
	@rm -rf .theos/ipa $(IPA_OUTPUT_DIR)
