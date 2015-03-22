//
//  FLFInstagramWebServices.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramWebServices.h"

@implementation FLFInstagramWebServices

-(id)initWithTableView:(UITableView *)tableView andViewController:(FLFShopViewController *)viewController
{
    self = [super init];
    if (self)
    {
        self.viewControllerForLogin = viewController;
        self.tableView = tableView;
        self.mediaMutableArray = [[NSMutableArray alloc] init];
        [self setupAccessToken];
    }
    return self;
}

-(void)setupAccessToken
{
    self.scopeString = @"basic+likes+comments";
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = self.scopeString;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    self.viewControllerForLogin.webView.delegate = self.viewControllerForLogin;
    
    __weak FLFInstagramWebServices *weakSelf = self;
    
    void(^loadMediaBlock)() = ^(){
        InstagramEngine *sharedEngine = [InstagramEngine sharedEngine];
        
        if (sharedEngine.accessToken)
        {
            [weakSelf fetchMoreMedia];
        }
    };
    
    self.viewControllerForLogin.loadInitialInstagramMediaBlock = loadMediaBlock;
    [self.viewControllerForLogin.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL)shouldLoadRequest:(NSURLRequest *)request
{
    NSString *URLString = [request.URL absoluteString];
    
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]])
    {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1) {
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            NSLog(@"ready to load media");
        }
        return NO;
    }
    return YES;
}

-(void)loadInstagram
{
    [self.instagram loginWithBlock:^(NSError *error) {
        NSLog(@"Instagram success");
        
    }];
}

-(void)fetchMoreMedia
{
//    [[InstagramEngine sharedEngine] getSelfFeedWithCount:20 maxId:nil success:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
//        NSLog(@"Instagram:%@",media);
//    } failure:^(NSError *error) {
//        NSLog(@"Error getting media:%@", [error localizedDescription]);
//    }];
//    [[InstagramEngine sharedEngine] searchUsersWithString:@"thefunlyfe_" withSuccess:^(NSArray *users, InstagramPaginationInfo *paginationInfo) {
//        InstagramModel *user = users[0];
//        NSLog(@"%@",user.Id);
//    } failure:^(NSError *error) {
//        NSLog(@"Error getting media:%@", [error localizedDescription]);
//    }];
    [[InstagramEngine sharedEngine] getMediaForUser:@"1382575886" count:20 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [self.mediaMutableArray addObjectsFromArray:media];
        NSLog(@"Instagram:%@",media);
        //[self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Error getting media:%@", [error localizedDescription]);
    }];
    
//    //https://api.instagram.com/v1/users/thefunlyfe_/media/recent?access_token=18890017.828ab96.eb34c8fe66b0480b9eca839cebbb819e&count=20
}

@end
