//
//  JTAddWidget.h
//  JumpTapAPI
//
//  Copyright 2009 Jumptap, Inc. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class CLLocation;

#pragma mark -
#pragma mark AdultContent enum typedef declaration
typedef enum jtAdultContent {
	AdultContentAllowed,
	AdultContentNotAllowed,
	AdultContentOnly
} AdultContent;

#pragma mark -
#pragma mark Transitions enum typedef declaration
typedef enum jtTransitions {
	TransitionHorizontalSlide, // Note: Both TransitionHorizontalSlide and TransitionVerticalSlide
	TransitionVerticalSlide,   //       have been deprecated and are now just aliases for TransitionSlide
	
	TransitionCurl,
	TransitionFlip,
	TransitionSlide,
	TransitionDisolve,
	TransitionNone
} Transitions;



/*********************************************************************
 * Documentation for implementing the Jumptap ad library             *
 *  is available here:                                               *
 *  https://support.jumptap.com/index.php/IPhone_Library_Integration *
 *********************************************************************/

#pragma mark -
#pragma mark JTAdWidgetDelegate declaration
@protocol JTAdWidgetDelegate <NSObject>

#pragma mark Required methods
@required

/*!
 @method     publisherId:
 @abstract   Your "Publisher Id" as given to you by Jumptap
 */
- (NSString *) publisherId: (id) theWidget;

#pragma mark Optional methods
@optional


#pragma mark -Targeting
/*!
 @method     site:
 @abstract   "site" is optional and is used to specify additional applications (Jumptap provided)
 @discussion "site" is used if you have multiple applications. Site is 
             optional and is typically not provided if you only have one
             application. The site name is provided by Jumptap.
 
 @param theWidget The particular widget being interrogated
 */
- (NSString *) site: (id) theWidget;


/*!
 @method     adSpot:
 @abstract   "Ad Spot" is used to specify a specific page or section within the application (Jumptap provided)
 @discussion "Ad Spot" can be used to identify specific pages or sections within the
              application. The ad spot names are provided by Jumptap.
 
 @param theWidget The particular widget being interrogated
 */
- (NSString *) adSpot: (id) theWidget;


/*!
 @method     query:
 @abstract   "Query" is currently reserved for future use.
 
 @param theWidget The particular widget being interrogated
 */
- (NSString *) query: (id) theWidget;

// Which adult classification of ads can be returned
- (AdultContent) adultContent: (id) theWidget;

#pragma mark -General Configuration
/***
 * Any extra URL parameters (targeting parameters, etc) to be added to the request URL
 * These should be in name=value format separated by an ampersand (&). Do not URL encode.
 *
 * Supported parameters and values are:
 *		mt-age		- user's age in years, integer, 1-199
 *		mt-gender	- user's gender, m or f
 *		mt-hhi		- user's household income range in thousands.
 *			For example, 030_040 represents an income between 30,000-40,000
 *			Possible values are:
 *				000_015, 015_020, 020_030, 030_040, 040_050, 
 *				050_075, 075_100, 100_125, 125_150, 150_OVER
 * For example, to send the equivalent of mt-gender=f&mt-age=25&mt-hhi=050_075
 * you would return the following:
 *
 *	return [NSMutableDictionary dictionaryWithObjectsAndKeys: @"f", @"mt-gender",  
 *															  @"25", @"mt-age", 
 *			                                                  @"050_075", @"mt-hhi", 
 *			                                                  nil, nil];
 ***/
- (NSDictionary*) extraParameters: (id) theWidget;

// If the ad being requested is an interstitial (most likely NO)
- (BOOL) isInterstitial: (id) theWidget;

// The color to use for the background of text ads
- (UIColor *) adBackgroundColor: (id) theWidget;

// the color to use for the foreground (text) of text ads
- (UIColor *) adForegroundColor: (id) theWidget;

#pragma mark -Location Configuration
// Provide the library with access to a CLLocation if already available
- (CLLocation*) location: (id) theWidget;


#pragma mark -Ad Display and User Interaction
// The ad is ready
- (BOOL) shouldRenderAd: (id) theWidget;

// Implementing client has prepared for the call, RUNS IN A NON-UI THREAD
- (BOOL) shouldDialNumberWithURL: (NSURL*) url;

// User has clicked the ad and entered the creative
- (void) beginAdInteraction: (id) theWidget;

// User has returned from the creative
- (void) endAdInteraction: (id) theWidget;

- (void) beginDisplayingInterstitial: (id) theWidget;
- (void) endDisplayingInterstitial: (id) theWidget;

// The ad orientation changed
- (void) adWidget: (id) theWidget orientationHasChangedTo: (UIInterfaceOrientation) interfaceOrientation;

// Language methods
- (NSString*) getPlayVideoPrompt:(id) theWidget;
- (NSString*) getBackButtonPrompt:(id) theWidget isInterstitial:(BOOL)isInterstitial;
- (NSString*) getSafariButtonPrompt:(id) theWidget;
- (NSString*) getAdvertisementTitle:(id) theWidget;

#pragma mark -Error Handling
// Error when trying to show the ad
- (void) adWidget: (id) theWidget didFailToShowAd: (NSError *) error;

// Error when trying to request the ad.
- (void) adWidget: (id) theWidget didFailToRequestAd: (NSError *) error;

// Return a specific view controller for use in displaying ad overlays
// If this method is not implemented or returns nil, the SDK will attempt
// to locate the current UIViewController.  If you are experiencing odd
// overlay display issues, you may want implement this method and provide
// the UIViewController responsible for the UIView that the JTAdWidget is
// contained in.
- (UIViewController*)adViewController:(id)theWidget;

@end


#pragma mark -
#pragma mark JTAdWidget declaration
@interface JTAdWidget : UIView

@property (assign) BOOL                 autorotate;
@property (assign) Transitions          transition;
@property (assign) int                  refreshInterval;

+ (NSString*) version;
+ (void) initializeAdService:(BOOL)allowLocationUse;
+ (void) enableLocationUse;

- (id) initWithDelegate: (id<JTAdWidgetDelegate>) theDelegate shouldStartLoading: (BOOL) shouldStart;
- (void) setDelegate: (id<JTAdWidgetDelegate>) theDelegate;
- (void) renderAd;
- (void) refreshAd;
@end
