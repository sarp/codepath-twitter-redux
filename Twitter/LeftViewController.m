//
//  LeftViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "LeftViewController.h"
#import "UIImageView+AFNetworking.h"
#import "User.h"

@interface LeftViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation LeftViewController

static NSInteger const kProfileIndex = 0;
static NSInteger const kHomeIndex = 1;
static NSInteger const kMentionsIndex = 2;
static NSInteger const kLogoutIndex = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewdidLoad");
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView reloadData];
    
    User *currentUser = [User currentUser];
    self.nameLabel.text = currentUser.name;
    self.usernameLabel.text = [NSString stringWithFormat:@"@%@", currentUser.screenname];
    [self.profileImage setImageWithURL:currentUser.profileImageUrl];
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    if (indexPath.row == kProfileIndex) {
        cell.textLabel.text = @"Profile";
    } else if (indexPath.row == kHomeIndex) {
        cell.textLabel.text = @"Timeline";
    } else if (indexPath.row == kMentionsIndex) {
        cell.textLabel.text = @"Mentions";
    } else if (indexPath.row == kLogoutIndex) {
        cell.textLabel.text = @"Logout";
    } else {
        cell.textLabel.text = @"Unknown";
    }

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected row: %ld", indexPath.row);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate didTapController:self withIndexPath:indexPath];
}
@end
;