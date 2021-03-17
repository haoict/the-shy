
#import "Tweak.h"

static BOOL enable;
static double delay;
static BOOL dimIconsAndLabels;
static BOOL hideLabels;
static double iconOpacity;
static double labelOpacity;

static void reloadPrefs() {
  NSDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH] ?: [@{} mutableCopy];

  enable = [[settings objectForKey:@"enable"] ?: @(YES) boolValue];
  delay = [[settings objectForKey:@"delay"] doubleValue] ?: 1.0f;
  if (delay < 1.0f) {
    delay = 1.0f;
  }
  dimIconsAndLabels = [[settings objectForKey:@"dimIconsAndLabels"] ?: @(YES) boolValue];
  hideLabels = [[settings objectForKey:@"hideLabels"] ?: @(YES) boolValue];

  iconOpacity = ([settings objectForKey:@"iconOpacity"] == nil ? 50.0 : [[settings objectForKey:@"iconOpacity"] doubleValue]) / 100.0;
  labelOpacity = ([[settings objectForKey:@"labelOpacity"] doubleValue] ?: 0.0f) / 100.0;
}

static void animateIconListViewLabelsAlpha(SBIconListView *listView, double iconAlpha, double labelAlpha) {
  [UIView animateWithDuration:0.5 animations:^{
    if (dimIconsAndLabels) {
      [listView setAlphaForAllIcons:iconAlpha];
    }
    if (hideLabels) {
      [listView setIconsLabelAlpha:labelAlpha];
    }
  }];
}

static void prepareHideIconsLabelsWithDelay(id self, double _delay) {
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_hideIconsLabels) object:nil];
  [self performSelector:@selector(_hideIconsLabels) withObject:nil afterDelay:_delay];
}

static void prepareHideIconsLabels(id self) {
  prepareHideIconsLabelsWithDelay(self, delay);
}

%group Core

  %hook SBIconView
    // Label are becoming visible after dismissing the force touch context menu. This prevents that.
    - (void)setIconLabelAlpha:(double)alpha {
      if (!self.showingContextMenu) {
        %orig;
      }
    }
  %end

  /* Labels are visible when a new app is downloaded. */
  %hook SBApplicationPlaceholderController
    - (void)applicationPlaceholdersAdded:(id)arg1 {
      %orig;

      SBIconController *iconController = [%c(SBIconController) sharedInstance];
      [iconController.rootFolderController.contentView _hideIconsLabels];
    }
  %end

  %hook SBFolderController
    - (void)folderControllerDidOpen:(id)folderController {
      %orig;
      prepareHideIconsLabels(self);
    }

    -(void)folderControllerWillClose:(id)arg1 {
      %orig;
      SBIconController *iconController = [%c(SBIconController) sharedInstance];
      [iconController.rootFolderController.contentView _showIconsLabels];
      [self _showIconsLabels];
    }

    -(void)folderControllerDidClose:(id)arg1 {
      %orig;
      SBIconController *iconController = [%c(SBIconController) sharedInstance];
      prepareHideIconsLabels(iconController.rootFolderController.contentView);
    }

    %new
    - (void)_hideIconsLabels {
      animateIconListViewLabelsAlpha(self.currentIconListView, iconOpacity, labelOpacity);
    }

    %new
    - (void)_showIconsLabels {
      animateIconListViewLabelsAlpha(self.currentIconListView, 1.0f, 1.0f);
    }
  %end

  %hook SBCoverSheetIconFlyInAnimator
    -(void)_prepareAnimation {
      %orig;
      SBIconController *iconController = [%c(SBIconController) sharedInstance];
      [iconController.rootFolderController.contentView _showIconsLabels];
    }

    /* This method shows the labels after unlock. Our own hide animation
      is applied here.
      While the SBCoverSheetIconFlyInAnimator object itself has a property
      to the `iconListView`, the SBRootFolderView is used as it will use
      the same performSelector queue as when scrolling.
      This seems to result in the most elegant solution. */
    - (void)_cleanupAnimation {
      %orig;
      /* The 1.8f might seem like a magic number, but it was the measured
        time of the unlock animation from start to finish. It was measured
        from `SBBiometricEventLogger`'s method `_unlockAnimationWillStart`
        to this call. */
      SBIconController *iconController = [%c(SBIconController) sharedInstance];
      prepareHideIconsLabelsWithDelay(iconController.rootFolderController.contentView, MAX(delay - 1.8f, 0));
    }
  %end

  %hook SBMainSwitcherViewController
    // back to springboard
    - (void)switcherContentController:(id)arg1 setContainerStatusBarHidden:(BOOL)arg2 animationDuration:(double)arg3 {
      %orig;
      if (arg2 == false) {
        SBIconController *iconController = [%c(SBIconController) sharedInstance];
        [iconController.rootFolderController.contentView _showIconsLabels];
        prepareHideIconsLabelsWithDelay(iconController.rootFolderController.contentView, MAX(delay, 1.0));
      }
    }
  %end

  %hook SBFolderView
    - (void)scrollViewDidEndDragging:(id)scrollView willDecelerate:(BOOL)decelerate {
      %orig;
      prepareHideIconsLabels(self);
    }

    - (void)scrollViewWillBeginDragging:(id)scrollView {
      %orig;
      [self _showIconsLabels];
    }

    -(void)pageControl:(id)arg1 didMoveCurrentPageToPage:(long long)arg2 withScrubbing:(BOOL)arg3 {
      %orig;

      if ([self respondsToSelector: @selector(dockListView)]) {
        animateIconListViewLabelsAlpha(self.dockListView, 1.0f, 1.0f);
      }
      prepareHideIconsLabels(self);
    }

    /* Dropping an icon in editing mode leaves the label as visible. */
    - (void)iconListView:(id)arg1 iconDragItem:(id)arg2 willAnimateDropWithAnimator:(id)arg3 {
      %orig;
      // prepareHideIconsLabelsWithDelay(self, MAX(delay, 1.2f));
    }

    %new
    - (void)_hideIconsLabels {
      animateIconListViewLabelsAlpha(self.currentIconListView, iconOpacity, labelOpacity);
      if ([self respondsToSelector: @selector(dockListView)]) {
        animateIconListViewLabelsAlpha(self.dockListView, iconOpacity, labelOpacity);
      }
    }

    %new
    - (void)_showIconsLabels {
      animateIconListViewLabelsAlpha(self.currentIconListView, 1.0f, 1.0f);
      if ([self respondsToSelector: @selector(dockListView)]) {
        animateIconListViewLabelsAlpha(self.dockListView, 1.0f, 1.0f);
      }
    }
  %end

%end

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) reloadPrefs, CFSTR(PREF_CHANGED_NOTIF), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
  reloadPrefs();

  if (enable) {
    %init(Core);
  }
}