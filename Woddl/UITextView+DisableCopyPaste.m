//
//  UITextView+DisableCopyPaste.m
//  Woddl
//
//  Created by Louis on 2/2/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import "UITextView+DisableCopyPaste.h"

@implementation UITextView (DisableCopyPaste)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}

- (BOOL)canBecomeFirstResponder
{
    return NO;
}

@end
