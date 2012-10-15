//
//  JumpTapAppReport.h
//  TestApp
//
//  Created by James Maki on 8/27/09.
//  Copyright 2009 JumpTap Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JT_INSTALL_FLAG_KEY @"JTAppInstall"
#define JT_INSTALL_DATE_KEY @"JTAppInstallDate"

@interface JumpTapAppReport : NSObject

/***
 * Controls if application useage is submitted after the initial install report (default is NO)
 ***/
+ (void) reportApplicationUsage: (BOOL) submitApplicationUsage;

/***
 * Controls if logging useful for debugging is turned on (default is NO)
 ***/
+ (void) loggingEnabled: (BOOL) enabled;

/***
 * Handles application launch URLs to see if previous reports were successfull
 ***/
+ (void) handleApplicationLaunchUrl: (NSURL*) url;

/***
 * Submits the report of the application install (and/or application useage).  This method determines
 * the what custom scheme your application is registered with (if any) by looking at
 * [[[[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"] objectAtIndex: 0] 
 *    objectForKey: @"CFBundleURLSchemes"] objectAtIndex: 0]
 *
 * If this value exists, it is then used to create the URL <SCHEME>://autodetected
 * If this value does not exist, appUrl is set to nil
 *
 * After detecting the scheme and building the URL (if a custom scheme is supported) this method delegates
 * functionality to [JumpTapAppReport submitReportWithExtraInfo:withAppUrl:]
 ***/
+ (void) submitReportWithExtraInfo: (NSDictionary*) info;

/***
 * Submits the report of the application install (and/or application useage) using the specified application
 * URL.  A URL fragment (jtsuccess=true) is appended to appUrl before redirecting through Safari which
 * will later be looked for in [JumpTapAppReport handleApplicationLaunchUrl:]
 *
 * If appUrl is nil then no requests will be proxied through Safari
 ***/
+ (void) submitReportWithExtraInfo: (NSDictionary*) info withAppUrl: (NSString*) appUrl;

/***
 * Sets the base url for reporting purposes.  The default is http://a.jumptap.com/a
 *
 ***/
+ (void) setReportingUrl:(NSString*)toSet;

+ (NSString *) constructIDFAForConversion;
+ (NSString *)sha1DigestToString:(unsigned char*)messageDigest;
+ (NSString *) checkTrackingEnabledForConversion;
#ifndef NO_UDID
+ (NSString *) constructHashedDeviceIdForConversion;
#endif
@end
