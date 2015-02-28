//
//  SecondViewController.h
//  FNLApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface SecondViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AVAudioPlayerDelegate>
@property (nonatomic) NSArray *tracksArray;
@property (nonatomic) AVAudioPlayer *audioPlayer;

@end

