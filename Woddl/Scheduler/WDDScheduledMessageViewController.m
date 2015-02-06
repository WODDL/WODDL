//
//  WDDScheduledMessageViewController.m
//  Woddl
//
//  Created by Roman Bigun on 11.10.14.
//  Copyright (c) 2014 IDS. All rights reserved.
//

#import <OHAttributedStringAdditions.h>
#import "WDDScheduledMessageViewController.h"
#import "WDDScheduledMessageTableViewCell.h"
#import "WDDSchedulerHelper.h"
#import "WDDDataBase.h"
#import "SAMHUDView.h"
#import "ECSlidingViewController.h"
#import "MBProgressHUD.h"
NSString * const WDDScheduledMessageViewControllerIdentifier = @"ScheduledMessageListViewController";

@interface WDDScheduledMessageViewController ()
@property(weak, nonatomic) NSArray *sns;
@property(retain, nonatomic) NSMutableArray *allMessages;
@property(retain, nonatomic)NSDictionary *dictMessage;
@property (strong, nonatomic) SAMHUDView *progressHUD;
@end

@implementation WDDScheduledMessageViewController
{

    MBProgressHUD *HUD;
}
//- (IBAction)showMainScreenAction:(UIBarButtonItem *)sender
//{
//    WDDStatusViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDStatusScreen];
//    [self.navigationController pushViewController:searchVC animated:YES];
//}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    

}
- (void)customizeEditButton
{
    SEL backActionSelector = ([self.navigationController.viewControllers indexOfObject:self] ? @selector(popBackViewController) : @selector(dismissViewController) );
    [self.editButton addTarget:self action:backActionSelector forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)popBackViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupBackButton
{
    [self customizeBackButton];
    
}

-(NSString *)getTWToken:(NSString*)body
{
    
    if (body.length > 0)
    {
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs)
        {
            
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            
            if (elements.count > 1)
            {
                NSString *field = elements[0];
                NSString *value = elements[1];
                
                if ([field isEqualToString:@"oauth_token"])
                {
                    return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                }
            }
        }
        
        
    }
    
    return @"";
    
    
}
- (id)getTWSecret:(NSString *)body {
    
    if (body.length > 0)
    {
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs)
        {
            
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            
            if (elements.count > 1)
            {
                NSString *field = elements[0];
                NSString *value = elements[1];
                
                if ([field isEqualToString:@"oauth_token_secret"])
                {
                    return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
            }
        }
    }
    
    return @"";
    
    
}
- (id)getTWUserId:(NSString *)body {
    
    if (body.length > 0)
    {
        NSArray *pairs = [body componentsSeparatedByString:@"&"];
        
        for (NSString *pair in pairs)
        {
            
            NSArray *elements = [pair componentsSeparatedByString:@"="];
            
            if (elements.count > 1)
            {
                NSString *field = elements[0];
                NSString *value = elements[1];
                
                if ([field isEqualToString:@"user_id"])
                {
                    return [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                }
            }
        }
    }
    
    return @"";
    
    
}

-(void)loading
{

   
    [self setupNavigationBarTitle];
    [self setupBackButton];
    self.statusViewController = self;
    [WDDDataBase sharedDatabase].updatingStatus = YES;
    self.messagesTableView.delegate=self;
    self.messagesTableView.dataSource=self;
    [self customizeEditButton];
    
    
    self.allMessages = [[NSMutableArray alloc] init];
    
    
    /////////
    
    /////////
    for(int i=0;i<3;i++)
    {
        if(i==0)
        {
            _sns = [[WDDDataBase sharedDatabase] fetchAllSocialNetworks];
            _sns = [_sns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessToken != nil && type == 1"]];
            for(SocialNetwork *tmp in _sns)
            {
                NSString *accessTokenTmp = [tmp accessToken];
                
                    NSArray *arr = [[WDDSchedulerHelper sharedManager] listOfScheduledPostsWithToken:accessTokenTmp andForSocial:@"facebook" andUserId:@""];
                    if(arr.count>0)
                    {
                        [self.allMessages addObjectsFromArray:arr];
                    }
            }
            
            
        }
        if(i==1)
        {
            _sns = [[WDDDataBase sharedDatabase] fetchAllSocialNetworks];
            _sns = [_sns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessToken != nil && type == 2"]];
            for(SocialNetwork *tmp in _sns)
            {
                NSString *accessTokenTmp = [tmp accessToken];
               
                NSArray *arr = [[WDDSchedulerHelper sharedManager] listOfScheduledPostsWithToken:[self getTWSecret:accessTokenTmp] andForSocial:@"twitter" andUserId:[self getTWToken:accessTokenTmp]];
                if(arr.count>0)
                {
                    [self.allMessages addObjectsFromArray:arr];
                }

                
            }
            
        }
        if(i==2)
        {
            _sns = [[WDDDataBase sharedDatabase] fetchAllSocialNetworks];
            _sns = [_sns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessToken != nil && type == 4"]];
            for(SocialNetwork *tmp in _sns)
            {
                NSString *accessTokenTmp = [tmp accessToken];
                NSArray *arr = [[WDDSchedulerHelper sharedManager] listOfScheduledPostsWithToken:accessTokenTmp andForSocial:@"linkedin" andUserId:@""];
                if(arr.count>0)
                {
                    [self.allMessages addObjectsFromArray:arr];
                }
            }
            
            
        }
        
    }
    
    [self.messagesTableView reloadData];
    

}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Loading...";
    HUD.detailsLabelText = @"please wait";
    [HUD showWhileExecuting:@selector(loading) onTarget:self withObject:nil animated:YES];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allMessages.count;
}
-(NSString*)convertUnixTimestamtToHRString:(NSString*)u_time
{

    double unixTimeStamp = [u_time doubleValue];
    NSTimeInterval _interval=unixTimeStamp;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    [_formatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    NSString *_date=[_formatter stringFromDate:date];
    
    return _date;

}
-(IBAction)deleteMessage:(UIButton*)sender
{
    
    int postId=[[NSString stringWithFormat:@"%@",[[self.allMessages valueForKey:@"id"] objectAtIndex:sender.tag]] intValue];
    NSString *token = [NSString stringWithFormat:@"%@",[[self.allMessages valueForKey:@"token"] objectAtIndex:sender.tag]];
    long index = sender.tag;
    NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
    [object setObject:[NSString stringWithFormat:@"%i",postId] forKey:@"postId"];
    [object setObject:token forKey:@"token"];
    [object setObject:[NSString stringWithFormat:@"%li",index] forKey:@"indexToDelete"];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    HUD.delegate = self;
    HUD.labelText = @"Deleting...";
    HUD.detailsLabelText = @"please wait";
    
    [HUD showWhileExecuting:@selector(deletingAction:) onTarget:self withObject:object animated:YES];
    
}
-(void)deletingAction:(NSDictionary*)data
{
    if(data)
    {
        
        [[WDDSchedulerHelper sharedManager] deletePostWithId:[[NSString stringWithFormat:@"%@",[data objectForKey:@"postId"]] intValue] andToken:[data objectForKey:@"token"]];
        [self.allMessages removeObjectAtIndex:[[NSString stringWithFormat:@"%@",[data objectForKey:@"indexToDelete"]] intValue]];
        [self.messagesTableView reloadData];
    }
    
    

}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDDScheduledMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WDDMessageTableViewCellIdentifier forIndexPath:indexPath];
    NSString *post = [[self.allMessages valueForKey:@"post"] objectAtIndex:indexPath.row];
    cell.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    if(post.length>37)
    {
        [cell.messageLabel setNumberOfLines:2];
    }
    if(post.length>60)
    {
        [cell.messageLabel setNumberOfLines:3];
    }
    
    cell.messageLabel.attributedText = [self getTagHighlightedText: post];
    cell.messageTime.text = [NSString stringWithFormat:@"Time: %@",[self convertUnixTimestamtToHRString:[[self.allMessages valueForKey:@"time"] objectAtIndex:indexPath.row]]];
    cell.messageStatus.text = [NSString stringWithFormat:@"Status: %@",[[self.allMessages valueForKey:@"status"] objectAtIndex:indexPath.row]];
    cell.messageDelete.tag = indexPath.row;
    [cell.messageDelete addTarget:self action:@selector(deleteMessage:) forControlEvents:UIControlEventTouchUpInside];
    cell.messageEdit.tag = indexPath.row;
    [cell.messageEdit addTarget:self action:@selector(editMessage:) forControlEvents:UIControlEventTouchUpInside];
    NSLog(@"Path = %@",[NSString stringWithFormat:@"%@",[[self.allMessages valueForKey:@"path"] objectAtIndex:indexPath.row]]);
    
    if([[NSString stringWithFormat:@"%@",[[self.allMessages valueForKey:@"path"] objectAtIndex:indexPath.row]] length]>10)
    {
        cell.messageHasAttachment.alpha=1;
    }
    else
    {
    
        cell.messageHasAttachment.alpha=0;
    
    }
    if([[[self.allMessages valueForKey:@"social"] objectAtIndex:indexPath.row] isEqualToString:@"facebook"])
    {
        
        [cell.messageSocialTwiter setBackgroundImage:[UIImage imageNamed:@"facebook-pre.png"] forState:UIControlStateNormal];
        
    }
    else if([[[self.allMessages valueForKey:@"social"] objectAtIndex:indexPath.row] isEqualToString:@"twitter"])
    {
       [cell.messageSocialTwiter setBackgroundImage:[UIImage imageNamed:@"twitter-pre.png"] forState:UIControlStateNormal];
    }
    else if([[[self.allMessages valueForKey:@"social"] objectAtIndex:indexPath.row] isEqualToString:@"linkedin"])
    {
        [cell.messageSocialTwiter setBackgroundImage:[UIImage imageNamed:@"linkedin-pre.png"] forState:UIControlStateNormal];
    }
    

    return cell;
}

- (NSMutableAttributedString*)getTagHighlightedText: (NSString *)text
{
    NSString *regexString = [NSString stringWithFormat:@"(?:(?<=\\s)|^)(#|@)(\\w*[0-9A-Za-z_]+\\w*)"];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern: regexString
                                                                            options: NSRegularExpressionCaseInsensitive
                                                                              error: nil];
    NSArray *matches = [regex matchesInString: text
                                      options: 0
                                        range: NSMakeRange(0, [text length])];
    
    NSMutableAttributedString *highlitedText = [NSMutableAttributedString attributedStringWithString: text];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        [highlitedText setAttributes: @{ NSFontAttributeName: [UIFont boldSystemFontOfSize: kPostFontSize ],
                              NSForegroundColorAttributeName: [UIColor blackColor] }
                               range: matchRange];
    }
    
    return highlitedText;
}

#pragma mark - UITableView delegate
#pragma mark

const CGFloat kRowHeightMessages = 111.0f;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeightMessages;
}

-(IBAction)editMessage:(UIButton*)sender
{

    self.dictMessage=[[NSDictionary alloc] initWithDictionary:(NSDictionary*)[self.allMessages objectAtIndex:sender.tag]];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:[NSKeyedArchiver archivedDataWithRootObject:self.dictMessage] forKey:@"curEditingMessage"];
    [def synchronize];
    
    [self popBackViewController];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)sender {
    
  
    
}


@end
