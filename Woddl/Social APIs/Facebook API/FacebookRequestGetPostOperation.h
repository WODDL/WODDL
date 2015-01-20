//
//  FacebookRequestGetPostOperation.h
//  Woddl
//
//  Created by Oleg Komaristov on 27.11.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookRequestTypes.h"

@interface FacebookRequestGetPostOperation : NSOperation

@property (nonatomic,strong) ComplationGetFBPostBlock completionBlock;
@property (nonatomic, strong) NSString* token;
@property (nonatomic, strong) NSDictionary* dataDict;

-(id)initFacebookRequestGetPostOperationWithToken:(NSString*)token_ andDictionary:(NSDictionary*)data withComplationBlock:(ComplationGetFBPostBlock)complationBlock_;

@end
