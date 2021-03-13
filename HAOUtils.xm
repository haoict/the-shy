#import <libhdev/HUtilities/HLicenseManager.h>

#define DOCUMENT_DIR_PLIST_FILENAME "com.haoict.theshypref.plist"
#define TWEAK_NAME "The shy"
#define TWEAK_VERSION "1.1.0"

%ctor {
  [HLicenseManager licenseTracker:@"" apiKey:@"" plistFile:@DOCUMENT_DIR_PLIST_FILENAME tweakName:@TWEAK_NAME tweakVersion:@TWEAK_VERSION];
}
