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
// EmergenceServerWindowController.m
// 
// Created by Eric Czarny on Saturday, March 14, 2009.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "EmergenceServerWindowController.h"
#import "EmergenceSynergyManager.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

@implementation EmergenceServerWindowController

static EmergenceServerWindowController *sharedInstance = nil;

- (id)init {
    if (self = [super initWithWindowNibName: EmergenceServerWindowNibName]) {
        mySynergyManager = [EmergenceSynergyManager sharedManager];
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

+ (EmergenceServerWindowController *)sharedController {
    @synchronized(self) {
        if (!sharedInstance) {
            [[self alloc] init];
        }
    }
    
    return sharedInstance;
}

#pragma mark -

- (void)awakeFromNib {
    [[self window] center];
}

#pragma mark -

- (void)showServerWindow: (id)sender {
    [self showWindow: sender];
}

- (void)hideServerWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)toggleServerWindow: (id)sender {
    if ([[self window] isKeyWindow]) {
        [self hideServerWindow: sender];
    } else {
        [self showServerWindow: sender];
    }
}

#pragma mark -

- (void)startSynergyServer: (id)sender {
    NSString *leftScreen = [myLeftScreenTextField stringValue];
    NSString *rightScreen = [myRightScreenTextField stringValue];
    
    if ([EmergenceUtilities isStringEmpty: leftScreen] && [EmergenceUtilities isStringEmpty: rightScreen]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: ZeroKitLocalizedString(@"OK")];
        
        [alert setMessageText: ZeroKitLocalizedString(@"Please provide more information")];
        [alert setInformativeText: ZeroKitLocalizedString(@"Emergence requires a valid hostname, or IP address, of at least one Synergy client.")];
        
        [alert runModal];
        
        return;
    }
    
    if (![mySynergyManager configureSynergyServerWithLeftScreen: leftScreen rightScreen: rightScreen error: nil]) {
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        
        [alert addButtonWithTitle: ZeroKitLocalizedString(@"OK")];
        
        [alert setMessageText: ZeroKitLocalizedString(@"Unable to configure the Synergy server")];
        [alert setInformativeText: ZeroKitLocalizedString(@"There was a problem configuring the Synergy server, please try again.")];
        
        [alert runModal];
        
        return;
    }
    
    [mySynergyManager startSynergyServer];
    
    [self hideServerWindow: self];
}

@end
