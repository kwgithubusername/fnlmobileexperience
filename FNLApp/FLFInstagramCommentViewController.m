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
@end

@implementation FLFInstagramCommentViewController

-(id)initWithWebServices:(FLFInstagramWebServices *)webServices
{
    self = [super init];
    if (self)
    {
        self.webServices = webServices;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)postComment
{
    
}

-(void)createSendButton
{
    NSLog(@"creating send button");
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //CGSize viewBoundsSize = self.view.bounds.size;
    [button setTitle:@"Send" forState:UIControlStateNormal];
    [button sizeToFit];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;  //This part hung me up
    [self.view addSubview:button];
    //needed to make smaller for iPhone 4 dev here, so >=200 instead of 748
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-16-[button]"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(button)]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-16-[button]"
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
    [self createSendButton];
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
