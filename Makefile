include theos/makefiles/common.mk

TWEAK_NAME = OneMoreTime
OneMoreTime_FILES = Tweak.xm
ARCHS=armv7 armv7s arm64
DEBUG=0
TARGET=iphone:clang:8.1:7.0

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/tweak.mk


after-install::
	install.exec "killall -9 SpringBoard"

SUBPROJECTS = prefs
include $(THEOS_MAKE_PATH)/aggregate.mk