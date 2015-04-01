//
//  NSString+Additions.m
//  Woddl
//
//  Created by Oleg Komaristov on 06.01.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

- (BOOL)isEndsWithNewlineCharacter
{
    NSUInteger stringLength = [self length];
    if (stringLength == 0)
    {
        return NO;
    }
    unichar lastChar = [self characterAtIndex:stringLength-1];
    return [[NSCharacterSet newlineCharacterSet] characterIsMember:lastChar];
}

- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end
{
    NSScanner* scanner = [NSScanner scannerWithString: self];
    [scanner setCharactersToBeSkipped:nil];
    [scanner scanUpToString:start intoString:NULL];
    if([scanner scanString:start intoString:NULL])
    {
        NSString* result = nil;
        if([scanner scanUpToString:end intoString:&result])
        {
            return result;
        }
    }
    return nil;
}

@end
