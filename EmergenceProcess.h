#import <Cocoa/Cocoa.h>
#import "EmergenceProcessDelegate.h"

@interface EmergenceProcess : NSObject<NSCoding> {
    NSTask *myTask;
    NSFileHandle *myStandardInput;
    NSFileHandle *myStandardOutput;
    NSArray *myArguments;
    NSInteger myProcessIdentifier;
    id<EmergenceProcessDelegate> myDelegate;
}

- (id)initWithArguments: (NSArray *)arguments delegate: (id<EmergenceProcessDelegate>)delegate;

- (id)initWithDelegate: (id<EmergenceProcessDelegate>)delegate;

#pragma mark -

- (NSArray *)arguments;

- (void)setArguments: (NSArray *)arguments;

#pragma mark -

- (NSInteger)processIdentifier;

#pragma mark -

- (void)startProcess;

- (void)stopProcess;

#pragma mark -

- (BOOL)isProcessRunning;

@end
