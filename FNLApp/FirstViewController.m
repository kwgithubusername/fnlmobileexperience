//
//  FirstViewController.m
//  FNLApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FirstViewController.h"
#import "FLFTwitterTableViewCell.h"
#import "FLFTableViewDataSource.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <MBProgressHUD.h>
#import "FLFTwitterWebServices.h"
#import "FLFInstagramTableViewCell.h"
#import "FLFInstagramWebServices.h"
#import "FLFInstagramLoginViewController.h"

#define FLFUsername @"thefunlyfe_"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *twitterTableView;
@property (weak, nonatomic) IBOutlet UITableView *instagramTableView;
@property (nonatomic) FLFTableViewDataSource *twitterDataSource;
@property (nonatomic) FLFTableViewDataSource *instagramDataSource;
@property (nonatomic) FLFTwitterWebServices *twitterWebServices;
@property (nonatomic) FLFInstagramWebServices *instagramWebServices;

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
- (IBAction)likeButtonTapped:(UIButton *)sender
{
    FLFInstagramTableViewCell *cell = (FLFInstagramTableViewCell *)sender.superview.superview;
    NSInteger row = [self.instagramTableView indexPathForCell:cell].row;
    InstagramMedia *media = [self.instagramWebServices.mediaMutableArray objectAtIndex:row];
    
    if (sender.titleLabel.textColor != [UIColor redColor])
    {
        [[InstagramEngine sharedEngine] likeMedia:media withSuccess:^{
            sender.titleLabel.textColor = [UIColor redColor];
            [self showMBProgressHUDSuccessWithString:@"Media liked"];
        } failure:^(NSError *error) {
            NSLog(@"error liking:%@", [error localizedDescription]);
        }];
    }
    else if (sender.titleLabel.textColor == [UIColor redColor])
    {
        [[InstagramEngine sharedEngine] unlikeMedia:media withSuccess:^{
            sender.titleLabel.textColor = [UIColor redColor];
            [self showMBProgressHUDSuccessWithString:@"Media unliked"];
        } failure:^(NSError *error) {
            NSLog(@"error liking:%@", [error localizedDescription]);
        }];
    }
    
}

- (IBAction)tweetButtonTapped:(UIButton *)sender
{
    FLFTwitterTableViewCell *cell = (FLFTwitterTableViewCell *)sender.superview.superview;
    NSInteger row = [self.twitterTableView indexPathForCell:cell].row;
    NSDictionary *tweetDictionary = [self.twitterWebServices.twitterFeedMutableArray objectAtIndex:row];
    NSString *idString = tweetDictionary[@"id_str"];
    NSLog(@"idstring is %@",idString);
    
    UIImage *favoriteOnImage = [UIImage imageNamed:@"favorite_on.png"];
    UIImage *favoriteOffImage = [UIImage imageNamed:@"favorite.png"];
    UIImage *retweetOnImage = [UIImage imageNamed:@"retweet_on.png"];
    UIImage *retweetImage = [UIImage imageNamed:@"retweet.png"];
    
    if (sender.tag == 4) // if not favorited
    {
        [self.twitterWebServices.twitter postFavoriteCreateWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status)
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
        [self.twitterWebServices.twitter postFavoriteDestroyWithStatusID:idString includeEntities:@1 successBlock:^(NSDictionary *status)
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
        [self.twitterWebServices.twitter postStatusRetweetWithID:idString successBlock:^(NSDictionary *status)
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
        [self.twitterWebServices.twitter getStatusesShowID:idString trimUser:@1 includeMyRetweet:@1 includeEntities:@1 successBlock:^(NSDictionary *status)
        {
            NSString *idStringOfRetweet = status[@"current_user_retweet"][@"id_str"];
            [self.twitterWebServices.twitter postStatusesDestroy:idStringOfRetweet trimUser:@1 successBlock:^(NSDictionary *status)
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
            tweetSheet.completionHandler = ^(SLComposeViewControllerResult result)
            {
                switch(result) {
                    case SLComposeViewControllerResultCancelled:
                        break;
                        //  This means the user hit 'Send'
                    case SLComposeViewControllerResultDone:
                        [self showMBProgressHUDSuccessWithString:@"Reply tweeted"];
                        break;
                }
            };
            [self presentViewController:tweetSheet animated:YES completion:nil];
        }
        else
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please make sure you have at least one Twitter account set up." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        };
    }
}

-(void)setupTwitterDataSource
{
    __weak FirstViewController *weakSelf = self;
    
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView){
        
        FLFTwitterTableViewCell *twitterCell = [[FLFTwitterTableViewCell alloc] init];
        
        twitterCell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell"];
    
        NSDictionary *twitterFeedDictionary = weakSelf.twitterWebServices.twitterFeedMutableArray[indexPath.row];
        
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
        dispatch_async(dispatch_get_main_queue(), ^{
            twitterCell.favoriteButton.imageView.image = favoriteStatusImage;
        });
        
        
        UIImage *retweetStatusImage = [twitterFeedDictionary[@"retweeted"] boolValue] ? [UIImage imageNamed:@"retweet_on.png"] : [UIImage imageNamed:@"retweet.png"];
        twitterCell.retweetButton.tag = [twitterFeedDictionary[@"retweeted"] boolValue] ? 3 : 2;
        dispatch_async(dispatch_get_main_queue(), ^{
            twitterCell.retweetButton.imageView.image = retweetStatusImage;
        });
        
        return twitterCell;
    };
    
    NSInteger(^numberOfRowsInSectionBlock)() = ^NSInteger(){
        return [weakSelf.twitterWebServices.twitterFeedMutableArray count];
    };
    
    void (^willDisplayCellBlock)(NSIndexPath *indexPath) = ^(NSIndexPath *indexPath){
        if (indexPath.row == [weakSelf.twitterWebServices.twitterFeedMutableArray count]-1)
        {
            [weakSelf.twitterWebServices fetchMoreTweets];
        }
    };
    
    self.twitterDataSource = [[FLFTableViewDataSource alloc] initWithCellForRowAtIndexPathBlock:cellForRowAtIndexPathBlock NumberOfRowsInSectionBlock:numberOfRowsInSectionBlock WillDisplayCellBlock:willDisplayCellBlock];
    self.twitterTableView.delegate = self.twitterDataSource;
    self.twitterTableView.dataSource = self.twitterDataSource;
}

-(void)setupInstagramDataSource
{
    __weak FirstViewController *weakSelf = self;
    
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView){
        
        FLFInstagramTableViewCell *instagramCell = [[FLFInstagramTableViewCell alloc] init];
        
        instagramCell = [tableView dequeueReusableCellWithIdentifier:@"instagramCell"];
        
        InstagramMedia *instagramObject = weakSelf.instagramWebServices.mediaMutableArray[indexPath.row];
        
        NSURL *imageURL = instagramObject.standardResolutionImageURL;
        
        [weakSelf.instagramWebServices loadImageIntoCell:instagramCell withURL:imageURL];
        
        instagramCell.captionLabel.text = instagramObject.caption.text;
        
        [[InstagramEngine sharedEngine] getMedia:instagramObject.Id withSuccess:^(InstagramMedia *media) {
            NSLog(@"media is %@", media);
            NSSet *likesSet = [[NSSet alloc] initWithArray:media.likes];
            UIColor *likedOrNotColor =  [likesSet containsObject:[weakSelf.instagramWebServices loadInstagramUserInfo].Id]? [UIColor redColor] : [UIColor grayColor];
            dispatch_async(dispatch_get_main_queue(), ^{
                instagramCell.likeButton.titleLabel.textColor = likedOrNotColor;
            });
        } failure:^(NSError *error) {
            NSLog(@"Error getting media:%@", [error localizedDescription]);
        }];
        
        return instagramCell;
    };
    
    NSInteger(^numberOfRowsInSectionBlock)() = ^NSInteger(){
        return [weakSelf.instagramWebServices.mediaMutableArray count];
    };
    
    void (^willDisplayCellBlock)(NSIndexPath *indexPath) = ^(NSIndexPath *indexPath){
        if (indexPath.row == [weakSelf.instagramWebServices.mediaMutableArray count]-1)
        {
            [weakSelf.instagramWebServices fetchMoreMedia];
        }
    };
    
    self.instagramDataSource = [[FLFTableViewDataSource alloc] initWithCellForRowAtIndexPathBlock:cellForRowAtIndexPathBlock NumberOfRowsInSectionBlock:numberOfRowsInSectionBlock WillDisplayCellBlock:willDisplayCellBlock];
    self.instagramTableView.delegate = self.instagramDataSource;
    self.instagramTableView.dataSource = self.instagramDataSource;
}

- (void)setupInstagram
{
    self.instagramWebServices = [[FLFInstagramWebServices alloc] initWithTableView:self.instagramTableView];
    
    if (![self.instagramWebServices hasAccessToken])
    {
        FLFInstagramLoginViewController *loginViewController = [[FLFInstagramLoginViewController alloc] initWithWebServices:self.instagramWebServices];
        [self presentViewController:loginViewController animated:YES completion:nil];
    }

    [self setupInstagramDataSource];
}

-(void)setupTwitter
{
    self.twitterWebServices = [[FLFTwitterWebServices alloc] initWithTableView:self.twitterTableView];
    [self.twitterWebServices loadTwitter];
    [self setupTwitterDataSource];
    self.twitterTableView.estimatedRowHeight = 44;
    self.twitterTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupTwitter];
    [self setupInstagram];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
