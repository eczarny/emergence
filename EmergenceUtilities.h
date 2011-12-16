#import <Cocoa/Cocoa.h>

@class EmergenceProcess;

@interface EmergenceUtilities : ZeroKitUtilities {
    
}

+ (NSString *)synergyClientPath;

+ (NSString *)synergyServerPath;

#pragma mark -

+ (NSString *)synergyConfigurationFilePath;

#pragma mark -

+ (BOOL)saveProcess: (EmergenceProcess *)process toFile: (NSString *)file;

+ (EmergenceProcess *)processFromFile: (NSString *)file;

@end
