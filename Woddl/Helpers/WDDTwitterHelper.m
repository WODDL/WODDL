//
//  WDDTwitterHelper.m
//  Woddl
//
//  Created by Louis on 3/13/15.
//  Copyright (c) 2015 IDS. All rights reserved.
//

#import "WDDTwitterHelper.h"

@implementation WDDTwitterHelper

+ (void)getToken: (NSString**)token secret: (NSString**)secret userid: (NSString**)userid from: (NSString*)body
{
    if (body.length > 0)
    {
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs)
        {
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            
            if (elements.count > 1)
            {
                NSString *field = elements[0];
                NSString *value = elements[1];
                
                if (token != nil && [field isEqualToString: @"oauth_token"]) {
                    
                    *token = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                else if (secret != nil && [field isEqualToString: @"oauth_token_secret"]) {
                    
                    *secret = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
                else if (userid != nil && [field isEqualToString: @"user_id"]) {
                    
                    *userid = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
            }
        }
    }
}

@end
