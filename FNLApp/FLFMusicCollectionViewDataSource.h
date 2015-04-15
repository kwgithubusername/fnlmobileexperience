//
//  FLFMusicCollectionViewDataSource.h
//  FNLApp
//
//  Created by Woudini on 4/14/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef UICollectionViewCell *(^CellForItemAtIndexPathBlock)(NSIndexPath *indexPath, UICollectionView *collectionView);
typedef NSInteger (^NumberOfItemsInSectionBlock)();

@interface FLFMusicCollectionViewDataSource : NSObject <UICollectionViewDataSource>
-(id)initWithCellForItemAtIndexPathBlock:(CellForItemAtIndexPathBlock)aCellForItemAtIndexPathBlock
             NumberOfItemsInSectionBlock:(NumberOfItemsInSectionBlock)aNumberOfItemsInSectionBlock;
@end