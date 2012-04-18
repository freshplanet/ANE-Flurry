//
//  FlurryAdDelegate.h
//  FlurryAnalytics
//
//  Created by chunhao on 3/2/10.
//  Copyright 2010 Flurry Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol FlurryAdDelegate <NSObject>

@optional
/* 
 called after data is received
 */
- (void)dataAvailable;

/*
 called after data is determined to be unavailable
 */
- (void)dataUnavailable;

/*
 called when video data is available
 */
- (void)videoAvailable;

/*
 called when video data is available
 */
- (void)videoUnavailable;

/*
 called before canvas displays
 code to pause app states can be set here
 */
- (void)canvasWillDisplay:(NSString *)hook;

/*
 called before canvas closes
 code to resume app states can be set here
 */
- (void)canvasWillClose;

/*
 called before takeover displays
 code to pause app states can be set here
 */
- (void)takeoverWillDisplay:(NSString *)hook;

/*
 called before takeover closes
 code to resume app states can be set here
 */
- (void)takeoverWillClose;

/*
 called after video did not finish (did not complete)
 */
- (void)videoDidNotFinish:(NSString *)hook;

/*
 called after video finished (completed). pass user cookies with reward info if completion is rewarded.
 */
- (void)videoDidFinish:(NSString*)hook withUserCookies:(NSDictionary*)userCookies; 

/*
 called when an app is successfully launched. 
 */
- (void) appLaunched:(NSString *)hook
         userCookies:(NSDictionary*) userCookies;


/*
 called when an ad banner is fully expanded.
 */
- (void) bannerExpanded:(NSString *)hook;


/*
 called when an ad banner is fully collapsed.
 */
- (void) bannerCollapsed:(NSString *)hook;

/*
 called when an ad banner is hidden, in the event where there are no more ads to show.
 */
- (void) bannerHidden:(NSString *)hook;


@end
