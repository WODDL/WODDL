//
//  WDDStatusViewController.h
//  Woddl
//
//  Created by Oleg Komaristov on 23.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDDLinkShorterViewController.h"

@interface WDDStatusViewController : WDDLinkShorterViewController
{
    BOOL isTwitterButtonEnabled;
    BOOL isLinkedinButtonEnabled;
    BOOL isFoursquareButtonEnabled;
}

- (IBAction)setActiveNetwork:(UIButton *)sender;
-(IBAction)schedulerDoneAction:(UIButton*)sender;
@property (assign, nonatomic) NSInteger statusesTaskCounter;
@property (nonatomic, retain) IBOutlet UIDatePicker *schedulerDataTimePeaker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *linkedInButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *foursquareButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *schedulerButton;
@property (weak, nonatomic) IBOutlet UIView *schedulerView;
@property (strong, nonatomic) NSDictionary *messageToEdit;
-(IBAction)displayScheduledMessages:(UIButton*)sender;
@end
