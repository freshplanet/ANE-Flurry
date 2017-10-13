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
#import <Foundation/Foundation.h>
#import "FlashRuntimeExtensions.h"

#define DEFINE_ANE_FUNCTION(fn) FREObject fn(FREContext context, void* functionData, uint32_t argc, FREObject argv[])
#define MAP_FUNCTION(fn, data) { (const uint8_t*)(#fn), (data), &(fn) }
#define ROOT_VIEW_CONTROLLER [[[UIApplication sharedApplication] keyWindow] rootViewController]

void AirFlurry_FPANE_DispatchEvent(FREContext context, NSString* eventName);
void AirFlurry_FPANE_DispatchEventWithInfo(FREContext context, NSString* eventName, NSString* eventInfo);
void AirFlurry_FPANE_Log(FREContext context, NSString* message);

NSString* AirFlurry_FPANE_FREObjectToNSString(FREObject object);
NSArray* AirFlurry_FPANE_FREObjectToNSArrayOfNSString(FREObject object);
NSDictionary* AirFlurry_FPANE_FREObjectsToNSDictionaryOfNSString(FREObject keys, FREObject values);
BOOL AirFlurry_FPANE_FREObjectToBool(FREObject object);
NSInteger AirFlurry_FPANE_FREObjectToInt(FREObject object);
double AirFlurry_FPANE_FREObjectToDouble(FREObject object);

FREObject AirFlurry_FPANE_BOOLToFREObject(BOOL boolean);
FREObject AirFlurry_FPANE_IntToFREObject(NSInteger i);
FREObject AirFlurry_FPANE_DoubleToFREObject(double d);
FREObject AirFlurry_FPANE_NSStringToFREObject(NSString* string);
FREObject AirFlurry_FPANE_CreateError(NSString* error, NSInteger* id);
