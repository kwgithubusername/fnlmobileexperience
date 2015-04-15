//
//  FLFMusicCollectionViewDataSource.m
//  FNLApp
//
//  Created by Woudini on 4/14/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFMusicCollectionViewDataSource.h"
@interface FLFMusicCollectionViewDataSource ()

@property (nonatomic, copy) CellForItemAtIndexPathBlock cellForItemAtIndexPathBlock;
@property (nonatomic, copy) NumberOfItemsInSectionBlock numberOfItemsInSectionBlock;

@end

@implementation FLFMusicCollectionViewDataSource

-(id)initWithCellForItemAtIndexPathBlock:(CellForItemAtIndexPathBlock)aCellForItemAtIndexPathBlock
             NumberOfItemsInSectionBlock:(NumberOfItemsInSectionBlock)aNumberOfItemsInSectionBlock
{
    self = [super init];
    if (self)
    {
        self.cellForItemAtIndexPathBlock = [aCellForItemAtIndexPathBlock copy];
        self.numberOfItemsInSectionBlock = [aNumberOfItemsInSectionBlock copy];
    }
    return self;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.numberOfItemsInSectionBlock();
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellForItemAtIndexPathBlock(indexPath, collectionView);
}

@end
