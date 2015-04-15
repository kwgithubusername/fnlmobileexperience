//
//  SecondViewController.m
//  FNLApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "SecondViewController.h"
#import "SCUI.h"
#import "FLFMusicCollectionViewDataSource.h"

@interface SecondViewController ()
@property (nonatomic) int currentTrackInt;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) FLFMusicCollectionViewDataSource *dataSource;
@end

@implementation SecondViewController

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"track tapped");
    if (!self.audioPlayer.playing && self.currentTrackInt == indexPath.row)
    {
        [self.audioPlayer play];
        return;
    }
    
    if (self.audioPlayer.playing)
    {
        [self.audioPlayer pause];
    }
    
    if (!self.audioPlayer || self.currentTrackInt != indexPath.row)
    {
        NSDictionary *track = [[self.tracksArray firstObject] objectAtIndex:indexPath.row];
        NSString *streamURL = [track objectForKey:@"stream_url"];
        
        SCAccount *account = [SCSoundCloud account];
        
        [SCRequest performMethod:SCRequestMethodGET
                      onResource:[NSURL URLWithString:streamURL]
                 usingParameters:nil
                     withAccount:account
          sendingProgressHandler:nil
                 responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                     NSError *playerError;
                     self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                     [self.audioPlayer prepareToPlay];
                     [self.audioPlayer play];
                 }];
        self.currentTrackInt = (int)indexPath.row;
    }
}

-(void)setupDataSource
{
    __weak SecondViewController *weakSelf = self;
    
    UICollectionViewCell *(^cellForItemAtIndexPathBlock)(NSIndexPath *indexPath, UICollectionView *collectionView) = ^UICollectionViewCell *(NSIndexPath *indexPath, UICollectionView *collectionView)
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trackCell" forIndexPath:indexPath];
        NSDictionary *track = [[weakSelf.tracksArray firstObject] objectAtIndex:indexPath.row];
        NSLog(@"trackis %@", track);
        UILabel *label = (UILabel *)[cell viewWithTag:100];
        label.text = [track objectForKey:@"title"];;
        return cell;
    };
    
    NSInteger(^numberOfItemsInSectionBlock)() = ^NSInteger(){
        return [[weakSelf.tracksArray firstObject] count];
    };
    
    self.dataSource = [[FLFMusicCollectionViewDataSource alloc] initWithCellForItemAtIndexPathBlock:cellForItemAtIndexPathBlock
        NumberOfItemsInSectionBlock:numberOfItemsInSectionBlock];
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.delegate = self;
}

- (void)getTracks
{
    SCAccount *account = [SCSoundCloud account];

    if (account == nil) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Not Logged In"
                              message:@"You must login first"
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    SCRequestResponseHandler handler;
    handler = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSError *jsonError = nil;
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            self.tracksArray = [[NSArray alloc] initWithObjects:jsonResponse, nil];
            NSLog(@"json response is %@", jsonResponse);
            [self setupDataSource];
            [self.collectionView reloadData];
        }
    };
    
    NSString *resourceURL = @"https://api.soundcloud.com/me/tracks.json";
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:resourceURL]
             usingParameters:nil
                 withAccount:account
      sendingProgressHandler:nil
             responseHandler:handler];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getTracks];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
