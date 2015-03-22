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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    [self.viewControllerForLogin.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
