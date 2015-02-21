//
//  ComposeTweetController.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ComposeTweetController.h"
#import "User.h"
#import "UIImageView+AFNetworking.h"
#import "TwitterClient.h"

@interface ComposeTweetController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
@property (weak, nonatomic) IBOutlet UILabel *profileHandle;
@property (weak, nonatomic) IBOutlet UITextView *textview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topPadding;
@end

@implementation ComposeTweetController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    
    // Do any additional setup after loading the view from its nib.
    User *user = [User currentUser];
    
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    [self.profileImage setImageWithURL:[user profileImageUrl]];
    self.profileName.text = user.name;
    self.profileHandle.text = user.screenname;
    
    // give focus
    if (self.original != nil) {
        if (self.original.retweetedTweet != nil) {
            self.textview.text = [NSString stringWithFormat:@"@%@ @%@ ", self.original.retweetedTweet.user.screenname, self.original.user.screenname];
        } else {
            self.textview.text = [NSString stringWithFormat:@"@%@ ", self.original.user.screenname];
        }
    }
    [self.textview becomeFirstResponder];
}

- (void) onCancel {
    [self.textview resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) onTweet {
    [[TwitterClient sharedInstance] tweet:self.textview.text original:self.original completion:^(Tweet *tweet, NSError *error) {
        if (error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            [self.delegate composeTweetController:self didPostTweet:tweet];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    if (device.orientation == UIDeviceOrientationPortrait) {
        self.topPadding.constant = 80;
    } else {
        self.topPadding.constant = 48;
    }
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
