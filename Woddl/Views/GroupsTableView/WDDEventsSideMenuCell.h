//
//  WDDEventsSideMenuCell.h
//  Woddl
//
//  Created by Oleg Komaristov on 09.01.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDDEventsSideMenuCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextView *eventInformationLabel;

+ (CGFloat)calculateCellHeightForText:(NSString *)text;
@end