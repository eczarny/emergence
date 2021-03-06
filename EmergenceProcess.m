#import "EmergenceProcess.h"

@interface EmergenceProcess (EmergenceProcessPrivate)

- (void)getData: (NSNotification *)notification;

#pragma mark -

- (void)killProcess;

@end

#pragma mark -

@implementation EmergenceProcess

- (id)initWithArguments: (NSArray *)arguments delegate: (id<EmergenceProcessDelegate>)delegate {
    if (self = [super init]) {
        myTask = nil;
        myStandardInput = nil;
        myStandardOutput = nil;
        myArguments = [arguments retain];
        myProcessIdentifier = -1;
        myDelegate = delegate;
    }
    
    return self;
}

- (id)initWithDelegate: (id<EmergenceProcessDelegate>)delegate {
    if (self = [super init]) {
        myTask = nil;
        myStandardInput = nil;
        myStandardOutput = nil;
        myArguments = nil;
        myProcessIdentifier = -1;
        myDelegate = delegate;
    }
    
    return self;
}

#pragma mark -

- (id)initWithCoder: (NSCoder *)coder {
    if (self = [super init]) {
        myProcessIdentifier = [coder decodeIntegerForKey: @"processIdentifier"];
        myDelegate = [coder decodeObjectForKey: @"delegate"];
    }
    
    return self;
}

#pragma mark -

- (void)encodeWithCoder: (NSCoder *)coder {
    [coder encodeInteger: myProcessIdentifier forKey: @"processIdentifier"];
    [coder encodeObject: myDelegate forKey: @"delegate"];
}

#pragma mark -

- (NSArray *)arguments {
    return myArguments;
}

- (void)setArguments: (NSArray *)arguments {
    if (myArguments != arguments) {
        [myArguments release];
        
        myArguments = [arguments retain];
    }
}

#pragma mark -

- (NSInteger)processIdentifier {
    return myProcessIdentifier;
}

#pragma mark -

- (void)startProcess {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    if ([self isProcessRunning]) {
        NSLog(@"The process is already running. Unable to start another.");
        
        return;
    }
    
    if (!myArguments || (myArguments && ([myArguments count] < 1))) {
        NSLog(@"Unable to start the process, invalid arguments: %@", myArguments);
        
        return;
    }
    
    myTask = [[NSTask alloc] init];
    
    [myTask setStandardInput: [NSPipe pipe]];
    [myTask setStandardOutput: [NSPipe pipe]];
    [myTask setStandardError: [myTask standardOutput]];
    [myTask setLaunchPath: [myArguments objectAtIndex: 0]];
    [myTask setArguments: [myArguments subarrayWithRange: NSMakeRange(1, [myArguments count] - 1)]];
    
    myStandardInput = [[[myTask standardInput] fileHandleForWriting] retain];
    myStandardOutput = [[[myTask standardOutput] fileHandleForReading] retain];
    
    [notificationCenter addObserver: self
                           selector: @selector(getData:)
                               name: NSFileHandleReadCompletionNotification
                             object: myStandardOutput];
    
    [myStandardOutput readInBackgroundAndNotify];
    
    [myTask launch];
    
    [myDelegate processDidStart: self];
    
    NSInteger processIdentifier = [myTask processIdentifier];
    
    if (processIdentifier) {
        myProcessIdentifier = processIdentifier;
    }
}

- (void)stopProcess {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    NSData *data;
    
    if (!myTask) {
        NSLog(@"Unable to terminate the task, attempting to kill the process instead.");
        
        [self killProcess];
        
        return;
    }
    
    [notificationCenter removeObserver: self
                                  name: NSFileHandleReadCompletionNotification
                                object: myStandardOutput];
    
    [myTask terminate];
    
    while ((data = [myStandardOutput availableData]) && [data length]) {
        [myDelegate process: self didReceiveData: data];
    }
    
    [myDelegate processDidStop: self];
    
    myProcessIdentifier = -1;
}

#pragma mark -

- (BOOL)isProcessRunning {
    if (!myTask) {
        if ((myProcessIdentifier > -1) && !kill(myProcessIdentifier, 0)) {
            return YES;
        } else {
            return NO;
        }
    }
    
    return [myTask isRunning];
}

#pragma mark -

- (void)dealloc {
    [myTask release];
    [myStandardInput release];
    [myStandardOutput release];
    [myArguments release];
    
    [super dealloc];
}

@end

#pragma mark -

@implementation EmergenceProcess (EmergenceProcess)

- (void)getData: (NSNotification *)notification {
    NSData *data = [[notification userInfo] objectForKey: NSFileHandleNotificationDataItem];
    
    if([data length]) {
        [myDelegate process: self didReceiveData: data];
    } else {
        [self stopProcess];
    }
    
    [[notification object] readInBackgroundAndNotify];
}

#pragma mark -

- (void)killProcess {
    if (myProcessIdentifier == -1) {
        NSLog(@"Unable to kill the process, no process identifier defined.");
        
        return;
    }
    
    kill(myProcessIdentifier, 15);
    
    [myDelegate processDidStop: self];
    
    myProcessIdentifier = -1;
}

@end
