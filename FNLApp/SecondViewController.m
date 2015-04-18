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
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeControlHorizontalSlider;
@end

@implementation SecondViewController

- (IBAction)previousButtonTapped:(UIButton *)sender
{
    
}
- (IBAction)nextButtonTapped:(UIButton *)sender
{
    
}

- (IBAction)playOrPauseButtonTapped:(UIButton *)sender
{
    BOOL isInPlayMode = self.audioPlayer.isPlaying;
    if (isInPlayMode)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.imageView.image = [UIImage imageNamed:@"playMITLicenseInverted.png"];
        });
        
        [self.audioPlayer pause];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            sender.imageView.image = [UIImage imageNamed:@"pauseInvertedMITLicense.png"];
        });

        [self playTrack];
    }
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

-(void)playTrack
{
    if (!self.audioPlayer)
    {
        [self playTrackAtIndex:0];
    }
    else
    {
        [self.audioPlayer play];
    }
}

-(void)playTrackAtIndex:(int)index
{
    NSDictionary *track = [[self.tracksArray firstObject] objectAtIndex:index];
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
    self.currentTrackInt = index;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"track tapped");
    
    if (!self.audioPlayer || self.currentTrackInt != indexPath.row)
    {
        [self.audioPlayer pause];
        [self playTrackAtIndex:(int)indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playOrPauseButton.imageView.image = [UIImage imageNamed:@"pauseInvertedMITLicense.png"];
        });
        return;
    }
    else
    {
        [self playOrPauseButtonTapped:self.playOrPauseButton];
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

-(void)enableButtons
{
    self.playOrPauseButton.enabled = YES;
    self.forwardButton.enabled = YES;
    self.backButton.enabled = YES;
}

-(void)getMusic
{
    __weak SecondViewController *weakSelf = self;
    
    void (^getTracksCompletionBlock)(id jsonResponse) = ^void(id jsonResponse){
        weakSelf.tracksArray = [[NSArray alloc] initWithObjects:jsonResponse, nil];
        [weakSelf setupDataSource];
        [weakSelf.collectionView reloadData];
        [weakSelf enableButtons];
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
