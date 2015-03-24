//
//  FLFInstagramLoginViewController.h
//  FNLApp
//
//  Created by Woudini on 3/23/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLFInstagramWebServices.h"
@interface FLFInstagramLoginViewController : UIViewController <UIWebViewDelegate>

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices;

@end
