//
//  FLFMusicWebServices.m
//  FNLApp
//
//  Created by Woudini on 4/15/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFMusicWebServices.h"
#import "SCUI.h"
#import <UIImageView+AFNetworking.h>

@interface FLFMusicWebServices ()
@property (nonatomic, copy) GetTracksCompletionBlock getTracksCompletionBlock;
@end

@implementation FLFMusicWebServices

-(id)initWithCompletionBlock:(GetTracksCompletionBlock)aGetTracksCompletionBlock
{
    self = [super init];
    if (self)
    {
        self.getTracksCompletionBlock = aGetTracksCompletionBlock;
    }
    return self;
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
#warning NSInvalidArgumentException reason 'data parameter is nil' when no internet connection
        NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                             JSONObjectWithData:data
                                             options:0
                                             error:&jsonError];
        if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
            self.getTracksCompletionBlock(jsonResponse);
            NSLog(@"json response is %@", jsonResponse);
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

-(void)loadImageIntoCell:(FLFMusicTrackCollectionViewCell *)cell withURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    UIImage *placeholderImage = [[UIImage alloc] init];
    
    [cell.artworkImageView setImageWithURLRequest:request
                          placeholderImage:placeholderImage
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       
                                       //NSLog(@"setImageWithURLRequest executed");
                                       cell.artworkImageView.image = image;
                                       //cell.imageView.image = image;
                                   }
                                   failure:nil];
}

@end
