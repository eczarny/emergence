#import <Cocoa/Cocoa.h>

@class EmergenceProcess;

@protocol EmergenceProcessDelegate

- (void)processDidStart: (EmergenceProcess *)process;

- (void)processDidStop: (EmergenceProcess *)process;

#pragma mark -

- (void)process: (EmergenceProcess *)process didFailWithError: (NSError *)error;

#pragma mark -

- (void)process: (EmergenceProcess *)process didReceiveData: (NSData *)data;

@end
