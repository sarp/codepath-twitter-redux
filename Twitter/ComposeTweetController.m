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

@property (strong, nonatomic) UILabel *countLabel;
@property (strong, nonatomic) UIBarButtonItem *tweetButton;
@end

@implementation ComposeTweetController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    
    // Initialize nav bar items
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.countLabel.font = [UIFont systemFontOfSize:14.0];
    self.countLabel.text = @"140";
    
    UIBarButtonItem *countItem = [[UIBarButtonItem alloc] initWithCustomView:self.countLabel];
    self.tweetButton = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onTweet)];
    self.navigationItem.rightBarButtonItems = @[self.tweetButton, countItem];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    
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
    [self updateRighBarButtonItems];
    BOOL isPortrait =([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait);
    [self updatePadding:isPortrait];
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

- (void) updateRighBarButtonItems {
    NSUInteger characters = self.textview.text.length;
    [self.tweetButton setEnabled:(characters > 0 && characters <= 140)];
    NSInteger remaining = 140 - characters;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", remaining];
    self.countLabel.textColor = remaining >= 20 ? [UIColor lightGrayColor] : [UIColor redColor];
    [self.countLabel sizeToFit];
}

- (void) textViewDidChange:(UITextView *)textView {
    [self updateRighBarButtonItems];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) updatePadding:(BOOL) isPortrait {
    if (isPortrait) {
        self.topPadding.constant = 80;
    } else {
        self.topPadding.constant = 48;
    }
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    [self updatePadding:(device.orientation == UIDeviceOrientationPortrait)];
}

@end
