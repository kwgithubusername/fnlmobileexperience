//
//  FLFInstagramWebServices.m
//  FNLApp
//
//  Created by Woudini on 3/21/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramWebServices.h"

@implementation FLFInstagramWebServices

-(id)initWithTableView:(UITableView *)tableView
{
    self = [super init];
    if (self)
    {
        self.tableView = tableView;
        self.instagram = [[InstagramEngine alloc] init];
        self.mediaMutableArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)loadInstagram
{
    [self.instagram loginWithBlock:^(NSError *error) {
        NSLog(@"Instagram success");
        [self.instagram getMediaForUser:@"thefunlyfe_" count:20 maxId:nil withSuccess:^(NSArray *media, InstagramPaginationInfo *paginationInfo) {
            [self.mediaMutableArray addObjectsFromArray:media];
            NSLog(@"Instagram:%@",self.mediaMutableArray);
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            NSLog(@"Error getting media:%@", [error localizedDescription]);
        }];
    }];
}

-(void)fetchMoreMedia
{

}

@end
