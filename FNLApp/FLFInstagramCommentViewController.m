//
//  FLFInstagramCommentViewController.m
//  FNLApp
//
//  Created by Woudini on 3/27/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "FLFInstagramCommentViewController.h"

@interface FLFInstagramCommentViewController ()
@property (nonatomic) FLFInstagramWebServices *webServices;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (nonatomic) UITextField *textField;
@property (nonatomic) UIButton *sendButton;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) BOOL viewsCreated;
@property (nonatomic) NSString *captionString;
@end

@implementation FLFInstagramCommentViewController

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices andImage:(UIImage *)image withCaptionString:(NSString *)captionString
{
    self = [super init];
    if (self)
    {
        self.webServices = webServices;
        self.captionString = captionString;
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

-(void)postComment
{
    
}

#pragma mark - Create Views -

-(void)createCaptionLabel
{
    KILabel *captionLabel = [[KILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    captionLabel.text = self.captionString;
    captionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    captionLabel.font = [UIFont systemFontOfSize:14];
    captionLabel.numberOfLines = 7;
    captionLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:captionLabel];
    
    NSDictionary *viewsDictionary = @{ @"closeButton" : self.closeButton, @"imageView" : self.imageView, @"captionLabel" : captionLabel, @"textField" : self.textField, @"sendButton" : self.sendButton};
    
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
                               constraintsWithVisualFormat:@"H:[imageView]-8-[captionLabel]-16-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
}

-(void)createImageView
{
    NSLog(@"creating imageView");
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageView];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-16-[imageView]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(imageView)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-16-[imageView]"
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

-(void)createTextField
{
    NSLog(@"creating textField");
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0,0,200,40)];
    
    NSDictionary *viewsDictionary = @{ @"sendButton" : self.sendButton, @"textField" : textField };
    
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    //textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [self.view addSubview:textField];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[textField]-16-|"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[textField]-8-[sendButton]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[textField(200)]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[textField(31)]"
                               options:0
                               metrics:nil
                               views:viewsDictionary]];
    [self.view bringSubviewToFront:textField];
    textField.placeholder = @"Add comment";
    textField.userInteractionEnabled = YES;
    self.textField = textField;
}

-(void)createCloseButton
{
    NSLog(@"creating close button");
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //CGSize viewBoundsSize = self.view.bounds.size;
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton sizeToFit];
    
    closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:closeButton];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-8-[closeButton]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(closeButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[closeButton]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(closeButton)]];
    //IBAction
    [closeButton addTarget:self
               action:@selector(closeWindow)
     forControlEvents:UIControlEventTouchUpInside];
    self.closeButton = closeButton;
}

-(void)createSendButton
{
    NSLog(@"creating send button");
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    [sendButton sizeToFit];
    
    sendButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sendButton];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[sendButton]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(sendButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[sendButton]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(sendButton)]];
    //IBAction
    [sendButton addTarget:self
                  action:@selector(postComment)
        forControlEvents:UIControlEventTouchUpInside];
    self.sendButton = sendButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.viewsCreated)
    {
        [self removeSubviews];
        [self createSendButton];
        [self createCloseButton];
        [self createImageView];
        [self createTextField];
        [self createCaptionLabel];
        self.viewsCreated = YES;
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
