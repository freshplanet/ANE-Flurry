//
//  AirFlurry.m
//  AirFlurry
//
//  Created by Thibaut Crenn on 4/17/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AirFlurry.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject (fn)(FREContext context, void* functionData, uint32_t argc, FREObject argv[])



@implementation AirFlurry

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end

DEFINE_ANE_FUNCTION(setAppVersion)
{
    uint32_t length = 0;
    const uint8_t *value = NULL;
    FREGetObjectAsUTF8( argv[0], &length, &value );
    NSString* versionName = [NSString stringWithUTF8String: (char*) value];
    [FlurryAnalytics setAppVersion:versionName];
    
    return nil;
}



DEFINE_ANE_FUNCTION(logEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    FREGetObjectAsUTF8(argv[0], &stringLength, &value);
    NSString *eventName = [NSString stringWithUTF8String:(char*)value];
    /*NSMutableDictionary *params;
    
    if (argc == 3)
    {
        FREObject arrKey = argv[1]; // array
        uint32_t arr_len; // array length
        
        FREObject arrValue = argv[2]; // array
        
        if (arrKey != nil)
        {
            FREGetArrayLength(arrKey, &arr_len);
            
            params = [[NSMutableDictionary alloc] init];
            
            for(int32_t i=arr_len-1; i>=0;i--){
                
                // get an element at index
                FREObject key;
                FREGetArrayElementAt(arrKey, i, &key);
                
                FREObject value;
                FREGetArrayElementAt(arrValue, i, &value);
                
                
                // convert it to NSString
                uint32_t stringLength;
                const uint8_t *keyString;
                FREGetObjectAsUTF8(key, &stringLength, &keyString);
                
                
                const uint8_t *valueString;
                FREGetObjectAsUTF8(value, &stringLength, &valueString);
                
                [params setValue:[NSString stringWithUTF8String:(char*)valueString] forKey:[NSString stringWithUTF8String:(char*)keyString]];
            }
            
        }
    }
    
    

    if (params != nil && params.count > 0)
    {
        [FlurryAnalytics logEvent:eventName withParameters:params];
    } else
    {*/
        [FlurryAnalytics logEvent:eventName];
    //}
 
    return nil;
}




DEFINE_ANE_FUNCTION(logError)
{
    uint32_t length = 0;
    const uint8_t *error;
    FREGetObjectAsUTF8( argv[0], &length, &error );
    NSString* errorId = [NSString stringWithUTF8String: (char*) error];

    const uint8_t *msg;
    FREGetObjectAsUTF8( argv[1], &length, &msg );
    NSString* message = [NSString stringWithUTF8String: (char*) msg];

    [FlurryAnalytics logError:errorId message:message error:nil];

    return NULL;
}


DEFINE_ANE_FUNCTION(setUserId)
{
    uint32_t length = 0;
    const uint8_t *value = NULL;
    FREGetObjectAsUTF8( argv[0], &length, &value );
    NSString* userId = [NSString stringWithUTF8String: (char*) value];
    [FlurryAnalytics setUserID:userId];

    return NULL;
}

DEFINE_ANE_FUNCTION(setUserInfo)
{
    int32_t age = 0;
    FREGetObjectAsInt32(argv[0], &age);
    [FlurryAnalytics setAge:age];

    uint32_t length = 0;
    const uint8_t *gnd = NULL;
    FREGetObjectAsUTF8( argv[1], &length, &gnd );
    NSString* gender = [NSString stringWithUTF8String: (char*) gnd];
    [FlurryAnalytics setGender:gender];
   
    return NULL;
}



DEFINE_ANE_FUNCTION(setSendEventsOnPause)
{
    uint32_t onPause = NO;
    FREGetObjectAsBool(argv[0], &onPause);

    [FlurryAnalytics setSessionReportsOnPauseEnabled:onPause];
    [FlurryAnalytics setSessionReportsOnCloseEnabled:!onPause];
  
    return NULL;
}

DEFINE_ANE_FUNCTION(startTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    FREGetObjectAsUTF8(argv[0], &stringLength, &value);
    NSString *eventName = [NSString stringWithUTF8String:(char*)value];

    [FlurryAnalytics logEvent:eventName timed:YES];

    return NULL;
}


DEFINE_ANE_FUNCTION(stopTimedEvent)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    FREGetObjectAsUTF8(argv[0], &stringLength, &value);
    NSString *eventName = [NSString stringWithUTF8String:(char*)value];

    [FlurryAnalytics endTimedEvent:eventName withParameters:nil];

    return NULL;
}


DEFINE_ANE_FUNCTION(startSession)
{
    uint32_t stringLength;
    
    const uint8_t *value;
    FREGetObjectAsUTF8(argv[0], &stringLength, &value);
    NSString *apiKey = [NSString stringWithUTF8String:(char*)value];

    [FlurryAnalytics startSession:apiKey];
    return NULL;
}

DEFINE_ANE_FUNCTION(stopSession)
{
    return NULL;
}


// ContextInitializer()
//
// The context initializer is called when the runtime creates the extension context instance.
void AirFlurryContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, 
                                uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{    
    // Register the links btwn AS3 and ObjC. (dont forget to modify the nbFuntionsToLink integer if you are adding/removing functions)
    NSInteger nbFuntionsToLink = 10;
    *numFunctionsToTest = nbFuntionsToLink;
    
    FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * nbFuntionsToLink);
    
    func[0].name = (const uint8_t*) "setAppVersion";
    func[0].functionData = NULL;
    func[0].function = &setAppVersion;
    
    func[1].name = (const uint8_t*) "logEvent";
    func[1].functionData = NULL;
    func[1].function = &logEvent;
    
    func[2].name = (const uint8_t*) "logError";
    func[2].functionData = NULL;
    func[2].function = &logError;
    
    func[3].name = (const uint8_t*) "setUserId";
    func[3].functionData = NULL;
    func[3].function = &setUserId;

    func[4].name = (const uint8_t*) "setUserInfo";
    func[4].functionData = NULL;
    func[4].function = &setUserInfo;

    func[5].name = (const uint8_t*) "setSendEventsOnPause";
    func[5].functionData = NULL;
    func[5].function = &setSendEventsOnPause;

    func[6].name = (const uint8_t*) "startTimedEvent";
    func[6].functionData = NULL;
    func[6].function = &startTimedEvent;

    func[7].name = (const uint8_t*) "stopTimedEvent";
    func[7].functionData = NULL;
    func[7].function = &stopTimedEvent;
    
    func[8].name = (const uint8_t*) "startSession";
    func[8].functionData = NULL;
    func[8].function = &startSession;

    func[9].name = (const uint8_t*) "stopSession";
    func[9].functionData = NULL;
    func[9].function = &stopSession;

    
    *functionsToSet = func;
    
}

// ContextFinalizer()
//
// Set when the context extension is created.

void AirFlurryContextFinalizer(FREContext ctx) { 
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