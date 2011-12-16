#import "EmergenceGeneralPreferencePane.h"
#import "EmergenceUtilities.h"

@implementation EmergenceGeneralPreferencePane

- (void)preferencePaneDidLoad {
    NSInteger loginItemEnabledState = NSOffState;
    
    if ([EmergenceUtilities isLoginItemEnabledForBundle: [EmergenceUtilities applicationBundle]]) {
        loginItemEnabledState = NSOnState;
    }
    
    [myLoginItemEnabled setState: loginItemEnabledState];
}

#pragma mark -

- (NSString *)name {
    return ZeroKitLocalizedString(@"General");
}

#pragma mark -

- (NSImage *)icon {
    return [EmergenceUtilities imageFromResource: @"General Preferences" inBundle: [EmergenceUtilities applicationBundle]];
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

- (void)toggleLoginItem: (id)sender {
    if ([myLoginItemEnabled state] == NSOnState) {
        [EmergenceUtilities enableLoginItemForBundle: [EmergenceUtilities applicationBundle]];
    } else{
        [EmergenceUtilities disableLoginItemForBundle: [EmergenceUtilities applicationBundle]];
    }
}

@end
