//
//  WDDScheduledMessageTableViewCell.h
//  Woddl
//
//  Created by Roman Bigun on 11.10.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const WDDMessageTableViewCellIdentifier;


@interface WDDScheduledMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTime;
@property (weak, nonatomic) IBOutlet UILabel *messageStatus;
@property (weak, nonatomic) IBOutlet UIButton *messageSocialFacebook;
@property (weak, nonatomic) IBOutlet UIButton *messageSocialTwiter;
@property (weak, nonatomic) IBOutlet UIButton *messageSocialLinkedIn;
@property (weak, nonatomic) IBOutlet UIButton *messageDelete;
@property (weak, nonatomic) IBOutlet UIButton *messageEdit;
@property (weak, nonatomic) IBOutlet UIImageView *messageHasAttachment;

@end
