//
//  TwitterImagesLoader.h
//  Woddl
//
//  Created by Oleg Komaristov on 31.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterImagesLoader : NSObject

+(TwitterImagesLoader*)Instance;
- (NSString*) cacheAvatarWithScreenNameUser: (NSString *) screenName andImage:(UIImage*)image;

@end
