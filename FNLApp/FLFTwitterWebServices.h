//
//  FLFTwitterWebServices.h
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"
@interface FLFTwitterWebServices : NSObject

@property (nonatomic) NSMutableArray *twitterFeedMutableArray;
@property (nonatomic) STTwitterAPI *twitter;
-(id)initWithTableView:(UITableView *)tableView;
-(void)fetchMoreTweets;
-(void)loadTwitter;
-(void)loadTwitterForScreenShots;
@end
