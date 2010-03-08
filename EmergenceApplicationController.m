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
// EmergenceApplicationController.m
// 
// Created by Eric Czarny on Monday, February 23, 2009.
// Copyright (c) 2010 Divisible by Zero.
// 

#import "EmergenceApplicationController.h"
#import "EmergenceClientWindowController.h"
#import "EmergenceServerWindowController.h"
#import "EmergenceSynergyManager.h"
#import "EmergenceUtilities.h"
#import "EmergenceConstants.h"

@interface EmergenceApplicationController (EmergenceApplicationControllerPrivate)

- (NSString *)synergyStatus;

#pragma mark -

- (NSMenuItem *)synergyStatusItem;

#pragma mark -

- (NSMenuItem *)synergyClientItem;

- (NSMenuItem *)synergyServerItem;

#pragma mark -

- (NSMenu *)statusItemMenu;

#pragma mark -

- (void)refreshStatusMenu;

#pragma mark -

- (void)createStatusItem;

- (void)destroyStatusItem;

#pragma mark -

- (void)menuDidSendAction: (NSNotification *)notification;

@end

#pragma mark -

@implementation EmergenceApplicationController

- (id)init {
    if (self = [super init]) {
        myClientWindowController = [EmergenceClientWindowController sharedController];
        myServerWindowController = [EmergenceServerWindowController sharedController];
        mySynergyManager = [EmergenceSynergyManager sharedManager];
    }
    
    return self;
}

#pragma mark -

- (void)applicationWillFinishLaunching: (NSNotification *)notification {
    [EmergenceUtilities registerDefaults];
    
    [mySynergyManager synchronizeSynergyProcessWithFilesystem];
}

- (void)applicationDidFinishLaunching: (NSNotification *)notification {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector(refreshStatusMenu)
                               name: EmergenceSynergyProcessStartedNotification
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(refreshStatusMenu)
                               name: EmergenceSynergyProcessFinishedNotification
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector(menuDidSendAction:)
                               name: NSMenuDidSendActionNotification
                             object: nil];
    
    [self createStatusItem];
}

#pragma mark -

- (void)togglePreferencesWindow: (id)sender {
    [[ZeroKitPreferencesWindowController sharedController] togglePreferencesWindow: sender];
}

#pragma mark -

- (void)showClientWindow: (id)sender {
    [myServerWindowController hideServerWindow: sender];
    
    [myClientWindowController showClientWindow: sender];
}

- (void)showServerWindow: (id)sender {
    [myClientWindowController hideClientWindow: sender];
    
    [myServerWindowController showServerWindow: sender];
}

#pragma mark -

- (void)stopSynergy: (id)sender {
    [mySynergyManager stopSynergy];
}

#pragma mark -

- (void)applicationWillTerminate: (NSNotification *)notification {
    [mySynergyManager synchronizeSynergyProcessWithFilesystem];
    
    [self destroyStatusItem];
}

@end

#pragma mark -

@implementation EmergenceApplicationController (EmergenceApplicationControllerPrivate)

- (NSString *)synergyStatus {
    NSString *status;
    
    if ([mySynergyManager isSynergyClientRunning]) {
        status = ZeroKitLocalizedString(@"Synergy client is running");
    } else if ([mySynergyManager isSynergyServerRunning]) {
        status = ZeroKitLocalizedString(@"Synergy server is running");
    } else {
        status = ZeroKitLocalizedString(@"Synergy is idle");
    }
    
    return status;
}

#pragma mark -

- (NSMenuItem *)synergyStatusItem {
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    
    [menuItem setTitle: [self synergyStatus]];
    
    [menuItem setAction: NULL];
    
    return menuItem;
}

#pragma mark -

- (NSMenuItem *)synergyClientItem {
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    
    [menuItem setTitle: ZeroKitLocalizedString(@"Start the Synergy Client...")];
    
    if ([mySynergyManager isSynergyServerRunning]) {
        [menuItem setAction: NULL];
    } else if ([mySynergyManager isSynergyClientRunning]) {
        [menuItem setTitle: ZeroKitLocalizedString(@"Stop the Synergy Client")];
        
        [menuItem setAction: @selector(stopSynergy:)];
    } else {
        [menuItem setAction: @selector(showClientWindow:)];
    }
    
    return menuItem;
}

- (NSMenuItem *)synergyServerItem {
    NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
    
    [menuItem setTitle: ZeroKitLocalizedString(@"Start the Synergy Server...")];
    
    if ([mySynergyManager isSynergyClientRunning]) {
        [menuItem setAction: NULL];
    } else if ([mySynergyManager isSynergyServerRunning]) {
        [menuItem setTitle: ZeroKitLocalizedString(@"Stop the Synergy Server")];
        
        [menuItem setAction: @selector(stopSynergy:)];
    } else {
        [menuItem setAction: @selector(showServerWindow:)];
    }
    
    return menuItem;
}

#pragma mark -

- (NSMenu *)statusItemMenu {
    NSMenu *statusItemMenu = [[[NSMenu alloc] init] autorelease];
    
    [statusItemMenu addItemWithTitle: ZeroKitLocalizedString(@"About Emergence") action: @selector(orderFrontStandardAboutPanel:) keyEquivalent: @""];
    [statusItemMenu addItem: [NSMenuItem separatorItem]];
    
    [statusItemMenu addItem: [self synergyStatusItem]];
    
    [statusItemMenu addItem: [NSMenuItem separatorItem]];
    
    [statusItemMenu addItem: [self synergyClientItem]];
    [statusItemMenu addItem: [self synergyServerItem]];
    
    [statusItemMenu addItem: [NSMenuItem separatorItem]];
    [statusItemMenu addItemWithTitle: ZeroKitLocalizedString(@"Preferences...") action: @selector(togglePreferencesWindow:) keyEquivalent: @""];
    [statusItemMenu addItem: [NSMenuItem separatorItem]];
    [statusItemMenu addItemWithTitle: ZeroKitLocalizedString(@"Quit Emergence") action: @selector(terminate:) keyEquivalent: @""];
    
    return statusItemMenu;
}

#pragma mark -

- (void)refreshStatusMenu {
    NSString *applicationVersion = [EmergenceUtilities applicationVersion];
    NSString *synergyStatus = [self synergyStatus];
    
    if (applicationVersion) {
        [myStatusItem setToolTip: [NSString stringWithFormat: @"Emergence %@ - %@", applicationVersion, synergyStatus]];
    } else {
        [myStatusItem setToolTip: [NSString stringWithFormat: @"Emergence - %@", synergyStatus]];
    }
    
    [myStatusItem setMenu: [self statusItemMenu]];
}

#pragma mark -

- (void)createStatusItem {
    myStatusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength: NSVariableStatusItemLength] retain];
    
    [myStatusItem setTitle: @"eM"];
    [myStatusItem setHighlightMode: YES];
    
    [self refreshStatusMenu];
}

- (void)destroyStatusItem {
    [[NSStatusBar systemStatusBar] removeStatusItem: myStatusItem];
    
    [myStatusItem release];
}

#pragma mark -

- (void)menuDidSendAction: (NSNotification *)notification {
    [NSApp activateIgnoringOtherApps: YES];
}

@end
