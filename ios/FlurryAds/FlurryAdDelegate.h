//
//  FlurryAdDelegate.h
//  FlurryAnalytics
//
//  Copyright 2010 - 2012 Flurry, Inc. All rights reserved.
//
//  Methods in this header file are for use with Flurry
//

#import <UIKit/UIKit.h>

typedef enum {
    WEB_BANNER = 1,
    WEB_TAKEOVER = 2,
    VIDEO_TAKEOVER = 3,
    AD_BANNER = 4,
    AD_TAKEOVER = 5,
    NETWORK_BANNER = 6,
    NETWORK_TAKEOVER = 7
} FlurryAdType;

/*!
 *  @brief Provides all available delegates for receiving callbacks related to Ad Serving.
 *  
 *  Set of methods that allow developers to manage and take actions within
 *  different phases of App ad display.
 *  
 *  @note This class serves as a delegate for FlurryAds. \n
 *  For additional information on how to use Flurry's Ads SDK to
 *  attract high-quality users and monetize your user base see <a href="http://wiki.flurry.com/index.php?title=AppCircle">Support Center - AppCircle</a>.
 *  @author 2010 - 2012 Flurry, Inc. All Rights Reserved.
 *  @version 4.0.0
 * 
 */
@protocol FlurryAdDelegate <NSObject>

@optional

/*!
 *  @brief Invoked when an ad is loaded on the specified @c adSpace.
 *  @since 4.0.0
 * 
 *  This method informs the app that an ad has been loaded for display. You can decide at this point not to show this ad by simply returning NO.
 *
 *  @see FlurryAds#showAdForSpace:view:size:timeout: for details on the method that will invoke this delegate.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 *  @param adType The type of ad to be displayed. See @c FlurryAdType in the FlurryAdDelegate.h file for allowable values.
 */
- (BOOL) spaceShouldDisplay:(NSString*)adSpace forType:(FlurryAdType)adType;

/*!
 *  @brief Invoked when an ad will display on the specified @c adSpace.
 *  @since 4.1
 * 
 *  This method informs the app that an ad will display to the user. You can use this to pause app states. You can also decide not to show this ad by simply returning NO.
 *
 *  @see FlurryAds#showAdForSpace:view:size:timeout: for details on the method that will invoke this delegate.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 *  @param adType The type of ad to be displayed. See @c FlurryAdType in the FlurryAdDelegate.h file for allowable values.
 */
- (void) spaceWillDisplay:(NSString*)adSpace forType:(FlurryAdType)adType;

/*!
 *  @brief Invoked when the ad will be removed.
 *  @since 4.1
 * 
 *  This method informs the app that an ad will be removed. 
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void)spaceWillDismiss:(NSString *)adSpace;

/*!
 *  @brief Invoked when the ad has been removed.
 *  @since 4.0.0
 * 
 *  This method informs the app that an ad has closed. You can use this to resume app
 *  states.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void)spaceDidDismiss:(NSString *)adSpace;

/*!
 *  @brief Invoked when the ad has been selected that will take the user out of the app.
 *  @since 4.0.0
 * 
 *  This method informs the app that an ad has been clicked and the user is about to be taken outside the app.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void)spaceWillLeaveApplication:(NSString *)adSpace;

/*!
 *  @brief Invoked when a user completes an action locally that results in a revenue bearing transaction.
 *  @since 4.0.0
 * 
 *  This method informs the user has completed a revenue bearing action.
 *
 *  @note This is only called for local methods (like video views) and is not called on the completion of an app install/launch.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 *  @param userCookies Passes additional information that can be used to identify the user.
 */
- (void)spaceDidReward:(NSString *)adSpace userCookies:(NSDictionary *)userCookies;

/*!
 *  @brief Invoked when an ad fails to render.
 *  @since 4.0.0
 * 
 *  This method informs the user an ad was retrieved, however, was unsuccessful in displaying to the user (could be lost network connectivity for example).
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void) spaceDidFailToRender:(NSString *)space;

/*!
 *  @brief Invoked when a space will be expanded.
 *  @since 4.1
 * 
 *  This method informs the app an ad space (typcially a banner) will be expanded. Apps should pause their state when they receive this notification
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void) spaceWillExpand:(NSString *)adSpace;

/*!
 *  @brief Invoked when a space will be collapsed.
 *  @since 4.1
 * 
 *  This method informs the app an ad space (typcially a banner) will be collapsed.
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
- (void) spaceWillCollapse:(NSString *)adSpace;

/*!
 *  @brief Invoked when a space has been collapsed.
 *  @since 4.1
 * 
 *  This method informs the app an ad space (typcially a banner) has been collapsed. Apps should resume their state when they receive this notification
 *
 *  @param adSpace The placement of an ad in your app, where placement may
 *  be splash screen for SPLASH_AD.
 */
 - (void) spaceDidCollapse:(NSString *)adSpace;

@optional

#pragma mark App Keys
/** @name Third party network Calls
 *  Optional calls to pass information needed to display ads through 3rd parties. 
 */
//@{

/*!
 *  @brief The Millennial APID.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in Millennial, found here: https://developer.millennialmedia.com/Application/index.php#manageApps.
 */
- (NSString *)appSpotMillennialAppKey; //your millennial APID, found here: https://developer.millennialmedia.com/Application/index.php#manageApps

/*!
 *  @brief The Millennial APID for interstitials.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in Millennial, found here: https://developer.millennialmedia.com/Application/index.php#manageApps.
 */
- (NSString *)appSpotMillennialInterstitalAppKey;

/*!
 *  @brief The InMobi APID.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in InMobi, found here: https://www.inmobi.com/pub/mysite.html?platFormType=all
 */
- (NSString *)appSpotInMobiAppKey;

/*!
 *  @brief The AdMob Publisher Id.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in AdMob, found here: http://www.admob.com/my_sites/ (click manage settings)
 */
- (NSString *)appSpotAdMobPublisherID;

/*!
 *  @brief The Mobclix Application Id.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in Mobclix 
 */
- (NSString *)appSpotMobclixApplicationID; 

/*!
 *  @brief The Jumptap Application Id.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in Jumptap 
 */
- (NSString *)appSpotJumptapApplicationID;

/*!
 *  @brief The Greystripe Application Id.
 *  @since 4.0.0
 * 
 *  This is the id for your app as set in Greystripe 
 */
- (NSString *)appSpotGreystripeApplicationID;


#pragma mark Information


#pragma mark Callbacks

/*!
 *  @brief [Deprecated] Allow you to set your rootViewController.
 *  @since 4.0.0
 *  @deprecated
 * 
 *  This method has been deprecated.  Please call FlurryAds#initialze: instead.
 *
 */
- (id)appSpotRootViewController;

#pragma mark Optional settings

/**
 Some networks support accelerometer-enabled ads.  
 */
/*!
 *  @brief For networks that support accelerometer-enabled ads.
 *  @since 4.0.0
 * 
 *  This method allows you to enable accelerometer based ads for networks that support this setting via the client sdk. Set to NO if your app uses the accelerometer
 to avoid conflict. Set to YES if you want the special ads. Default is NO.
 */
- (BOOL)appSpotAccelerometerEnabled;

//@}

@end
