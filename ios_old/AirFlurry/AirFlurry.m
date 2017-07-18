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

#import "AirFlurry.h"
#import "Flurry.h"

FREContext AirFlurryCtx = nil;


@implementation AirFlurry


#pragma mark - Singleton

static id sharedInstance = nil;

+ (AirFlurry *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}

- (id)copy
{
    return self;
}


#pragma mark - Analytics

- (void)startSession:(NSString *)apiKey
{    
    [Flurry setDebugLogEnabled:NO];
    [Flurry startSession:apiKey];
}


#pragma mark - Other

+ (void)log:(NSString *)message
{
    FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"LOGGING", (const uint8_t *)[message UTF8String]);
}

@end


#pragma mark - C interface - Flurry setup

DEFINE_ANE_FUNCTION(startSession)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *apiKey = [NSString stringWithUTF8String:(char*)value];
        [[AirFlurry sharedInstance] startSession:apiKey];
    }
    return nil;
}

DEFINE_ANE_FUNCTION(stopSession)
{
    // Doesn't do anything on iOS.
    return nil;
}


#pragma mark - C interface - Analytics

DEFINE_ANE_FUNCTION(setAppVersion)
{
    uint32_t stringLength = 0;
    
    const uint8_t *value = NULL;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *versionName = [NSString stringWithUTF8String:(char*)value];
        [Flurry setAppVersion:versionName];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(logEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) != FRE_OK)
    {
        return nil;
    }
    NSString *eventName = [NSString stringWithUTF8String:(char*)value];
    
    NSMutableDictionary *params;
    if (argc > 1 && argv[1] != NULL && argv[2] != NULL && argv[1] != nil && argv[2] != NULL)
    {
        FREObject arrKey = argv[1]; // array
        uint32_t arr_len = 0; // array length
        
        FREObject arrValue = argv[2]; // array
        
        if (arrKey != nil)
        {
            if (FREGetArrayLength(arrKey, &arr_len) != FRE_OK)
            {
                arr_len = 0;
            }
            
            params = [[NSMutableDictionary alloc] init];
            
            for (int32_t i = arr_len-1; i >= 0; i--)
            {
                // get an element at index
                FREObject key;
                if (FREGetArrayElementAt(arrKey, i, &key) != FRE_OK)
                {
                    continue;
                }
                
                FREObject value;
                if (FREGetArrayElementAt(arrValue, i, &value) != FRE_OK)
                {
                    continue;
                }
                
                // convert it to NSString
                uint32_t stringLength;
                const uint8_t *keyString;
                if (FREGetObjectAsUTF8(key, &stringLength, &keyString) != FRE_OK)
                {
                    continue;
                }
                
                const uint8_t *valueString;
                if (FREGetObjectAsUTF8(value, &stringLength, &valueString) != FRE_OK)
                {
                    continue;
                }
                
                [params setValue:[NSString stringWithUTF8String:(char*)valueString] forKey:[NSString stringWithUTF8String:(char*)keyString]];
            }
        }
    }
    
    if (params != nil && params.count > 0)
    {
        [Flurry logEvent:eventName withParameters:params];
    }
    else
    {
        [Flurry logEvent:eventName];
    }
 
    return nil;
}

DEFINE_ANE_FUNCTION(logError)
{
    uint32_t stringLength;
    
    const uint8_t *valueId;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &valueId) != FRE_OK)
    {
        return nil;
    }
    NSString *errorId = [NSString stringWithUTF8String:(char*)valueId];
    
    const uint8_t *valueMessage;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueMessage) != FRE_OK)
    {
        return nil;
    }
    NSString *message = [NSString stringWithUTF8String:(char*)valueMessage];
    
    [Flurry logError:errorId message:message error:nil];
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserId)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *userId = [NSString stringWithUTF8String:(char*)value];
        [Flurry setUserID:userId];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(setUserInfo)
{
    int32_t age = 0;
    if (FREGetObjectAsInt32(argv[0], &age) == FRE_OK)
    {
        [Flurry setAge:age];
    }

    uint32_t stringLength = 0;
    
    const uint8_t *value = NULL;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &value ) == FRE_OK)
    {
        NSString *gender = [NSString stringWithUTF8String:(char*)value];
        [Flurry setGender:gender];
        
    }
   
    return nil;
}

DEFINE_ANE_FUNCTION(setSendEventsOnPause)
{
    uint32_t onPause = NO;
    if (FREGetObjectAsBool(argv[0], &onPause) == FRE_OK)
    {
        [Flurry setSessionReportsOnPauseEnabled:onPause];
        [Flurry setSessionReportsOnCloseEnabled:!onPause];
    }
  
    return nil;
}

DEFINE_ANE_FUNCTION(startTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *eventName = [NSString stringWithUTF8String:(char*)value];
        [Flurry logEvent:eventName timed:YES];
    }

    return nil;
}

DEFINE_ANE_FUNCTION(stopTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &value) == FRE_OK)
    {
        NSString *eventName = [NSString stringWithUTF8String:(char*)value];
        [Flurry endTimedEvent:eventName withParameters:nil];
    }

    return NULL;
}

DEFINE_ANE_FUNCTION(setCrashReportingEnabled)
{
    uint32_t enabled = NO;
    if (FREGetObjectAsBool(argv[0], &enabled) == FRE_OK)
    {
        [Flurry setCrashReportingEnabled:enabled];
    }
    
    return nil;
}


#pragma mark - ANE setup

void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 11;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    // Session
    
    func[0].name = (const uint8_t*) "startSession";
    func[0].functionData = NULL;
    func[0].function = &startSession;
    
    func[1].name = (const uint8_t*) "stopSession";
    func[1].functionData = NULL;
    func[1].function = &stopSession;
    
    
    // Analytics
    
    func[2].name = (const uint8_t*) "setAppVersion";
    func[2].functionData = NULL;
    func[2].function = &setAppVersion;
    
    func[3].name = (const uint8_t*) "logEvent";
    func[3].functionData = NULL;
    func[3].function = &logEvent;
    
    func[4].name = (const uint8_t*) "logError";
    func[4].functionData = NULL;
    func[4].function = &logError;
    
    func[5].name = (const uint8_t*) "setUserId";
    func[5].functionData = NULL;
    func[5].function = &setUserId;

    func[6].name = (const uint8_t*) "setUserInfo";
    func[6].functionData = NULL;
    func[6].function = &setUserInfo;

    func[7].name = (const uint8_t*) "setSendEventsOnPause";
    func[7].functionData = NULL;
    func[7].function = &setSendEventsOnPause;

    func[8].name = (const uint8_t*) "startTimedEvent";
    func[8].functionData = NULL;
    func[8].function = &startTimedEvent;

    func[9].name = (const uint8_t*) "stopTimedEvent";
    func[9].functionData = NULL;
    func[9].function = &stopTimedEvent;
    
    func[10].name = (const uint8_t*) "setCrashReportingEnabled";
    func[10].functionData = NULL;
    func[10].function = &setCrashReportingEnabled;
    

    AirFlurryCtx = ctx;
    
    *functionsToSet = func;
}

void AirFlurryContextFinalizer(FREContext ctx) {}

void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFlurryContextInitializer; 
	*ctxFinalizerToSet = &AirFlurryContextFinalizer;
}

void AirFlurryFinalizer(void *extData) {}
