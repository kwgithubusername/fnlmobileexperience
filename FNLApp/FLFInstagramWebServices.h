//
//  FLFInstagramWebServices.h
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "FLFInstagramTableViewCell.h"
@interface FLFInstagramWebServices : NSObject
@property (nonatomic) UITableView *tableView;
@property (nonatomic) InstagramEngine *instagram;
@property (nonatomic) NSMutableArray *mediaMutableArray;
@property (nonatomic) NSString *scopeString;

-(id)initWithTableView:(UITableView *)tableView;
-(void)loadImageIntoCell:(FLFInstagramTableViewCell *)cell withURL:(NSURL *)URL;
-(InstagramUser *)loadInstagramUserInfo;
-(void)fetchMoreMedia;
-(NSURL *)setupAccessToken;
-(void)checkForAccessTokenAndLoad;
-(BOOL)hasAccessToken;

@end
