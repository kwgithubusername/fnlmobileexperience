//
//  FLFMusicWebServices.h
//  FNLApp
//
//  Created by Woudini on 4/15/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLFMusicTrackCollectionViewCell.h"

typedef void (^GetTracksCompletionBlock)(id jsonResponse);

@interface FLFMusicWebServices : NSObject

-(id)initWithCompletionBlock:(GetTracksCompletionBlock)aGetTracksCompletionBlock;
-(void)loadImageIntoCell:(FLFMusicTrackCollectionViewCell *)cell withURL:(NSURL *)URL;
-(void)getTracks;
@end
