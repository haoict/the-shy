#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <libhdev/HUtilities/HCommon.h>

#define PLIST_PATH "/var/mobile/Library/Preferences/com.haoict.theshypref.plist"
#define PREF_CHANGED_NOTIF "com.haoict.theshypref/PrefChanged"

@interface SBIconView
@property (assign, nonatomic) double iconLabelAlpha;
@property (getter=isShowingContextMenu, nonatomic, readonly) BOOL showingContextMenu; 
- (void)setIconImageAlpha:(double)alpha;
- (void)setLabelAccessoryViewHidden:(BOOL)hidden;
@end

@interface SBIconListView : UIView
- (void)setIconsLabelAlpha:(double)alpha;
- (void)setAlphaForAllIcons:(double)alpha;
@end

@interface SBFolderView : UIView
@property (nonatomic, readonly) SBIconListView *currentIconListView;
@property (nonatomic, readonly) SBIconListView *dockListView; 
@end

@interface SBFolderView (TheShy)
- (void)_hideIconsLabels;
- (void)_showIconsLabels;
@end


@interface SBFolderController : NSObject
@property (nonatomic, readonly) SBIconListView *currentIconListView;
@property (nonatomic, readonly) SBIconListView *dockListView; 
@property (nonatomic, readonly) SBIconListView *dockIconListView;
@end

@interface SBFolderController (TheShy)
- (void)_hideIconsLabels;
- (void)_showIconsLabels;
@end

@interface SBRootFolderController : SBFolderController
@property (nonatomic, readonly) SBFolderView *contentView;
@end

@interface SBIconController : NSObject
@property (getter=_rootFolderController, nonatomic, readonly) SBRootFolderController *rootFolderController;
+ (id)sharedInstance;
@end
