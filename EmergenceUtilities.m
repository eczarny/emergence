#import "EmergenceUtilities.h"
#import "EmergenceProcess.h"
#import "EmergenceConstants.h"

@interface EmergenceUtilities (EmergenceUtilitiesPrivate)

+ (NSString *)pathForSynergyExecutable: (NSString *)synergyExecutable;

@end

#pragma mark -

@implementation EmergenceUtilities

+ (NSString *)synergyClientPath {
    return [EmergenceUtilities pathForSynergyExecutable: EmergenceSynergyClientExecutable];
}

+ (NSString *)synergyServerPath {
    return [EmergenceUtilities pathForSynergyExecutable: EmergenceSynergyServerExecutable];
}

#pragma mark -

+ (NSString *)synergyConfigurationFilePath {
    NSString *applicationSupportPath = [EmergenceUtilities applicationSupportPathForBundle: [EmergenceUtilities applicationBundle]];
    
    return [applicationSupportPath stringByAppendingPathComponent: EmergenceSynergyConfigurationFile];
}

#pragma mark -

+ (BOOL)saveProcess: (EmergenceProcess *)process toFile: (NSString *)file {
    NSString *processPath = [[EmergenceUtilities applicationSupportPathForBundle: [EmergenceUtilities applicationBundle]] stringByAppendingPathComponent: file];
    
    return [NSKeyedArchiver archiveRootObject: process toFile: processPath];
}

+ (EmergenceProcess *)processFromFile: (NSString *)file {
    NSString *processPath = [[EmergenceUtilities applicationSupportPathForBundle: [EmergenceUtilities applicationBundle]] stringByAppendingPathComponent: file];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile: processPath];
}

@end

#pragma mark -

@implementation EmergenceUtilities (EmergenceUtilitiesPrivate)

+ (NSString *)pathForSynergyExecutable: (NSString *)synergyExecutable {
    NSString *executablesPath = [[[EmergenceUtilities applicationBundle] executablePath] stringByDeletingLastPathComponent];
    NSString *synergyExecutablesPath = [executablesPath stringByAppendingPathComponent: EmergenceSynergyExecutablesDirectory];
    
    return [synergyExecutablesPath stringByAppendingPathComponent: synergyExecutable];
}

@end
