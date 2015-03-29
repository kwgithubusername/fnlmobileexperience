//
//  FLFInstagramCommentTableViewCell.m
//  FNLApp
//
//  Created by Woudini on 3/29/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramCommentTableViewCell.h"
#import "KILabel.h"
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
        [self createUsernameLabel];
        [self createCommentLabel];
    });
    // Initialization code
}

-(void)createUsernameLabel
{
    self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.usernameLabel.adjustsFontSizeToFitWidth = YES;
    self.usernameLabel.font = [UIFont systemFontOfSize:12];
    self.usernameLabel.text = self.usernameString;
    self.usernameLabel.textColor = [UIColor blueColor];
    self.usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.usernameLabel.numberOfLines = 1;
    
    [self.contentView addSubview:self.usernameLabel];
    
    NSDictionary *viewsDictionary = @{ @"usernameLabel" : self.usernameLabel};
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:|-[usernameLabel]"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-[usernameLabel]"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary]];
}

-(void)createCommentLabel
{
    self.commentLabel = [[KILabel alloc] initWithFrame:CGRectZero];
    self.commentLabel.adjustsFontSizeToFitWidth = YES;
    self.commentLabel.font = [UIFont systemFontOfSize:12];
    self.commentLabel.text = self.commentString;
    self.commentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.commentLabel.numberOfLines = 5;
    
    [self.contentView addSubview:self.commentLabel];
    
    NSDictionary *viewsDictionary = @{ @"usernameLabel" : self.usernameLabel, @"commentLabel" : self.commentLabel};
    
    [self.contentView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"V:[usernameLabel]-[commentLabel]-|"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary]];
    [self.contentView addConstraints:[NSLayoutConstraint
                                    constraintsWithVisualFormat:@"H:|-[commentLabel]-|"
                                    options:0
                                    metrics:nil
                                    views:viewsDictionary]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
