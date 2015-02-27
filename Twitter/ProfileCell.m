//
//  ProfileCell.m
//  Twitter
//
//  Created by Sarp Centel on 2/26/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "ProfileCell.h"
#import "UIImageView+AFNetworking.h"

@implementation ProfileCell

- (void)awakeFromNib {
    self.profileImage.layer.cornerRadius = 3;
    self.profileImage.clipsToBounds = YES;
    self.fullName.preferredMaxLayoutWidth = self.fullName.frame.size.width;
}

- (void) setUser:(User*) user {
    [self.backgroundImage setImageWithURL:user.bannerUrl == nil ? user.profileBackgroundImageUrl : user.bannerUrl];
    [self.profileImage setImageWithURL:user.profileImageUrl];

    self.fullName.text = user.name;
    self.screenName.text = [NSString stringWithFormat:@"@%@", user.screenname];
    NSLog(@"tweet: %@ follower: %@ following: %@", user.tweetCount, user.followerCount, user.followingCount);
    self.tweetCountLabel.text = [self countify:user.tweetCount];
    self.followerCountLabel.text = [self countify:user.followerCount];
    self.followingCountLabel.text = [self countify:user.followingCount];
}

- (NSString*) countify: (NSString*) original {
    NSInteger count = [original integerValue];
    if (count >= 1E6) {
        return [NSString stringWithFormat:@"%.1fM", count / 1E6];
    } else if (count >= 1E4) {
        return [NSString stringWithFormat:@"%.1fK", (double)count / 1E3];
    } else if (count >= 1E3) {
        return [NSString stringWithFormat:@"%ld,%03ld", count / 1000, count % 1000];
    } else {
        return original;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end