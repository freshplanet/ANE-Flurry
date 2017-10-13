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

package com.freshplanet.ane.AirFlurry
{
import com.freshplanet.ane.AirFlurry.enums.AirFlurryGender;
import com.freshplanet.ane.AirFlurry.events.AirFlurryEvent;

import flash.events.EventDispatcher;
	import flash.events.StatusEvent;
	import flash.external.ExtensionContext;
	import flash.system.Capabilities;

	public class AirFlurry extends EventDispatcher {

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									   PUBLIC API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		

		/**
		 * Flurry is supported on iOS and Android devices.
		 *
		 */
		public static function get isSupported() : Boolean {
			return isAndroid || isIOS;
		}

		/**
		 * AirFlurry instance
		 * @return AirFlurry instance
		 */
		public static function get instance() : AirFlurry {
			return _instance ? _instance : new AirFlurry();
		}
		
		/**
		 * If <code>true</code>, logs will be displayed at the Actionscript level.
		 */
		public function get logEnabled() : Boolean {
			return _logEnabled;
		}

		public function set logEnabled( value : Boolean ) : void {
			_logEnabled = value;
		}


		/**
		 * Start AirFlurry
		 * @param apiKey Flurry API key
		 * @param appVersion Version of your app
		 * @param continueSessionInMillis Set the timeout for expiring a Flurry session
		 */
		public function init(apiKey:String, appVersion:String, continueSessionInMillis:int = 100):void {
			if(apiKey == null || appVersion == null) {
				log("Please provide apiKey and appVersion to initialize AirFlurry");
				return;

			}
			if (isSupported)
				_context.call("initFlurry", apiKey, appVersion, continueSessionInMillis);

		}

		/**
		 * Does an active session exist
		 */
		public function get isSessionOpen() : Boolean {
			return _context.call("isSessionOpen");
		}

		/**
		 * Set user id
		 * @param userId
		 */
		public function setUserId(userId:String):void {
			if (isSupported)
				_context.call("setUserId", userId);
		}

		/**
		 * Set user age
		 * @param age Must be > 0.
		 */
		public function setUserAge(age:uint):void {
			if (isSupported)
				_context.call("setUserAge", age);
		}

		/**
		 * Set user gender
		 * @param gender
		 */
		public function setUserGender(gender:AirFlurryGender):void {
			if (isSupported)
				_context.call("setUserGender", gender.value);
		}

		/**
		 * Set user location
		 * @param latitude
		 * @param longitude
		 * @param horizontalAccuracy
		 * @param verticalAccuracy
		 */
		public function setLocation(latitude:Number, longitude:Number, horizontalAccuracy:Number, verticalAccuracy:Number):void {
			if (isSupported)
				_context.call("setLocation", latitude, longitude, horizontalAccuracy, verticalAccuracy);
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
		public function logEvent(eventName:String, properties:Object = null):void {
			if (!checkLength(eventName)) {
				log("Couldn't log event " + eventName + " (too long, max 255)");
				return;
			}

			var parameterKeys:Array = [];
			var parameterValues:Array = [];
			if (properties) {
				var value:String;
				var count:int = 0;
				for (var key:String in properties) {
					if (count > 10) {
						log("Too many properties provided. Only kept " + JSON.stringify(parameterKeys));
						break;
					}

					value = properties[key].toString();
					if (checkLength(value) && checkLength(key)) {
						parameterKeys.push(key);
						parameterValues.push(value);
					}
					else {
						log("Skipped property " + key + ". Value " + value + " was too long");
					}
					count++;
				}
			}

			if (isSupported)
				_context.call("logEvent", eventName, parameterKeys, parameterValues);

		}

		/**
		 * Starts a timed event specified by eventName
		 * @param eventName
		 * @param properties map of additional parameters sent with the event. Limits :
		 * <ul>
		 * <li>Max 10 parameters per event</li>
		 * <li>Key and value names must be below 255 characters</li>
		 * </ul>
		 */
		public function startTimedEvent(eventName:String, properties:Object = null):void {
			if (!checkLength(eventName)) {
				log("Couldn't start timed event " + eventName + " (too long, max 255)");
				return;
			}

			var parameterKeys:Array = [];
			var parameterValues:Array = [];
			if (properties) {
				var value:String;
				var count:int = 0;
				for (var key:String in properties) {
					if (count > 10) {
						log("Too many properties provided. Only kept " + JSON.stringify(parameterKeys));
						break;
					}

					value = properties[key].toString();
					if (checkLength(value) && checkLength(key)) {
						parameterKeys.push(key);
						parameterValues.push(value);
					}
					else {
						log("Skipped property " + key + ". Value " + value + " was too long");
					}
					count++;
				}
			}

			if (isSupported)
				_context.call("startTimedEvent", eventName, parameterKeys, parameterValues);
		}

		/**
		 * Ends a timed event specified by eventName
		 * @param eventName must be <= 255 characters
		 * @param properties map of additional parameters sent with the event. Limits :
		 * <ul>
		 * <li>Max 10 parameters per event</li>
		 * <li>Key and value names must be below 255 characters</li>
		 * </ul>
		 */
		public function stopTimedEvent(eventName:String, properties:Object = null):void {
			if (!checkLength(eventName)) {
				log("Couldn't stop timed event " + eventName + " (too long, max 255)");
				return;
			}

			var parameterKeys:Array = [];
			var parameterValues:Array = [];
			if (properties) {
				var value:String;
				var count:int = 0;
				for (var key:String in properties) {
					if (count > 10) {
						log("Too many properties provided. Only kept " + JSON.stringify(parameterKeys));
						break;
					}

					value = properties[key].toString();
					if (checkLength(value) && checkLength(key)) {
						parameterKeys.push(key);
						parameterValues.push(value);
					}
					else {
						log("Skipped property " + key + ". Value " + value + " was too long");
					}
					count++;
				}
			}

			if (isSupported)
				_context.call("stopTimedEvent", eventName, parameterKeys, parameterValues);

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
		public function logError(errorId:String, message:String = null):void {
			if (!errorId) {
				log("Couldn't log error. You need to provide an error ID.");
				return;
			}

			if (errorId.length > 255) {
				errorId = errorId.substr(0, 255);
			}

			message = message || "";
			if (message.length > 255) {
				message = message.substr(0, 255);
			}

			if (isSupported)
				_context.call("logError", errorId, message);

		}

		/**
		 * This method increments the page view count for a session when invoked
		 */
		public function logPageView():void {
			if (isSupported)
				_context.call("logPageView");
		}

		/**
		 * Use this method report session data when the app is closed. iOS only
		 * @param value
		 */
		public function set setSessionReportsOnCloseEnabled(value:Boolean):void {
			if (isIOS)
				_context.call("setSessionReportsOnCloseEnabled", value);

		}

		/**
		 * Use this method report session data when the app is paused. iOS only
		 * @param value
		 */
		public function set setSessionReportsOnPauseEnabled(value:Boolean):void {
			if (isIOS)
				_context.call("setSessionReportsOnPauseEnabled", value);

		}

		/**
		 * Use this method to enable reporting of errors and events when application is
		 *  running in backgorund (such applications have  UIBackgroundModes in Info.plist). iOS only
		 * @param value
		 */
		public function set setBackgroundSessionEnabled(value:Boolean):void {
			if (isIOS)
				_context.call("setBackgroundSessionEnabled", value);

		}

		/**
		 * This method should be used in case of #setBackgroundSessionEnabled: set to true. It can be
		 *  called when application finished all background tasks (such as playing music) to pause session. iOS only
		 */
		public function pauseBackgroundSession():void {
			if (isIOS)
				_context.call("pauseBackgroundSession");

		}

		// --------------------------------------------------------------------------------------//
		//																						 //
		// 									 	PRIVATE API										 //
		// 																						 //
		// --------------------------------------------------------------------------------------//
		
		private static const EXTENSION_ID : String = "com.freshplanet.ane.AirFlurry";
		private static var _instance : AirFlurry;
		private var _context : ExtensionContext = null;
		private var _logEnabled : Boolean = true;

		/**
		 * "private" singleton constructor
		 */
		public function AirFlurry() {
			if (!_instance) {
				_context = ExtensionContext.createExtensionContext(EXTENSION_ID, null);
				if (!_context) {
					log("ERROR - Extension context is null. Please check if extension.xml is setup correctly.");
					return;
				}
				_context.addEventListener(StatusEvent.STATUS, onStatus);

				_instance = this;
			}
			else {
				throw Error("This is a singleton, use instance, do not call the constructor directly.");
			}
		}

		private static function get isAndroid():Boolean {
			return Capabilities.manufacturer.indexOf("Android") > -1;
		}
		
		private static function get isIOS():Boolean {
			return Capabilities.manufacturer.indexOf("iOS") > -1;
		}


		private function checkLength(value:String):Boolean {
			return value && value.length < 255;
		}

		private function onStatus(event:StatusEvent):void {
			if (event.code == AirFlurryEvent.SESSION_STARTED) {
				this.dispatchEvent(new AirFlurryEvent(AirFlurryEvent.SESSION_STARTED));
			}
			else if (event.code == "log") {
				log(event.level);
			}
		}

		private function log(message:String):void {
			if (_logEnabled) trace("[AirFlurry] " + message);
		}
	}
}