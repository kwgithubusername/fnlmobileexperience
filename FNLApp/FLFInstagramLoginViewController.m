//
//  FLFInstagramLoginViewController.m
//  FNLApp
//
//  Created by Woudini on 3/23/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramLoginViewController.h"
#import "InstagramEngine.h"
@interface FLFInstagramLoginViewController ()
@property (nonatomic) FLFInstagramWebServices *webServices;
@end

@implementation FLFInstagramLoginViewController

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices
{
    self = [super init];
    if (self)
    {
        self.webServices = webServices;
    }
    return self;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *URLString = [request.URL absoluteString];
    
    if ([URLString hasPrefix:[[InstagramEngine sharedEngine] appRedirectURL]]) {
        NSString *delimiter = @"access_token=";
        NSArray *components = [URLString componentsSeparatedByString:delimiter];
        if (components.count > 1)
        {
            NSString *accessToken = [components lastObject];
            NSLog(@"ACCESS TOKEN = %@",accessToken);
            [[InstagramEngine sharedEngine] setAccessToken:accessToken];
            NSLog(@"ready to load media");
            [self.webServices checkForAccessTokenAndLoad];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        return NO;
    }
    return YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.view.backgroundColor = [UIColor grayColor];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.size.height/3, self.view.frame.size.width,self.view.frame.size.height*0.38)];
    webView.delegate = self;
    [self.view addSubview:webView];
    [webView loadRequest:[NSURLRequest requestWithURL:[self.webServices setupAccessToken]]];
}

@end
