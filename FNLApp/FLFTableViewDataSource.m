//
//  FLFTwitterDataSource.m
//  FNLApp
//
//  Created by Woudini on 3/15/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFTableViewDataSource.h"

@interface FLFTableViewDataSource()
@property (nonatomic, copy) CellForRowAtIndexPathBlock cellForRowAtIndexPathBlock;
@property (nonatomic, copy) NumberOfRowsInSectionBlock numberOfRowsInSectionBlock;
@property (nonatomic, copy) WillDisplayCellBlock willDisplayCellBlock;

@end

@implementation FLFTableViewDataSource


-(id)initWithCellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock
             NumberOfRowsInSectionBlock:(NumberOfRowsInSectionBlock)aNumberOfRowsInSectionBlock
                   WillDisplayCellBlock:(WillDisplayCellBlock)aWillDisplayCellBlock
{
    self = [super init];
    if (self)
    {
        self.cellForRowAtIndexPathBlock = [aCellForRowAtIndexPathBlock copy];
        self.numberOfRowsInSectionBlock = [aNumberOfRowsInSectionBlock copy];
        self.willDisplayCellBlock = [aWillDisplayCellBlock copy];
    }
    return self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRowsInSectionBlock();
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellForRowAtIndexPathBlock(indexPath, tableView);
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.willDisplayCellBlock)
    {
        self.willDisplayCellBlock(indexPath);
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end

