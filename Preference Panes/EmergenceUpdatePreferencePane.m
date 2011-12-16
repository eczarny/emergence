#import "EmergenceUpdatePreferencePane.h"
#import "EmergenceUtilities.h"

@implementation EmergenceUpdatePreferencePane

- (void)preferencePaneDidLoad {
    if ([mySparkleUpdater automaticallyChecksForUpdates]) {
        [myCheckForUpdatesButton setState: NSOnState];
    } else {
        [myCheckForUpdatesButton setState: NSOffState];
    }
}

#pragma mark -

- (NSString *)name {
    return ZeroKitLocalizedString(@"Update");
}

#pragma mark -

- (NSImage *)icon {
    return [EmergenceUtilities imageFromResource: @"Update Preferences" inBundle: [EmergenceUtilities applicationBundle]];
}

#pragma mark -

- (NSString *)toolTip {
    return nil;
}

#pragma mark -

- (NSView *)view {
    return myView;
}

#pragma mark -

- (void)toggleCheckForUpdates: (id)sender {
    [mySparkleUpdater setAutomaticallyChecksForUpdates: ![mySparkleUpdater automaticallyChecksForUpdates]];
}

@end
