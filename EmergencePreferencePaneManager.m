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
// EmergencePreferencePaneManager.m
// 
// Created by Eric Czarny on Monday, March 9, 2009.
// Copyright (c) 2009 Divisible by Zero.
// 

#import "EmergencePreferencePaneManager.h"
#import "EmergencePreferencePane.h"
#import "EmergencePreferencePaneProtocol.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

@implementation EmergencePreferencePaneManager

static EmergencePreferencePaneManager *sharedInstance = nil;

- (id)init {
    if (self = [super init]) {
        myPreferencePanes = [[NSMutableDictionary alloc] init];
        myPreferencePaneOrder = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark -

+ (EmergencePreferencePaneManager *)sharedManager {
    if (!sharedInstance) {
        sharedInstance = [[EmergencePreferencePaneManager alloc] init];
    }
    
    return sharedInstance;
}

#pragma mark -

- (BOOL)preferencePanesAreReady {
    return myPreferencePanes && ([myPreferencePanes count] > 0);
}

#pragma mark -

- (void)loadPreferencePanes {
    NSBundle *applicationBundle = [EmergenceUtilities applicationBundle];
    NSString *path = [applicationBundle pathForResource: EmergencePreferencePanesFile ofType: EmergencePropertyListFileExtension];
    NSDictionary *preferencePaneDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSDictionary *preferencePanes = [preferencePaneDictionary objectForKey: EmergencePreferencePanesKey];
    NSArray *preferencePaneOrder = [preferencePaneDictionary objectForKey: EmergencePreferencePaneOrderKey];
    NSEnumerator *preferencePaneNameEnumerator = [preferencePanes keyEnumerator];
    NSEnumerator *preferencePaneNameOrderEnumerator = [preferencePaneOrder objectEnumerator];
    NSString *preferencePaneName;
    
    NSLog(@"The preference pane manager is loading preference panes from: %@", path);
    
    [myPreferencePanes removeAllObjects];
    
    while (preferencePaneName = [preferencePaneNameEnumerator nextObject]) {
        NSString *preferencePaneClassName = [preferencePanes objectForKey: preferencePaneName];
        
        if (preferencePaneClassName) {
            Class preferencePaneClass = [applicationBundle classNamed: preferencePaneClassName];
            
            if (preferencePaneClass) {
                EmergencePreferencePane *preferencePane = [[preferencePaneClass alloc] init];
                
                if (preferencePane) {
                    [preferencePane preferencePaneDidLoad];
                    
                    [myPreferencePanes setObject: preferencePane forKey: preferencePaneName];
                    
                    [preferencePane release];
                } else {
                    NSLog(@"Failed initializing preference pane named: %@", preferencePaneName);
                }
            } else {
                NSLog(@"Unable to load preference pane with class named: ", preferencePaneClassName);
            }
        } else {
            NSLog(@"The preference pane, %@, is missing a class name!", preferencePaneName);
        }
    }
    
    [myPreferencePaneOrder removeAllObjects];
    
    while (preferencePaneName = [preferencePaneNameOrderEnumerator nextObject]) {
        if ([myPreferencePanes objectForKey: preferencePaneName]) {
            NSLog(@"Adding %@ to the preference pane order.", preferencePaneName);
            
            [myPreferencePaneOrder addObject: preferencePaneName];
        } else {
            NSLog(@"Unable to set the preference pane order for preference pane named: ", preferencePaneName);
        }
    }
}

#pragma mark -

- (id<EmergencePreferencePaneProtocol>)preferencePaneWithName: (NSString *)name {
    return [myPreferencePanes objectForKey: name];
}

#pragma mark -

- (NSArray *)preferencePanes {
    return [myPreferencePanes allValues];
}

- (NSArray *)preferencePaneNames {
    return [myPreferencePanes allKeys];
}

#pragma mark -

- (NSArray *)preferencePaneOrder {
    return myPreferencePaneOrder;
}

#pragma mark -

- (void)dealloc {
    [myPreferencePanes release];
    [myPreferencePaneOrder release];
    
    [super dealloc];
}

@end
