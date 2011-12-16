#import "EmergenceSynergyProcess.h"
#import "EmergenceConstants.h"

@implementation EmergenceSynergyProcess

- (id)initWithArguments: (NSArray *)arguments processType: (SynergyProcessType)processType {
    if (self = [super initWithArguments: arguments delegate: self]) {
        myProcessType = processType;
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder *)coder {
    if (self = [super initWithCoder: coder]) {
        myProcessType = [coder decodeIntegerForKey: @"processType"];
    }
    
    return self;
}

#pragma mark -

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeInteger: myProcessType forKey: @"processType"];
    
    [super encodeWithCoder: coder];
}

#pragma mark -

- (SynergyProcessType)processType {
    return myProcessType;
}

- (void)setProcessType: (SynergyProcessType)processType {
    myProcessType = processType;
}

#pragma mark -

#pragma mark Process Delegate Methods

#pragma mark -

- (void)processDidStart: (EmergenceProcess *)process {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process has been started with the following arguments: %@", myArguments);
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessStartedNotification object: self];
}

- (void)processDidStop: (EmergenceProcess *)process {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process has been stopped.");
    
    myProcessType = SynergyProcessTypeError;
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessFinishedNotification object: self];
}

#pragma mark -

- (void)process: (EmergenceProcess *)process didFailWithError: (NSError *)error {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process failed.");
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessFailedNotification object: self];
}

#pragma mark -

- (void)process: (EmergenceProcess *)process didReceiveData: (NSData *)data {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSString *output = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    NSRange range;
    
    NSLog(@"The Synergy process received data: %@", output);
    
    range = [output rangeOfString: EmergenceSynergyConnectionRefusedString];
    
    if (range.location != NSNotFound) {
        NSLog(@"The Synergy connection has been refused.");
        
        [self stopProcess];
        
        [notificationCenter postNotificationName: EmergenceSynergyConnectionRefusedNotification object: self];
    }
    
    range = [output rangeOfString: EmergenceSynergyErrorString];
    
    if (range.location != NSNotFound) {
        NSLog(@"Synergy encountered a fatal error.");
        
        [self stopProcess];
        
        [notificationCenter postNotificationName: EmergenceSynergyFatalErrorNotification object: self];
    }
}

@end
