//
//  SecondViewController.m
//  FNLApp
//
//  Created by Woudini on 2/5/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "SecondViewController.h"
#import "SCUI.h"
#import "FLFMusicTrackCollectionViewCell.h"
#import "FLFMusicCollectionViewDataSource.h"
#import "FLFMusicWebServices.h"

@interface SecondViewController ()
@property (nonatomic) int currentTrackInt;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) FLFMusicCollectionViewDataSource *dataSource;
@property (nonatomic) FLFMusicWebServices *webServices;
@property (weak, nonatomic) IBOutlet UISlider *volumeControlHorizontalSlider;
@end

@implementation SecondViewController

- (IBAction)playButtonTapped:(UIButton *)sender
{
    
}

- (IBAction)volumeControlHorizontalSliderMoved:(UISlider *)sender
{
    self.audioPlayer.volume = sender.value;
}

-(FLFMusicWebServices *)webServices
{
    if (!_webServices) _webServices = [[FLFMusicWebServices alloc] init];
    return _webServices;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"track tapped");
    if (self.audioPlayer && !self.audioPlayer.playing && self.currentTrackInt == indexPath.row)
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
                     self.audioPlayer.volume = self.volumeControlHorizontalSlider.value;
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
        FLFMusicTrackCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"trackCell" forIndexPath:indexPath];
        NSDictionary *trackDictionary = [[weakSelf.tracksArray firstObject] objectAtIndex:indexPath.row];
        NSLog(@"trackis %@", trackDictionary);
        cell.trackNameLabel.text = [trackDictionary objectForKey:@"title"];
        NSURL *trackArtworkImageURL = [NSURL URLWithString:trackDictionary[@"artwork_url"]];
        [weakSelf.webServices loadImageIntoCell:cell withURL:trackArtworkImageURL];
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

-(void)getMusic
{
    __weak SecondViewController *weakSelf = self;
    
    void (^getTracksCompletionBlock)(id jsonResponse) = ^void(id jsonResponse){
        weakSelf.tracksArray = [[NSArray alloc] initWithObjects:jsonResponse, nil];
        [weakSelf setupDataSource];
        [weakSelf.collectionView reloadData];
    };
    
    self.webServices = [[FLFMusicWebServices alloc] initWithCompletionBlock:getTracksCompletionBlock];
    [self.webServices getTracks];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.allowsSelection = YES;
    [self getMusic];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
