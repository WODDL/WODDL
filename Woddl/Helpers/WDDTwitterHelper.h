//
//  WDDTwitterHelper.h
//  Woddl
//
//  Created by Louis on 3/13/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDDTwitterHelper : NSObject

+ (void)getToken: (NSString**)token secret: (NSString**)secret userid: (NSString**)userid from: (NSString*)body;

@end
