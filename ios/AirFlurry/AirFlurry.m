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


@interface AirFlurry ()
{
    UIWindow *_applicationWindow;
    NSString *_interstitialDisplayed;
    NSMutableDictionary *_cookies;
    NSMutableDictionary *_targetingKeywords;
    NSString *_adMobPublisherID;
    NSString *_greystripeApplicationID;
    NSString *_inMobiAppKey;
    NSString *_jumptapApplicationID;
    NSString *_millenialAppKey;
    NSString *_millenialInterstitialAppKey;
    NSString *_mobclixApplicationID;
}

@property (nonatomic, readonly) UIView *rootView;
@property (nonatomic, readonly) UIView *bannerContainer;
@property (nonatomic, readonly) NSMutableDictionary *spacesStatus;

- (void)onWindowDidBecomeKey:(NSNotification *)notification;
- (BOOL)statusForSpace:(NSString *)space;
- (void)setStatus:(BOOL)status forSpace:(NSString *)space;

@end


@implementation AirFlurry

@synthesize bannerContainer = _bannerContainer;
@synthesize spacesStatus = _spacesStatus;

#pragma mark - Memory management

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:nil];
    [_applicationWindow release];
    [_bannerContainer release];
    [_spacesStatus release];
    [_interstitialDisplayed release];
    [_cookies release];
    [_targetingKeywords release];
    [_adMobPublisherID release];
    [_greystripeApplicationID release];
    [_inMobiAppKey release];
    [_jumptapApplicationID release];
    [_millenialAppKey release];
    [_millenialInterstitialAppKey release];
    [_mobclixApplicationID release];
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

- (void)startSession:(NSString *)apiKey
{
    _applicationWindow = [[[UIApplication sharedApplication] keyWindow] retain];
    
    [Flurry setDebugLogEnabled:YES];
    [Flurry startSession:apiKey];
    
    [FlurryAds enableTestAds:NO];
    [FlurryAds setAdDelegate:self];
    [FlurryAds initialize:_applicationWindow.rootViewController];
    
    // Set third-party networks credentials
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSDictionary *credentials = [info objectForKey:@"AppSpotCredentials"];
    if (credentials)
    {
        _adMobPublisherID = [[credentials objectForKey:@"AdMobPublisherID"] retain];
        _greystripeApplicationID = [[credentials objectForKey:@"GreystripeApplicationID"] retain];
        _inMobiAppKey = [[credentials objectForKey:@"InMobiAppKey"] retain];
        _jumptapApplicationID = [[credentials objectForKey:@"JumptapApplicationID"] retain];
        _millenialAppKey = [[credentials objectForKey:@"MillenialAppKey"] retain];
        _millenialInterstitialAppKey = [[credentials objectForKey:@"MillenialInterstitialAppKey"] retain];
        _mobclixApplicationID = [[credentials objectForKey:@"MobclixApplicationID"] retain];
    }
    
    // Listen to key window notification (bugfix for interstitial that disappear)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWindowDidBecomeKey:) name:UIWindowDidBecomeKeyNotification object:nil];
}


#pragma mark - Ads

- (UIView *)rootView
{
    return [[[[UIApplication sharedApplication] keyWindow] rootViewController] view];
}

- (UIView *)bannerContainer
{
    if (!_bannerContainer)
    {
        CGRect bannerFrame = CGRectZero;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            bannerFrame.size = CGSizeMake(728, 90);
        }
        else
        {
            bannerFrame.size = CGSizeMake(320, 50);
        }
        
        _bannerContainer = [[UIView alloc] initWithFrame:bannerFrame];
    }
    
    return _bannerContainer;
}

- (NSMutableDictionary *)spacesStatus
{
    if (!_spacesStatus)
    {
        _spacesStatus = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    
    return _spacesStatus;
}

- (BOOL)statusForSpace:(NSString *)space
{
    if (!space) return NO;
    
    NSNumber *numberStatus = [self.spacesStatus objectForKey:space];
    
    return numberStatus ? [numberStatus boolValue] : NO;
}

- (void)setStatus:(BOOL)status forSpace:(NSString *)space
{
    [self.spacesStatus setObject:[NSNumber numberWithBool:status] forKey:space];
}

- (BOOL)showAdForSpace:(NSString *)space size:(FlurryAdSize)size timeout:(int64_t)timeout
{
    UIView *adView = (size == FULLSCREEN) ? self.rootView : self.bannerContainer;
    
    if (size == BANNER_BOTTOM || size == BANNER_TOP)
    {
        CGRect bannerFrame = adView.frame;
        bannerFrame.origin.y = (size == BANNER_BOTTOM) ? self.rootView.bounds.size.height - bannerFrame.size.height : 0;
        adView.frame = bannerFrame;
    }
    
    if ([FlurryAds adReadyForSpace:space]) // if ad is ready, show it
    {
        [self setStatus:YES forSpace:space];
        if (size == FULLSCREEN) _interstitialDisplayed = [space retain];
        else [self.rootView addSubview:adView];
        [FlurryAds displayAdForSpace:space onView:adView];
        return YES;
    }
    else if (timeout == 0) // else if async display requested, fetch then show
    {
        [self setStatus:YES forSpace:space];
        if (size == FULLSCREEN) _interstitialDisplayed = [space retain];
        else [self.rootView addSubview:adView];
        [FlurryAds fetchAndDisplayAdForSpace:space view:adView size:size];
        return YES;
    }
    else // else, ad unavailable
    {
        return NO;
    }
}

- (void)fetchAdForSpace:(NSString *)space size:(FlurryAdSize)size
{
    UIView *adView = (size == FULLSCREEN) ? self.rootView : self.bannerContainer;
    
    [FlurryAds fetchAdForSpace:space frame:adView.frame size:size];
}

- (void)removeAdFromSpace:(NSString *)space
{
    [self setStatus:NO forSpace:space];
    
    if ([space isEqualToString:_interstitialDisplayed])
    {
        [_interstitialDisplayed release];
        _interstitialDisplayed = nil;
    }
    else
    {
        [self.bannerContainer removeFromSuperview];
    }
    
    [FlurryAds removeAdFromSpace:space];
}

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

- (void)addTargetingKeywordWithValue:(NSString *)value forKey:(NSString *)key
{
    if (!_targetingKeywords)
    {
        _targetingKeywords = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    [_targetingKeywords setObject:value forKey:key];
    [FlurryAds setKeywordsForTargeting:_targetingKeywords];
}

- (void)clearTargetingKeywords
{
    if (_targetingKeywords)
    {
        [_targetingKeywords removeAllObjects];
        [FlurryAds setKeywordsForTargeting:_targetingKeywords];
    }
}


#pragma mark - FlurryAdDelegate

- (BOOL)spaceShouldDisplay:(NSString *)adSpace interstitial:(BOOL)interstitial
{
    return [self statusForSpace:adSpace];
}

- (void)spaceDidDismiss:(NSString *)adSpace interstitial:(BOOL)interstitial
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

- (void)spaceDidFailToRender:(NSString *)space error:(NSError *)error
{
    NSLog(@"[Flurry] Ad failed to render: %@. Error: %@", space, [error localizedDescription]);
    
    if (AirFlurryCtx != nil)
    {
        FREDispatchStatusEventAsync(AirFlurryCtx, (const uint8_t *)"SPACE_DID_FAIL_TO_RENDER", (const uint8_t *)[space UTF8String]);
    }
}


#pragma mark - FlurryAdDelegate - 3rd-party networks

- (NSString *)appSpotAdMobPublisherID
{
    return _adMobPublisherID;
}

- (NSString *)appSpotGreystripeApplicationID
{
    return _greystripeApplicationID;
}

- (NSString *)appSpotInMobiAppKey
{
    return _inMobiAppKey;
}

- (NSString *)appSpotJumptapApplicationID
{
    return _jumptapApplicationID;
}

- (NSString *)appSpotMillennialAppKey
{
    return _millenialAppKey;
}

- (NSString *)appSpotMillennialInterstitalAppKey
{
    return _millenialInterstitialAppKey;
}

- (NSString *)appSpotMobclixApplicationID
{
    return _mobclixApplicationID;
}


#pragma mark - NSNotificationCenter

- (void)onWindowDidBecomeKey:(NSNotification *)notification
{
    UIWindow *window = (UIWindow *)notification.object;
    
    if (window == _applicationWindow)
    {
        [AirFlurry log:@"Application window became key"];
    }
    else
    {
        [AirFlurry log:@"Other window became key"];
    }
    
    if (_interstitialDisplayed != nil)
    {
        [AirFlurry log:[NSString stringWithFormat:@"Interstitial displayed: %@", _interstitialDisplayed]];
    }
    
    if (window == _applicationWindow && _interstitialDisplayed != nil)
    {
        [self spaceDidDismiss:_interstitialDisplayed interstitial:YES];
        [_interstitialDisplayed release];
        _interstitialDisplayed = nil;
    }
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
        // Try to show an ad
        BOOL isAdAvailable = [[AirFlurry sharedInstance] showAdForSpace:space size:sizeValue timeout:timeout];
        
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

DEFINE_ANE_FUNCTION(fetchAd)
{
    NSString *space = nil;
    FlurryAdSize sizeValue;
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
    
    if (space != nil)
    {
        [[AirFlurry sharedInstance] fetchAdForSpace:space size:sizeValue];
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
        [[AirFlurry sharedInstance] removeAdFromSpace:space];
    }
    
    return nil;
}

DEFINE_ANE_FUNCTION(addUserCookie)
{
    uint32_t stringLength;
    
    const uint8_t *keyString;
    if (FREGetObjectAsUTF8(argv[0], &stringLength, &keyString) != FRE_OK)
    {
        return nil;
    }
    NSString *key = [NSString stringWithUTF8String:(char*)keyString];
    
    const uint8_t *valueString;
    if (FREGetObjectAsUTF8(argv[1], &stringLength, &valueString) != FRE_OK)
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

DEFINE_ANE_FUNCTION(addTargetingKeyword)
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
    
    [[AirFlurry sharedInstance] addTargetingKeywordWithValue:value forKey:key];
    
    return nil;
}

DEFINE_ANE_FUNCTION(clearTargetingKeywords)
{
    [[AirFlurry sharedInstance] clearTargetingKeywords];
    return nil;
}


#pragma mark - ANE setup

void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 17;
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
    
    func[11].name = (const uint8_t*) "fetchAd";
    func[11].functionData = NULL;
    func[11].function = &fetchAd;
    
    func[12].name = (const uint8_t*) "removeAd";
    func[12].functionData = NULL;
    func[12].function = &removeAd;
    
    func[13].name = (const uint8_t*) "addUserCookie";
    func[13].functionData = NULL;
    func[13].function = &addUserCookie;
    
    func[14].name = (const uint8_t*) "clearUserCookies";
    func[14].functionData = NULL;
    func[14].function = &clearUserCookies;
    
    func[15].name = (const uint8_t*) "addTargetingKeyword";
    func[15].functionData = NULL;
    func[15].function = &addTargetingKeyword;
    
    func[16].name = (const uint8_t*) "clearTargetingKeywords";
    func[16].functionData = NULL;
    func[16].function = &clearTargetingKeywords;
    

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