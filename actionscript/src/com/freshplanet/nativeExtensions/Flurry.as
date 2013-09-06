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
	import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class Flurry extends EventDispatcher
	{
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		public static const MALE_GENDER:String   = "m";
		public static const FEMALE_GENDER:String = "f";
		
		/** Flurry is supported on iOS and Android devices. */
		public static function get isSupported() : Boolean
		{
			return isAndroid || isIOS;
		}
		
		public function Flurry() 
		{
			if (!_instance)
			{
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context)
				{
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);
				
				_instance = this;
			}
			else
			{
				throw Error("This is a singleton, use getInstance(), do not call the constructor directly.");
			}
		}
		
		public static function getInstance() : Flurry
		{
			return _instance ? _instance : new Flurry();
		}
		
		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 * If <code>false</code>, logs will be displayed only at the native level.
		 */
		public function get logEnabled() : Boolean
		{
			return _logEnabled;
		}
		
		public function set logEnabled( value : Boolean ) : void
		{
			_logEnabled = value;
		}
		
		/**
		 * Enable/disable crash reporting on iOS.
		 * <br><br>
		 * 
		 * You can only have one crash handler per app on iOS, so this feature is disabled by default.
		 */
		public function get iOSCrashReportingEnabled():Boolean
		{
			return _iOSCrashReportingEnabled;
		}
		
		public function set iOSCrashReportingEnabled(value:Boolean):void
		{
			_iOSCrashReportingEnabled = value;
			if (isIOS)
			{
				log("iOS crash reporting " + (_iOSCrashReportingEnabled ? "enabled" : "disabled"));
				_context.call("setCrashReportingEnabled", _iOSCrashReportingEnabled);
			}
		}
		
		public function setIOSAPIKey(apiKey:String):void
		{
			_iOSApiKey = apiKey;
		}
		
		public function setAndroidAPIKey(apiKey:String):void
		{
			_androidApiKey = apiKey;
		}
		
		/**
		 * This method must be called prior to <code>startSession()</code>.
		 * <br><br>
		 * 
		 * Note: There is a maximum of 605 versions allowed for a single app.  
		 */
		public function setAppVersion(versionName:String):void
		{
			log("Set app version to " + versionName);
			
			if (isSupported)
			{
				_context.call("setAppVersion", versionName)
			}
		}
		
		/**
		 * Start the Flurry session.
		 * <br><br>
		 * 
		 * Note: You must set your API keys with <code>setIOSAPIKey()</code> and/or <code>setAndroidAPIKey</code>
		 * before calling <code>startSession()</code>.
		 */
		public function startSession():void
		{
			var apiKey:String = getApiKeyFromDevice();
			if (apiKey)
			{
				log("Start session with API key " + apiKey);
				
				if (isSupported)
				{
					_context.call("startSession", apiKey)
				}
			}
		}
		
		public function stopSession():void
		{
			log("Stop session");
			
			if (isSupported)
			{
				_context.call("stopSession")
			}
		}
		
		public function setUserId(userId:String):void
		{
			log("Set user ID to " + userId);
			
			if (isSupported)
			{
				_context.call("setUserId", userId)
			}
		}
		
		/**
		 * @param age Must be > 0.
		 * @param gender Must be one of the two defined constants <code>MALE_GENDER</code> or <code>FEMALE_GENDER</code>.
		 */
		public function setUserInfo(age:int, gender:String):void
		{
			if (age <= 0)
			{
				log("Couldn't set user info. Age must be > 0 (value provided: " + age + ")");
				return;
			}
			else if (gender != MALE_GENDER && gender != FEMALE_GENDER)
			{
				log("Couldn't set user info. Gender must be Flurry.MALE_GENDER or Flurry.FEMALE_GENDER (value provided: " + gender + ")");
				return;
			}
			
			log("Set user info - Age = " + age + " - Gender = " + gender); 
			
			if (isSupported)
			{				
				_context.call("setUserInfo", age, gender);
			}
		}
		
		public function setSendEventsOnPause(value:Boolean):void
		{
			if (isSupported)
			{
				_context.call("setSendEventsOnPause", value)
			}
		}
		
		/**
		 * Log a regular event.
		 *  
		 * @param eventName Name of the event. Limits :
		 * <ul>
		 * <li>300 unique event names per application</li>
		 * <li>Event name must be below 255 characters</li>
		 * <li>Each session can log up to 200 events and up to 100 unique event names</li>
		 * </ul>
		 * 
		 * @param properties map of additional parameters sent with the event. Limits :
		 * <ul>
		 * <li>Max 10 parameters per event</li>
		 * <li>Key and value names must be below 255 characters</li>
		 * </ul>
		 */
		public function logEvent(eventName:String, properties:Object = null):void
		{	
			if (!checkLength(eventName))
			{
				log("Couldn't log event " + eventName + " (too long)");
				return;
			}
			
			log("Log event - " + eventName + (properties ? " - " + JSON.stringify(properties) : ""));
			
			var parameterKeys:Array = [];
			var parameterValues:Array = [];
			if (properties)
			{
				var value:String;
				var count:int = 0;
				for (var key:String in properties)
				{
					if (count > 10)
					{
						log("Too many properties provided. Only kept " + JSON.stringify(parameterKeys));
						break;
					}
					
					value = properties[key].toString();
					if (checkLength(value) && checkLength(key))
					{
						parameterKeys.push(key);
						parameterValues.push(value);
					}
					else
					{
						log("Skipped property " + key + ". Value " + value + " was too long");
					}
					count++;
				}
			}
			
			if (isSupported)
			{
				_context.call("logEvent", eventName, parameterKeys, parameterValues);
			}
		}
		
		public function startTimedEvent(eventName:String):void
		{
			if (!checkLength(eventName))
			{
				log("Couldn't start timed event " + eventName + " (too long)");
				return;
			}
			
			log("Start timed event - " + eventName);
			
			if (isSupported)
			{
				_context.call("startTimedEvent", eventName)
			}
		}
		
		public function stopTimedEvent(eventName:String):void
		{
			if (!checkLength(eventName))
			{
				log("Couldn't stop timed event " + eventName + " (too long)");
				return;
			}
			
			log("Stop timed event - " + eventName);
			
			if (isSupported)
			{
				_context.call("stopTimedEvent", eventName)
			}
		}
		
		/**
		 * Log an error.
		 * <br><br>
		 * 
		 * Limits:
		 * <ul>
		 * <li>Flurry only reports the first 10 errors in each session.</li>
		 * <li>Error ID and message are truncated to 255 characters.</li>
		 * </ul>
		 */
		public function logError(errorId:String, message:String = null):void
		{
			if (!errorId)
			{
				log("Couldn't log error. You need to provide an error ID.");
				return;
			}
			
			if (errorId.length > 255)
			{
				errorId = errorId.substr(0, 255);
			}
			
			message = message || "";
			if (message.length > 255)
			{
				message = message.substr(0, 255);
			}
			
			log("Log error - " + errorId + (message.length > 0 ? " - " + message : ""))
			
			if (isSupported)
			{
				_context.call("logError", errorId, message)
			}
		}
		
		
		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.AirFlurry";
		
		private static var _instance : Flurry;
		
		private var _context : ExtensionContext;
		private var _logEnabled : Boolean;
		private var _iOSCrashReportingEnabled:Boolean;
		private var _iOSApiKey:String;
		private var _androidApiKey:String;
		
		private static function get isAndroid():Boolean
		{
			return Capabilities.manufacturer.indexOf("Android") > -1;
		}
		
		private static function get isIOS():Boolean
		{
			return Capabilities.manufacturer.indexOf("iOS") > -1;
		}
		
		private function getApiKeyFromDevice():String
		{
			if (isAndroid)
			{
				return _androidApiKey;
			}
			if (isIOS)
			{
				return _iOSApiKey;
			}
			return null;
		}
		
		private function checkLength(value:String):Boolean
		{
			return value && value.length < 255;
		}
		
		private function onStatus(event:StatusEvent):void
		{
			if (event.code == "LOGGING")
			{
				log(event.level);
			}
		}

		private function log(message:String):void
		{
			if (_logEnabled) trace("[Flurry] " + message);
		}
	}
}