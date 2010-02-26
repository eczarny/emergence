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
// EmergenceProcess.h
// 
// Created by Eric Czarny on Thursday, May 7, 2009.
// Copyright (c) 2010 Divisible by Zero.
// 

#import <Cocoa/Cocoa.h>
#import "EmergenceProcessDelegate.h"

@interface EmergenceProcess : NSObject<NSCoding> {
    NSTask *myTask;
    NSFileHandle *myStandardInput;
    NSFileHandle *myStandardOutput;
    NSArray *myArguments;
    NSInteger myProcessIdentifier;
    id<EmergenceProcessDelegate> myDelegate;
}

- (id)initWithArguments: (NSArray *)arguments delegate: (id<EmergenceProcessDelegate>)delegate;

- (id)initWithDelegate: (id<EmergenceProcessDelegate>)delegate;

#pragma mark -

- (NSArray *)arguments;

- (void)setArguments: (NSArray *)arguments;

#pragma mark -

- (NSInteger)processIdentifier;

#pragma mark -

- (void)startProcess;

- (void)stopProcess;

#pragma mark -

- (BOOL)isProcessRunning;

@end
