//
//  GSLeaderboardAdView.h
//  GreystripeSDK
//
//  Created by Justine DiPrete on 11/11/11.
//  Copyright (c) 2011 Greystripe. All rights reserved.
//

#import "GSBannerAdView.h"

extern const CGFloat kGSLeaderboardWidth;
extern const CGFloat kGSLeaderboardHeight;
extern NSString * const kGSLeaderboardParameter;

/**
 * A subclass of the GSBannerAdView that can be used to fetch and display 
 * Leaderboard ads. 
 *
 * This conforms to the GSAd protocol.
 */
@interface GSLeaderboardAdView : GSBannerAdView

@end
