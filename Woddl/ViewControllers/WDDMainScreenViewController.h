//
//  IDSMainScreenViewController.h
//  Woddl
//
//  Created by Oleg Komaristov on 22.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullTableView.h"
#import "WDDBasePostsViewController.h"

@interface WDDMainScreenViewController : WDDBasePostsViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, PullTableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuSideButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;

@property (weak, nonatomic) IBOutlet PullTableView *postsTable;
@property (weak, nonatomic) IBOutlet UILabel *emptyGroupLabel;

//  Social network filtering
@property (strong, nonatomic) NSNumber *socialNetworkFilterType;
@property (strong, nonatomic) NSString *groupIDFilter;

- (void)showMainScreenAction:(UIBarButtonItem *)sender;

@end
