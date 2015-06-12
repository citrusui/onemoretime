include theos/makefiles/common.mk

BUNDLE_NAME = OneMoreTime
OneMoreTime_FILES = GPMTRootListController.m GPMTMiscListController.m
OneMoreTime_INSTALL_PATH = /Library/PreferenceBundles
OneMoreTime_FRAMEWORKS = UIKit
OneMoreTime_PRIVATE_FRAMEWORKS = Preferences
OneMoreTime_LIBRARIES = cepheiprefs
ARCHS = armv7 armv7s arm64
TARGET=iphone:clang:8.1:7.0


include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/OneMoreTime.plist$(ECHO_END)
