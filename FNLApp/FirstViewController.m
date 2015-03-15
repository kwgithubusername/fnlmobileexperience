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

#define FLFUsername @"thefunlyfe_"
#define FLFConsumerKey @"Wdk3Vcbhbrcu7AM6EeMPTdjm5"
#define FLFConsumerSecret @"iT6eLSTD16RidjYpJxIBbzWwnACbjc9qoLVd8iL0C7S66DBTFY"

@interface FirstViewController ()
@property (nonatomic) NSMutableArray *twitterFeedMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSString *currentIDString;
@property (nonatomic) FLFTwitterDataSource *dataSource;

@end

@implementation FirstViewController

-(void)setupDataSource
{
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView){
        
        FLFTwitterTableViewCell *twitterCell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell"];
    
        NSDictionary *twitterFeedDictionary = self.twitterFeedMutableArray[indexPath.row];
        
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
        return [self.twitterFeedMutableArray count];
    };
    
    void (^willDisplayCellBlock)(NSIndexPath *indexPath) = ^(NSIndexPath *indexPath){
        if (indexPath.row == [self.twitterFeedMutableArray count]-1)
        {
            [self fetchMoreTweets];
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
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:FLFConsumerKey consumerSecret:FLFConsumerSecret];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *username)
     {
         [twitter getUserTimelineWithScreenName:FLFUsername successBlock:^(NSArray *statuses)
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
