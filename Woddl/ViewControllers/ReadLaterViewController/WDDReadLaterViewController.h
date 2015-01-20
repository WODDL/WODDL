//
//  WDDReadLaterViewController.h
//  Woddl
//
//  Created by Oleg Komaristov on 14.04.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import "WDDBasePostsViewController.h"

@class WDDMainScreenViewController;

@interface WDDReadLaterViewController : WDDBasePostsViewController

@property (weak, nonatomic) WDDMainScreenViewController *mainScreenViewController;
@property (weak, nonatomic) IBOutlet UITableView *postsTable;


@end
