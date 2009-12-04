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
// EmergenceSynergyProcess.m
// 
// Created by Eric Czarny on Sunday, March 1, 2009.
// Copyright (c) 2009 Divisible by Zero.
// 

#import "EmergenceSynergyProcess.h"
#import "EmergenceConstants.h"

@implementation EmergenceSynergyProcess

- (id)initWithArguments: (NSArray *)arguments processType: (SynergyProcessType)processType {
    if (self = [super initWithArguments: arguments delegate: self]) {
        myProcessType = processType;
    }
    
    return self;
}

- (id)initWithCoder: (NSCoder*)coder {
    if (self = [super initWithCoder: coder]) {
        myProcessType = [coder decodeIntegerForKey: @"processType"];
    }
    
    return self;
}

#pragma mark -

- (void)encodeWithCoder: (NSCoder*)coder {
    [coder encodeInteger: myProcessType forKey: @"processType"];
    
    [super encodeWithCoder: coder];
}

#pragma mark -

- (SynergyProcessType)processType {
    return myProcessType;
}

- (void)setProcessType: (SynergyProcessType)processType {
    myProcessType = processType;
}

#pragma mark -

#pragma mark Process Delegate Methods

#pragma mark -

- (void)processDidStart: (EmergenceProcess *)process {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process has been started with the following arguments: %@", myArguments);
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessStartedNotification object: self];
}

- (void)processDidStop: (EmergenceProcess *)process {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process has been stopped.");
    
    myProcessType = SynergyProcessTypeError;
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessFinishedNotification object: self];
}

#pragma mark -

- (void)process: (EmergenceProcess *)process didFailWithError: (NSError *)error {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    NSLog(@"The Synergy process failed.");
    
    [notificationCenter postNotificationName: EmergenceSynergyProcessFailedNotification object: self];
}

#pragma mark -

- (void)process: (EmergenceProcess *)process didReceiveData: (NSData *)data {
    NSString *output = [[[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding] autorelease];
    
    NSLog(@"The Synergy process received data: %@", output);
}

@end
