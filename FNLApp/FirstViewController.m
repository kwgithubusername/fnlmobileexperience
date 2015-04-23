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
#import "FLFInstagramCommentViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FLFDateFormatter.h"

#define FLFUsername @"thefunlyfe_"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UITableView *twitterTableView;
@property (weak, nonatomic) IBOutlet UITableView *instagramTableView;
@property (nonatomic) FLFTableViewDataSource *twitterDataSource;
@property (nonatomic) FLFTableViewDataSource *instagramDataSource;
@property (nonatomic) FLFTwitterWebServices *twitterWebServices;
@property (nonatomic) FLFInstagramWebServices *instagramWebServices;
@property (nonatomic) MPMoviePlayerController *videoPlayer;
@property (nonatomic) int tableViewRowOfCurrentVideoPlayingInt;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBarTitleItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic) FLFDateFormatter *dateFormatter;
@property (nonatomic) UIRefreshControl *instagramRefresh;
@property (nonatomic) UIRefreshControl *twitterRefresh;

@end

@implementation FirstViewController

-(FLFDateFormatter *)dateFormatter
{
    if (!_dateFormatter) _dateFormatter = [[FLFDateFormatter alloc] init];
    return _dateFormatter;
}

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
- (IBAction)commentButtonTapped:(UIButton *)sender
{
    FLFInstagramTableViewCell *cell = (FLFInstagramTableViewCell *)sender.superview.superview;
    NSInteger row = [self.instagramTableView indexPathForCell:cell].row;
    InstagramMedia *media = [self.instagramWebServices.mediaMutableArray objectAtIndex:row];
    UIImage *image = cell.photoView.image;
    FLFInstagramCommentViewController *commentViewController = [[FLFInstagramCommentViewController alloc] initWithWebServices:self.instagramWebServices andImage:(UIImage *)image withInstagramMedia:media];
    commentViewController.mainViewController = self;
    UIView *contentView = [[UIView alloc] initWithFrame:self.instagramTableView.frame];
    commentViewController.view.frame = contentView.frame;
    
    //NSInteger row = [self.instagramTableView indexPathForCell:cell].row;
    //InstagramMedia *media = [self.instagramWebServices.mediaMutableArray objectAtIndex:row];
    
    [self.view addSubview:commentViewController.view];
    [self addChildViewController:commentViewController];
    [commentViewController didMoveToParentViewController:self];
    
}
- (IBAction)likeButtonTapped:(UIButton *)sender
{
    FLFInstagramTableViewCell *cell = (FLFInstagramTableViewCell *)sender.superview.superview;
    NSInteger row = [self.instagramTableView indexPathForCell:cell].row;
    InstagramMedia *media = [self.instagramWebServices.mediaMutableArray objectAtIndex:row];
    
    if (sender.tag == 6)
    {
        [[InstagramEngine sharedEngine] likeMedia:media withSuccess:^{
            sender.titleLabel.textColor = [UIColor redColor];
            sender.tag = 7;
            [self showMBProgressHUDSuccessWithString:@"Media liked"];
        } failure:^(NSError *error) {
            NSLog(@"error liking:%@", [error localizedDescription]);
        }];
    }
    else if (sender.tag == 7)
    {
        [[InstagramEngine sharedEngine] unlikeMedia:media withSuccess:^{
            sender.titleLabel.textColor = [UIColor grayColor];
            sender.tag = 6;
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

#pragma mark - Data source -

-(void)setupTwitterDataSource
{
    __weak FirstViewController *weakSelf = self;
    
    UITableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^UITableViewCell *(NSIndexPath *indexPath, UITableView *tableView){
        
        FLFTwitterTableViewCell *twitterCell = [tableView dequeueReusableCellWithIdentifier:@"twitterCell"];
    
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
        
        FLFInstagramTableViewCell *instagramCell = [tableView dequeueReusableCellWithIdentifier:@"instagramCell"];
        
        InstagramMedia *instagramObject = weakSelf.instagramWebServices.mediaMutableArray[indexPath.row];
        
        NSURL *imageURL = instagramObject.standardResolutionImageURL;
        
        [weakSelf.instagramWebServices loadImageIntoCell:instagramCell withURL:imageURL];
        
        instagramCell.captionLabel.text = instagramObject.caption.text;
        
        instagramCell.timeLabel.text = [weakSelf.dateFormatter formatDate:instagramObject.createdDate];
        
        UIColor *likedOrNotColor =  instagramObject.userHasLiked ? [UIColor redColor] : [UIColor grayColor];
        
        dispatch_async(dispatch_get_main_queue(), ^{
                instagramCell.likeButton.tag = instagramObject.userHasLiked? 7 : 6;
                instagramCell.likeButton.titleLabel.textColor = likedOrNotColor;
                instagramCell.commentButton.enabled = instagramObject.commentCount > 0 ? YES:NO;
                instagramCell.commentButton.alpha = instagramCell.commentButton.enabled ? 1:0;
        });
        
        if (instagramObject.isVideo)
        {
            if (instagramCell.photoView.gestureRecognizers.count == 0)
            {
                UITapGestureRecognizer *tapToPlayVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(instagramVideoTapped:)];
                instagramCell.photoView.tag = indexPath.row;
                instagramCell.photoView.userInteractionEnabled = YES;
                [instagramCell.photoView addGestureRecognizer:tapToPlayVideo];
                instagramCell.playButtonImageView.image = [UIImage imageNamed:@"playMITLicenseInverted.png"];
                instagramCell.playButtonImageView.alpha = 0.5;
            }
        }
        
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
    [self setupInstagramDataSource];
    self.instagramTableView.estimatedRowHeight = 130;
    self.instagramTableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)checkForInstagramAccessToken
{
    if (![self.instagramWebServices hasAccessToken])
    {
        FLFInstagramLoginViewController *loginViewController = [[FLFInstagramLoginViewController alloc] initWithWebServices:self.instagramWebServices];
        loginViewController.mainViewController = self;
        UIView *contentView = [[UIView alloc] initWithFrame:self.instagramTableView.frame];
        loginViewController.view.frame = contentView.frame;
        [self.view addSubview:loginViewController.view];
        [self addChildViewController:loginViewController];
        [loginViewController didMoveToParentViewController:self];
    }
}

-(void)setupTwitter
{
    self.twitterWebServices = [[FLFTwitterWebServices alloc] initWithTableView:self.twitterTableView];
    [self.twitterWebServices loadTwitter];
    [self setupTwitterDataSource];
    self.twitterTableView.estimatedRowHeight = 44;
    self.twitterTableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Instagram Video -

-(void)instagramVideoTapped:(UIGestureRecognizer *)sender
{
    NSLog(@"video tapped");
    if (self.videoPlayer.playbackState == MPMoviePlaybackStatePlaying && self.tableViewRowOfCurrentVideoPlayingInt == sender.view.tag)
    {
        [self.videoPlayer pause];
    }
    else
    {
        [self playInstagramVideo:sender];
    }
}

-(void)playInstagramVideo:(UIGestureRecognizer *)sender
{
    [self removeVideoPlayers];
    self.tableViewRowOfCurrentVideoPlayingInt = (int)sender.view.tag;
    InstagramMedia *mediaToPlay = self.instagramWebServices.mediaMutableArray[sender.view.tag];
    NSURL *videoURL = mediaToPlay.standardResolutionVideoURL;
    [self setupVideoPlayerWithURL:videoURL];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerPlaybackDidFinishNotification object:self.videoPlayer queue:nil usingBlock:^(NSNotification *note)
     {
        [self removeVideoPlayers];
    ;}];
}

-(void)setupVideoPlayerWithURL:(NSURL *)videoURL
{
    [self setupNavbarGestureRecognizer];
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [self.videoPlayer prepareToPlay];
    CGSize viewFrameSize = self.view.frame.size;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown
                           forView:self.videoPlayer.view
                             cache:YES];
    
    [self.view addSubview:self.videoPlayer.view];
    self.videoPlayer.view.frame = CGRectMake(viewFrameSize.width/6, viewFrameSize.height/6, viewFrameSize.width*2/3, viewFrameSize.height*2/3);
    self.videoPlayer.view.tag = 101;
    [self.videoPlayer play];
    [UIView commitAnimations];
}

- (void)setupNavbarGestureRecognizer
{
    // recognise taps on navigation bar to hide
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeVideoPlayers)];
    gestureRecognizer.numberOfTapsRequired = 1;
    // create a view which covers most of the tap bar to
    // manage the gestures - if we use the navigation bar
    // it interferes with the nav buttons
    CGRect frame = self.navBar.frame;
    UIView *navBarTapView = [[UIView alloc] initWithFrame:frame];
    [self.navBar addSubview:navBarTapView];
    [navBarTapView setUserInteractionEnabled:YES];
    [navBarTapView addGestureRecognizer:gestureRecognizer];
    navBarTapView.tag = 999;
    self.navBarTitleItem.title = @"Tap here to dismiss video";
}

-(void)removeVideoPlayers
{
    for (UIView *view in self.view.subviews)
    {
        if (view.tag == 101 || view.tag == 999)
        {
            [self.videoPlayer stop];
            [view removeFromSuperview];
            self.navBarTitleItem.title = @"FunLyfe";
        }
    }
}

#pragma mark - Pull to refresh -

-(void)refreshInstagram
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeRefreshControlIfItExistsInInstagramTableView) name:@"FNLEndRefreshNotification" object:nil];
    [self setupInstagram];
    [self.instagramWebServices checkForAccessTokenAndLoad];
}

- (void)removeRefreshControlIfItExistsInInstagramTableView;
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FNLEndRefreshNotification" object:nil];
    for (UIRefreshControl *refreshControl in self.instagramTableView.subviews)
    {
        if (refreshControl.tag == 400)
        {
            NSLog(@"ending refresh");
           [refreshControl endRefreshing];
        }
    }
}

-(void)addPullToRefresh
{
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshInstagram) forControlEvents:UIControlEventValueChanged];
    [self.instagramTableView addSubview:refreshControl];
    refreshControl.tag = 400;
}

#pragma mark - View and background -

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPullToRefresh];
    [self setupBackground];
    [self setupTwitter];
    [self setupInstagram];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setupBackground
{
    self.view.backgroundColor = [UIColor grayColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor grayColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkForInstagramAccessToken];
}

@end
