//
//  FLFInstagramWebServices.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramWebServices.h"
#import <UIImageView+AFNetworking.h>

@interface FLFInstagramWebServices ()
@property (nonatomic) NSString *currentMaxIDString;
@end


@implementation FLFInstagramWebServices

-(id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.tableView = tableView;
        self.mediaMutableArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSURL *)setupAccessToken
{
    self.scopeString = @"basic+likes+comments";
    
    NSDictionary *configuration = [InstagramEngine sharedEngineConfiguration];
    NSString *scopeString = self.scopeString;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@", configuration[kInstagramKitAuthorizationUrlConfigurationKey], configuration[kInstagramKitAppClientIdConfigurationKey], configuration[kInstagramKitAppRedirectUrlConfigurationKey], scopeString]];
    
    return url;
}

-(BOOL)hasAccessToken
{
    InstagramEngine *sharedEngine = [InstagramEngine sharedEngine];
    return sharedEngine.accessToken ? YES : NO;
}

-(void)checkForAccessTokenAndLoad
{
    if ([self hasAccessToken])
    {
        [self fetchMoreMedia];
    }
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

-(InstagramUser *)loadInstagramUserInfo
{
    //__weak FLFInstagramWebServices *weakSelf = self;
    __block InstagramUser *user;
    [[InstagramEngine sharedEngine] getSelfUserDetailsWithSuccess:^(InstagramUser *userDetail) {
         user = userDetail;
    } failure:^(NSError *error) {
        NSLog(@"Error getting user info:%@", [error localizedDescription]);
    }];
    return user;
}

-(void)fetchMoreMedia
{
    NSString *maxIDString = self.currentMaxIDString;
    [[InstagramEngine sharedEngine] getMediaForUser:@"1382575886" count:10 maxId:maxIDString withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
        [self.mediaMutableArray addObjectsFromArray:media];
        InstagramMedia *lastMediaObject = [self.mediaMutableArray lastObject];
        self.currentMaxIDString = lastMediaObject.Id;
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
