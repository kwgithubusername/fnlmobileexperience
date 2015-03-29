//
//  FLFInstagramCommentViewController.h
//  FNLApp
//
//  Created by Woudini on 3/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLFInstagramWebServices.h"
@interface FLFInstagramCommentViewController : UIViewController
@property (nonatomic) UIViewController *mainViewController;
-(id)initWithWebServices:(FLFInstagramWebServices *)webServices andImage:(UIImage *)image withInstagramMedia:(InstagramMedia *)media;

@end
