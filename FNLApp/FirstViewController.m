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
#define FLFUsername @"thefunlyfe_"
#define FLFConsumerKey @"Wdk3Vcbhbrcu7AM6EeMPTdjm5"
#define FLFConsumerSecret @"iT6eLSTD16RidjYpJxIBbzWwnACbjc9qoLVd8iL0C7S66DBTFY"

@interface FirstViewController ()

typedef void (^FavoriteTweetBlock)(FLFTwitterTableViewCell *cell, NSString *idString);

@property (nonatomic) NSMutableArray *twitterFeedMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *currentIDString;
@property (nonatomic) FLFTwitterDataSource *dataSource;
@property (nonatomic) STTwitterAPI *twitter;
@property (nonatomic, copy) FavoriteTweetBlock favoriteBlock;

@end

@implementation FirstViewController

-(void)setupTweetButtonBlocks
{
    __weak FirstViewController *weakSelf = self;
    
    void (^favoriteTweetBlock)(FLFTwitterTableViewCell*, NSString*) = ^(FLFTwitterTableViewCell *cell, NSString *idString) {
        if (![cell.tintColor isEqual:[UIColor redColor]])
        {
            [weakSelf.twitter postFavoriteCreateWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status) {
                cell.tintColor = [UIColor redColor];
            } errorBlock:^(NSError *error) {
                NSLog(@"error favoriting:%@", [error localizedDescription]);
            }];
        }
        else
        {
            [weakSelf.twitter postFavoriteDestroyWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status) {
                cell.tintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
            } errorBlock:^(NSError *error) {
                NSLog(@"error unfavoriting:%@", [error localizedDescription]);
            }];
        }
    };
    
    void (^retweetBlock)(FLFTwitterTableViewCell*, NSString*) = ^(FLFTwitterTableViewCell *cell, NSString *idString) {

        [weakSelf.twitter postStatusRetweetWithID:idString successBlock:^(NSDictionary *status) {
                cell.favoriteButton.enabled = NO;
                cell.tintColor = [UIColor redColor];
            } errorBlock:^(NSError *error) {
                NSLog(@"error favoriting:%@", [error localizedDescription]);
        }];
    };
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0)
    {
        
    }
}

- (IBAction)tweetButtonTapped:(UIButton *)sender
{
    FLFTwitterTableViewCell *cell = (FLFTwitterTableViewCell *)sender.superview.superview;
    NSInteger row = [self.tableView indexPathForCell:cell].row;
    NSDictionary *tweetDictionary = [self.twitterFeedMutableArray objectAtIndex:row];
    NSString *idString = tweetDictionary[@"id_str"];
    NSLog(@"idstring is %@",idString);
    
    if ([sender.titleLabel.text isEqualToString:@"Favorite"])
    {
        
    }
    
    if ([sender.titleLabel.text isEqualToString:@"Retweet"])
    {
        
    }
    
    if ([sender.titleLabel.text isEqualToString:@"Reply"])
    {
        UIActionSheet *share = [[UIActionSheet alloc] initWithTitle:@"Reply" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Tweet", nil];
        [share showInView:self.view];
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
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:FLFConsumerKey consumerSecret:FLFConsumerSecret];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username)
     {
         [twitter getUserTimelineWithScreenName:FLFUsername sinceID:self.currentIDString maxID:nil count:20 successBlock:^(NSArray *statuses) {
             [self.twitterFeedMutableArray addObjectsFromArray:statuses];
             [self.tableView reloadData];
             self.currentIDString = [self.twitterFeedMutableArray lastObject][@"id_str"];
         } errorBlock:^(NSError *error) {
             NSLog(@"%@", error.debugDescription);
         }];
         
     } errorBlock:^(NSError *error)
     {
         
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
