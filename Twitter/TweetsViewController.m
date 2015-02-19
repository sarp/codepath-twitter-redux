//
//  TweetsViewController.m
//  Twitter
//
//  Created by Sarp Centel on 2/18/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "TweetsViewController.h"
#import "ComposeTweetController.h"
#import "TweetDetailsController.h"
#import "User.h"
#import "Tweet.h"
#import "TweetCell.h"
#import "TwitterClient.h"

// TODO: Add delegate to listen to tweet event

@interface TweetsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *tweets;
@property (strong, nonatomic) TweetCell *currentCell;

- (IBAction)onLogout:(id)sender;
@end

// TODO: Pull to refresh

@implementation TweetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 150.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"TweetCell" bundle:nil] forCellReuseIdentifier:@"TweetCell"];
    
    self.title = @"Home";
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    
    navBar.tintColor = [UIColor whiteColor];
    navBar.barTintColor = [UIColor colorWithRed:100.0f/255.0f green:166.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStylePlain target:self action:@selector(onNewTweet)];
    
    // Do any additional setup after loading the view from its nib.
    
    [[TwitterClient sharedInstance] homeTimelineWithParams:nil completion:^(NSArray *tweets, NSError *error) {
        self.tweets = tweets;
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    [cell setTweet:self.tweets[indexPath.row]];
    
    self.currentCell = cell;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[TweetDetailsController alloc] initWithTweet:self.tweets[indexPath.row]] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onNewTweet {
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:[[ComposeTweetController alloc] init]];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onLogout:(id)sender {
    [[User currentUser] logout];
}
@end
