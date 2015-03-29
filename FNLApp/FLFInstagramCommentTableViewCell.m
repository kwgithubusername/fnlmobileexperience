//
//  FLFInstagramCommentTableViewCell.m
//  FNLApp
//
//  Created by Woudini on 3/29/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramCommentTableViewCell.h"

@implementation FLFInstagramCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier usernameString:(NSString *)username commentString:(NSString *)comment
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.usernameString = username;
        self.commentString = comment;
        [self setup];
    }
    return self;
}

- (void)setup
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,50,50)];
        [self.usernameLabel sizeToFit];
        self.usernameLabel.adjustsFontSizeToFitWidth = YES;
        self.usernameLabel.font = [UIFont systemFontOfSize:12];
        self.usernameLabel.text = self.usernameString;
        self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.usernameLabel.numberOfLines = 1;
        
        [self.superview addSubview:self.usernameLabel];
        
        NSDictionary *viewsDictionary = @{ @"usernameLabel" : self.usernameLabel};
        
        [self.superview addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:|-16-[usernameLabel]"
                                        options:0
                                        metrics:nil
                                        views:viewsDictionary]];
        [self.superview addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"H:|-16-[usernameLabel]"
                                        options:0
                                        metrics:nil
                                        views:viewsDictionary]];
        [self addSubview:self.usernameLabel];
    });
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
