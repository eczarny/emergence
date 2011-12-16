#import "EmergenceServerWindowController.h"
#import "EmergenceSynergyManager.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

@implementation EmergenceServerWindowController

static EmergenceServerWindowController *sharedInstance = nil;

- (id)init {
    if (self = [super initWithWindowNibName: EmergenceServerWindowNibName]) {
        mySynergyManager = [EmergenceSynergyManager sharedManager];
    }
    
    return self;
}

#pragma mark -

+ (id)allocWithZone: (NSZone *)zone {
    @synchronized(self) {
        if (!sharedInstance) {
            sharedInstance = [super allocWithZone: zone];
            
            return sharedInstance;
        }
    }
    
    return nil;
}

#pragma mark -

+ (EmergenceServerWindowController *)sharedController {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (void)awakeFromNib {
    [[self window] center];
}

#pragma mark -

- (void)showServerWindow: (id)sender {
    [self showWindow: sender];
}

- (void)hideServerWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)toggleServerWindow: (id)sender {
    if ([[self window] isKeyWindow]) {
        [self hideServerWindow: sender];
    } else {
        [self showServerWindow: sender];
    }
}

#pragma mark -

- (void)startSynergyServer: (id)sender {
    NSString *leftScreen = [myLeftScreenTextField stringValue];
    NSString *rightScreen = [myRightScreenTextField stringValue];
    
    if ([EmergenceUtilities isStringEmpty: leftScreen] && [EmergenceUtilities isStringEmpty: rightScreen]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: ZeroKitLocalizedString(@"OK")];
        
        [alert setMessageText: ZeroKitLocalizedString(@"Please provide more information")];
        [alert setInformativeText: ZeroKitLocalizedString(@"Emergence requires a valid hostname, or IP address, of at least one Synergy client.")];
        
        [alert runModal];
        
        return;
    }
    
    if (![mySynergyManager configureSynergyServerWithLeftScreen: leftScreen rightScreen: rightScreen error: nil]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: ZeroKitLocalizedString(@"OK")];
        
        [alert setMessageText: ZeroKitLocalizedString(@"Unable to configure the Synergy server")];
        [alert setInformativeText: ZeroKitLocalizedString(@"There was a problem configuring the Synergy server, please try again.")];
        
        [alert runModal];
        
        return;
    }
    
    [mySynergyManager startSynergyServer];
    
    [self hideServerWindow: self];
}

@end
