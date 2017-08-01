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

package com.freshplanet.ane.AirFlurry.functions;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.flurry.android.Constants;
import com.flurry.android.FlurryAgent;

public class SetUserGenderFunction extends BaseFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		super.call(context, args);

		byte gender = 0;
		String genderString = getStringFromFREObject(args[0]);
		if (genderString.compareTo("m") == 0) {
			gender = Constants.MALE;
		}
		else if (genderString.compareTo("f") == 0) {
			gender = Constants.FEMALE;
		}
		FlurryAgent.setGender(gender);

		return null;
	}

}
