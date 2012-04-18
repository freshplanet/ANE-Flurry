//
//  AirFlurry.h
//  AirFlurry
//
//  Created by Thibaut Crenn on 4/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"
#import "FlurryAnalytics.h"

@interface AirFlurry : NSObject

@end

FREObject setAppVersion(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject logEvent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject logError(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject setUserId(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject setUserInfo(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject setSendEventsOnPause(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject startTimedEvent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject stopTimedEvent(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject startSession(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);
FREObject stopSession(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]);



void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                 uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet);

void AirFlurryContextFinalizer(FREContext ctx);
void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet );