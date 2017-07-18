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
package com.freshplanet.ane.AirFlurry.enums {
public class AirFlurryGender {


	/***************************
	 *
	 * PUBLIC
	 *
	 ***************************/


	static public const MALE                : AirFlurryGender = new AirFlurryGender(Private, "m");
	static public const FEMALE              : AirFlurryGender = new AirFlurryGender(Private, "f");

	public static function fromValue(value:String):AirFlurryGender {

		switch (value)
		{
			case MALE.value:
				return MALE;
				break;
			case FEMALE.value:
				return FEMALE;
				break;
			default:
				return null;
			break;
		}
	}

	public function get value():String {
		return _value;
	}

	/***************************
	 *
	 * PRIVATE
	 *
	 ***************************/

	private var _value:String = null;

	public function AirFlurryGender(access:Class, value:String) {

		if (access != Private)
			throw new Error("Private constructor call!");

		_value = value;
	}
}
}

final class Private {}
