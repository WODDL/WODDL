//
//  WDDSchedulerHelper.h
//  Woddl
//
//  Created by Roman Bigun on 27.09.14.
//  Copyright (c) 2014 ErmineSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDDSchedulerHelper : NSObject
+ (instancetype)sharedManager;
-(BOOL)scheduleMessage2:(NSString*)message token:(NSString*)token secret:(NSString*)secret userID:(NSString*)userId picture:(NSData*)pic sendDate:(NSDate*)date forSocial:(NSString*)social userName:(NSString*)userName;

-(NSArray*)listOfScheduledPostsWithToken:(NSString*)token andForSocial:(NSString*)social andUserId:(NSString*)userId;
-(BOOL)deletePostWithId:(int)postId andToken:(NSString*)token;
- (NSString *)encodeToBase64String:(UIImage *)image;
@end
