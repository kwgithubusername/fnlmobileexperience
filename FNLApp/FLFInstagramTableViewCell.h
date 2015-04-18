//
//  FLFInstagramTableViewCell.h
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//
#import "KILabel.h"
#import <UIKit/UIKit.h>

@interface FLFInstagramTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet KILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *playButtonImageView;

@end
