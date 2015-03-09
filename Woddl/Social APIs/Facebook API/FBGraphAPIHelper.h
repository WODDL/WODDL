//
//  FBGraphAPIHelper.h
//  Woddl
//
//  Created by Louis on 3/6/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBGraphAPIHelper : NSObject

+ (void)setAccessToken: (NSString*)token;

+ (void)loadInfoFromUser: (NSString*)userId completion: (void(^)(NSDictionary *userInfo))completion;
+ (void)loadEventsFromUser: (NSString*)userId completion: (void(^)(NSDictionary *eventsInfo))completion;
+ (NSString*)GetProfilePictureUrlFromID: (NSString*)a_id;

@end
