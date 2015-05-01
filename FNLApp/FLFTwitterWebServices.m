//
//  FLFTwitterWebServices.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFTwitterWebServices.h"
#import <Accounts/Accounts.h>

#define FLFUsername @"thefunlyfe_"
#define FLFConsumerKey @"Wdk3Vcbhbrcu7AM6EeMPTdjm5"
#define FLFConsumerSecret @"iT6eLSTD16RidjYpJxIBbzWwnACbjc9qoLVd8iL0C7S66DBTFY"

@interface FLFTwitterWebServices ()
@property (nonatomic) UITableView *tableView;
@property (nonatomic) NSString *currentIDString;
@end

@implementation FLFTwitterWebServices

-(id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.twitterFeedMutableArray = [[NSMutableArray alloc] init];
        self.tableView = tableView;
    }
    return self;
}

-(void)fetchMoreTweets
{
    NSLog(@"fetching more");
    [self.twitter getUserTimelineWithScreenName:FLFUsername sinceID:self.currentIDString maxID:nil count:20 successBlock:^(NSArray *statuses) {
        
        for (NSDictionary *dictionary in statuses)
        {
            [self.twitterFeedMutableArray addObject:[dictionary mutableCopy]];
        }
        
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
                          for (NSDictionary *dictionary in statuses)
                          {
                              [self.twitterFeedMutableArray addObject:[dictionary mutableCopy]];
                          }
                          [self.tableView reloadData];
                          self.currentIDString = [self.twitterFeedMutableArray lastObject][@"id_str"];
                          [[NSNotificationCenter defaultCenter] postNotificationName:@"FNLEndTwitterRefreshNotification" object:nil];
                          
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


@end
