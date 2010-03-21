// 
// Copyright (c) 2010 Eric Czarny <eczarny@gmail.com>
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of  this  software  and  associated documentation files (the "Software"), to
// deal  in  the Software without restriction, including without limitation the
// rights  to  use,  copy,  modify,  merge,  publish,  distribute,  sublicense,
// and/or sell copies  of  the  Software,  and  to  permit  persons to whom the
// Software is furnished to do so, subject to the following conditions:
// 
// The  above  copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE  SOFTWARE  IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED,  INCLUDING  BUT  NOT  LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS  OR  COPYRIGHT  HOLDERS  BE  LIABLE  FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY,  WHETHER  IN  AN  ACTION  OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
// 

// 
// Emergence
// EmergenceSynergyManager.m
// 
// Created by Eric Czarny on Tuesday, March 3, 2009.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "EmergenceSynergyManager.h"
#import "EmergenceSynergyProcess.h"
#import "EmergenceProcess.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

typedef enum {
    SynergyClientOrientationLeft,
    SynergyClientOrientationRight,
    SynergyClientOrientationBoth
} SynergyClientOrientation;

#pragma mark -

@interface EmergenceSynergyManager (EmergenceSynergyManagerPrivate)

- (SynergyClientOrientation)orientationWithLeftScreen: (NSString *)leftScreen rightScreen: (NSString *)rightScreen;

#pragma mark -

- (NSString *)configureClientWithScreen: (NSString *)screen orientation: (SynergyClientOrientation)orientation template: (NSString *)template;

@end

#pragma mark -

@implementation EmergenceSynergyManager

static EmergenceSynergyManager *sharedInstance = nil;

- (id)init {
    if (self = [super init]) {
        mySynergyProcess = nil;
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

+ (EmergenceSynergyManager *)sharedManager {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (BOOL)configureSynergyServerWithLeftScreen: (NSString *)leftScreen rightScreen: (NSString *)rightScreen error: (NSError **)error {
    NSString *configurationFilePath = [EmergenceUtilities synergyConfigurationFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    SynergyClientOrientation orientation = [self orientationWithLeftScreen: leftScreen rightScreen: rightScreen];
    NSString *hostName = [[NSProcessInfo processInfo] hostName];
    NSString *configurationTemplatePath = nil;
    NSString *configurationTemplate = nil;
    NSString *configuration = nil;
    
    if ([fileManager fileExistsAtPath: configurationFilePath]) {
        if (![fileManager removeItemAtPath: configurationFilePath error: error]) {
            NSLog(@"Unable to remove the existing Synergy configuration file at path: %@", configurationFilePath);
            
            return NO;
        }
    }
    
    if (orientation == SynergyClientOrientationBoth) {
        configurationTemplate = EmergenceSynegyServerConfigurationTemplate2;
    } else {
        configurationTemplate = EmergenceSynegyServerConfigurationTemplate1;
    }
    
    configurationTemplatePath = [[EmergenceUtilities applicationBundle] pathForResource: configurationTemplate ofType: EmergenceSynergyConfigurationFileExtension];    
    configurationTemplate = [NSString stringWithContentsOfFile: configurationTemplatePath encoding: NSUTF8StringEncoding error: error];
    
    if (!configurationTemplate) {
        NSLog(@"Unable to load the Synergy configuration template.");
        
        return NO;
    }
    
    configuration = [configurationTemplate stringByReplacingOccurrencesOfString: @"#screen-0" withString: hostName];
    
    if (orientation == SynergyClientOrientationLeft) {
        configuration = [self configureClientWithScreen: leftScreen orientation: orientation template: configuration];
    } else if (orientation == SynergyClientOrientationRight) {
        configuration = [self configureClientWithScreen: rightScreen orientation: orientation template: configuration];
    } else {
        configuration = [configuration stringByReplacingOccurrencesOfString: @"#screen-1" withString: leftScreen];
        configuration = [configuration stringByReplacingOccurrencesOfString: @"#screen-2" withString: rightScreen];
    }
    
    if (![configuration writeToFile: configurationFilePath atomically: YES encoding: NSUTF8StringEncoding error: error]) {
        NSLog(@"Unable to create the Synergy configuration file.");
        
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (void)startSynergyClientAtHostName: (NSString *)hostName {
    NSString *synergyPath = [EmergenceUtilities synergyClientPath];
    NSArray *arguments;
    
    NSLog(@"Attempting to start the Synergy client with server hostname: %@", hostName);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: synergyPath]) {
        NSLog(@"The Synergy executable cannot be found at path: %@", synergyPath);
        
        return;
    }
    
    if ([self isSynergyRunning]) {
        NSLog(@"Synergy is already running, another Synergy process cannot be launched.");
        
        return;
    }
    
    arguments = [NSArray arrayWithObjects: synergyPath, @"-d", EmergenceSynergyDebuggingLevel, @"-f", hostName, nil];
    
    mySynergyProcess = [[EmergenceSynergyProcess alloc] initWithArguments: arguments processType: SynergyProcessTypeClient];
    
    [mySynergyProcess startProcess];
}

- (void)startSynergyServer {
    NSString *synergyPath = [EmergenceUtilities synergyServerPath];
    NSArray *arguments;
    
    NSLog(@"Attempting to start the Synergy server.");
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: synergyPath]) {
        NSLog(@"The Synergy executable cannot be found at path: %@", synergyPath);
        
        return;
    }
    
    if ([self isSynergyRunning]) {
        NSLog(@"Synergy is already running, another Synergy process cannot be launched.");
        
        return;
    }
    
    arguments = [NSArray arrayWithObjects: synergyPath, @"-d", EmergenceSynergyDebuggingLevel, @"-f", @"-c", [EmergenceUtilities synergyConfigurationFilePath], nil];
    
    mySynergyProcess = [[EmergenceSynergyProcess alloc] initWithArguments: arguments processType: SynergyProcessTypeServer];
    
    [mySynergyProcess startProcess];
}

#pragma mark -

- (void)stopSynergy {
    if (mySynergyProcess && [mySynergyProcess isProcessRunning]) {
        [mySynergyProcess stopProcess];
        
        [mySynergyProcess release];
        
        mySynergyProcess = nil;
    } else {
        NSLog(@"Synergy has already been stopped.");
    }
}

#pragma mark -

- (BOOL)isSynergyRunning {
    if (mySynergyProcess && [mySynergyProcess isProcessRunning]) {
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (BOOL)isSynergyClientRunning {
    if ([self isSynergyRunning] && ([mySynergyProcess processType] == SynergyProcessTypeClient)) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isSynergyServerRunning {
    if ([self isSynergyRunning] && ([mySynergyProcess processType] == SynergyProcessTypeServer)) {
        return YES;
    }
    
    return NO;
}

#pragma mark -

- (void)synchronizeSynergyProcessWithFilesystem {
    EmergenceProcess *process = [EmergenceUtilities processFromFile: EmergenceSynergyProcessFile];
    
    if ([self isSynergyRunning]) {
        NSLog(@"The Synergy manager is saving the current Synergy process to disk.");
        
        if (![EmergenceUtilities saveProcess: mySynergyProcess toFile: EmergenceSynergyProcessFile]) {
            NSLog(@"Unable to save the Synergy process to disk.");
        }
    } else if (process && [process isProcessRunning]) {
        NSLog(@"The Synergy manager found a Synergy process saved to disk: %d", [process processIdentifier]);
        
        [mySynergyProcess autorelease];
        
        mySynergyProcess = [process retain];
    }
}

@end

#pragma mark -

@implementation EmergenceSynergyManager (EmergenceSynergyManagerPrivate)

- (SynergyClientOrientation)orientationWithLeftScreen: (NSString *)leftScreen rightScreen: (NSString *)rightScreen {
    if (![EmergenceUtilities isStringEmpty: leftScreen] && ![EmergenceUtilities isStringEmpty: rightScreen]) {
        return SynergyClientOrientationBoth;
    } else if (![EmergenceUtilities isStringEmpty: leftScreen]) {
        return SynergyClientOrientationLeft;
    } else {
        return SynergyClientOrientationRight;
    }
}

#pragma mark -

- (NSString *)configureClientWithScreen: (NSString *)screen orientation: (SynergyClientOrientation)orientation template: (NSString *)template {
    NSString *configuration = nil;
    
    if (orientation == SynergyClientOrientationLeft) {
        configuration = [template stringByReplacingOccurrencesOfString: @"#orientation" withString: @"left"];
        configuration = [configuration stringByReplacingOccurrencesOfString: @"#opposite-orientation" withString: @"right"];
    } else {
        configuration = [template stringByReplacingOccurrencesOfString: @"#orientation" withString: @"right"];
        configuration = [configuration stringByReplacingOccurrencesOfString: @"#opposite-orientation" withString: @"left"];
    }
    
    configuration = [configuration stringByReplacingOccurrencesOfString: @"#screen-0" withString: @"localhost"];
    
    configuration = [configuration stringByReplacingOccurrencesOfString: @"#screen-1" withString: screen];
    
    return configuration;
}

@end
