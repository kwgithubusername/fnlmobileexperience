//
//  FLFInstagramCommentViewController.m
//  FNLApp
//
//  Created by Woudini on 3/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramCommentViewController.h"
#import "FLFTableViewDataSource.h"
#import "FLFInstagramCommentTableViewCell.h"
@interface FLFInstagramCommentViewController ()
@property (nonatomic) FLFInstagramWebServices *webServices;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) BOOL viewsCreated;
@property (nonatomic) UILabel *captionLabel;
@property (nonatomic) InstagramMedia *media;
@property (nonatomic) FLFTableViewDataSource *instagramDataSource;
@property (nonatomic) UITableView *instagramTableView;
@property (nonatomic) NSMutableArray *commentsMutableArray;
@end

@implementation FLFInstagramCommentViewController

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices andImage:(UIImage *)image withInstagramMedia:(InstagramMedia *)media
{
    self = [super init];
    if (self)
    {
        self.webServices = webServices;
        self.media = media;
        self.image = image;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)removeSubviews
{
    for (UIView *view in self.view.subviews)
    {
        [view removeFromSuperview];
    }
}

-(void)closeWindow
{
    UIViewController *viewController = [self.mainViewController.childViewControllers lastObject];
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

#pragma mark - Create Views -

-(void)createCommentTableView
{
    self.instagramTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self setupInstagramDataSource];
    self.instagramTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.instagramTableView];
    
    NSDictionary *viewsDictionary = @{ @"tableView" : self.instagramTableView, @"closeButton" : self.closeButton, @"imageView" : self.imageView, @"captionLabel" : self.captionLabel};
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[captionLabel]-8-[tableView]-8-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-[tableView]-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    self.instagramTableView.estimatedRowHeight = 44;
    self.instagramTableView.rowHeight = UITableViewAutomaticDimension;

}

-(void)setupInstagramDataSource
{
    __weak FLFInstagramCommentViewController *weakSelf = self;
    
    FLFInstagramCommentTableViewCell *(^cellForRowAtIndexPathBlock)(NSIndexPath *indexPath, UITableView *tableView) = ^FLFInstagramCommentTableViewCell *(NSIndexPath *indexPath, UITableView *tableView)
    {
        InstagramComment *comment;
        
        if ([self.commentsMutableArray count] != 0)
        {
            comment = self.commentsMutableArray[indexPath.row];
        }
        else
        {
            comment = weakSelf.media.comments[indexPath.row];
        }
        //InstagramComment *instagramComment = weakSelf.media.comments[indexPath.row];
        
        NSString *usernameString = comment.user.username;
        NSString *commentString = comment.text;
            
        FLFInstagramCommentTableViewCell *commentCell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
        
        if (commentCell == nil)
        {
            commentCell = [[FLFInstagramCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell" usernameString:usernameString commentString:commentString];
        }
        
        return commentCell;
    };
    
    NSInteger(^numberOfRowsInSectionBlock)() = ^NSInteger(){
        return [weakSelf.media.comments count];
    };
    
    self.instagramDataSource = [[FLFTableViewDataSource alloc] initWithCellForRowAtIndexPathBlock:cellForRowAtIndexPathBlock NumberOfRowsInSectionBlock:numberOfRowsInSectionBlock WillDisplayCellBlock:nil];
    self.instagramTableView.delegate = self.instagramDataSource;
    self.instagramTableView.dataSource = self.instagramDataSource;
}


-(void)createCaptionLabel
{
    KILabel *captionLabel = [[KILabel alloc] initWithFrame:CGRectZero];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.font = [UIFont systemFontOfSize:14];
    captionLabel.text = self.media.caption.text;
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    captionLabel.numberOfLines = 0;
    
    [self.view addSubview:captionLabel];
    
    NSDictionary *viewsDictionary = @{ @"closeButton" : self.closeButton, @"imageView" : self.imageView, @"captionLabel" : captionLabel};
    
    [self.view addConstraints:[NSLayoutConstraint
                              constraintsWithVisualFormat:@"V:[closeButton]-[captionLabel]"
                              options:0
                              metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[captionLabel(100)]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[imageView]-8-[captionLabel]-8-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    self.captionLabel = captionLabel;
}

-(void)createImageView
{
    NSLog(@"creating imageView");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    NSDictionary *viewsDictionary = @{ @"closeButton" : self.closeButton, @"imageView" : imageView};
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[closeButton]-0-[imageView]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-8-[imageView]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(imageView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[imageView(100)]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(imageView)]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[imageView(100)]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(imageView)]];
    imageView.image = self.image;
    self.imageView = imageView;
}

-(void)createCloseButton
{
    NSLog(@"creating close button");
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton sizeToFit];
    
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:closeButton];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-0-[closeButton]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[closeButton]-8-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(closeButton)]];
    //IBAction
    [closeButton addTarget:self
               action:@selector(closeWindow)
     forControlEvents:UIControlEventTouchUpInside];
    self.closeButton = closeButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.commentsMutableArray = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.viewsCreated)
    {
        [self removeSubviews];
        [self createCloseButton];
        [self createImageView];
        [self createCaptionLabel];
        [self createCommentTableView];
        self.viewsCreated = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.instagramTableView reloadData];
    });
}

@end
