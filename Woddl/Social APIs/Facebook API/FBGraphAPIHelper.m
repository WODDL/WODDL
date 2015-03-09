//
//  FBGraphAPIHelper.m
//  Woddl
//
//  Created by Louis on 3/6/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import "FBGraphAPIHelper.h"

NSString *access_token;

const NSString *kGraphAPIBaseUrl = @"https://graph.facebook.com/v2.2";

@implementation FBGraphAPIHelper

+ (void)setAccessToken: (NSString*)token {
    
    access_token = token;
}

+ (void)loadInfoFromUser: (NSString*)userId completion: (void(^)(NSDictionary *userInfo))completion {
    
    NSString *apiUrl = [NSString stringWithFormat: @"%@/%@?fields=id,name&access_token=%@", kGraphAPIBaseUrl, userId, access_token];
    
    [FBGraphAPIHelper callAPIWithUrl: apiUrl completion:^(NSDictionary *response) {
        
        completion (response);
    }];
}

+ (void)loadEventsFromUser: (NSString*)userId completion: (void(^)(NSDictionary *eventsInfo))completion {
    
    NSString * const kEventFields = @"id,name,description,start_time,end_time,location,owner,updated_time,venue";
    
    NSString *apiUrl = [NSString stringWithFormat: @"%@/%@/events?fields=%@&access_token=%@", kGraphAPIBaseUrl, userId, kEventFields, access_token];
    
    [FBGraphAPIHelper callAPIWithUrl: apiUrl completion:^(NSDictionary *response) {
        
        completion (response);
    }];
}

+ (void)loadGroupsFromUser: (NSString*)userId completion: (void(^)(NSDictionary *groupsInfo))completion
{
    NSString * const kGroupsFields = @"id,name,email,link";
    
    NSString *apiUrl = [NSString stringWithFormat: @"%@/%@/events?fields=%@&access_token=%@", kGraphAPIBaseUrl, userId, kEventFields, access_token];
    
    [FBGraphAPIHelper callAPIWithUrl: apiUrl completion:^(NSDictionary *response) {
        
        completion (response);
    }];
}

+ (NSString*)GetProfilePictureUrlFromID: (NSString*)a_id
{
    return [NSString stringWithFormat: @"%@/%@/picture?type=square", kGraphAPIBaseUrl, a_id];
}

+ (void)callAPIWithUrl: (NSString*)apiUrl completion: (void(^)(NSDictionary *response))completion
{
    NSMutableURLRequest *requestURL = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: apiUrl]
                                                              cachePolicy: NSURLRequestReloadIgnoringLocalCacheData
                                                          timeoutInterval: 60.0];
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest: requestURL returningResponse: nil error: nil];

    if(responseData) {
        
        NSError* error = nil;
        NSDictionary* response = [NSJSONSerialization JSONObjectWithData: responseData
                                                                 options: kNilOptions
                                                                   error: &error];
        
        NSLog(@"Facebook Graph API Response = %@", response);
        
        if (error) {
            
            NSLog(@"Facebook Graph API Error = %@", error.description);
            response = nil;
        }
        
        completion (response);
    }
    
    completion (nil);
}

@end
