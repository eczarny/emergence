#import <Cocoa/Cocoa.h>

@class EmergenceSynergyManager;

@interface EmergenceClientWindowController : NSWindowController {
    EmergenceSynergyManager *mySynergyManager;
    IBOutlet NSTextField *myHostNameTextField;
}

+ (EmergenceClientWindowController *)sharedController;

#pragma mark -

- (void)showClientWindow: (id)sender;

- (void)hideClientWindow: (id)sender;

#pragma mark -

- (void)toggleClientWindow: (id)sender;

#pragma mark -

- (void)startSynergyClient: (id)sender;

@end
