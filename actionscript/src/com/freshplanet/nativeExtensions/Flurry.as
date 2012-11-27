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

package com.freshplanet.nativeExtensions
{
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;
	import flash.utils.getTimer;

	/**
	 * Class handling all frontend analytics 
	 * @author titi
	 * 
	 */
	public class Flurry extends EventDispatcher
	{
				
		private static var _instance:Flurry;
		
		private var extCtx:ExtensionContext;
		
		public function Flurry() 
		{
			if (!_instance)
			{
				if (this.isFlurrySupported)
				{
					trace('[Flurry] creating Flurry context');
					extCtx = ExtensionContext.createExtensionContext("com.freshplanet.AirFlurry", null);
					extCtx.addEventListener(StatusEvent.STATUS, onStatus);
				} else
				{
					trace('[Flurry] Flurry is not supported', "no log will be displayed");
				}
				_instance = this;
			}
			else
			{
				throw Error( '[Flurry Error] This is a singleton, use getInstance, do not call the constructor directly');
			}

		}
		
		private function onStatus(event:StatusEvent):void
		{
			var e:FlurryAdsEvent;
			
			switch(event.code)
			{
				case FlurryAdsEvent.SPACE_DID_DISMISS:
					e = new FlurryAdsEvent(FlurryAdsEvent.SPACE_DID_DISMISS, event.level);
					break;
				case FlurryAdsEvent.SPACE_WILL_LEAVE_APPLICATION:
					e = new FlurryAdsEvent(FlurryAdsEvent.SPACE_WILL_LEAVE_APPLICATION, event.level);
					break;
				case FlurryAdsEvent.SPACE_DID_FAIL_TO_RENDER:
					e = new FlurryAdsEvent(FlurryAdsEvent.SPACE_DID_FAIL_TO_RENDER, event.level);
					break;
				case "LOGGING":
					trace('[Flurry] ' + event.level);
					break;	
			}
			
			if (e) dispatchEvent(e);
		}
		
		
		public static function getInstance() : Flurry
		{
			return _instance ? _instance : new Flurry();
		}

		private function get isAndroid():Boolean
		{
			return Capabilities.manufacturer.indexOf('Android') > -1;
		}
		
		private function get isIOS():Boolean
		{
			return Capabilities.manufacturer.indexOf('iOS') > -1;
		}

		private function get isFlurrySupported():Boolean
		{
			var result:Boolean = this.isIOS || this.isAndroid;
			return result;
		}

		
		
		/**
		 * Log an event (not timed). For timed events, @see startTimedEvent
		 *  
		 * @param eventName name of the event. Limits :
		 * <ul>
		 * <li>300 event name differents per project</li>
		 * <li>event name below 255 characters</li>
		 * <li>each session can log up to 200 events and up to 100 unique event names</li>
		 * </ul>
		 * @param properties map of additional parameters sent with the event. Limits :
		 * <ul>
		 * <li>max 10 parameters per event</li>
		 * <li>key and value name below 255 characters</li>
		 * </ul>
		 */
		public function logEvent(eventName:String, properties:Object = null):void
		{
			trace("[Flurry]", "logEvent", eventName, properties);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					trace("[Flurry Warning]", "event name too long (>255 characters)", eventName);
					return;
				}

				var parameterKeys:Array = [];
				var parameterValues:Array = [];
				if (properties != null)
				{
					var value:String;
					var count:int = 0;
					for (var key:String in properties)
					{
						if (count > 10)
						{
							trace("[Flurry Warning]", "too many properties sent (>10) for event", eventName);
							break;
						}
						value = properties[key].toString();
						if (checkLength(value) && checkLength(key))
						{
							parameterKeys.push(key);
							parameterValues.push(value);
						} else
						{
							trace("[Flurry Warning]", "key or value too long (>255 characters)", key, value);
						}
						count++;
					}
					trace("[Flurry]", "logEvent", eventName, parameterKeys, parameterValues);
					extCtx.call("logEvent", eventName, parameterKeys, parameterValues);
				} else
				{
					trace("[Flurry]", "logEvent", eventName);
					extCtx.call("logEvent", eventName, [], []);
				}
			}
		}
		
		private function checkLength(value:String):Boolean
		{
			return value != null && value.length < 255;
		}
		
		
		
		/**
		 * Report Application errors. Limits:
		 * Flurry will report the first 10 errors to occur in each session
		 * 
		 * We also limit error and message to 255 characters (truncate if higher). 
		 * 
		 * @param errorId
		 * @param message
		 * 
		 */
		public function logError(errorId:String, message:String):void
		{
			if (isFlurrySupported && errorId != null)
			{
				errorId = errorId.length > 255 ? errorId.substr(0, 253) : errorId;
				
				message = message == null ? "" : message;
				message = message.length > 255 ? message.substr(0, 253) : message;

				extCtx.call("logError", errorId, message)
			}
		}
		
		
		/**
		 * Set the user id associated with the current session. 
		 * @param userId 
		 * 
		 */
		public function setUserId(userId:String):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setUserId", userId)
			}
		}
		
		public static const MALE_GENDER:String   = "m";
		public static const FEMALE_GENDER:String = "f";

		
		/**
		 * Set the user info associated with the current session 
		 * @param age age of the user ( > 0)
		 * @param gender gender of the user. Must be one of the two defined constants: @see MALE_GENDER, @see FEMALE_GENDER
		 * 
		 */
		public function setUserInfo(age:int, gender:String):void
		{
			if (isFlurrySupported)
			{
				if ([MALE_GENDER, FEMALE_GENDER].indexOf(gender) == -1)
				{
					trace("[Flurry]", "wrong gender provided", gender, "must be Flurry.MALE_GENDER or Flurry.FEMALE_GENDER")
				}
				extCtx.call("setUserInfo", age, gender)
			}
		}
		
		
		/**
		 * Set the version name sent for this session. Limits:
		 * There is a maximum of 605 versions allowed for a single app. 
		 * This method must be called prior to invoking startSession:.
		 * @param versionName
		 * 
		 */
		public function setAppVersion(versionName:String):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setAppVersion", versionName)
			}
		}
		
		/**
		 * Switch the send events when user pauses the app. 
		 * @param value True : send events on pause. False : send events on stop.
		 * 
		 */
		public function setSendEventsOnPause(value:Boolean):void
		{
			if (isFlurrySupported)
			{
				extCtx.call("setSendEventsOnPause", value)
			}
		}

		
		/**
		 * Start logging a timed event. 
		 * @param eventName
		 * 
		 */
		public function startTimedEvent(eventName:String):void
		{
			trace("[Flurry]", "startTimedEvent", eventName);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					trace("[Flurry Warning]", "event name too long (>255 characters)", eventName);
					return;
				}
				trace("[Flurry]", "start logEvent Timed", eventName);

				extCtx.call("startTimedEvent", eventName)
			}
		}
		
		
		/**
		 * Stop recording the given timed event. 
		 * @param eventName
		 * 
		 */
		public function stopTimedEvent(eventName:String):void
		{
			trace("[Flurry]", "stopTimedEvent", eventName);

			if (isFlurrySupported)
			{
				if (!checkLength(eventName))
				{
					trace("[Flurry Warning]", "event name too long (>255 characters)", eventName);
					return;
				}
				trace("[Flurry]", "stop logEvent Timed", eventName);

				extCtx.call("stopTimedEvent", eventName)
			}
		}

		
		/**
		 * Start a new Flurry Session. 
		 * Every event will be recorded afterwards.
		 * 
		 */
		public function startSession():void
		{
			trace('start session');
			if (isFlurrySupported)
			{
				
				var apiKey:String = getApiKeyFromDevice();
				if (apiKey != null)
				{
					trace('start session with api key'+apiKey);
					extCtx.call("startSession", apiKey)
				} else
				{
					trace("[Flurry Warning]", "api key not found");
				}
			}
		}
		
		private var iOSApiKey:String;
		private var androidApiKey:String;

		
		private function getApiKeyFromDevice():String
		{
			if (this.isAndroid)
			{
				return androidApiKey;
			}
			if (this.isIOS)
			{
				return iOSApiKey;
			}
			return null;
		}
		
		public function setIOSAPIKey(apiKey:String):void
		{
			this.iOSApiKey = apiKey;
		}
		
		public function setAndroidAPIKey(apiKey:String):void
		{
			this.androidApiKey = apiKey;
		}

		
		/**
		 * Stop the current session. 
		 */
		public function stopSession():void
		{
			if (isFlurrySupported)
			{
				extCtx.call("stopSession")
			}
		}
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		// ADS SECTION
		/////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private var _activeAdSpaces : Array = [];
		
		/**
		 * Display an ad onscreen.
		 * 
		 * @param space String: Name of the adSpace that you defined on the Flurry website.
		 * @param size String: Size of the ad. This is generally overridden on the server-side
		 * by the size specified on the Flurry website.
		 * @param timeout int: Maximum time (in ms) ad requests should block before they return.
		 * For asynchronous requests (recommended for banners), pass 0. (Default: 0)
		 * @param force Boolean: If true, the ad will be requested no matter what. If false, the
		 * ad won't be requested if showAd() has been called before for this ad space without
		 * calling removeAd() afterward. (Default: false).
		 * 
		 * @see FlurryAdSize
		 */ 
		public function showAd( space : String, size : String, timeout : int = 0, force : Boolean = false ) : Boolean
		{
			if (!isFlurrySupported) return false;
			if (_activeAdSpaces.indexOf(space) != -1 && !force) return true;
			
			if (_activeAdSpaces.indexOf(space) == -1) _activeAdSpaces.push(space);
			
			trace('[Flurry] Show ad "'+space+'" with size "'+size+'"');
			
			return extCtx.call('showAd', space, size, timeout);
		}
		
		/**
		 * Fetch an ad to be displayed later (with <code>showAd()</code>).
		 * 
		 * @param space String: Name of the adSpace that you defined on the Flurry website.
		 * @param size String: Size of the ad. This is generally overridden on the server-side
		 * by the size specified on the Flurry website.
		 * 
		 * @see #showAd()
		 * @see FlurryAdSize
		 */
		public function fetchAd( space : String, size : String ) : void
		{
			if (!isFlurrySupported) return;
			
			trace('[Flurry] Fetch ad "'+space+'" with size "'+size+'"');
			
			extCtx.call('fetchAd', space, size);
		}
		
		/**
		 * Remove an ad from the screen.
		 * 
		 * @param space String: Name of the adSpace that you defined on the Flurry website.
		 */ 
		public function removeAd( space : String ) : void
		{
			if (!isFlurrySupported) return;
			
			if (_activeAdSpaces.indexOf(space) != -1)
				_activeAdSpaces.splice(_activeAdSpaces.indexOf(space), 1);
			
			trace('[Flurry] Remove ad "'+space+'"');
			
			extCtx.call('removeAd', space);
		}
		
		/**
		 * Adds a key/value pair to the user cookies.
		 * Those cookies are used once the user install new app.
		 */
		public function addUserCookie( key : String, value : String ) : void
		{
			if (isFlurrySupported)
			{
				extCtx.call("addUserCookie", key, value);
			}
		}
		
		/**
		 * Clear the stored cookies.
		 * 
		 * @see #addUserCookie()
		 */
		public function clearUserCookies() : void
		{
			if (isFlurrySupported)
			{
				extCtx.call("clearUserCookies");
			}
		}
		
		/**
		 * Adds a key/value pair to the targeting keywords.
		 * Those keywords are used to target ads.
		 */
		public function addTargetingKeyword( key : String, value : String ) : void
		{
			if (isFlurrySupported)
			{
				extCtx.call("addTargetingKeyword", key, value);
			}
		}
		
		/**
		 * Clear the stored targeting keywords.
		 * 
		 * @see #addTargetingKeyword()
		 */
		public function clearTargetingKeywords() : void
		{
			if (isFlurrySupported)
			{
				extCtx.call("clearTargetingKeywords");
			}
		}
	}
}