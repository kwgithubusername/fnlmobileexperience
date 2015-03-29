//
//  FLFInstagramCommentTableViewCell.h
//  FNLApp
//
//  Created by Woudini on 3/29/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFInstagramCommentTableViewCell : UITableViewCell
@property (nonatomic) NSString *usernameString;
@property (nonatomic) NSString *commentString;
@property (nonatomic) UILabel *usernameLabel;
@property (nonatomic) UILabel *commentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier usernameString:(NSString *)username commentString:(NSString *)comment;
@end
