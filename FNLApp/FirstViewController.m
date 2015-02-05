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

#define FLFUsername @"thefunlyfe_"
#define FLFConsumerKey @"Wdk3Vcbhbrcu7AM6EeMPTdjm5"
#define FLFConsumerSecret @"iT6eLSTD16RidjYpJxIBbzWwnACbjc9qoLVd8iL0C7S66DBTFY"

@interface FirstViewController ()
@property (nonatomic) NSMutableArray *twitterFeedMutableArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FirstViewController

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLFTwitterTableViewCell *twitterCell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell"];
    
    //    if (!twitterCell)
    //    {
    //        twitterCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"twitterCell"];
    //    }
    //
    NSDictionary *twitterFeedDictionary = self.twitterFeedMutableArray[indexPath.row];
    
    twitterCell.tweetLabel.text = twitterFeedDictionary[@"text"];
    twitterCell.dateLabel.text = twitterFeedDictionary[@"created_at"];
    return twitterCell;
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.twitterFeedMutableArray count];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadTwitter];
    
    // Do any additional setup after loading the view, typically from a nib.
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
