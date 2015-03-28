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
@end

@implementation FLFInstagramCommentViewController

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices andImage:(UIImage *)image
{
    self = [super init];
    if (self)
    {
        self.webServices = webServices;
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
}

-(void)createCloseButton
{
    NSLog(@"creating close button");
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //CGSize viewBoundsSize = self.view.bounds.size;
    [button setTitle:@"Close" forState:UIControlStateNormal];
    [button sizeToFit];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-16-[button]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[button]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    //IBAction
    [button addTarget:self
               action:@selector(closeWindow)
     forControlEvents:UIControlEventTouchUpInside];
}

-(void)createSendButton
{
    NSLog(@"creating send button");
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [button setTitle:@"Send" forState:UIControlStateNormal];
    [button sizeToFit];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:button];

    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:[button]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:[button]-16-|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    //IBAction
    [button addTarget:self
                  action:@selector(postComment)
        forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self removeSubviews];
    [self createSendButton];
    [self createCloseButton];
    [self createImageView];
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
