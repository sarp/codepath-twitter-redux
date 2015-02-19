//
//  LoginViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/17/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TweetsViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)onLogin:(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Twitter Client";
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user != nil) {
            // Modally present tweets view
            NSLog(@"Welcome to %@", user.name);
            [self.navigationController pushViewController:[[TweetsViewController alloc] init] animated:YES];
        } else {
            // Present error view
        }
    }];
}
@end
