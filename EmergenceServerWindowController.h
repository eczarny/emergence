#import <Cocoa/Cocoa.h>

@class EmergenceSynergyManager;

@interface EmergenceServerWindowController : NSWindowController {
    EmergenceSynergyManager *mySynergyManager;
    IBOutlet NSTextField *myLeftScreenTextField;
    IBOutlet NSTextField *myRightScreenTextField;
}

+ (EmergenceServerWindowController *)sharedController;

#pragma mark -

- (void)showServerWindow: (id)sender;

- (void)hideServerWindow: (id)sender;

#pragma mark -

- (void)toggleServerWindow: (id)sender;

#pragma mark -

- (void)startSynergyServer: (id)sender;

@end
