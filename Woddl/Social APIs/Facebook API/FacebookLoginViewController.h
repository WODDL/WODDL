//
//  FacebookLoginViewController.h
//  Woddl
//
//  Created by Oleg Komaristov on 28.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol fbLoginViewControllerDelegate;
@interface FacebookLoginViewController : UIViewController
{
    UIWebView* fbWebView;
    UIActivityIndicatorView* fbWebActivityIndicator;
}

@property(nonatomic,assign) id<fbLoginViewControllerDelegate> delegate;

@end

@protocol fbLoginViewControllerDelegate <NSObject>

-(void)loginSuccessWithToken:(NSString*)token andTimeExpire:(id)expires andUserID:(NSString*)userID andScreenName:(NSString*)name andImageURL:(NSString*)imageURL andProfileURL:(NSString *)profileURLString;
-(void)loginCencel;

@end
