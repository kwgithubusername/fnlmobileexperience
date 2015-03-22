//
//  FLFShopViewController.h
//  FNLApp
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFShopViewController : UIViewController <NSURLSessionDownloadDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL didLoadFromDifferentTab;

-(void)loadWebpageWithURLString:(NSString *)URLString;

@end
