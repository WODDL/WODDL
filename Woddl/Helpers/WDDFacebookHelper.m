//
//  WDDFacebookHelper.m
//  Woddl
//
//  Created by Louis on 3/16/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import "WDDFacebookHelper.h"

WDDFacebookHelper *_helper;

@implementation WDDFacebookHelper

+ (id)Helper
{
    if (_helper == nil) {
        
        _helper = [[WDDFacebookHelper alloc] init];
    }
    return _helper;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        
        
    }
    return self;
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    if (!error && state == FBSessionStateOpen) {
        
        NSLog(@"Session opened");
        
        completionHandler (nil);
        
        return;
    }
    
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed) {

        NSLog(@"Session closed");
        
        completionHandler ([NSError errorWithDomain: @"Closed" code: 100 userInfo: nil]);
    }
    
    if (error) {
        
        NSString *alertText;
        NSString *alertTitle;

        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError: error];
        }
        else {
            
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {

                NSLog(@"User cancelled login");
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
            }
            else {

                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }

        [FBSession.activeSession closeAndClearTokenInformation];

        NSLog(@"Facebook - %@\n%@", alertTitle, alertText);
        
        completionHandler (error);
    }
}

- (void)loginWithCompletion: (CompletionHandler)completion
{
    completionHandler = completion;
    
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    else {

        //@"offline_access,publish_actions,read_mailbox,xmpp_login,user_subscriptions,user_relationships,user_work_history,user_about_me,publish_stream,user_photos,manage_pages,manage_notifications";
        // , @"user_activities", @"user_birthday", @"user_likes", @"user_relationships", @"user_tagged_places", @"read_mailbox", @"read_stream", @"manage_notifications", @"user_events", @"manage_pages", @"user_groups"
        [FBSession openActiveSessionWithReadPermissions: @[@"public_profile", @"email", @"user_friends", @"user_photos", @"user_posts", @"user_groups"]
                                           allowLoginUI: YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             [self sessionStateChanged: session state: state error: error];
         }];
    }
}

- (void)openSessionPublishPermissionsWithCompletion: (void(^)(NSError *error))completion
{
    if ([[FBSession activeSession] isOpen]) {
        
        if ([FBSession.activeSession.permissions
             indexOfObject: @"publish_actions"] == NSNotFound) {
            
            [self requestNewPublishPermissionWithCompletion: completion];
        }
        else {
            
            completion (nil);
        }
    }
    else {
        
        [FBSession openActiveSessionWithPublishPermissions: [NSArray arrayWithObject: @"publish_actions"] defaultAudience: FBSessionDefaultAudienceFriends allowLoginUI: NO completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            [self openSessionPublishPermissionsWithCompletion: completion];
        }];
    }
}

- (void)requestNewPublishPermissionWithCompletion: (void(^)(NSError *error))completion
{
    // Request publish_actions
    [FBSession.activeSession requestNewPublishPermissions: [NSArray arrayWithObject: @"publish_actions"]
                                          defaultAudience: FBSessionDefaultAudienceFriends
                                        completionHandler: ^(FBSession *session, NSError *error) {
                                            
                                            if (!error) {
                                                
                                                if ([FBSession.activeSession.permissions
                                                     indexOfObject: @"publish_actions"] == NSNotFound) {

                                                    NSLog(@"Facebook Permission not granted - Your action will not be published to Facebook.");
                                                    
                                                    completion ([NSError errorWithDomain: @"Not Granted" code: 100 userInfo: nil]);
                                                }
                                                else {
                                                    
                                                    completion (nil);
                                                }
                                            }
                                            else {
                                                // There was an error, handle it
                                                // See https://developers.facebook.com/docs/ios/errors/
                                                
                                                completion (error);
                                            }
                                            
                                        }];
}


@end
