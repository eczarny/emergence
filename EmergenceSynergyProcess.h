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
// EmergenceSynergyProcess.h
// 
// Created by Eric Czarny on Sunday, March 1, 2009.
// Copyright (c) 2009 Divisible by Zero.
// 

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
