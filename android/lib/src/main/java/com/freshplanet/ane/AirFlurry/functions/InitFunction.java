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

import com.adobe.fre.FREContext;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;
import com.flurry.android.FlurryAgentListener;
import com.freshplanet.ane.AirFlurry.Constants;

import static android.util.Log.VERBOSE;

public class InitFunction extends BaseFunction {

	@Override
	public FREObject call(FREContext context, FREObject[] args) {

		super.call(context, args);

		final FREContext appContext = context;
		String apiKey = getStringFromFREObject(args[0]);
		String appVersion = getStringFromFREObject(args[1]);
		int continueSessionInMillis = getIntFromFREObject(args[2]);

		FlurryAgent.setVersionName(appVersion);
		new FlurryAgent.Builder()
				.withLogEnabled(true)
				.withCaptureUncaughtExceptions(true)
				.withContinueSessionMillis(continueSessionInMillis)
				.withLogEnabled(true)
				.withLogLevel(VERBOSE)
				.withListener(new FlurryAgentListener() {
					@Override
					public void onSessionStarted() {
						appContext.dispatchStatusEventAsync(Constants.AirFlurryEvent_SESSION_STARTED, "");

					}
				})
				.build(context.getActivity(), apiKey);



		return null;
	}

}
