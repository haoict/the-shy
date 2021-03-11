ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SHYPref
SHYPref_FILES = $(wildcard *.m)
SHYPref_INSTALL_PATH = /Library/PreferenceBundles
SHYPref_PRIVATE_FRAMEWORKS = Preferences
SHYPref_EXTRA_FRAMEWORKS = libhdev
SHYPref_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SHYPref.plist$(ECHO_END)
