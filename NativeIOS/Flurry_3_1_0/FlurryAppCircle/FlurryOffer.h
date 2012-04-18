//
//  FlurryOffer.h
//  Flurry iPhone Analytics Agent
//
//  Copyright 2010 Flurry, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlurryOffer : NSObject {
	NSString* appDisplayName;
	UIImage* appIcon;
	NSString* referralUrl;
	NSNumber* appPrice;
	NSString* appDescription;
}

@property (retain) NSString* appDisplayName;
@property (retain) UIImage* appIcon;
@property (retain) NSString* referralUrl;
@property (retain) NSNumber* appPrice;
@property (retain) NSString* appDescription;

@end

