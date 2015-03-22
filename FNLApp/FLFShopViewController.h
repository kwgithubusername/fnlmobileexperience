//
//  FLFShopViewController.h
//  FNLApp
//
//  Created by Woudini on 2/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LoadInitialInstagramMediaBlock)();

@interface FLFShopViewController : UIViewController <NSURLSessionDownloadDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) BOOL didLoadFromDifferentTab;
@property (nonatomic, copy) LoadInitialInstagramMediaBlock loadInitialInstagramMediaBlock;


-(void)loadWebpageWithURLString:(NSString *)URLString;

@end
