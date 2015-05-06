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
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBarProperty;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation SecondViewController

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag)
    {
        [self nextButtonTapped:nil];
    }
}

- (IBAction)previousButtonTapped:(UIButton *)sender
{
    [self.audioPlayer pause];
    
    if (self.currentTrackInt == 0)
    {
        self.currentTrackInt = (int)[[self.tracksArray firstObject] count]-1;
    }
    else
    {
        self.currentTrackInt--;
    }
    
    [self playTrackAtIndex:self.currentTrackInt];
}
- (IBAction)nextButtonTapped:(UIButton *)sender
{
    [self.audioPlayer pause];
    
    if (self.currentTrackInt == [[self.tracksArray firstObject] count]-1)
    {
        self.currentTrackInt = 0;
    }
    else
    {
        self.currentTrackInt++;
    }
    
    [self playTrackAtIndex:self.currentTrackInt];
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playOrPauseButton.imageView.image = [UIImage imageNamed:@"pauseInvertedMITLicense.png"];
    });
}

-(void)playTrackAtIndex:(int)index
{
    [self.spinner startAnimating];
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
                 [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
                 [[AVAudioSession sharedInstance] setActive: YES error: nil];
                 [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                 self.audioPlayer.volume = self.volumeControlHorizontalSlider.value;
                 [self.audioPlayer prepareToPlay];
                 [self.audioPlayer play];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     self.playOrPauseButton.imageView.image = [UIImage imageNamed:@"pauseInvertedMITLicense.png"];
                     self.currentTrackInt = index;
                     [self.spinner stopAnimating];
                 });
             }];
    
}

-(void)setCurrentTrackInt:(int)currentTrackInt
{
    FLFMusicTrackCollectionViewCell *oldTrackCell = (FLFMusicTrackCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentTrackInt inSection:0]];
    FLFMusicTrackCollectionViewCell *newTrackCell = (FLFMusicTrackCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:currentTrackInt inSection:0]];
    dispatch_async(dispatch_get_main_queue(), ^{
        oldTrackCell.trackNameLabel.textColor = [UIColor whiteColor];
        newTrackCell.trackNameLabel.textColor = [UIColor greenColor];
    });
    
    _currentTrackInt = currentTrackInt;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // NSLog(@"track tapped");
    
    if (!self.audioPlayer || self.currentTrackInt != indexPath.row)
    {
        [self.audioPlayer pause];
        [self playTrackAtIndex:(int)indexPath.row];
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
        // NSLog(@"trackis %@", trackDictionary);
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
    [self setupBackground];
    self.collectionView.allowsSelection = YES;
    [self getMusic];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setupBackground
{
    self.view.backgroundColor = [UIColor grayColor];
    [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
    
    CGRect frame = CGRectMake(90, 0, self.view.frame.size.width-180, self.navigationBarProperty.frame.size.height);
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:frame];
    
    [self.navigationBarProperty addSubview:logoView];
    logoView.image = [UIImage imageNamed:@"funlyfebanner.png"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
