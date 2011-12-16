#import <Cocoa/Cocoa.h>

@class EmergenceSynergyProcess;

@interface EmergenceSynergyManager : NSObject {
    EmergenceSynergyProcess *mySynergyProcess;
}

+ (EmergenceSynergyManager *)sharedManager;

#pragma mark -

- (BOOL)configureSynergyServerWithLeftScreen: (NSString *)leftScreen rightScreen: (NSString *)rightScreen error: (NSError **)error;

#pragma mark -

- (void)startSynergyClientAtHostName: (NSString *)hostName;

- (void)startSynergyServer;

#pragma mark -

- (void)stopSynergy;

#pragma mark -

- (BOOL)isSynergyRunning;

#pragma mark -

- (BOOL)isSynergyClientRunning;

- (BOOL)isSynergyServerRunning;

#pragma mark -

- (void)synchronizeSynergyProcessWithFilesystem;

@end
