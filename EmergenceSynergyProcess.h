#import <Cocoa/Cocoa.h>
#import "EmergenceProcess.h"

typedef enum {
    SynergyProcessTypeError = -1,
    SynergyProcessTypeClient,
    SynergyProcessTypeServer
} SynergyProcessType;

#pragma mark -

@interface EmergenceSynergyProcess : EmergenceProcess<NSCoding, EmergenceProcessDelegate> {
    SynergyProcessType myProcessType;
}

- (id)initWithArguments: (NSArray *)arguments processType: (SynergyProcessType)processType;

#pragma mark -

- (SynergyProcessType)processType;

- (void)setProcessType: (SynergyProcessType)type;

@end
