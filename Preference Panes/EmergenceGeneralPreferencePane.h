#import <Cocoa/Cocoa.h>

@interface EmergenceGeneralPreferencePane : NSObject<ZeroKitPreferencePaneProtocol> {
    IBOutlet NSView *myView;
    IBOutlet NSButton *myLoginItemEnabled;
}

- (NSString *)name;

#pragma mark -

- (NSImage *)icon;

#pragma mark -

- (NSString *)toolTip;

#pragma mark -

- (NSView *)view;

#pragma mark -

- (void)toggleLoginItem: (id)sender;

@end
