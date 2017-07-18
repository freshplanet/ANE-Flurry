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

import java.util.HashMap;
import java.util.List;


import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;

public class LogEventFunction extends BaseFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {
		super.call(context, args);


		String eventName = getStringFromFREObject(args[0]);
		HashMap<String, String> params = new HashMap<String, String>();

		if ( args.length == 3 ) {
			List<String> paramsKeys = getListOfStringFromFREArray((FREArray) args[1]);
			List<String> paramsValues = getListOfStringFromFREArray((FREArray) args[2]);

			for(int i = 0; i < paramsKeys.size(); i++){
				String key = paramsKeys.get(i);
				String value = paramsValues.get(i);
				params.put(key, value);
			}
		}

		if (params.size() > 0) {
			FlurryAgent.logEvent(eventName, params);
		} else {
			FlurryAgent.logEvent(eventName);
		}

		return null;
	}

}
