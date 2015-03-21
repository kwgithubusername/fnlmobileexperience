//
//  FirstViewController.m
//  FNLApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FirstViewController.h"
#import "STTwitter.h"
#import "FLFTwitterTableViewCell.h"
#import "FLFTwitterDataSource.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MBProgressHUD.h>

#define FLFUsername @"thefunlyfe_"
#define FLFConsumerKey @"Wdk3Vcbhbrcu7AM6EeMPTdjm5"
#define FLFConsumerSecret @"iT6eLSTD16RidjYpJxIBbzWwnACbjc9qoLVd8iL0C7S66DBTFY"

@interface FirstViewController ()

@property (nonatomic) NSMutableArray *twitterFeedMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *currentIDString;
@property (nonatomic) FLFTwitterDataSource *dataSource;
@property (nonatomic) STTwitterAPI *twitter;

@end

@implementation FirstViewController



-(void)showMBProgressHUDSuccessWithString:(NSString *)string
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = string;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        sleep(2);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (IBAction)tweetButtonTapped:(UIButton *)sender
{
    FLFTwitterTableViewCell *cell = (FLFTwitterTableViewCell *)sender.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    NSDictionary *tweetDictionary = [self.twitterFeedMutableArray objectAtIndex:row];
    NSString *idString = tweetDictionary[@"id_str"];
    NSLog(@"idstring is %@",idString);
    
    UIImage *favoriteOnImage = [UIImage imageNamed:@"favorite_on.png"];
    UIImage *favoriteOffImage = [UIImage imageNamed:@"favorite.png"];
    UIImage *retweetOnImage = [UIImage imageNamed:@"retweet_on.png"];
    UIImage *retweetImage = [UIImage imageNamed:@"retweet.png"];
    
    if (sender.tag == 4) // if not favorited
    {
        [self.twitter postFavoriteCreateWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status)
        {
            sender.imageView.image = favoriteOnImage;
            sender.tag = 5;
            [self showMBProgressHUDSuccessWithString:@"Tweet favorited"];
            
        } errorBlock:^(NSError *error)
        {
                NSLog(@"error favoriting:%@", [error localizedDescription]);
        }];
    }
    else if (sender.tag == 5) // if favorited
    {
        [self.twitter postFavoriteDestroyWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status)
        {
            sender.imageView.image = favoriteOffImage;
            sender.tag = 4;
            [self showMBProgressHUDSuccessWithString:@"Tweet unfavorited"];
        } errorBlock:^(NSError *error)
        {
                NSLog(@"error unfavoriting:%@", [error localizedDescription]);
        }];
    }
    
    if (sender.tag == 2) // if not retweeted
    {
        [self.twitter postStatusRetweetWithID:idString successBlock:^(NSDictionary *status)
        {
            sender.imageView.image = retweetOnImage;
            sender.tag = 3;
            [self showMBProgressHUDSuccessWithString:@"Tweet retweeted"];
        } errorBlock:^(NSError *error)
        {
            NSLog(@"error retweeting:%@", [error localizedDescription]);
        }];
    }
    else if (sender.tag == 3) // if retweeted
    {
        [self.twitter getStatusesShowID:idString trimUser:@1 includeMyRetweet:@1 includeEntities:@1 successBlock:^(NSDictionary *status)
        {
            NSString *idStringOfRetweet = status[@"current_user_retweet"][@"id_str"];
            [self.twitter postStatusesDestroy:idStringOfRetweet trimUser:@1 successBlock:^(NSDictionary *status)
            {
                sender.imageView.image = retweetImage;
                sender.tag = 2;
                [self showMBProgressHUDSuccessWithString:@"Retweet removed"];
            } errorBlock:^(NSError *error)
            {
                NSLog(@"error removing retweet:%@", [error localizedDescription]);
            }];
            
        } errorBlock:^(NSError *error) {
            NSLog(@"error removing retweet:%@", [error localizedDescription]);
        }];
    }

    if (sender.tag == 1)
    {
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
            [tweetSheet setInitialText:[[NSString alloc] initWithFormat:@"@%@",FLFUsername]];
            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result){[self showMBProgressHUDSuccessWithString:@"Reply tweeted"];};
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure you have at least one Twitter account set up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        };
    }
}

-(void)setupTwitterTimeline
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted == YES)
        {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            if ([arrayOfAccounts count] > 0)
            {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                NSURL *requestAPI = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/user_timeline.json"];
                NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                [parameters setObject:FLFUsername forKey:@"screen_name"];
                [parameters setObject:@"20" forKey:@"count"];
                
                SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:requestAPI parameters:parameters];
                posts.account = twitterAccount;
                [posts performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                {
                    NSArray *tweetArray = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
                    if ([tweetArray count] > 0)
                    {
                        [self.twitterFeedMutableArray addObjectsFromArray:tweetArray];
                        dispatch_async(dispatch_get_main_queue(),
                        ^{
                            [self.tableView reloadData];
                        });
                    }
                }];
                
            }
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
     ];
}

-(void)setupDataSource
{
    __weak FirstViewController *weakSelf = self;
    
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView){
        
        FLFTwitterTableViewCell *twitterCell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell"];
    
        NSDictionary *twitterFeedDictionary = weakSelf.twitterFeedMutableArray[indexPath.row];
        
        twitterCell.tweetLabel.text = twitterFeedDictionary[@"text"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //Wed Dec 01 17:08:03 +0000 2010
        [dateFormatter setDateFormat:@"eee, MMM dd HH:mm:ss ZZZZ yyyy"];
        NSDate *date = [dateFormatter dateFromString:twitterFeedDictionary[@"created_at"]];
        [dateFormatter setDateFormat:@"eee, MMM dd HH:mm:ss yyyy"];
        NSString *dateString = [dateFormatter stringFromDate:date];
        twitterCell.dateLabel.text = dateString;
        
        UIImage *favoriteStatusImage = [twitterFeedDictionary[@"favorited"] boolValue] ? [UIImage imageNamed:@"favorite_on.png"] : [UIImage imageNamed:@"favorite.png"];
        twitterCell.favoriteButton.tag = [twitterFeedDictionary[@"favorited"] boolValue] ? 5 : 4;
        twitterCell.favoriteButton.imageView.image = favoriteStatusImage;
        
        UIImage *retweetStatusImage = [twitterFeedDictionary[@"retweeted"] boolValue] ? [UIImage imageNamed:@"retweet_on.png"] : [UIImage imageNamed:@"retweet.png"];
        twitterCell.retweetButton.tag = [twitterFeedDictionary[@"retweeted"] boolValue] ? 3 : 2;
        twitterCell.retweetButton.imageView.image = retweetStatusImage;
        
        return twitterCell;
    };
    
    NSInteger(^numberOfRowsInSectionBlock)() = ^NSInteger(){
        return [weakSelf.twitterFeedMutableArray count];
    };
    
    void (^willDisplayCellBlock)(NSIndexPath *indexPath) = ^(NSIndexPath *indexPath){
        if (indexPath.row == [weakSelf.twitterFeedMutableArray count]-1)
        {
            [weakSelf fetchMoreTweets];
        }
    };
    
    self.dataSource = [[FLFTwitterDataSource alloc] initWithCellForRowAtIndexPathBlock:cellForRowAtIndexPathBlock NumberOfRowsInSectionBlock:numberOfRowsInSectionBlock WillDisplayCellBlock:willDisplayCellBlock];
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSLog(@"The");
//    sleep(1);
//    NSLog(@"world");
//    sleep(1);
//    NSLog(@"is");
//    sleep(1);
//    NSLog(@"yurns");
//    sleep(1);
//    sleep(3);
    [self loadTwitter];
    [self setupDataSource];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)fetchMoreTweets
{
    NSLog(@"fetching more");
    [self.twitter getUserTimelineWithScreenName:FLFUsername sinceID:self.currentIDString maxID:nil count:20 successBlock:^(NSArray *statuses) {
             [self.twitterFeedMutableArray addObjectsFromArray:statuses];
             [self.tableView reloadData];
             self.currentIDString = [self.twitterFeedMutableArray lastObject][@"id_str"];
         } errorBlock:^(NSError *error) {
             NSLog(@"%@", error.debugDescription);
         }];
}

- (void)loadTwitter
{
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted == YES)
        {
            NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
            if ([arrayOfAccounts count] > 0)
            {
                ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                self.twitter = [STTwitterAPI twitterAPIOSWithAccount:twitterAccount];
                //    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:FLFConsumerKey consumerSecret:FLFConsumerSecret];
                
                [self.twitter verifyCredentialsWithSuccessBlock:^(NSString *username)
                 {
                     [self.twitter getUserTimelineWithScreenName:FLFUsername successBlock:^(NSArray *statuses)
                      {
                          
                          self.twitterFeedMutableArray = [[NSMutableArray alloc] initWithArray:statuses];
                          NSLog(@"%@", self.twitterFeedMutableArray);
                          [self.tableView reloadData];
                          self.currentIDString = [self.twitterFeedMutableArray lastObject][@"id_str"];
                          
                      } errorBlock:^(NSError *error)
                      {
                          
                          NSLog(@"%@", error.debugDescription);
                          
                      }];
                     
                 } errorBlock:^(NSError *error)
                 {
                     
                     NSLog(@"%@", error.debugDescription);
                     
                 }];
            }
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
