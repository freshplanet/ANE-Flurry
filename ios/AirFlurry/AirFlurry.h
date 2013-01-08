//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//  
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//  
//    http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//  
//////////////////////////////////////////////////////////////////////////////////////

#import "FlashRuntimeExtensions.h"
#import "FlurryAds.h"
#import "FlurryAdDelegate.h"


@interface AirFlurry : NSObject <FlurryAdDelegate>

+ (AirFlurry *)sharedInstance;

+ (void)log:(NSString *)message;

// Analytics
- (void)startSession:(NSString *)apiKey;

// Ads
- (BOOL)showAdForSpace:(NSString *)space size:(FlurryAdSize)size timeout:(int64_t)timeout;
- (void)fetchAdForSpace:(NSString *)space size:(FlurryAdSize)size;
- (void)removeAdFromSpace:(NSString *)space;
- (void)addUserCookieWithValue:(NSString *)value forKey:(NSString *)key;
- (void)clearUserCookies;
- (void)addTargetingKeywordWithValue:(NSString *)value forKey:(NSString *)key;
- (void)clearTargetingKeywords;

@end


// C interface - Analytics
DEFINE_ANE_FUNCTION(setAppVersion);
DEFINE_ANE_FUNCTION(logEvent);
DEFINE_ANE_FUNCTION(logError);
DEFINE_ANE_FUNCTION(setUserId);
DEFINE_ANE_FUNCTION(setUserInfo);
DEFINE_ANE_FUNCTION(setSendEventsOnPause);
DEFINE_ANE_FUNCTION(startTimedEvent);
DEFINE_ANE_FUNCTION(stopTimedEvent);
DEFINE_ANE_FUNCTION(startSession);
DEFINE_ANE_FUNCTION(stopSession);


// C interface - Ads
DEFINE_ANE_FUNCTION(showAd);
DEFINE_ANE_FUNCTION(fetchAd);
DEFINE_ANE_FUNCTION(removeAd);
DEFINE_ANE_FUNCTION(addUserCookie);
DEFINE_ANE_FUNCTION(clearUserCookies);
DEFINE_ANE_FUNCTION(addTargetingKeyword);
DEFINE_ANE_FUNCTION(clearTargetingKeywords);


// ANE setup
void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                 uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFlurryContextFinalizer(FREContext ctx);
void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );
void AirFlurryFinalizer(void *extData);