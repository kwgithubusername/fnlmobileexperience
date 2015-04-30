//
//  FLFShopViewController.m
//  FNLApp
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFShopViewController.h"
@interface FLFShopViewController ()
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBarProperty;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FLFShopViewController

- (IBAction)backButtonTapped:(UIBarButtonItem *)sender
{
    if (self.webView.canGoBack)
    {
        [self.webView goBack];
    }
}

- (IBAction)forwardButtonTapped:(UIBarButtonItem *)sender
{
    if (self.webView.canGoForward)
    {
        [self.webView goForward];
    }
}

- (IBAction)homeButtonTapped:(UIBarButtonItem *)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.thefunlyfe.com"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

- (IBAction)refreshButtonTapped:(UIBarButtonItem *)sender
{
    [self.webView reload];
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.spinner startAnimating];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.spinner stopAnimating];
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self.webView loadData:[NSData dataWithContentsOfURL:location] MIMEType:downloadTask.response.MIMEType textEncodingName:downloadTask.response.textEncodingName baseURL:downloadTask.response.URL];
    [self.spinner stopAnimating];
}

-(void)loadWebpageWithURLString:(NSString *)URLString
{
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBackground];
    self.webView.delegate = self;
    
    if (!self.didLoadFromDifferentTab)
    {
        [self homeButtonTapped:nil];
    }
}

-(void)setupBackground
{
    self.view.backgroundColor = [UIColor grayColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    CGRect frame = CGRectMake(90, 0, self.view.frame.size.width-180, self.navigationBarProperty.frame.size.height);
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:frame];
    
    [self.navigationBarProperty addSubview:logoView];
    logoView.image = [UIImage imageNamed:@"funlyfebanner.png"];
}

@end
