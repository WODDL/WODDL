//
//  WDDSideMenuViewController.h
//  Woddl
//
//  Created by Oleg Komaristov on 23.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDDMainScreenViewController.h"

@interface WDDSideMenuViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) WDDMainScreenViewController *mainScreenViewController;

-(IBAction)reportBugPressed:(id)sender;
-(IBAction)gotFeedback:(id)sender;

@end
