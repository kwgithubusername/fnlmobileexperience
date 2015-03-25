//
//  FLFTwitterTableViewCell.m
//  FLFApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFTwitterTableViewCell.h"
#import "FLFShopViewController.h"
#define UIParentViewController(__view) ({ \
UIResponder *__responder = __view; \
while ([__responder isKindOfClass:[UIView class]]) \
__responder = [__responder nextResponder]; \
(UIViewController *)__responder; \
})

@implementation FLFTwitterTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.tweetLabel.linkURLTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
        // Open URLs
        if (![string hasPrefix:@"http://"] && ![string hasPrefix:@"https://"])
        {
            string = [[NSString alloc] initWithFormat:@"http://%@", string];
        }
        UIViewController *viewController = UIParentViewController(self);
        FLFShopViewController *ThirdViewController = [viewController.tabBarController.viewControllers objectAtIndex:2];
        ThirdViewController.didLoadFromDifferentTab = YES;
        [ThirdViewController loadWebpageWithURLString:string];
        viewController.tabBarController.selectedIndex = 2;
        //self.superview.superview.superview.tabBarController.selectedIndex = 2;
        //tabBarController.selectedIndex = 1;
    };
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
