//
//  FLFInstagramWebServices.h
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstagramKit.h"
@interface FLFInstagramWebServices : NSObject
@property (nonatomic) UITableView *tableView;
@property (nonatomic) InstagramEngine *instagram;
@property (nonatomic) NSMutableArray *mediaMutableArray;

-(id)initWithTableView:(UITableView *)tableView;
-(void)loadInstagram;
-(void)fetchMoreMedia;

@end
