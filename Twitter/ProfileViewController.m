//
//  ProfileViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCell.h"
#import "TwitterClient.h"
#import "TweetCell.h"

@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *timelineImageView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;

@property (strong, nonatomic) NSArray* tweets;

@end

@implementation ProfileViewController

- (void) loadData {
    [[TwitterClient sharedInstance] userTimelineForUser:self.user  completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tweetsTableView reloadData];
    }];
}

- (void) initNavigationBar {
    self.title = @"Profile";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithRed:100.0f/255.0f green:166.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationBar];
    
    self.tweetsTableView.delegate = self;
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.rowHeight = UITableViewAutomaticDimension;
    self.tweetsTableView.estimatedRowHeight = 100;
    
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    ProfileCell *headerView = [[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:self options:nil][0];
    [headerView setUser:self.user];
    self.tweetsTableView.tableHeaderView = headerView;
    /*
    [self.tweetsTableView registerNib:[UINib nibWithNibName:@"ProfileCell" bundle:nil] forCellReuseIdentifier:@"ProfileCell"];
     */
    [self loadData];
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell setTweet:self.tweets[indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end