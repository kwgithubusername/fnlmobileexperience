//
//  FLFTwitterDataSource.h
//  FNLApp
//
//  Created by Woudini on 3/15/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UITableViewCell *(^CellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView);
typedef NSInteger (^NumberOfRowsInSectionBlock)();
typedef void (^WillDisplayCellBlock)(NSIndexPath *indexPath);

@interface FLFTableViewDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

-(id)initWithCellForRowAtIndexPathBlock:(CellForRowAtIndexPathBlock)aCellForRowAtIndexPathBlock
             NumberOfRowsInSectionBlock:(NumberOfRowsInSectionBlock)aNumberOfRowsInSectionBlock
                   WillDisplayCellBlock:(WillDisplayCellBlock)aWillDisplayCellBlock;



@end
