//
//  GSConstants.h
//  SDK
//
//  Created by Justine DiPrete on 1/13/12.
//  Copyright (c) 2012 Greystripe. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The current version of the SDK.
 */
extern NSString * const kGSSDKVersion;

/**
 * Constants for the SDK.
 */
@interface GSConstants : NSObject

/**
 * The hashed identifier of the device that is currently running the SDK.
 */
+ (NSString *)hashedDeviceId;

/**
 * This is a convenience method to set the global unique identifier for the application.
 * This method should be called before any view controller containing a GSBannerAd is
 * initialized if the delegate does not implement the greystripeGUID method. This can 
 * only be set once. All subsequent attempts to set the GUID will be ignored. 
 */
+ (void)setGUID:(NSString *)a_GUID;

@end
