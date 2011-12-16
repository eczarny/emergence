#import <Cocoa/Cocoa.h>

@class EmergencePreferencesWindowController, EmergenceClientWindowController, EmergenceServerWindowController, EmergenceSynergyManager;

@interface EmergenceApplicationController : NSObject {
    EmergenceClientWindowController *myClientWindowController;
    EmergenceServerWindowController *myServerWindowController;
    EmergenceSynergyManager *mySynergyManager;
    NSStatusItem *myStatusItem;
}

- (void)togglePreferencesWindow: (id)sender;

#pragma mark -

- (void)showClientWindow: (id)sender;

- (void)showServerWindow: (id)sender;

#pragma mark -

- (void)stopSynergy: (id)sender;

@end
