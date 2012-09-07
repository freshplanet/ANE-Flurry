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

package com.freshplanet.flurry.functions.analytics;

import android.content.Context;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;
import com.freshplanet.flurry.ExtensionContext;

public class StartSessionFunction implements FREFunction
{
	private static String TAG = "Flurry - StartSessionFunction";
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		String apiKey = null;
		try
		{
			apiKey = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		if (apiKey != null)
		{
			// Set Flurry logs
			FlurryAgent.setLogEnabled(true);
			FlurryAgent.setLogLevel(Log.DEBUG);
			
			// Start Flurry session and initialize ads
			FlurryAgent.onStartSession(arg0.getActivity(), apiKey);
			FlurryAgent.initializeAds(arg0.getActivity());
			FlurryAgent.setAdListener((ExtensionContext)arg0);
			Log.d(TAG, "Started session and initalized ads");
			
			// Listen to the user location
			LocationManager locationManager = (LocationManager)(arg0.getActivity().getSystemService(Context.LOCATION_SERVICE));
			Criteria locationCriteria = new Criteria();
			locationCriteria.setAccuracy(Criteria.ACCURACY_COARSE);
			String locationProvider = locationManager.getBestProvider(locationCriteria, true);
			Location location = locationManager.getLastKnownLocation(locationProvider);
			if (location != null)
			{
				float latitude = (float)location.getLatitude();
				float longitude = (float)location.getLongitude();
				FlurryAgent.setLocation(latitude, longitude);
				
				Log.d(TAG, "Retrieved user location: ("+latitude+", "+longitude+")");
			}
			else
			{
				Log.d(TAG, "Couldn't retrieve user location (locationProvider = " + locationProvider + ")");
			}
		}
		else
		{
			Log.e(TAG, "API Key is null");
		}
		
		return null;
	}

}
