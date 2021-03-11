ARCHS = arm64 arm64e
TARGET = iphone:clang:14.4:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = theshy
theshy_FILES = $(wildcard *.xm *.m)
theshy_EXTRA_FRAMEWORKS = libhdev
theshy_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += pref

include $(THEOS_MAKE_PATH)/aggregate.mk

clean::
	rm -rf .theos packages