// 
// Copyright (c) 2009 Eric Czarny <eczarny@gmail.com>
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
// Copyright (c) 2009 Divisible by Zero.
// 

#import "EmergenceSynergyManager.h"
#import "EmergenceSynergyProcess.h"
#import "EmergenceProcess.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

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

- (void)startSynergyClientAtHostname: (NSString *)hostname {
    NSString *synergyPath = [EmergenceUtilities synergyClientPath];
    NSArray *arguments;
    
    NSLog(@"Attempting to start the Synergy client with server hostname: %@", hostname);
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: synergyPath]) {
        NSLog(@"The Synergy executable cannot be found at path: %@", synergyPath);
        
        return;
    }
    
    if ([self isSynergyRunning]) {
        NSLog(@"Synergy is already running, another Synergy process cannot be launched.");
        
        return;
    }
    
    arguments = [NSArray arrayWithObjects: synergyPath, @"-d", @"FATAL", @"-f", hostname, nil];
    
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
    
    arguments = [NSArray arrayWithObjects: synergyPath, @"-d", @"FATAL", @"-f", @"-c", [EmergenceUtilities synergyConfigurationFilePath], nil];
    
    mySynergyProcess = [[EmergenceSynergyProcess alloc] initWithArguments: arguments processType: SynergyProcessTypeServer];
    
    [EmergenceUtilities updateSynergyConfigurationFile];
    
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
    
    if (!mySynergyProcess && process) {
        NSLog(@"The Synergy manager found a Synergy process saved to disk: %d", [process processIdentifier]);
        
        mySynergyProcess = [process retain];
        
        return;
    } else {
        NSLog(@"The Synergy manager is saving the current Synergy process to disk.");
        
        if (![EmergenceUtilities saveProcess: mySynergyProcess toFile: EmergenceSynergyProcessFile]) {
            NSLog(@"Unable to save the Synergy process to disk.");
        }
    }
}

@end
