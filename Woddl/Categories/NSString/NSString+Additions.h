//
//  NSString+Additions.h
//  Woddl
//
//  Created by Oleg Komaristov on 06.01.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (BOOL)isEndsWithNewlineCharacter;
- (NSString*)stringBetweenString:(NSString*)start andString:(NSString*)end;

@end
