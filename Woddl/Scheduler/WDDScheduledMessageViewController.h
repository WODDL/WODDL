//
//  WDDScheduledMessageViewController.h
//  Woddl
//
//  Created by Roman Bigun on 11.10.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDDStatusViewController.h"
extern NSString * const WDDScheduledMessageViewControllerIdentifier;



@interface WDDScheduledMessageViewController : WDDStatusViewController<  UITableViewDelegate,
UITableViewDataSource   >

//  Views
@property (weak, nonatomic) IBOutlet UITableView *messagesTableView;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) WDDStatusViewController *statusViewController;
//  Model
@property (strong, nonatomic) NSArray *messages;   // of WDDLocation objects
@end
