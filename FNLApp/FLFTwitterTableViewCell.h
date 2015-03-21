//
//  FLFTwitterTableViewCell.h
//  FLFApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KILabel.h"
@interface FLFTwitterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet KILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;

@end
