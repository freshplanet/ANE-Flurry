//
//  GSFullscreenAd.h
//  GreystripeSDK
//
//  Created by Justine DiPrete on 11/10/11.
//  Copyright (c) 2011 Greystripe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GSAd.h"

#ifndef GS_PUBLIC
#ifndef _GSAdModel_h_included_
#define _GSAdModel_h_included_
@interface GSAdModel : NSObject <GSAd, UIWebViewDelegate>
@end
#endif
#else
#import "GSAdModel.h"
#endif

/**
 * A GSFullscreenAd can be used to fetch and display fullscreen ads. 
 *
 * This conforms to the GSAd protocol.
 */

@interface GSFullscreenAd : GSAdModel


/**
 * Initialize a GSFullscreenAd with a delegate. If this init is used, the
 * host app must implement the GUID method.
 *
 * @param a_delegate The delegate that will receive all ad notification messages.
 */
- (id)initWithDelegate:(id<GSAdDelegate>)a_delegate;

/**
 * Initialize a GSFullscreenAd with a delegate and a GUID. If the host app does
 * not implement the GUID method, this is the init method that needs to be called.
 * Otherwise an exception will be raised.
 *
 * @param a_delegate The delegate that will receive all ad notification messages.
 * @param a_GUID The global unique identifier for the application.
 */
- (id)initWithDelegate:(id<GSAdDelegate>)a_delegate GUID:(NSString *)a_GUID;

/**
 * Tells the shared GSFullscreenAdViewController to display the ad from the 
 * given view controller. This should be the view controller that is currently
 * displaying.
 *
 * @param a_viewController the view controller that the ad should be displayed from.
 */
- (BOOL)displayFromViewController:(UIViewController *)a_viewController;

@end