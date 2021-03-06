//
//  IDSAppDelegate.h
//  Woddl
//
//  Created by Oleg Komaristov on 22.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Reachability.h>

#define IS_IPHONE_6 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )667 ) < DBL_EPSILON )
#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
@interface WDDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) NSInteger networkActivityIndicatorCounter;
@property (strong, nonatomic) Reachability *reach;
@property (assign, nonatomic) BOOL isInternetConnected;
@property (nonatomic, readonly) BOOL isFirstStart;

@property (assign, nonatomic) BOOL loadFBGroupsOneByOne;

@property (nonatomic, retain) NSDate *appStartTime;

- (void)showHUDWithTitle:(NSString *)title;
- (void)dismissHUD;

- (void)startKeyboardDismissOnSwipe;
- (void)stopKeyboardDismissOnSwipe;
- (UIView*)keyboardView;

@end
