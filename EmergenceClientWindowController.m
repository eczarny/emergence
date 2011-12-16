#import "EmergenceClientWindowController.h"
#import "EmergenceSynergyManager.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

@implementation EmergenceClientWindowController

static EmergenceClientWindowController *sharedInstance = nil;

- (id)init {
    if (self = [super initWithWindowNibName: EmergenceClientWindowNibName]) {
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

+ (EmergenceClientWindowController *)sharedController {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (void)awakeFromNib {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector(toggleClientWindow:)
                               name: EmergenceSynergyProcessStartedNotification
                             object: nil];
    
    [[self window] center];
}

#pragma mark -

- (void)showClientWindow: (id)sender {
    [self showWindow: sender];
}

- (void)hideClientWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)toggleClientWindow: (id)sender {
    if ([[self window] isKeyWindow]) {
        [self hideClientWindow: sender];
    } else {
        [self showClientWindow: sender];
    }
}

#pragma mark -

- (void)startSynergyClient: (id)sender {
    NSString *hostName = [myHostNameTextField stringValue];
    
    if ([EmergenceUtilities isStringEmpty: hostName]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: ZeroKitLocalizedString(@"OK")];
        
        [alert setMessageText: ZeroKitLocalizedString(@"Please provide more information")];
        [alert setInformativeText: ZeroKitLocalizedString(@"Emergence requires a valid hostname, or IP address, of the Synergy server.")];
        
        [alert runModal];
        
        return;
    }
    
    [mySynergyManager startSynergyClientAtHostName: hostName];
    
    [self hideClientWindow: self];
}

@end
