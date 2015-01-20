//
//  WDDSchedulerHelper.m
//  Woddl
//
//  Created by Roman Bigun on 27.09.14.
//  Copyright (c) 2014 ErmineSoft. All rights reserved.
//

#import "WDDSchedulerHelper.h"
#import "JSON/JSON.h"
#define SERVER_PATH @"http://social.woddl.com"

#define scheduleMessageFacebook @"/api/facebook/create"
#define scheduledMessagesFacebook @"/api/facebook/list"
#define deleteFBMessage @"/api/facebook/delete"
#define editFBMessage @"/api/facebook/edit"

#define scheduleMessageTwitter @"/api/twitter/create"
#define scheduledMessagesTwitter @"/api/twitter/list"
#define deleteTwitterMessage @"/api/twitter/delete"
#define editTwitterMessage @"/api/Twitter/edit"

#define scheduleMessageLinkedin @"/api/Linkedin/create"
#define scheduledMessagesLinkedin @"/api/Linkedin/list"
#define deleteLinkedinMessage @"/api/Linkedin/delete"
#define editLinkedinMessage @"/api/Linkedin/edit"


@implementation WDDSchedulerHelper


+ (instancetype)sharedManager
{
    static WDDSchedulerHelper *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [self new];
    });
    
    return sharedManager;
}
-(NSString *)unixTimeInString:(NSDate*)date
{

    long long milliseconds = (long long)([[NSDate date] timeIntervalSince1970]);
    
    NSString *strTimeStamp = [NSString stringWithFormat:@"%lld",milliseconds];
    NSLog(@"The Timestamp is = %@",strTimeStamp);
    
    return strTimeStamp;

}
-(BOOL)deletePostWithId:(int)postId andToken:(NSString*)token
{

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH, deleteFBMessage]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *requestFields = @"";
    requestFields = [requestFields stringByAppendingFormat:@"id=%i&",postId];
    requestFields = [requestFields stringByAppendingFormat:@"token=%@",token];
    requestFields = [requestFields stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [requestFields dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestData;
    request.HTTPMethod = @"POST";
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error == nil && response.statusCode == 200)
    {
        
        NSString* responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        
        NSArray * responce=(NSArray*)[responseString JSONValue] ;
        NSLog(@"%@",responce);
        return YES;
        
    } else {
        //Error handling
        NSString* responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        return NO;
    }
    return NO;
    
}
-(NSArray*)listOfScheduledPostsWithToken:(NSString*)token andForSocial:(NSString*)social andUserId:(NSString*)userId
{
    
     NSURL *url = nil;
     NSString *requestFields = @"";
    
    if([social isEqualToString:@"facebook"])
    {
       url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduledMessagesFacebook]];
    }
    if([social isEqualToString:@"twitter"])
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduledMessagesTwitter]];
    }
    if([social isEqualToString:@"linkedin"])
    {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduledMessagesLinkedin]];
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   
    
    requestFields = [requestFields stringByAppendingFormat:@"token=%@&",token ];
    requestFields = [requestFields stringByAppendingFormat:@"start=%i&",0];
    if([social isEqualToString:@"twitter"] || [social isEqualToString:@"linkedin"])
    {
        requestFields = [requestFields stringByAppendingFormat:@"userId=%@&",userId ];
        
    }
    requestFields = [requestFields stringByAppendingFormat:@"limit=%i",1000];
    
    requestFields = [requestFields stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *requestData = [requestFields dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestData;
    request.HTTPMethod = @"POST";
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    NSData *responseData1 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error == nil && response.statusCode == 200)
    {
        
        NSString* responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
        
        NSArray * responce=(NSArray*)[responseString JSONValue] ;
        NSLog(@"%@",responce);
        
        return responce;
        
    } else {
        //Error handling
        NSString* responseString = [[NSString alloc] initWithData:responseData1 encoding:NSUTF8StringEncoding];
        NSLog(@"%@",responseString);
    }

    return nil;
}
- (NSString *)encodeToBase64String:(UIImage *)image
{
    NSString * test = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return test;
}

-(NSInteger)datesComparator:(NSDate*)postsDate
{
    NSDate * startTime = [NSDate date];
    NSTimeInterval secs = [postsDate timeIntervalSinceDate:startTime];
    return secs;
    
}
-(BOOL)scheduleMessage2:(NSString*)message token:(NSString*)token secret:(NSString*)secret userID:(NSString*)userId picture:(NSData*)pic sendDate:(NSDate*)date forSocial:(NSString*)social userName:(NSString *)userName
{

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    static NSString * const boundary = @"9m6dnw5z3dxxyhgfc2zc";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *urlString = @"";
    if([social isEqualToString:@"facebook"])
    {
        urlString = [[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduleMessageFacebook]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if([social isEqualToString:@"twitter"])
    {
        urlString = [[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduleMessageTwitter]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    if([social isEqualToString:@"linkedin"])
    {
       urlString = [[NSString stringWithFormat:@"%@%@",SERVER_PATH, scheduleMessageLinkedin]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableURLRequest *photoUploadRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    photoUploadRequest.HTTPMethod = @"POST";
    [photoUploadRequest addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"access_token\"\r\n\r\n%@", token] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name = \"media\";\r\nfilename=\"media.jpg\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
   
    //Configure data to post
    if(pic)
    {
       [body appendData:pic];
    }
    if([social isEqualToString:@"facebook"])
    {
        [params s_setObject:token forKey:@"token"];
        [params s_setObject:message forKey:@"post"];
        
    }
    else if([social isEqualToString:@"twitter"] || [social isEqualToString:@"linkedin"])
    {
    
        [params s_setObject:token forKey:@"token"];
        [params s_setObject:userId forKey:@"userId"];
        [params s_setObject:message forKey:@"post"];
        if(pic && [social isEqualToString:@"linkedin"])
        {
        
            NSString *text = [NSString stringWithFormat:NSLocalizedString(@"lskSharedPhotoLinedIn", @""), userName];
            
            [params s_setObject:text forKey:@"title"];
        
        }
        
    }
    NSLog(@"%@",[NSString stringWithFormat:@"%li",(long)[self datesComparator:date]]);
    [params s_setObject:[NSString stringWithFormat:@"%li",(long)[self datesComparator:date]]/*[self unixTimeInString:date]*/ forKey:@"time"];
    
    for (NSString *key in params.allKeys)
    {
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", key, params[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    photoUploadRequest.HTTPBody = body;
    [photoUploadRequest addValue:@(body.length).stringValue forHTTPHeaderField: @"Content-Length"];
    
    NSHTTPURLResponse *photoRequestResponse = nil;
    NSError *photoRequestError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:photoUploadRequest
                                         returningResponse:&photoRequestResponse
                                                     error:&photoRequestError];
    
    NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Respond : %@", response);
    
    if(data)
    {
    
        return YES;
    }
   
    return NO;

}

@end
