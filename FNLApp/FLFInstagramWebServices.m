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
        //self.instagram = [[InstagramEngine alloc] init];
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
    NSLog(@"authurl is %@", configuration[kInstagramKitAuthorizationUrlConfigurationKey]);
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    self.viewControllerForLogin.webView.delegate = self.viewControllerForLogin;
    [self.viewControllerForLogin.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL)shouldLoadRequest:(NSURLRequest *)request
{
    NSString *URLString = [request.URL absoluteString];
    NSLog(@"URLString is %@ while prefix is %@", URLString, [[InstagramEngine sharedEngine] appRedirectURL]);
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
    [self.instagram getMediaForUser:@"thefunlyfe_" count:20 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [self.mediaMutableArray addObjectsFromArray:media];
        NSLog(@"Instagram:%@",self.mediaMutableArray);
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Error getting media:%@", [error localizedDescription]);
    }];
}

@end
