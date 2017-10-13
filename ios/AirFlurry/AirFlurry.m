/*
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AirFlurry.h"
#import "Constants.h"

@interface AirFlurry ()
    @property (nonatomic, readonly) FREContext context;
@end


@implementation AirFlurry


- (instancetype)initWithContext:(FREContext)extensionContext {
    
    if ((self = [super init])) {
        
        _context = extensionContext;
    }
    
    return self;
}


-(void)flurrySessionDidCreateWithInfo:(NSDictionary *)info {

    [self sendEvent:kAirFlurryEvent_SESSION_STARTED];
}


#pragma mark - Other

- (void) sendLog:(NSString*)log {
    [self sendEvent:@"log" level:log];
}

- (void) sendEvent:(NSString*)code {
    [self sendEvent:code level:@""];
}

- (void) sendEvent:(NSString*)code level:(NSString*)level {
    FREDispatchStatusEventAsync(_context, (const uint8_t*)[code UTF8String], (const uint8_t*)[level UTF8String]);
}

@end

AirFlurry* GetAirFlurryContextNativeData(FREContext context) {
    
    CFTypeRef controller;
    FREGetContextNativeData(context, (void**)&controller);
    return (__bridge AirFlurry*)controller;
}

#pragma mark - C interface - Flurry setup

DEFINE_ANE_FUNCTION(initFlurry) {
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *apiKey = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        NSString *appVersion = AirFlurry_FPANE_FREObjectToNSString(argv[1]);
        NSInteger continueSessionInSeconds = (NSInteger) AirFlurry_FPANE_FREObjectToInt(argv[1]) / 1000; // value sent is in millis
        
        [Flurry setDelegate:controller];
        
        FlurrySessionBuilder* builder = [[[[[FlurrySessionBuilder new]
                                            withLogLevel:FlurryLogLevelAll]
                                           withCrashReporting:NO]
                                          withSessionContinueSeconds:continueSessionInSeconds]
                                         withAppVersion:appVersion];
        
        [Flurry startSession:apiKey withSessionBuilder:builder];
        
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to init Flurry : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}


DEFINE_ANE_FUNCTION(logEvent) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);

    @try {
        NSString *eventName = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        NSMutableDictionary *params = nil;
        if (argc > 1 && argv[1] != NULL && argv[2] != NULL && argv[1] != nil && argv[2] != NULL) {
            params = [[NSMutableDictionary alloc] init];
            NSArray *arrayKeys = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[1]);
            NSArray *arrayValues = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[2]);
            int i;
            for (i = 0; i < [arrayKeys count]; i++) {
                NSString *key = [arrayKeys objectAtIndex:i];
                NSString *value = [arrayValues objectAtIndex:i];
                [params setValue:value forKey:key];
            }
        }
        
        if (params != nil && params.count > 0) {
            [Flurry logEvent:eventName withParameters:params];
        }
        else {
            [Flurry logEvent:eventName];
        }

    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to logEvent : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(logError) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *errorId = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        NSString *message = AirFlurry_FPANE_FREObjectToNSString(argv[1]);
        
        [Flurry logError:errorId message:message error:nil];
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to logError : " stringByAppendingString:exception.reason]];
    }

    
    return nil;
}

DEFINE_ANE_FUNCTION(setLocation) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        
        double latitude = AirFlurry_FPANE_FREObjectToDouble(argv[0]);
        double longitude = AirFlurry_FPANE_FREObjectToDouble(argv[1]);
        float horizontalAccuracy = (float) AirFlurry_FPANE_FREObjectToDouble(argv[2]);
        float verticalAccuracy = (float) AirFlurry_FPANE_FREObjectToDouble(argv[3]);
        [Flurry setLatitude:latitude
                  longitude:longitude
         horizontalAccuracy:horizontalAccuracy
           verticalAccuracy:verticalAccuracy];
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setLocation : " stringByAppendingString:exception.reason]];
    }
    
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserId) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *userId = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        [Flurry setUserID:userId];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setUserId : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserAge) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSInteger userAge = AirFlurry_FPANE_FREObjectToInt(argv[0]);
        [Flurry setAge: (int) userAge];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setUserAge : " stringByAppendingString:exception.reason]];
    }
    
    
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserGender) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *userGender = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        [Flurry setGender:userGender];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setUserGender : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setSessionReportsOnCloseEnabled) {
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        BOOL enabled = AirFlurry_FPANE_FREObjectToBool(argv[0]);
        [Flurry setSessionReportsOnCloseEnabled:enabled];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setSessionReportsOnCloseEnabled : " stringByAppendingString:exception.reason]];
    }
  
    return nil;
}

DEFINE_ANE_FUNCTION(setSessionReportsOnPauseEnabled) {
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        BOOL enabled = AirFlurry_FPANE_FREObjectToBool(argv[0]);
        [Flurry setSessionReportsOnPauseEnabled:enabled];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setSessionReportsOnPauseEnabled : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setBackgroundSessionEnabled) {
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        BOOL enabled = AirFlurry_FPANE_FREObjectToBool(argv[0]);
        [Flurry setBackgroundSessionEnabled:enabled];
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to setBackgroundSessionEnabled : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(pauseBackgroundSession) {
    [Flurry pauseBackgroundSession];
    return nil;
}

DEFINE_ANE_FUNCTION(logPageView) {
    [Flurry logPageView];
    return nil;
}

DEFINE_ANE_FUNCTION(startTimedEvent) {
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *eventName = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        NSMutableDictionary *params = nil;
        if (argc > 1 && argv[1] != NULL && argv[2] != NULL && argv[1] != nil && argv[2] != NULL) {
            params = [[NSMutableDictionary alloc] init];
            NSArray *arrayKeys = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[1]);
            NSArray *arrayValues = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[2]);
            int i;
            for (i = 0; i < [arrayKeys count]; i++) {
                NSString *key = [arrayKeys objectAtIndex:i];
                NSString *value = [arrayValues objectAtIndex:i];
                [params setValue:value forKey:key];
            }
        }
        
        if (params != nil && params.count > 0) {
            [Flurry logEvent:eventName withParameters:params timed:YES];
        }
        else {
            [Flurry logEvent:eventName timed:YES];
        }
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to startTimedEvent : " stringByAppendingString:exception.reason]];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(stopTimedEvent) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        NSString *eventName = AirFlurry_FPANE_FREObjectToNSString(argv[0]);
        NSMutableDictionary *params = nil;
        if (argc > 1 && argv[1] != NULL && argv[2] != NULL && argv[1] != nil && argv[2] != NULL){
            params = [[NSMutableDictionary alloc] init];
            NSArray *arrayKeys = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[1]);
            NSArray *arrayValues = AirFlurry_FPANE_FREObjectToNSArrayOfNSString(argv[2]);
            int i;
            for (i = 0; i < [arrayKeys count]; i++) {
                NSString *key = [arrayKeys objectAtIndex:i];
                NSString *value = [arrayValues objectAtIndex:i];
                [params setValue:value forKey:key];
            }
        }
        
        if (params != nil && params.count > 0){
             [Flurry endTimedEvent:eventName withParameters:params];
        }
        else{
            [Flurry endTimedEvent:eventName withParameters:nil];
        }
        
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to stopTimedEvent : " stringByAppendingString:exception.reason]];
    }

   
    return NULL;
}

DEFINE_ANE_FUNCTION(isSessionOpen) {
    
    AirFlurry* controller = GetAirFlurryContextNativeData(context);
    
    if (!controller)
        return AirFlurry_FPANE_CreateError(@"context's AirFlurry is null", 0);
    
    @try {
        return AirFlurry_FPANE_BOOLToFREObject([Flurry activeSessionExists]);
    }
    @catch (NSException *exception) {
        [controller sendLog:[@"Exception occured while trying to check for open session : " stringByAppendingString:exception.reason]];
    }
    
    
    return AirFlurry_FPANE_BOOLToFREObject(NO);
}

#pragma mark - ANE setup

void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {

    AirFlurry* controller = [[AirFlurry alloc] initWithContext:ctx];
    FRESetContextNativeData(ctx, (void*)CFBridgingRetain(controller));
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(initFlurry, NULL),
        MAP_FUNCTION(logEvent, NULL),
        MAP_FUNCTION(logError, NULL),
        MAP_FUNCTION(setLocation, NULL),
        MAP_FUNCTION(setUserId, NULL),
        MAP_FUNCTION(setUserAge, NULL),
        MAP_FUNCTION(setUserGender, NULL),
        MAP_FUNCTION(startTimedEvent, NULL),
        MAP_FUNCTION(stopTimedEvent, NULL),
        MAP_FUNCTION(setSessionReportsOnCloseEnabled, NULL),
        MAP_FUNCTION(setSessionReportsOnPauseEnabled, NULL),
        MAP_FUNCTION(setBackgroundSessionEnabled, NULL),
        MAP_FUNCTION(pauseBackgroundSession, NULL),
        MAP_FUNCTION(logPageView, NULL),
        MAP_FUNCTION(isSessionOpen, NULL),
    };
    
    *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;

}

void AirFlurryContextFinalizer(FREContext ctx) {
    CFTypeRef controller;
    FREGetContextNativeData(ctx, (void **)&controller);
    CFBridgingRelease(controller);
}

void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) {
    *extDataToSet = NULL;
    *ctxInitializerToSet = &AirFlurryContextInitializer;
    *ctxFinalizerToSet = &AirFlurryContextFinalizer;
}

void AirFlurryFinalizer(void *extData) {}
