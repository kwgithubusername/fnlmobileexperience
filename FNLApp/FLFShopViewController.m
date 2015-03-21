//
//  FLFShopViewController.m
//  FNLApp
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFShopViewController.h"

@interface FLFShopViewController ()
@end

@implementation FLFShopViewController

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    [self.webView loadData:[NSData dataWithContentsOfURL:location] MIMEType:downloadTask.response.MIMEType textEncodingName:downloadTask.response.textEncodingName baseURL:downloadTask.response.URL];
    //[self.spinner stopAnimating];
}

-(void)loadWebpageWithURLString:(NSString *)URLString
{
    //[self startSpinner];
    NSURL *url = [NSURL URLWithString:URLString];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

-(IBAction)homeButtonTapped:(UIBarButtonItem *)sender
{
    //[self startSpinner];
    NSURL *url = [NSURL URLWithString:@"http://www.thefunlyfe.com"];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.didLoadFromDifferentTab)
    {
        [self homeButtonTapped:nil];
    }
}

@end
