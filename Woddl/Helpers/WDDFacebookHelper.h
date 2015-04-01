//
//  WDDFacebookHelper.h
//  Woddl
//
//  Created by Louis on 3/16/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol WDDFacebookHelperDelegate

@optional

@end

typedef void (^CompletionHandler)(NSError* error);

@interface WDDFacebookHelper : NSObject
{
    CompletionHandler completionHandler;
}

@property (nonatomic, strong) NSString *authResponse;

+ (id)Helper;
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)loginWithCompletion: (CompletionHandler)completion;
- (void)requestNewPublishPermissionWithCompletion: (void(^)(NSError *error))completion;
- (void)openSessionPublishPermissionsWithCompletion: (void(^)(NSError *error))completion;

@end
