//
//  WDDChatViewController.m
//  Woddl
//
//  Created by Oleg Komaristov on 23.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import "WDDChatViewController.h"
#import "WDDAppDelegate.h"

#import "WDDChatContactTitle.h"
#import "WDDChatMessageCell.h"

#import "XMPPClient.h"
#import "PrivateMessagesModel.h"
#import "PrivateMessagesStorage.h"
#import "PrivateMessageObject.h"

#import "UIPlaceholderTextView.h"
#import "PullLoadPrevTableView.h"

#import "NSDate+fromDate.h"

#import "XMPPRosterCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"

#import "XMPPMessageDeliveryReceipts.h"

#import "WDDChatMessageTypingCell.h"

#import "WDDDataBase.h"
#import "FaceBookOthersProfile.h"

#import "AvatarManager.h"
#import "UIImageView+AvatarLoading.h"

#define MAX_INPUT_TOOLBAR_HEIGHT    70.0f
#define INPUTTEXTVIEW_TOOLBAR_INSET 11.0f
#define INPUT_BG_EDGE_INSETS UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f)
#define HEADER_COLOR [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f]

@interface WDDChatViewController () <   UITableViewDataSource,
                                        UITableViewDelegate,
                                        NSFetchedResultsControllerDelegate,
                                        UITextViewDelegate,
                                        PullTableViewDelegate,
                                        XMPPStreamDelegate
                                    >
{
    messagesFromDate tableCurrentlyDisplaysMessagesFromDate;
}

@property (strong, nonatomic) IBOutlet PullLoadPrevTableView *messagesTable;

@property (strong, nonatomic) XMPPClient *client;

@property (strong, nonatomic) NSNumber *countOfUnreadMessagesInConverstion;
@property (strong, nonatomic) NSMutableArray *indexesOfMessages;
@property (strong, nonatomic) NSFetchedResultsController *messages;
@property (strong, nonatomic) NSFetchedResultsController *interlocutor;

@property (strong, nonatomic) IBOutlet UITextView *inputTextView;

@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputTextViewHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *keyboardHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *navbarHeight;
@property (weak, nonatomic) IBOutlet UIImageView *textViewBackgroundImageView;
@property (nonatomic, assign) BOOL activateInputFieldsSfouldSall;
@property (strong, nonatomic) UIImageView *interlocutorStatusImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputBGHeight;

@property (nonatomic, strong) XMPPMessageDeliveryReceipts *xmppMessageDeliveryReceipts;

- (IBAction)sendButtonPressed:(id)sender;

@end

@implementation WDDChatViewController

- (void)viewDidLoad
{
    
    
    tableCurrentlyDisplaysMessagesFromDate = messagesFromLastWeek;
    
    self.client = [[PrivateMessagesModel sharedModel] clientByBare:self.contact.streamBareJidStr];
    [self resetUnreadMessagesForContact:self.contact];
    self.inputTextView.scrollsToTop = YES;
    
#ifdef SHOW_AVATAR_AND_NAME_IN_TITLE
    NSData *avatarData = [[self.client xmppvCardAvatarModule] photoDataForJID:self.contact.jid];
    UIImage * avatarImage = nil;
    if (avatarData)
    {
        avatarImage = [UIImage imageWithData:avatarData];
    }
    else
    {
        avatarImage = [UIImage imageNamed:kAvatarPlaceholderImageName];
    }
    
    
    self.navigationItem.titleView = [[WDDChatContactTitle alloc] initWithAvatar:avatarImage name:self.contact.displayName maximumWidth:240];
#else
    [self setupNavigationBarTitle];
#endif
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr LIKE %@ AND timestamp > %@", self.contact.jidStr,
                                                             [NSDate dateFromNow:tableCurrentlyDisplaysMessagesFromDate]];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:self.client.xmppMessageArchivingStorage.messageEntityName];
    
    fetchRequest.predicate = predicate;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    
    self.messages = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                        managedObjectContext:self.client.xmppMessageArchivingStorage.mainThreadManagedObjectContext
                                                          sectionNameKeyPath:nil
                                                                   cacheName:nil];
    
    
     NSLog(@"%i",self.messages.fetchedObjects.count);
    self.messages.delegate = self;
    
    [self.messages performFetch:nil];
    [self removeDuplicates];
     NSLog(@"%i",self.messages.fetchedObjects.count);
    
    
     if (self.contact.unreadMessages)//unread messages
     {
         while (!self.messages.fetchedObjects.count && tableCurrentlyDisplaysMessagesFromDate != messagesFromTimesBeginning)
         {
             if (++tableCurrentlyDisplaysMessagesFromDate > messagesFromTimesBeginning)
             {
                 tableCurrentlyDisplaysMessagesFromDate = messagesFromTimesBeginning;
             }
             
             self.messages.fetchRequest.predicate =
             [NSPredicate predicateWithFormat:@"bareJidStr LIKE %@ AND timestamp > %@",
              self.contact.jidStr,
              [NSDate dateFromNow:tableCurrentlyDisplaysMessagesFromDate]];
             
             [self.messages performFetch:nil];
         }
     }
    
    self.navbarHeight.constant = ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.99f) ? 64.0f : 0.0f;
    self.inputViewTopConstraint.constant = ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.99f) ? 0.0f : 20.0f;
    self.keyboardHeight.constant = ([[[UIDevice currentDevice] systemVersion] floatValue] > 6.99f) ? 0.0f : 20.0f;
    self.inputTextView.layer.cornerRadius = 5.f;
    self.inputTextView.layer.masksToBounds = YES;
    
    //  Disable bottom pull to refresh
    [self.messagesTable disableLoadMore];
    
    self.textViewBackgroundImageView.image = [[UIImage imageNamed:@"inputFieldBG"]
                                              resizableImageWithCapInsets:INPUT_BG_EDGE_INSETS
                                              resizingMode:UIImageResizingModeStretch];
    
    [self setupInterlocutorFetchedResultController];
    [self customizeBackButton];
    
    [self.client.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    //setup XMPPMessageDeliveryReceipts
    self.xmppMessageDeliveryReceipts = [[XMPPMessageDeliveryReceipts alloc] init];
    self.xmppMessageDeliveryReceipts.autoSendMessageDeliveryReceipts = YES;
    self.xmppMessageDeliveryReceipts.autoSendMessageDeliveryRequests = YES;
    
    [self.xmppMessageDeliveryReceipts activate:self.client.xmppStream];
    self.messagesTable.delegate = self;
    
    
}
-(void)removeDuplicates
{

    NSArray *result = [self.client.xmppMessageArchivingStorage.mainThreadManagedObjectContext executeFetchRequest:self.messages.fetchRequest error:nil];
    NSMutableArray * mes = [[NSMutableArray alloc] initWithArray:result];
    
    for(int i=0;i<self.messages.fetchedObjects.count;i++)
    {
        
        NSFetchedResultsController *tmp = (NSFetchedResultsController *)[mes objectAtIndex:i];
        XMPPMessageArchiving_Message_CoreDataObject *message = tmp;
        
        for(int j=0;j<self.messages.fetchedObjects.count;j++)
        {
            if(i!=j)
            {
                NSFetchedResultsController *tmpComp = (NSFetchedResultsController *)[mes objectAtIndex:j];
                XMPPMessageArchiving_Message_CoreDataObject *comp = tmpComp;
                
                if([message.body isEqualToString:comp.body])
                {
                    [self.messages.managedObjectContext deleteObject:comp];
                    
                    
                }
            }
            
        }
        
    }


}
- (void)resetUnreadMessagesForContact:(XMPPUserCoreDataStorageObject *)user
{
    XMPPRosterCoreDataStorage *storage = self.client.xmppRosterStorage;
    [storage executeBlock:^{
        NSFetchRequest *contactRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
        contactRequest.predicate = [NSPredicate predicateWithFormat:@"jidStr LIKE[cd] %@", user.jidStr];
        contactRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES]];
        
        NSError *error;
        NSArray *clients = [self.client.managedObjectContext_roster executeFetchRequest:contactRequest error:&error];
        if (!error)
        {
            for (XMPPUserCoreDataStorageObject *user in clients)
            {
                user.unreadMessages = @(0);
            }
            NSError *error;
            [self.client.managedObjectContext_roster save:&error];
            if (error)
            {
#ifdef DEBUG
                DLog(@"Error: %@", [error localizedDescription]);
#endif
            }
        }
    }];
}

- (void)setupInterlocutorFetchedResultController
{
    NSFetchRequest *interlocutorRequest = [[NSFetchRequest alloc] initWithEntityName:@"XMPPUserCoreDataStorageObject"];
    interlocutorRequest.predicate = [NSPredicate predicateWithFormat:@"jidStr LIKE %@",
                                     self.contact.jidStr];
    interlocutorRequest.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"jidStr" ascending:YES]];
    
    self.interlocutor = [[NSFetchedResultsController alloc] initWithFetchRequest:interlocutorRequest
                                                            managedObjectContext:self.client.managedObjectContext_roster
                                                              sectionNameKeyPath:nil
                                                                       cacheName:nil];
    
    self.interlocutor.delegate = self;
    [self.interlocutor performFetch:nil];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self observeKeyboard:YES];
//    [self.inputTextView becomeFirstResponder];
//}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[Heatmaps trackScreenWithKey:@"503395516a70d21a-e50bbd40"]; ROMA
    
    [self observeKeyboard:YES];
    [self.inputTextView becomeFirstResponder];
    
    if (self.messages.fetchedObjects.count)
    {
        [self.messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

#pragma mark - Keyboar events hadling

- (void)observeKeyboard:(BOOL)observe
{
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    if (observe)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    
    
}
- (void)keyboardWillChangeFrame:(NSNotification*)note
{
    CGRect  frame               = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat animationDuration   = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
//    CGFloat keyboardHeight      = CGRectGetMaxY([[UIScreen mainScreen] bounds]) - CGRectGetMinY(frame);
    
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:animationDuration animations:^(void)
    {
        self.inputViewTopConstraint.constant = 215;
//        self.keyboardHeight.constant = keyboardHeight + (([[[UIDevice currentDevice] systemVersion] floatValue] > 6.99f) ? 0.0f : 20.0f);
        
        [self.view layoutIfNeeded];
    }];
    
    if (self.messages.fetchedObjects.count)
    {
        [self.messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.fetchedObjects.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
//    if(!self.activateInputFieldsSfouldSall)
//    {
//        NSDictionary* keyboardInfo = [note userInfo];
//        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
//        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
//        self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x,self.inputTextView.frame.origin.y>280?self.inputTextView.frame.origin.y-keyboardFrameBeginRect.size.height:self.inputTextView.frame.origin.y, self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
//    }
}

#pragma mark - Table View
static const CGFloat kHeaderHeight = 19.0f;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView;
    headerView = [self setupHeaderView];
    return headerView;
}

static const CGFloat kStatusIconOffset = 6.0f;
static const CGFloat kStatusIconSize = 7.0f;
static const CGFloat kContactLabelOffset = 23.0f;
static const CGFloat kContactLabelHeight = 16.0f;
static const CGFloat kContactLabelWidth = 200.0f;
static const CGFloat kContactLabelYOffset = 2.5f;
static const CGFloat kContactLabelFontSize = 14.0f;

- (UIView *)setupHeaderView
{
    UIView *headerView;
    
    CGRect headerFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kHeaderHeight);
    headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.backgroundColor = HEADER_COLOR;
    
    UIImageView *statusImageView = [self contactStatusImageView];
    statusImageView.frame = CGRectMake(kStatusIconOffset, kStatusIconOffset, kStatusIconSize, kStatusIconSize);
    self.interlocutorStatusImageView = statusImageView;
    
    UILabel *contactLabel = [self contactNameLabel];
    contactLabel.frame = CGRectMake(kContactLabelOffset, headerFrame.size.height - kContactLabelYOffset - kContactLabelHeight, kContactLabelWidth, kContactLabelHeight);
    
    [headerView addSubview:statusImageView];
    [headerView addSubview:contactLabel];
    
    return headerView;
}

- (UIImageView *)contactStatusImageView
{
    XMPPUserCoreDataStorageObject *interlocutor = [[self.interlocutor fetchedObjects] firstObject];
    return [[UIImageView alloc] initWithImage:[self statusImageForState:interlocutor.isOnline]];
}

- (UIImage *)statusImageForState:(BOOL)isOnline
{
    NSString *statusImageName = nil;
    if (isOnline)
    {
        statusImageName = @"ContactOnlineIcon";
    }
    else
    {
        statusImageName = @"ContactOfflineIcon";
    }
    
    UIImage *statusImage = [UIImage imageNamed:statusImageName];
    return statusImage;
}

- (UILabel *)contactNameLabel
{
    UILabel *contactLabel = [[UILabel alloc] init];
    contactLabel.text = self.contact.displayName;
    contactLabel.backgroundColor = [UIColor clearColor];
    contactLabel.font = [UIFont systemFontOfSize:kContactLabelFontSize];
    
    return contactLabel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int res = self.messages.sections.count;
    return res;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger res = [self.messages.sections[section] numberOfObjects];
    
    return res;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.messages objectAtIndexPath:indexPath];
    if (!message.isComposing)
    {
        return [WDDChatMessageCell heightForCellWithText:message.message.body];
    }
    else
    {
        return 44;
    }
}
-(NSIndexPath*)getNextIndexPath:(NSIndexPath*)indexPath
{

    NSInteger newLast = [indexPath indexAtPosition:indexPath.length-1]-1;
    indexPath = [[indexPath indexPathByRemovingLastIndex] indexPathByAddingIndex:newLast];

    return indexPath;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDDChatMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:kChatCellID forIndexPath:indexPath];
    
    
     XMPPMessageArchiving_Message_CoreDataObject *message = [self.messages objectAtIndexPath:indexPath];
    
    
    
                if (!message.isComposing)
                {
                    
                    cell.message = message;
                    
                    [cell setupSubviews];
                    

                    UserProfile *userProfile = nil;
                    NSString *jid = (message.isOutgoing ? self.client.xmppStream.myJID.full : self.contact.jidStr);
                    NSString *userId = [[jid componentsSeparatedByString:@"@"] firstObject];
                    if (userId)
                    {
                        if ([userId rangeOfString:@"-"].location == 0)  // Hack to remove "-" prefix in JID
                        {
                            userId = [userId substringFromIndex:1];
                        }
                        
                        userProfile = [[[WDDDataBase sharedDatabase] fetchObjectsWithEntityName:NSStringFromClass([FaceBookOthersProfile class])
                                                                                  withPredicate:[NSPredicate predicateWithFormat:@"userID == %@", userId]
                                                                                sortDescriptors:nil] firstObject];
                    }
                    
                    UIImage * avatarImage = nil;
                    
                    if (userProfile.avatarRemoteURL && [[AvatarManager sharedManager] isImageCachedForURL:[NSURL URLWithString:userProfile.avatarRemoteURL]] != ICTypeNone)
                    {
                        cell.avatar = [[AvatarManager sharedManager] imageForURL:[NSURL URLWithString:userProfile.avatarRemoteURL]];
                    }
                    else
                    {
                        NSData *avatarData = [[self.client xmppvCardAvatarModule] photoDataForJID:message.isOutgoing ? self.client.xmppStream.myJID : self.contact.jid];
                        
                        if (avatarData)
                        {
                            avatarImage = [UIImage imageWithData:avatarData];
                        }
                        else
                        {
                            avatarImage = [UIImage imageNamed:kAvatarPlaceholderImageName];
                        }
                        
                        cell.avatar = avatarImage;
                        
                        if (userProfile.avatarRemoteURL)
                        {
                            [[AvatarManager sharedManager] loadAvatarForURL:[NSURL URLWithString:userProfile.avatarRemoteURL]
                                                            complitionBlock:nil];
                        }
                    }

                    return cell;
                }
                else
                {
                    WDDChatMessageTypingCell *cell = [tableView dequeueReusableCellWithIdentifier:kTapingCellID forIndexPath:indexPath];
                    
                    NSString * isTypingString = NSLocalizedString(@"lskIsTyping", @"is typing...");
                    
                    cell.typingLabel.text = [NSString stringWithFormat:@"%@ %@", [self contactNameLabel].text, isTypingString];
                    
                    return cell;
                }
    



    return cell;
}




#pragma mark - NSFetchedResultsControllerDelegate protocol implementation

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if ([controller isEqual:self.messages])
    {
        [self.messagesTable beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    if (![controller isEqual:self.messages])
    {
        return;
    }

    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.messagesTable insertRowsAtIndexPaths:@[newIndexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.messagesTable deleteRowsAtIndexPaths:@[indexPath]
                                   withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [self.messagesTable moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.messagesTable reloadRowsAtIndexPaths:@[indexPath]
                                   withRowAnimation:UITableViewRowAnimationNone];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (![controller isEqual:self.messages])
    {
        return;
    }
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.messagesTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                           withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.messagesTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                           withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
            
        case NSFetchedResultsChangeUpdate:
            [self.messagesTable reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                           withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (controller == self.messages)
    {
        [self.messagesTable endUpdates];
        [self.messagesTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.fetchedObjects.count - 1 inSection:0]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else if (controller == self.interlocutor)
    {
        DLog(@"status");
        XMPPUserCoreDataStorageObject *interlocutor = [[controller fetchedObjects] firstObject];
        if (interlocutor && self.interlocutorStatusImageView)
        {
            DLog(@"status updated");
            self.interlocutorStatusImageView.image = [self statusImageForState:interlocutor.isOnline];
        }
    }

}

#pragma mark - text view

- (void)textViewDidChange:(UIPlaceholderTextView *)textView
{
    CGSize size = [textView sizeThatFits:CGSizeMake(self.inputTextView.frame.size.width, INFINITY)];
    
    if (size.height < MAX_INPUT_TOOLBAR_HEIGHT)
    {
        self.inputTextViewHeight.constant   = size.height;
        self.inputBGHeight.constant         = size.height;
        self.inputViewHeight.constant       = size.height + INPUTTEXTVIEW_TOOLBAR_INSET;
    }
    [self.view layoutIfNeeded];
    [textView scrollRangeToVisible:NSMakeRange(textView.text.length - 1, 1)];
    [self checkSendButtonState];
}

#pragma mark - pull delegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    if (++tableCurrentlyDisplaysMessagesFromDate > messagesFromTimesBeginning)
    {
        tableCurrentlyDisplaysMessagesFromDate = messagesFromTimesBeginning;
    }
    
    self.messages.fetchRequest.predicate =
    [NSPredicate predicateWithFormat:@"bareJidStr LIKE %@ AND timestamp > %@",
                                        self.contact.jidStr,
                                        [NSDate dateFromNow:tableCurrentlyDisplaysMessagesFromDate]];
    
    [self.messages performFetch:nil];
    [self removeDuplicates];
    [self.messagesTable reloadData];
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        pullTableView.pullTableIsRefreshing = NO;
    });
}

#pragma mark - actions

- (IBAction)sendButtonPressed:(id)sender
{
    NSString *niceText =
    [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self.client sendMessage:niceText toJid:self.contact.jid];
    
    self.inputTextView.text = @"";
    [self textViewDidChange:self.inputTextView];
}

#pragma mark - helper

- (void)checkSendButtonState
{
    NSString *niceText = [self.inputTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    DLog(@"nice text: \"%@\"", niceText);
    self.sendButton.enabled = niceText.length > 0;
}

-(void)keyboardWillShow:(NSNotification*)notification
{
    self.activateInputFieldsSfouldSall = NO;
    
    //    NSDictionary* keyboardInfo = [notification userInfo];
    //    NSValue* keyboardFrameValue = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    //    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    //    keyboardRect = keyboardFrame;
    //
    //    double animationDuration;
    //    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //    [UIView beginAnimations:nil context:nil];
    //	[UIView setAnimationDuration: animationDuration];
    //
    //    self.addCommentView.frame = CGRectMake(self.addCommentView.frame.origin.x,self.addCommentView.frame.origin.y-keyboardFrame.size.height, self.addCommentView.frame.size.width, self.addCommentView.frame.size.height);
    //
    //    self.commentsTable.frame = CGRectMake(self.commentsTable.frame.origin.x, self.commentsTable.frame.origin.y, self.commentsTable.frame.size.width, self.addCommentView.frame.origin.y-self.commentsTable.frame.origin.y);
    //
    //    [UIView commitAnimations];
}
-(void)keyboardWillHide:(NSNotification*)notification
{
    
    self.activateInputFieldsSfouldSall = YES;
    CGRect screenRect = self.view.frame;
    CGFloat screenHeight = screenRect.size.height;
    double animationDuration = 0.01;
    animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [self.inputTextView resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration: animationDuration];
    
    self.inputTextView.frame = CGRectMake(self.inputTextView.frame.origin.x,
                                           screenHeight-self.inputTextView.frame.size.height,
                                           self.inputTextView.frame.size.width, self.inputTextView.frame.size.height);
    
    [UIView commitAnimations];
    
}

@end
