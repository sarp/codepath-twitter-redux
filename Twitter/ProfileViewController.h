//
//  ProfileViewController.h
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) User *user;
@end
