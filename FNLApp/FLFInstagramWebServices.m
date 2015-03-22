//
//  FLFInstagramWebServices.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramWebServices.h"
#import <UIImageView+AFNetworking.h>

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
    [[InstagramEngine sharedEngine] getMediaForUser:@"1382575886" count:20 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [self.mediaMutableArray addObjectsFromArray:media];
        NSLog(@"Instagram:%@",media);
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        NSLog(@"Error getting media:%@", [error localizedDescription]);
    }];
}

-(void)loadImageIntoCell:(FLFInstagramTableViewCell *)cell withURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    UIImage *placeholderImage = [[UIImage alloc] init];
    
    [cell.photoView setImageWithURLRequest:request
                                   placeholderImage:placeholderImage
                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                
                                                //NSLog(@"setImageWithURLRequest executed");
                                                cell.photoView.image = image;
                                                //cell.imageView.image = image;
                                            }
                                            failure:nil];
}


@end
