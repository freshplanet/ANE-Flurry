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
#import "FlurryAds.h"

FREContext AirFlurryCtx = nil;


@interface AirFlurry ()
{
    NSMutableDictionary *_cookies;
}
@end


@implementation AirFlurry

@synthesize adMobPublisherID = _adMobPublisherID;
@synthesize greystripeApplicationID = _greystripeApplicationID;
@synthesize inMobiAppKey = _inMobiAppKey;
@synthesize jumptapApplicationID = _jumptapApplicationID;
@synthesize millenialAppKey = _millenialAppKey;
@synthesize millenialInterstitialAppKey = _millenialInterstitialAppKey;
@synthesize mobclixApplicationID = _mobclixApplicationID;

#pragma mark - Memory management

- (void)dealloc
{
    self.adMobPublisherID = nil;
    self.greystripeApplicationID = nil;
    self.inMobiAppKey = nil;
    self.jumptapApplicationID = nil;
    self.millenialAppKey = nil;
    self.millenialInterstitialAppKey = nil;
    self.mobclixApplicationID = nil;
    [_cookies release];
    [super dealloc];
}


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

- (void)addUserCookieWithValue:(NSString *)value forKey:(NSString *)key
{
    if (!_cookies)
    {
        _cookies = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    [_cookies setObject:value forKey:key];
    [FlurryAds setUserCookies:_cookies];
}

- (void)clearUserCookies
{
    if (_cookies)
    {
        [_cookies removeAllObjects];
        [FlurryAds setUserCookies:_cookies];
    }
}


#pragma mark - FlurryAdDelegate

- (void)spaceDidDismiss:(NSString *)adSpace
{
    NSLog(@"[Flurry] Closed ad: %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_DISMISS", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceWillLeaveApplication:(NSString *)adSpace
{
    NSLog(@"[Flurry] Exit application after clicking on ad: %@", adSpace);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_WILL_LEAVE_APPLICATION", (const uint8_t *)[adSpace UTF8String]);
    }
}

- (void)spaceDidFailToRender:(NSString *)space
{
    NSLog(@"[Flurry] Ad failed to render: %@", space);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_FAIL_TO_RENDER", (const uint8_t *)[space UTF8String]);
    }
}


#pragma mark - FlurryAdDelegate - 3rd-party networks

- (BOOL)appSpotTestMode
{
    return NO;
}

- (id)appSpotRootViewController
{
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

- (NSString *)appSpotAdMobPublisherID
{
    return self.adMobPublisherID;
}

- (NSString *)appSpotGreystripeApplicationID
{
    return self.greystripeApplicationID;
}

- (NSString *)appSpotInMobiAppKey
{
    return self.inMobiAppKey;
}

- (NSString *)appSpotJumptapApplicationID
{
    return self.jumptapApplicationID;
}

- (NSString *)appSpotMillennialAppKey
{
    return self.millenialAppKey;
}

- (NSString *)appSpotMillennialInterstitalAppKey
{
    return self.millenialInterstitialAppKey;
}

- (NSString *)appSpotMobclixApplicationID
{
    return self.mobclixApplicationID;
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
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        
        [Flurry setDebugLogEnabled:YES];
        [Flurry startSession:apiKey];
        
        [FlurryAds enableTestAds:NO];
        [FlurryAds setAdDelegate:[AirFlurry sharedInstance]];
        [FlurryAds initialize:rootViewController];
        
        // Set third-party networks credentials
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSDictionary *credentials = [info objectForKey:@"AppSpotCredentials"];
        if (credentials)
        {
            AirFlurry *flurry = [AirFlurry sharedInstance];
            flurry.adMobPublisherID = [credentials objectForKey:@"AdMobPublisherID"];
            flurry.greystripeApplicationID = [credentials objectForKey:@"GreystripeApplicationID"];
            flurry.inMobiAppKey = [credentials objectForKey:@"InMobiAppKey"];
            flurry.jumptapApplicationID = [credentials objectForKey:@"JumptapApplicationID"];
            flurry.millenialAppKey = [credentials objectForKey:@"MillenialAppKey"];
            flurry.millenialInterstitialAppKey = [credentials objectForKey:@"MillenialInterstitialAppKey"];
            flurry.mobclixApplicationID = [credentials objectForKey:@"MobclixApplicationID"];
        }
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


#pragma mark - C interface - Ads

DEFINE_ANE_FUNCTION(showAd)
{
    NSString *space = nil;
    FlurryAdSize sizeValue;
    int64_t timeout;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    }
    
    // Retrieve the ad size
    const uint8_t *sizeString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &sizeString) == FRE_OK)
    {
        NSString *size = [NSString stringWithUTF8String:(char*)sizeString];
        
        if ([size isEqualToString:@"BANNER_TOP"]) sizeValue = BANNER_TOP;
        else if ([size isEqualToString:@"BANNER_BOTTOM"]) sizeValue = BANNER_BOTTOM;
        else sizeValue = FULLSCREEN;
    }
    else
    {
        NSLog(@"[Flurry] showAd - Couldn't retrieve ad size. Defaulting to fullscreen.");
        sizeValue = FULLSCREEN;
    }
    
    // Retrieve the timeout
    int32_t timeout32;
    if (FREGetObjectAsInt32(argv[2], &timeout32) == FRE_OK)
    {
        timeout = (int64_t)timeout32;
    }
    else
    {
        NSLog(@"[Flurry] showAd - Couldn't retrieve timout. Defaulting to 0 (asynchronous).");
        timeout = 0;
    }
    
    if (space != nil)
    {
        // Retrieve the root view
        UIView *rootView = [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
        
        NSLog(@"Root view: %@", rootView);
        
        // Try to show an ad
        BOOL isAdAvailable = [FlurryAds showAdForSpace:space view:rootView size:sizeValue timeout:timeout];
        
        // Return the result (YES is the ad was shown, NO otherwise)
        FREObject result;
        if (FRENewObjectFromBool(isAdAvailable, &result) == FRE_OK)
        {
            return result;
        }
        else
        {
            NSLog(@"[Flurry] showAd - Couldn't get ad availability. Assuming it was unavailable.");
        }
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(removeAd)
{
    NSString *space = nil;
    uint32_t stringLength;
    
    // Retrieve the ad space name
    const uint8_t *spaceString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &spaceString) == FRE_OK)
    {
        space = [NSString stringWithUTF8String:(char*)spaceString];
    }
    
    if (space != nil)
    {
        // Remove the ad
        [FlurryAds removeAdFromSpace:space];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(addUserCookie)
{
    uint32_t stringLength;
    
    const uint8_t *keyString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &keyString) == FRE_OK)
    {
        return nil;
    }
    NSString *key = [NSString stringWithUTF8String:(char*)keyString];
    
    const uint8_t *valueString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueString) == FRE_OK)
    {
        return nil;
    }
    NSString *value = [NSString stringWithUTF8String:(char*)valueString];
    
    [[AirFlurry sharedInstance] addUserCookieWithValue:value forKey:key];
    
    return nil;
}

DEFINE_ANE_FUNCTION(clearUserCookies)
{
    [[AirFlurry sharedInstance] clearUserCookies];
    return nil;
}


#pragma mark - ANE setup

// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 14;
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

    
    // Ads
    
    func[10].name = (const uint8_t*) "showAd";
    func[10].functionData = NULL;
    func[10].function = &showAd;
    
    func[11].name = (const uint8_t*) "removeAd";
    func[11].functionData = NULL;
    func[11].function = &removeAd;
    
    func[12].name = (const uint8_t*) "addUserCookie";
    func[12].functionData = NULL;
    func[12].function = &addUserCookie;
    
    func[13].name = (const uint8_t*) "clearUserCookies";
    func[13].functionData = NULL;
    func[13].function = &clearUserCookies;

    AirFlurryCtx = ctx;
    
    *functionsToSet = func;
}

// ContextFinalizer()
//
// Set when the context extension is created.

void AirFlurryContextFinalizer(FREContext ctx)
{
    NSLog(@"Entering ContextFinalizer()");
    
    NSLog(@"Exiting ContextFinalizer()");	
}

// AirFlurryInitializer()
//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void AirFlurryInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet ) 
{
    
    NSLog(@"Entering ExtInitializer()");                    
    
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirFlurryContextInitializer; 
	*ctxFinalizerToSet = &AirFlurryContextFinalizer;
    
    NSLog(@"Exiting ExtInitializer()"); 
}