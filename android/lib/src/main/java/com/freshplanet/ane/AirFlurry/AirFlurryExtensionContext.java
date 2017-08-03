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

package com.freshplanet.ane.AirFlurry;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.freshplanet.ane.AirFlurry.functions.InitFunction;
import com.freshplanet.ane.AirFlurry.functions.IsSessionOpenFunction;
import com.freshplanet.ane.AirFlurry.functions.LogErrorFunction;
import com.freshplanet.ane.AirFlurry.functions.LogEventFunction;
import com.freshplanet.ane.AirFlurry.functions.LogPageViewFunction;
import com.freshplanet.ane.AirFlurry.functions.SetLocationFunction;
import com.freshplanet.ane.AirFlurry.functions.SetUserAgeFunction;
import com.freshplanet.ane.AirFlurry.functions.SetUserGenderFunction;
import com.freshplanet.ane.AirFlurry.functions.SetUserIdFunction;
import com.freshplanet.ane.AirFlurry.functions.StartTimedEventFunction;
import com.freshplanet.ane.AirFlurry.functions.StopTimedEventFunction;

public class AirFlurryExtensionContext extends FREContext
{	
	public AirFlurryExtensionContext()
	{
		Log.d(AirFlurryExtension.TAG, "Context created.");
	}
	
	@Override
	public void dispose()
	{
		Log.d(AirFlurryExtension.TAG, "Context disposed.");
		AirFlurryExtension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("initFlurry", new InitFunction());
		functionMap.put("logEvent", new LogEventFunction());
		functionMap.put("logError", new LogErrorFunction());
		functionMap.put("setUserId", new SetUserIdFunction());
		functionMap.put("setUserAge", new SetUserAgeFunction());
		functionMap.put("setUserGender", new SetUserGenderFunction());
		functionMap.put("startTimedEvent", new StartTimedEventFunction());
		functionMap.put("stopTimedEvent", new StopTimedEventFunction());
		functionMap.put("setLocation", new SetLocationFunction());
		functionMap.put("logPageView", new LogPageViewFunction());
		functionMap.put("isSessionOpen", new IsSessionOpenFunction());
		
		return functionMap;	
	}
}
