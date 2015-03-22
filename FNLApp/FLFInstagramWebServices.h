//
//  FLFInstagramWebServices.h
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
#import "FLFShopViewController.h"
#import "FLFInstagramTableViewCell.h"
@interface FLFInstagramWebServices : NSObject
@property (nonatomic) UITableView *tableView;
@property (nonatomic) InstagramEngine *instagram;
@property (nonatomic) NSMutableArray *mediaMutableArray;
@property (nonatomic) NSString *scopeString;
@property (nonatomic) FLFShopViewController *viewControllerForLogin;

-(id)initWithTableView:(UITableView *)tableView andViewController:(FLFShopViewController *)viewController;
-(void)loadImageIntoCell:(FLFInstagramTableViewCell *)cell withURL:(NSURL *)URL;
-(void)loadInstagram;
-(void)fetchMoreMedia;

@end
