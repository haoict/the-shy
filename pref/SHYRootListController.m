#include "SHYRootListController.h"

#define TWEAK_TITLE "The shy"
#define TINT_COLOR "#360107"
#define BUNDLE_NAME "SHYPref"

@implementation SHYRootListController
- (id)init {
  self = [super init];
  if (self) {
    self.tintColorHex = @TINT_COLOR;
    self.bundlePath = [NSString stringWithFormat:@"/Library/PreferenceBundles/%@.bundle", @BUNDLE_NAME];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[self localizedItem:@"APPLY"] style:UIBarButtonItemStylePlain target:self action:@selector(apply)];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  UIColor *tintColor = [HCommon colorFromHex:@"a61f32"];
  // set switches color
  UIWindow *keyWindow = [HCommon mainWindow];
  self.view.tintColor = tintColor;
  keyWindow.tintColor = tintColor;
  [UISwitch appearanceWhenContainedInInstancesOfClasses:@[self.class]].onTintColor = tintColor;
}

- (void)apply {
  [HCommon killProcess:@"backboardd" viewController:self alertTitle:@TWEAK_TITLE message:[self localizedItem:@"DO_YOU_REALLY_WANT_TO_RESPRING"] confirmActionLabel:[self localizedItem:@"CONFIRM"] cancelActionLabel:[self localizedItem:@"CANCEL"]];
}

@end
