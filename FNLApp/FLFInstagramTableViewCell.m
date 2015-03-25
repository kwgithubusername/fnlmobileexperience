//
//  FLFInstagramTableViewCell.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramTableViewCell.h"
#import "FLFShopViewController.h"
#define UIParentViewController(__view) ({ \
UIResponder *__responder = __view; \
while ([__responder isKindOfClass:[UIView class]]) \
__responder = [__responder nextResponder]; \
(UIViewController *)__responder; \
})
@implementation FLFInstagramTableViewCell

- (void)awakeFromNib {
    self.captionLabel.linkURLTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
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
    };
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
