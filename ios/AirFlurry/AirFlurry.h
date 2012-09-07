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
#import "FlurryAdDelegate.h"


@interface AirFlurry : NSObject <FlurryAdDelegate>

@property (strong, nonatomic) NSString *adMobPublisherID;
@property (strong, nonatomic) NSString *greystripeApplicationID;
@property (strong, nonatomic) NSString *inMobiAppKey;
@property (strong, nonatomic) NSString *jumptapApplicationID;
@property (strong, nonatomic) NSString *millenialAppKey;
@property (strong, nonatomic) NSString *millenialInterstitialAppKey;
@property (strong, nonatomic) NSString *mobclixApplicationID;

+ (AirFlurry *)sharedInstance;

- (void)addUserCookieWithValue:(NSString *)value forKey:(NSString *)key;
- (void)clearUserCookies;

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
DEFINE_ANE_FUNCTION(removeAd);
DEFINE_ANE_FUNCTION(addUserCookie);
DEFINE_ANE_FUNCTION(clearUserCookies);


// ANE setup
void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                 uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);
void AirFlurryContextFinalizer(FREContext ctx);
void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );