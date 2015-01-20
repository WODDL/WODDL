//
//  WDDStatusViewController.m
//  Woddl
//
//  Created by Oleg Komaristov on 23.10.13.
//  Copyright (c) 2013 IDS. All rights reserved.
//

#import "WDDStatusViewController.h"
#import "WDDDataBase.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WDDLocationManager.h"
#import "SAMHUDView.h"
#import <MBProgressHUD.h>
#import <WYPopoverController.h>
#import "WDDStatusSNAccountsViewController.h"
#import "WDDAddFriendViewController.h"
#import "WDDLocationsListViewController.h"
#import "FoursquareRequest.h"
#import "FacebookRequest.h"
#import "WDDSchedulerHelper.h"
#import "WDDURLShorter.h"
#import "UIImage+ResizeAdditions.h"
#import "NSCharacterSet+Emoji.h"
#import "WDDScheduledMessageViewController.h"
#import "DDXML.h"
#define POPOVER_COLOR [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f]



@interface WDDStatusViewController () < UITextViewDelegate,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate,
                                        UIActionSheetDelegate,
                                        WDDStatusSNAccountsDelegate,
                                        WYPopoverControllerDelegate,
                                        WDDAddFriendDelegate,
                                        WDDLocationsListDelegate,MBProgressHUDDelegate>
{
MBProgressHUD *HUD;
}

//  Views

@property (weak, nonatomic) IBOutlet UITextView *hiddenTextView;

@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *charCounterLabel;
@property (weak, nonatomic) IBOutlet UIButton *getLocationButton;

@property (weak, nonatomic) UIActionSheet *photoActionSheet;

@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (weak, nonatomic) IBOutlet UIView *preViewView;
@property (assign, nonatomic)BOOL isNeededToUpdateSchedulerFrame;
@property (weak, nonatomic) IBOutlet UIImageView *preViewImageView;
@property (strong, nonatomic) NSData *mediaAttachmentForSchedulePost;
// Model
@property (strong, nonatomic) NSMutableArray *imagePickerController;

@property (assign, nonatomic) NSInteger twitterCharactersLeft;

@property (strong, nonatomic) id mediaAttachment;
@property (assign, nonatomic, getter = isCameraMediaSource) BOOL cameraMediaSource;
@property (strong, nonatomic) WDDLocation *currentLocation;

@property (strong, nonatomic) SAMHUDView *progressHUD;
@property (assign, nonatomic) BOOL isEditMode;
@property (assign, nonatomic) int editingPostId;
@property (strong, nonatomic) NSString *editingPostToken;
@property (assign, nonatomic, getter = isEnteringTag) BOOL enteringTag;
@property (assign, nonatomic, getter = shouldResetFontToNormal) BOOL resetFontToNormal;
@property (assign, nonatomic, getter = isLastCharacterEmoji) BOOL lastCharacterEmoji;
@property (strong, nonatomic) WYPopoverController *popoverVC;

//Constraint

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstraint;



//  Selected social networks
@property (strong, nonatomic) NSArray *linkedInSelectedAccounts;
@property (strong, nonatomic) NSArray *facebookSelectedAccounts;
@property (strong, nonatomic) NSArray *facebookSelectedGroups;
@property (strong, nonatomic) NSArray *foursquareSelectedAccounts;
@property (strong, nonatomic) NSArray *twitterSelectedAccounts;
@property (strong, nonatomic) UISwitch *intentSwitch;

@end

static const NSInteger kSocialNetworkButtonTagBase = 2000;
static const NSInteger kMaxCountOfCharactersInText = 140;
static const NSInteger kTwitterImageLinkLength =  26;

@implementation WDDStatusViewController

@synthesize statusesTaskCounter = _statusesTaskCounter;

#pragma mark - lifecycle methods
#pragma mark SCHEDULER

- (void)showWithDetailsLabel
{
    if (APP_DELEGATE.isInternetConnected)
    {
//        if(IS_IPHONE_4 && self.isNeededToUpdateSchedulerFrame)
//        {
//            self.isNeededToUpdateSchedulerFrame = NO;
//            self.schedulerView.frame = CGRectMake(self.schedulerView.frame.origin.x,self.schedulerView.frame.origin.y-88 , self.schedulerView.frame.size.width, self.schedulerView.frame.size.height);
//            
//        }
       
        UIViewController *myController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScheduledMessageListViewController"];
        [self.navigationController pushViewController: myController animated:YES];
    }
    else
    {
        
        [UIAlertView showAlertWithMessage:@"Internet connection error"];
        
    }

    
}
-(IBAction)displayScheduledMessages:(UIButton*)sender
{
//    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
//    [self.navigationController.view addSubview:HUD];
//    
//    HUD.delegate = self;
//    HUD.labelText = @"Loading...";
//    HUD.detailsLabelText = @"updating data";
//    HUD.square = YES;
//    
//    //update main UI
//    
//    self.schedulerView.alpha=1;
//    
//    ///////////
//    
//    [HUD showWhileExecuting:@selector(showWithDetailsLabel) onTarget:self withObject:nil animated:YES];
    [self showWithDetailsLabel];
    
    
    
}

-(void)presentMessagesListPopoverfromView:(UIView*)view
{
    
    
             
             WDDScheduledMessageViewController *locationVC = [self.storyboard instantiateViewControllerWithIdentifier:WDDScheduledMessageViewControllerIdentifier];
    
             WYPopoverController *popover = [[WYPopoverController alloc] initWithContentViewController:locationVC];
             popover.popoverContentSize = locationVC.view.frame.size;
             
             popover.delegate = self;
             self.popoverVC = popover;
             
             [popover presentPopoverFromRect:[view bounds]
                                      inView:view
                    permittedArrowDirections:WYPopoverArrowDirectionDown
                                    animated:YES];
             
    
    
    
    
    
    
    
}
- (void)updateUIWithMessageInfo:(NSNotification *)notification
{
    
}
- (void)updateUIWithMessageInfoDict:(NSDictionary *)notification
{
    
    self.isEditMode = YES;
    self.editingPostId = [[NSString stringWithFormat:@"%@",[notification objectForKey:@"id"]] intValue];
    self.editingPostToken = [NSString stringWithFormat:@"%@",[notification objectForKey:@"token"]];
    self.schedulerView.alpha=1;
    self.inputTextview.text = [notification objectForKey:@"post"];
    
    if([[notification  objectForKey:@"social"] isEqualToString:@"facebook"])
    {
        [self.facebookButton setSelected:YES];
        [self.facebookButton setEnabled:YES];
        [self.twitterButton setSelected:NO];
        [self.linkedInButton setSelected:NO];
    }
    else if([[notification objectForKey:@"social"] isEqualToString:@"linkedin"])
    {
        [self.facebookButton setSelected:NO];
        [self.twitterButton setSelected:NO];
        [self.linkedInButton setSelected:YES];
        [self.linkedInButton setEnabled:YES];
    }
    else if([[notification objectForKey:@"social"] isEqualToString:@"twitter"])
    {
        [self.facebookButton setSelected:NO];
        [self.twitterButton setSelected:YES];
        [self.linkedInButton setSelected:NO];
        [self.twitterButton setEnabled:YES];
    }
    
    [self.view endEditing:YES];
    self.schedulerView.alpha=1.0f;
    int timeint = [[NSString stringWithFormat:@"%@",[notification objectForKey:@"time"]] intValue];
    [self.schedulerDataTimePeaker setDate:[NSDate dateWithTimeIntervalSince1970:timeint] animated:YES];
    
    //
    //Check for atachment
    NSString *url = [NSString stringWithFormat:@"%@",[notification objectForKey:@"path"]];
    NSLog(@"%@",url);
    if(url.length>10)//Load attachment
    {
        
                    
           UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
            // Then to set the image it must be done on the main thread
        
                if(image)
                {
                    
                    self.preViewImageView.image = [image thumbnailImage:25.f
                                                      transparentBorder:0.f
                                                           cornerRadius:1.f
                                                   interpolationQuality:kCGInterpolationDefault];
                    
                    self.mediaAttachment = UIImageJPEGRepresentation(image, 0.9);
                    _mediaAttachment = self.mediaAttachment;
                    
                    
                }
        
        
    }
    else
    {
        
        
        
        
    }
    [self updateCounter];
    [self updateCameraButton];
    [self updateLocationUI];
    [self.inputTextview becomeFirstResponder];
    
    
}

-(IBAction)displaySchedulerDateTimePeaker:(UIButton*)sender
{
    
//    if(IS_IPHONE_4)
//    {
//        self.isNeededToUpdateSchedulerFrame = NO;
//        self.schedulerView.frame = CGRectMake(self.schedulerView.frame.origin.x,self.schedulerView.frame.origin.y-88 , self.schedulerView.frame.size.width, self.schedulerView.frame.size.height);
//
//    }
    
    [self.schedulerDataTimePeaker becomeFirstResponder];
    [self.view endEditing:YES];
    self.schedulerView.alpha=1.0f;
    self.inputTextview.userInteractionEnabled = NO;
    
    
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

-(NSString*)getUserInfoWithToken:(NSString*)token
{
    NSMutableURLRequest *userRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"https://api.linkedin.com/v1/people/~:(first-name,last-name,picture-url,id)?oauth2_access_token=%@",token]]];
    
    NSError *error = nil; NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:userRequest returningResponse:&response error:&error];
    
    if(data)
    {
        DDXMLDocument *xmlDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
        DDXMLElement *rootElement = xmlDocument.rootElement;
        DDXMLElement* userIDElement = [[rootElement elementsForName:@"id"] firstObject];
        NSString* userID = [userIDElement stringValue];
        if (userID)
            return userID;
   
    }
    
    return @"";
}

-(void)displayProcessingMessages
{
    [self showProcessHUDWithText:@""];
   
    if (APP_DELEGATE.isInternetConnected)
    {
         if(self.isEditMode)
        {
            
            
            [[WDDSchedulerHelper sharedManager] deletePostWithId:self.editingPostId andToken:self.editingPostToken];
            
            self.isEditMode = NO;
            self.editingPostId = -1;
            self.editingPostToken = @"";
            
        }
        
        NSArray *allAvailableSelectedAccounts = [self formAllAvailableSelectedAccountsList];
        if(allAvailableSelectedAccounts.count==0)
        {
            
            [self showProcessHUDWithText:@""];
            [self removeProcessHUDWithText:@"Select social!"];
            return;
            
        }
        
      //  NSArray *allAvailableSelectedGruops = [self fromAllAvailableSelectedGroupsList];
        
       
       
        
        for (SocialNetwork *sn in allAvailableSelectedAccounts)
        {
                if(sn.type==[NSNumber numberWithInt:1])
                {
                   
                        NSString *accessTokenTmp = [sn accessToken];
                        
                        NSLog(@"LI token %@",accessTokenTmp);
                        
                        if([[WDDSchedulerHelper sharedManager] scheduleMessage2:self.inputTextview.text token:accessTokenTmp secret:@"" userID:@"" picture:self.mediaAttachment sendDate:self.schedulerDataTimePeaker.date forSocial:@"facebook"  userName:sn.profile.name]
                           )
                        {
                            [self showProcessHUDWithText:@""];
                            
                        }
                   
                   
                    
                }
                else if(sn.type==[NSNumber numberWithInt:2])
                {
                    

                    
                        NSString *accessTokenTmp = [sn accessToken];
                        NSLog(@"TW token %@",[self getTWToken:accessTokenTmp]);
                        NSLog(@"TW secret %@",[self getTWSecret:accessTokenTmp]);
                        NSLog(@"TW userId %@",[self getTWUserId:accessTokenTmp]);
                        
                        if([[WDDSchedulerHelper sharedManager] scheduleMessage2:self.inputTextview.text token:[self getTWSecret:accessTokenTmp] secret:@""  userID:[self getTWToken:accessTokenTmp] picture:self.mediaAttachment sendDate:self.schedulerDataTimePeaker.date forSocial:@"twitter"  userName:sn.profile.name])
                        {
                            [self showProcessHUDWithText:@""];
                           
                        }
                    
                    
                }
                else if(sn.type==[NSNumber numberWithInt:4])
                {
                    
                            NSString *accessTokenTmp = [sn accessToken];
                        
                            NSLog(@"LI token %@",accessTokenTmp);
                            if([[WDDSchedulerHelper sharedManager] scheduleMessage2:self.inputTextview.text token:accessTokenTmp secret:@""  userID:[self getUserInfoWithToken:accessTokenTmp] picture:self.mediaAttachment sendDate:self.schedulerDataTimePeaker.date  forSocial:@"linkedin" userName:sn.profile.name])
                            {
                            
                                [self showProcessHUDWithText:@""];
                                
                            }
                   
                    
                }
         
        
        
        }
        
    }
    else
    {
        
        [UIAlertView showAlertWithMessage:@"Internet connection error"];
        
    }
         
    [self removeProcessHUDWithText:@"Done."];
    [self.inputTextview becomeFirstResponder];
    [self updateUI];
}
         
         
         
         
         
- (void)myMixedTask {
    // Indeterminate mode
    sleep(2);
    // Switch to determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Progress";
    float progress = 0.0f;
    while (progress < 1.0f)
    {
        progress += 0.01f;
        HUD.progress = progress;
        usleep(50000);
    }
    // Back to indeterminate mode
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Cleaning up";
    sleep(2);
    // UIImageView is a UIKit class, we have to initialize it on the main thread
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    HUD.customView = imageView;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = @"Completed";
    sleep(2);
}
-(IBAction)schedulerDoneAction:(UIButton*)sender
{
   
    [self.inputTextview becomeFirstResponder];
    self.inputTextview.userInteractionEnabled = YES;
    self.isEditMode = YES;
    
    
}
- (void)showProcessHUDWithText:(NSString *)text
{
    if (!self.progressHUD)
    {
        self.progressHUD = [[SAMHUDView alloc] initWithTitle:text];
        [self.progressHUD show];
    }
    else
    {
        self.progressHUD.textLabel.text = text;
    }
}
- (void)removeProcessHUDWithText:(NSString *)text
{
    if (self.progressHUD)
    {
        [self.progressHUD completeAndDismissWithTitle:text];
        self.progressHUD = nil;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupButtons];
    self.twitterCharactersLeft = kMaxCountOfCharactersInText;
    [self setupNavigationBarTitle];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUIWithMessageInfo:) name:@"kNotificationMessageChoosenIdentifyer" object:nil];
    [self setupPopoverAppearance];
    self.isNeededToUpdateSchedulerFrame = YES;
    UIImage* sendButtonImage = [UIImage imageNamed:@"SendIcon"];
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.bounds = CGRectMake( 0, 0, sendButtonImage.size.width, sendButtonImage.size.height );
    [customButton setImage:sendButtonImage forState:UIControlStateNormal];
    [customButton addTarget:self action:@selector(saveStatusAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setCustomView:customButton];
    self.inputTextview.delegate = self;
    [self customizeBackButton];
    [self updateUI];
   
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.isNeededToUpdateSchedulerFrame = YES;
    [self.inputTextview resignFirstResponder];
    [super viewWillDisappear:YES];

}
- (void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [super viewDidAppear:animated];
   // [Heatmaps trackScreenWithKey:@"503395516a70d21a-087c22d3"];
    
    [WDDDataBase sharedDatabase].updatingStatus = YES;
    [self.inputTextview becomeFirstResponder];
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSData *data = [def objectForKey:@"curEditingMessage"];
    NSDictionary *retrievedDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSDictionary * dictionaryForEditingIem = [[NSDictionary alloc] initWithDictionary:retrievedDictionary];
    if(dictionaryForEditingIem.count>0)
    {
        
        [self updateUIWithMessageInfoDict:dictionaryForEditingIem];
        
    }
}

- (void)setupButtons
{
    [self setupSocialNetworkButtonsTag];
    
    [self setupButtonForSocialNetwork:kSocialNetworkFacebook];
    [self setupButtonForSocialNetwork:kSocialNetworkTwitter];
    [self setupButtonForSocialNetwork:kSocialNetworkLinkedIN];
    [self setupButtonForSocialNetwork:kSocialNetworkFoursquare];
}
- (void)setupSocialNetworkButtonsTag
{
    
    self.facebookButton.tag = kSocialNetworkButtonTagBase + kSocialNetworkFacebook;
    self.twitterButton.tag = kSocialNetworkButtonTagBase + kSocialNetworkTwitter;
    self.linkedInButton.tag = kSocialNetworkButtonTagBase + kSocialNetworkLinkedIN;
    self.foursquareButton.tag = kSocialNetworkButtonTagBase + kSocialNetworkFoursquare;
    
}
- (void)setupButtonForSocialNetwork:(SocialNetworkType)type
{
    NSInteger tag = kSocialNetworkButtonTagBase + type;
    UIButton *button = (UIButton *)[self.view viewWithTag:tag];
    
    if ([button isKindOfClass:[UIButton class]])
    {
        NSInteger supportingNetworks = [[WDDDataBase sharedDatabase] availableSocialNetworks];
        if (supportingNetworks & type)
        {
            button.selected = NO;
        }
        else
        {
            button.enabled = NO;
        }
    }
}

- (void)setupPopoverAppearance
{
    [WYPopoverBackgroundView appearance].fillBottomColor = POPOVER_COLOR;
    [WYPopoverBackgroundView appearance].fillTopColor = POPOVER_COLOR;
    [WYPopoverBackgroundView appearance].borderWidth = 5.0f;
}

#pragma mark - Setters 

- (void)setTwitterCharactersLeft:(NSInteger)twitterCharactersLeft
{
    _twitterCharactersLeft = twitterCharactersLeft;
    
    if (twitterCharactersLeft < 0)
    {
        if (self.twitterButton.isEnabled)
        {
            isTwitterButtonEnabled  = self.twitterButton.isEnabled;
            self.twitterButton.enabled = NO;
        }
        
        self.charCounterLabel.textColor = [UIColor redColor];
    }
    else
    {
        if (isTwitterButtonEnabled)
        {
            self.twitterButton.enabled = isTwitterButtonEnabled;
            self.twitterButton.selected = self.twitterSelectedAccounts.count;
        }
        self.charCounterLabel.textColor = [UIColor whiteColor];
    }
    
    self.charCounterLabel.text = [NSString stringWithFormat:@"%d", twitterCharactersLeft];
}

- (void)setMediaAttachment:(id)mediaAttachment
{
//    if (!mediaAttachment && _mediaAttachment)
//    {
//        if(isLinkedinButtonEnabled)
//        {
//            self.linkedInButton.selected = self.linkedInSelectedAccounts.count;;
//        }
//        
//        self.twitterCharactersLeft += kTwitterImageLinkLength;
//    }
//    else
//    {
//        if (self.linkedInButton.isEnabled)
//        {
//            isLinkedinButtonEnabled  = self.linkedInButton.isEnabled;
//            self.linkedInButton.enabled = NO;
//        }
//    }
    _mediaAttachment = mediaAttachment;
}

#pragma mark - Bar items action
//ROMA - Запостить пост )

- (IBAction)saveStatusAction:(UIBarButtonItem *)sender
{
    //ROMA: TODO:Зделать отсрочку отсылки поста
    if(self.isEditMode)
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        
        HUD.delegate = self;
        HUD.labelText = @"Scheduling...";
        HUD.detailsLabelText = @"please wait";
        HUD.square = YES;
       // [self updateUI];
        [self.schedulerButton setEnabled:YES];
        [self.inputTextview resignFirstResponder];
        [HUD showWhileExecuting:@selector(displayProcessingMessages) onTarget:self withObject:nil animated:YES];
        
    }
    else
    {

    if (![APP_DELEGATE isInternetConnected])
    {
        [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"lskConnectInternet", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"lskOK", @"") otherButtonTitles:nil] show];
       return ;
    }
    
    NSArray *allAvailableSelectedAccounts = [self formAllAvailableSelectedAccountsList];
    NSArray *allAvailableSelectedGruops = [self fromAllAvailableSelectedGroupsList];
    
    if (!self.inputTextview.text.length)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"lsEnterStatusUpdate", @"No SN selected")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"lskOK", @"OK button")
                          otherButtonTitles:nil] show];
        return ;
    }
    
    if (!allAvailableSelectedAccounts.count && !allAvailableSelectedGruops.count)
    {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:NSLocalizedString(@"lskSelectNetwork", @"No SN selected")
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"lskOK", @"OK button")
                          otherButtonTitles:nil] show];
        return ;
    }
    
    
    __weak WDDStatusViewController *wSelf = self;
    
    self.statusesTaskCounter++;
    
    [self processLinksInText:self.inputTextview.attributedText.mutableCopy
                 withOptions:ProcessLinksAtLastPosition
                  complition:^(BOOL isChanged, NSAttributedString *text)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            DLog(@"Status will be updated for %i accounts",   allAvailableSelectedAccounts.count);
            
            for (SocialNetwork *sn in allAvailableSelectedAccounts)
            {
                wSelf.statusesTaskCounter++;
                NSManagedObjectID *userID = sn.profile.objectID;
                
                DLog(@"Update status for social network %@ type %@", sn.type, sn.profile.name);
                
                [sn addStatusWithMessage:text.string
                               andImages:(wSelf.mediaAttachment ? @[wSelf.mediaAttachment] : nil)
                               andLocation:wSelf.currentLocation
                               withCompletionBlock:^(NSError *error)
                 {
                         
                         if (error)
                         {
                             [wSelf showStatusErrorForAcccountWithID:userID];
                             
                             DLog(@"Error: %@", [error localizedDescription]);
                         }
                         else
                         {
                             wSelf.statusesTaskCounter--;
                         }
                    }];
            }
            
            for (Group *group in allAvailableSelectedGruops)
            {
                for (UserProfile *user in group.managedBy)
                {
                    wSelf.statusesTaskCounter++;
                    NSManagedObjectID *userID = user.objectID;
                    
                    [user.socialNetwork addStatusWithMessage:text.string
                                                   andImages:(wSelf.mediaAttachment ? @[wSelf.mediaAttachment] : nil)
                                                 andLocation:wSelf.currentLocation
                                                     toGroup:group
                                         withCompletionBlock:^(NSError *error) {
                             
                                             if (error)
                                             {
                                                 [wSelf showStatusErrorForAcccountWithID:userID];
                                                 
                                                 DLog(@"Error: %@", [error localizedDescription]);
                                             }
                                             else
                                             {
                                                 wSelf.statusesTaskCounter--;
                                             }
                                         }];
                }
            }
            
            self.statusesTaskCounter--;
        });
    }];
    }
    [self.inputTextview becomeFirstResponder];
     NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setObject:[NSKeyedArchiver archivedDataWithRootObject:nil] forKey:@"curEditingMessage"];
    [def synchronize];
    
}

const NSInteger kStatusUpdateErrorAlertTag = 4321;

- (void)showStatusErrorForAcccountWithID:(NSManagedObjectID *)profileID
{
    if (!profileID)
    {
        DLog(@"Try to show error with nil profileID");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UserProfile *profile = (UserProfile *)[[WDDDataBase sharedDatabase].managedObjectContext objectWithID:profileID];
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"lskStatusUpdateError", @"Sataus change error message"), profile.name];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"lskError", @"")
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"lskClose", @"")
                                              otherButtonTitles:nil];
        alert.tag = kStatusUpdateErrorAlertTag;
        [alert show];
    });
}

- (NSArray *)fromAllAvailableSelectedGroupsList
{
    NSMutableArray *allSelectedGroups = [[NSMutableArray alloc] init];
    
    if (self.facebookSelectedGroups.count)
    {
        [allSelectedGroups addObjectsFromArray:self.facebookSelectedGroups];
    }
    
    return [allSelectedGroups copy];
}

- (NSArray *)formAllAvailableSelectedAccountsList
{
    NSMutableArray *allSelectedAccounts = [[NSMutableArray alloc] init];
    
    
    if (self.twitterSelectedAccounts.count && self.twitterCharactersLeft >= 0 && self.twitterButton.isEnabled)
    {
        [allSelectedAccounts addObjectsFromArray:self.twitterSelectedAccounts];
    }
    if (self.facebookSelectedAccounts.count)
    {
        [allSelectedAccounts addObjectsFromArray:self.facebookSelectedAccounts];
    }
    if (self.foursquareSelectedAccounts.count && self.foursquareButton.isEnabled)
    {
        [allSelectedAccounts addObjectsFromArray:self.foursquareSelectedAccounts];
    }
    if (self.linkedInSelectedAccounts.count && self.linkedInButton.isEnabled)
    {
        [allSelectedAccounts addObjectsFromArray:self.linkedInSelectedAccounts];
    }
    
    return [allSelectedAccounts copy];
}

#pragma mark - Appearance methods

- (void)dismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.presentingViewController dismissViewControllerAnimated:YES
                                                  completion:nil];
    });
}

#pragma mark - Actions

- (IBAction)setActiveNetwork:(UIButton *)sender
{
    SocialNetworkType type = sender.tag - kSocialNetworkButtonTagBase;
    NSArray *accounts = [[WDDDataBase sharedDatabase] fetchSocialNetworksAscendingWithType:type];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.accessToken != nil"];
    accounts = [accounts filteredArrayUsingPredicate:predicate];
//    NSSet *myGroups = [[[accounts firstObject] groups] filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"isManagedByMe == %@", @YES]];
    
    if (accounts.count > 1 || [[[accounts firstObject] profile] manageGroups].count)
    {
        WDDStatusSNAccountsViewController *accountsVC = [self.storyboard instantiateViewControllerWithIdentifier:kStoryboardIDStatusSNAccountsViewController];
        accountsVC.socialNetworkType = type;
        accountsVC.delegate = self;
        accountsVC.selectedAccounts = [[self selectedAccountsForSocialNetworkType:type] mutableCopy];
        accountsVC.selectedGroups = [[self selectedGroupsForSocialNetworkType:type] mutableCopy];
        
        WYPopoverController *popover = [[WYPopoverController alloc] initWithContentViewController:accountsVC];
        popover.popoverContentSize = accountsVC.view.frame.size;
       
        popover.delegate = self;
        self.popoverVC = popover;
        
        [popover presentPopoverFromRect:sender.bounds
                                 inView:sender
               permittedArrowDirections:WYPopoverArrowDirectionDown
                               animated:YES];
    }
    else
    {
        if ([self selectedAccountsForSocialNetworkType:type].count)
        {
            [self setSelectedAccounts:@[] andGroups:@[] forType:type];
        }
        else
        {
            [self setSelectedAccounts:accounts andGroups:@[] forType:type];
        }
        [self updateUI];
    }
}

- (NSArray *)selectedAccountsForSocialNetworkType:(SocialNetworkType)type
{
    NSArray *accounts;
    if (type == kSocialNetworkFacebook)
    {
        accounts = self.facebookSelectedAccounts;
    }
    else if (type == kSocialNetworkLinkedIN)
    {
        accounts = self.linkedInSelectedAccounts;
    }
    else if (type == kSocialNetworkFoursquare)
    {
        accounts = self.foursquareSelectedAccounts;
    }
    else if (type == kSocialNetworkTwitter)
    {
        accounts = self.twitterSelectedAccounts;
    }
    
    return accounts;
}

- (NSArray *)selectedGroupsForSocialNetworkType:(SocialNetworkType)type
{
    NSArray *groups;
    if (type == kSocialNetworkFacebook)
    {
        groups = self.facebookSelectedGroups;
    }
    
    return groups;
}

- (IBAction)takeMedia:(id)sender
{
    if (self.cameraButton.selected)
    {
        self.mediaAttachment = nil;
        [self updateUI];
    }
    else
    {
        [self showPhotoActionSheet];
    }
}

- (IBAction)getLocation:(UIButton *)sender
{
    if (self.currentLocation)
    {
        self.currentLocation = nil;
    }
    else
    {
        
        GetLocationBlock resultBlock = ^(WDDLocation *location, NSError *error)
        {
            if (!error)
            {
                NSArray *sns = [[WDDDataBase sharedDatabase] fetchAllSocialNetworks];
                sns = [sns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"accessToken != nil && type == 1"]];
                [[FacebookRequest new] getLocationsWithLocation:location
                                                    accessToken:[sns.firstObject accessToken]
                                                     completion:^(NSArray *locations)
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         if (locations)
                         {
                             
                             [self presentLocationsListPopoverWithLocations:locations
                                                                   fromView:sender];
                         }
                         else
                         {
                             DLog(@"error");
                         }
                     });
                     
                 }];

#ifdef DEBUG
                DLog(@"%@", location);
#endif
            }
            else
            {
#ifdef DEBUG
                DLog(@"%@", [error localizedDescription]);
#endif
            }
        };
        [[WDDLocationManager sharedLocationManager] getCurrentLocationInComplition:resultBlock];
    }
    [self updateUI];
}

- (IBAction)addSharp:(id)sender
{
    
    NSRange cursorPostion = self.inputTextview.selectedRange;
    self.inputTextview.text = [self.inputTextview.text stringByReplacingCharactersInRange:cursorPostion withString:@"#"];
    cursorPostion.location += 1;
    self.inputTextview.selectedRange = cursorPostion;
}

#pragma mark - Location help methods
#pragma mark 

- (void)presentLocationsListPopoverWithLocations:(NSArray *)locations fromView:(UIView *)view
{
    WDDLocationsListViewController *locationVC = [self.storyboard instantiateViewControllerWithIdentifier:WDDLocationsListViewControllerIdentifier];
    
    locationVC.locations = locations;
    locationVC.delegate = self;
    
    WYPopoverController *popover = [[WYPopoverController alloc] initWithContentViewController:locationVC];
    popover.popoverContentSize = locationVC.view.frame.size;
    
    popover.delegate = self;
    self.popoverVC = popover;
    
    [popover presentPopoverFromRect:[view bounds]
                             inView:view
           permittedArrowDirections:WYPopoverArrowDirectionDown
                           animated:YES];
}

#pragma mark - TextView delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (IS_IOS7)
    {
        [textView fixSrollingToLastLineBugInIOS7withText:text];
    }
    
    if ([text rangeOfCharacterFromSet:[NSCharacterSet emojiCharacterSet]
                              options:0].location != NSNotFound)
    {
        self.lastCharacterEmoji = YES;
    }
    else
    {
        self.lastCharacterEmoji = NO;
    }
    
    if ([text rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]
                              options:0].location != NSNotFound)
    {
        self.resetFontToNormal = YES;
    }
    
    if ([text isEqualToString:@"@"] && range.location == textView.text.length)
    {
        [self.linkedInButton setEnabled:NO];
        [self.facebookButton setEnabled:NO];
        NSRange range = NSMakeRange((textView.text.length > 0) ? textView.text.length - 1 : 0, MIN(1, textView.text.length));
        NSString *previousCharacter = [textView.text substringWithRange:range];
        previousCharacter = [previousCharacter stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!previousCharacter.length)
        {
            [self performSegueWithIdentifier:kStoryboardSegueIDAddFriendsScreen sender:self];
            return NO;
        }
    }
    
    
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [super textViewDidChange:textView];
    
    //  Save cursor position - prevent jumping cursor after highlighting tags and usernames
    NSRange cursorPostion = textView.selectedRange;
    
    [self highlightTagsInText:[textView.attributedText mutableCopy]];
    
    if (textView.text.length && self.shouldResetFontToNormal && !self.isLastCharacterEmoji)
    {
        NSRange lastCharacterRange = NSMakeRange(textView.text.length-1, 1);
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:textView.attributedText];
        [attributedString setAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:kPostFontSize ],
                                           NSForegroundColorAttributeName:[UIColor blackColor]} range:lastCharacterRange];
        textView.attributedText = attributedString;
    }
    
    //  Reset cursor position after highlighting tags and usernames
    textView.selectedRange = cursorPostion;
}

- (void)highlightTagsInText:(NSMutableAttributedString *)text
{
    NSString *regexString = [NSString stringWithFormat:@"(?:(?<=\\s)|^)(#|@)(\\w*[0-9A-Za-z_]+\\w*)"];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    NSArray *matches = [regex matchesInString:text.string
                                      options:0
                                        range:NSMakeRange(0, [text length])];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange matchRange = [match range];
        [text setAttributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:kPostFontSize ],
                                           NSForegroundColorAttributeName:[UIColor blackColor] }
                      range:matchRange];
        self.inputTextview.attributedText = text;
    }
}

#pragma mark - Image picker controller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* imageFromPicker = [self getMediaWithInfo:info];
    
    if(imageFromPicker)
    {
        //[self setupImagePreView:imageFromPicker];
        self.preViewImageView.image = [imageFromPicker thumbnailImage:25.f
                                                    transparentBorder:0.f
                                                         cornerRadius:1.f
                                                 interpolationQuality:kCGInterpolationDefault];
    }

    [self updateUI];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Save media to camera roll

- (UIImage *)getMediaWithInfo:(NSDictionary *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage])
    {
        self.mediaAttachment = [self getImageAndSaveToCameraRollWithInfo:info];
        DLog(@"Photo size for status update is %lu bytes", (unsigned long)[(NSData *)self.mediaAttachment length]);
        UIImage *image = [UIImage imageWithData:self.mediaAttachment];
        
        return image;
    }
    return nil;
}

const CGFloat kPhotoWidthMax = 1024.0f;
- (NSData *)getImageAndSaveToCameraRollWithInfo:(NSDictionary *)info
{
    UIImage *tempImage = info[UIImagePickerControllerOriginalImage];
    
    if (self.isCameraMediaSource)
    {
        self.cameraMediaSource = NO;
        UIImageWriteToSavedPhotosAlbum(tempImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    
    CGSize size = tempImage.size;
    if (size.width > kPhotoWidthMax)
    {
        CGFloat proportion = kPhotoWidthMax/size.width;
        size = CGSizeMake( kPhotoWidthMax, size.height * proportion);
        tempImage = [tempImage resizedImage:size interpolationQuality:kCGInterpolationNone];
    }
    
    return UIImageJPEGRepresentation(tempImage, 0.8);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
#ifdef DEBUG
    if (!error)
    {
        DLog(@"Image saved to camera roll");
        
    }
    else
    {
        DLog(@"Error saving media: %@", [error localizedDescription]);
    }
#endif
}

#pragma mark - Update UI methods

- (void)updateUI
{
    [self updateCounter];
    [self updateCameraButton];
    [self updateLocationUI];
    [self updateSocialNetworkButtons];
}

- (void)updateCounter
{
    self.twitterCharactersLeft = kMaxCountOfCharactersInText - self.inputTextview.text.length - (self.mediaAttachment ? kTwitterImageLinkLength : 0);
}

- (void)updateCameraButton
{
    self.cameraButton.selected = (self.mediaAttachment ? YES : NO);
    self.preViewView.hidden = (self.mediaAttachment ? NO : YES);
}

- (void)updateLocationUI
{
    [self updateLocationLabel];
    [self updateLocationButton];
}

- (void)updateLocationLabel
{
    if (self.currentLocation.name)
    {
        if (isFoursquareButtonEnabled)
        {
            self.foursquareButton.enabled  = isFoursquareButtonEnabled;
            self.foursquareButton.selected = self.foursquareSelectedAccounts.count;
        }
    }
    else
    {
        if (self.foursquareButton.isEnabled)
        {
            isFoursquareButtonEnabled  = self.foursquareButton.isEnabled;
            
            self.foursquareButton.enabled = NO;
        }
    }
    
    self.locationNameLabel.hidden = (self.currentLocation.name ? NO : YES);
    self.locationNameLabel.text = self.currentLocation.name;
}

- (void)updateLocationButton
{
    self.getLocationButton.selected = (self.currentLocation ? YES : NO);
}

- (void)updateSocialNetworkButtons
{
    self.linkedInButton.selected = (self.linkedInSelectedAccounts.count ? YES : NO);
    self.facebookButton.selected = ((self.facebookSelectedAccounts.count || self.facebookSelectedGroups.count)? YES : NO);
    self.foursquareButton.selected = (self.foursquareSelectedAccounts.count ? YES : NO);
    self.twitterButton.selected = (self.twitterSelectedAccounts.count ? YES : NO);
}

#pragma mark - Action sheet
- (void)showPhotoActionSheet
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"lskImageSource", @"Select camera source type")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"lskCancel", @"Cancel button title")
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"lskTakePhoto", @"Take photo using camera"),
                                                                      NSLocalizedString(@"lskChooseFromLibrary", @"Selcet photo from library"),nil];
    [actionSheet showInView:self.view];
    self.photoActionSheet = actionSheet;
}

static const NSInteger kActionSheetPhotoCameraButton = 0;
static const NSInteger kActionSheetLibraryCameraButton = 1;

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    switch (buttonIndex) {
        case kActionSheetPhotoCameraButton:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.cameraMediaSource = YES;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                [self showAlertView:NSLocalizedString(@"lskCameraNotAvailable", @"Device has not camera")];
            }
        }
            break;
        case kActionSheetLibraryCameraButton:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
            {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                self.cameraMediaSource = NO;
                [self presentViewController:imagePicker animated:YES completion:nil];
            }
            else
            {
                [self showAlertView:NSLocalizedString(@"lskLibraryUnavailable", @"Library is not available")];
            }
        }
            break;
    }
}

- (void)showAlertView:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"lskOK", @"OK button for alert")
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIAlertView
#pragma mark 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kStatusUpdateErrorAlertTag)
    {
        self.statusesTaskCounter--;
    }
}

#pragma mark - Setters and getters

-(NSInteger)statusesTaskCounter
{
    @synchronized(self)
    {
        return _statusesTaskCounter;
    }
}

-(void)setStatusesTaskCounter:(NSInteger)statusesTaskCounter
{
    @synchronized(self)
    {
        if(_statusesTaskCounter == 0 && statusesTaskCounter == 1)
        {
            [self showProcessHUDWithText:NSLocalizedString(@"lskProcessing", @"")];
        }
        else if(_statusesTaskCounter == 1 && statusesTaskCounter == 0)
        {
            [self removeProcessHUDOnSuccessLoginHUDWithText:NSLocalizedString(@"lskComplete", @"")];
           // [self dismiss];
        }
        _statusesTaskCounter = statusesTaskCounter;
    }
}

#pragma mark - HUD methods

- (void)removeProcessHUDOnSuccessLoginHUDWithText:(NSString *)text
{
    if (self.progressHUD)
    {
        [self.progressHUD completeAndDismissWithTitle:text];
        self.progressHUD = nil;
    }
}

- (void)removeProcessHUDOnFailLoginHUDWithText:(NSString *)text
{
    if (self.progressHUD)
    {
        [self.progressHUD failAndDismissWithTitle:text];
        self.progressHUD = nil;
    }
}

#pragma mark - WDDSocialNetworkAccounts VC delegate
- (void)didSelectSocialNetworkAccounts:(NSArray *)selectedAccounts andGroups:(NSArray *)groups forType:(SocialNetworkType)type
{
    [self setSelectedAccounts:selectedAccounts  andGroups:groups forType:type];
    [self updateUI];
}

- (void)setSelectedAccounts:(NSArray *)accounts andGroups:(NSArray *)groups forType:(SocialNetworkType)type
{
    if (type == kSocialNetworkFacebook)
    {
        self.facebookSelectedAccounts = accounts;
        self.facebookSelectedGroups = groups;
    }
    else if (type == kSocialNetworkLinkedIN)
    {
        self.linkedInSelectedAccounts = accounts;
    }
    else if (type == kSocialNetworkFoursquare)
    {
        self.foursquareSelectedAccounts  = accounts;
    }
    else if (type == kSocialNetworkTwitter)
    {
        self.twitterSelectedAccounts  = accounts;
    }
}
- (void)popoverControllerDidDismissPopover:(WYPopoverController *)popoverController
{
    self.popoverVC = nil;
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kStoryboardSegueIDAddFriendsScreen])
    {
        UINavigationController *navVC = segue.destinationViewController;
        WDDAddFriendViewController *addFriendVC = [navVC.viewControllers firstObject];
        
        //  User [self formAllAvailableSelectedAccountsList] for showing friends just for selected SN.
        //  If nil - shows all friends from all networks
        addFriendVC.socialNetworks = nil;//[self formAllAvailableSelectedAccountsList];
        addFriendVC.delegate = self;
    }
}

#pragma mark - WDDAddFriendDelegate
- (void)didAddFriendWithName:(NSString *)friendName
{
    if (friendName.length)
    {
        
        NSString *friendNameString = [NSString stringWithFormat:@" @%@ ", [friendName lastPathComponent]];

        NSMutableAttributedString *friendNameAtrString = [[NSMutableAttributedString alloc] initWithString:friendNameString
                                                                                                attributes:@{ NSFontAttributeName:[UIFont boldSystemFontOfSize:kPostFontSize ],
                                                                                                       NSForegroundColorAttributeName:[UIColor blackColor] }];
        [friendNameAtrString setAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:kPostFontSize ],
                                              NSForegroundColorAttributeName:[UIColor blackColor] }
                                     range:NSMakeRange(friendNameString.length-1 , 1)];
        
        NSMutableAttributedString *compliteAtrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.inputTextview.attributedText];
        [compliteAtrString appendAttributedString:friendNameAtrString];
        self.inputTextview.attributedText = compliteAtrString;
        [self updateUI];
    }
}

#pragma mark - WDDLocationsListDelegate
#pragma mark 

- (void)didSelectLocataion:(WDDLocation *)location
{
    self.currentLocation = location;
    [self updateUI];
    [self.popoverVC dismissPopoverAnimated:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [FoursquareRequest requestNearestPlacesInBackgroundForLatitude:location.latidude
                                                         longitude:location.longitude
                                                          accuracy:location.accuracy
                                                            intent:@"browse"
                                                      searchString:location.name
                                                    withCompletion:^(NSArray *results, NSError *error)
     {
         if (weakSelf.currentLocation == location && !error)
         {
             NSInteger index = [results indexOfObjectPassingTest:^BOOL(WDDLocation *locationFourSquare, NSUInteger idx, BOOL *stop)
                                {
                                    return ([location.name caseInsensitiveCompare:locationFourSquare.name] == NSOrderedSame);
                                }];
             
             if (index != NSNotFound)
             {
                 weakSelf.currentLocation.foursquareID = [results[index] foursquareID];
             }
             else
             {
                 results = [results sortedArrayUsingComparator:^NSComparisonResult(WDDLocation *location1, WDDLocation *location2)
                            {
                                double sqr1 = (location1.latidude - location.latidude) * (location1.latidude - location.latidude) + (location1.longitude - location.longitude) * (location1.longitude - location.longitude);
                                double sqr2 = (location2.latidude - location.latidude) * (location2.latidude - location.latidude) + (location2.longitude - location.longitude) * (location2.longitude - location.longitude);
                                if (sqr1 < sqr2)
                                {
                                    return NSOrderedAscending;
                                }
                                else if (sqr1 > sqr2)
                                {
                                    return NSOrderedDescending;
                                }
                                else return NSOrderedSame;
                            }];
                 weakSelf.currentLocation.foursquareID = [results.firstObject foursquareID];
             }
         }
     }];
}

#pragma mark - Image View User Choose

-(void)setupImagePreView:(UIImage *)image
{
    const int kPicWidth = 40;
    const int kPicHeight = 40;
    const int kDistBetwTextAndImage = 5;
    
    int updatedTextHeight = self.inputTextview.frame.size.height - kPicHeight - kDistBetwTextAndImage;
    
    DLog(@"frame = %f", self.inputTextview.frame.size.height);
    [self.mainView layoutSubviews];
    
    self.textViewConstraint.constant = self.textViewConstraint.constant + kPicHeight + kDistBetwTextAndImage;
    
    UIImageView* preViewImageView = [[UIImageView alloc] init];
    
    preViewImageView.image = image;
    
    preViewImageView.frame = CGRectMake(self.inputTextview.frame.origin.x, updatedTextHeight + kDistBetwTextAndImage + kDistBetwTextAndImage, kPicWidth, kPicHeight);
    
    [self.mainView addSubview:preViewImageView];
    
    //self.textViewHeightConstraint.constant = textView.contentSize.height
}


@end
