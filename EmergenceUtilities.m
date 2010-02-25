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
// EmergenceUtilities.m
// 
// Created by Eric Czarny on Monday, February 23, 2009.
// Copyright (c) 2009 Divisible by Zero.
// 

#import "EmergenceUtilities.h"
#import "EmergenceProcess.h"
#import "EmergenceConstants.h"

@interface EmergenceUtilities (EmergenceUtilitiesPrivate)

+ (NSString *)pathForSynergyExecutable: (NSString *)synergyExecutable;

@end

#pragma mark -

@implementation EmergenceUtilities

+ (NSBundle *)applicationBundle {
    return [NSBundle mainBundle];
}

+ (NSString *)applicationVersion {
    NSBundle *applicationBundle = [EmergenceUtilities applicationBundle];
    NSString *applicationVersion = [applicationBundle objectForInfoDictionaryKey: EmergenceApplicationBundleShortVersionString];
    
    if (!applicationVersion) {
        applicationVersion = [applicationBundle objectForInfoDictionaryKey: EmergenceApplicationBundleVersion];
    }
    
    return applicationVersion;
}

#pragma mark -

+ (void)registerDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *path = [[EmergenceUtilities applicationBundle] pathForResource: EmergenceDefaultPreferencesFile ofType: EmergencePropertyListFileExtension];
    NSDictionary *emergenceDefaults = [[[NSDictionary alloc] initWithContentsOfFile: path] autorelease];
    
    [defaults registerDefaults: emergenceDefaults];
}

#pragma mark -

+ (NSString *)applicationSupportPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([paths count] > 0) ? [paths objectAtIndex: 0] : NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    applicationSupportPath = [applicationSupportPath stringByAppendingPathComponent: EmergenceApplicationName];
    
    if (![fileManager fileExistsAtPath: applicationSupportPath isDirectory: nil]) {
        NSLog(@"The application support directory does not exist, it will be created.");
        
        if (![fileManager createDirectoryAtPath: applicationSupportPath attributes: nil]) {
            NSLog(@"There was a problem creating the application support directory at path: %@", applicationSupportPath);
        }
    }
    
    return applicationSupportPath;
}

#pragma mark -

+ (NSString *)synergyClientPath {
    return [EmergenceUtilities pathForSynergyExecutable: EmergenceSynergyClientExecutable];
}

+ (NSString *)synergyServerPath {
    return [EmergenceUtilities pathForSynergyExecutable: EmergenceSynergyServerExecutable];
}

#pragma mark -

+ (NSString *)synergyConfigurationFilePath {
    NSString *applicationSupportPath = [EmergenceUtilities applicationSupportPath];
    
    return [applicationSupportPath stringByAppendingPathComponent: EmergenceSynergyConfigurationFile];
}

#pragma mark -

+ (BOOL)saveProcess: (EmergenceProcess *)process toFile: (NSString *)file {
    NSString *processPath = [[EmergenceUtilities applicationSupportPath] stringByAppendingPathComponent: file];
    
    return [NSKeyedArchiver archiveRootObject: process toFile: processPath];
}

+ (EmergenceProcess *)processFromFile: (NSString *)file {
    NSString *processPath = [[EmergenceUtilities applicationSupportPath] stringByAppendingPathComponent: file];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile: processPath];
}

#pragma mark -

+ (BOOL)isLoginItemEnabled {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[EmergenceUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    BOOL result = NO;
    
    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;
        
        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
        
        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;
            OSStatus errStatus = LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
            
            if (errStatus == noErr) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];
                
                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    result = YES;
                    
                    break;
                }
            }
        }
        
        [sharedFileListArray release];
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    return result;
}

#pragma mark -

+ (void)enableLoginItem {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[EmergenceUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        LSSharedFileListItemRef sharedFileListItem = LSSharedFileListInsertItemURL(sharedFileList, kLSSharedFileListItemLast, NULL, NULL, applicationPathURL, NULL, NULL);
        
        if (sharedFileListItem) {
            CFRelease(sharedFileListItem);
        }
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    CFRelease(sharedFileList);
}

+ (void)disableLoginItem {
    LSSharedFileListRef sharedFileList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    NSString *applicationPath = [[EmergenceUtilities applicationBundle] bundlePath];
    CFURLRef applicationPathURL= (CFURLRef)[NSURL fileURLWithPath: applicationPath];
    
    if (sharedFileList) {
        NSArray *sharedFileListArray = nil;
        UInt32 seedValue;
        
        sharedFileListArray = (NSArray *)LSSharedFileListCopySnapshot(sharedFileList, &seedValue);
        
        for (id sharedFile in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileListItem = (LSSharedFileListItemRef)sharedFile;
            OSStatus status = LSSharedFileListItemResolve(sharedFileListItem, 0, (CFURLRef *)&applicationPathURL, NULL);
            
            if (status == noErr) {
                NSString *resolvedApplicationPath = [(NSURL *)applicationPathURL path];
                
                if ([resolvedApplicationPath compare: applicationPath] == NSOrderedSame) {
                    LSSharedFileListItemRemove(sharedFileList, sharedFileListItem);
                }
            }
        }
        
        [sharedFileListArray release];
    } else {
        NSLog(@"Unable to create the shared file list.");
    }
    
    CFRelease(sharedFileList);
}

#pragma mark -

+ (NSImage *)imageFromBundledImageResource: (NSString *)resource {
    NSString *resourcePath = [[EmergenceUtilities applicationBundle] pathForImageResource: resource];
    
    return [[[NSImage alloc] initWithContentsOfFile: resourcePath] autorelease];
}

#pragma mark -

+ (BOOL)isStringEmpty: (NSString *)string {
    if (!string || [string isEqualToString: @""]) {
        return YES;
    }
    
    return NO;
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
