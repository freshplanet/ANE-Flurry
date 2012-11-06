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

package com.freshplanet.flurry.functions.ads;

import android.util.Log;
import android.widget.RelativeLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.FlurryAdSize;
import com.flurry.android.FlurryAgent;
import com.freshplanet.flurry.ExtensionContext;

public class ShowAdFunction implements FREFunction
{
	private static String TAG = "Flurry - ShowAdFunction";
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		// Retrieve the ad space name
		String space = null;
		try
		{
			space = arg1[0].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			return null;
		}
		
		// Retrieve the ad size
		FlurryAdSize size;
		try
		{
			String sizeString = arg1[1].getAsString();
			
			if (sizeString == "BANNER_TOP")
			{
				size = FlurryAdSize.BANNER_TOP;
			}
			else if (sizeString == "BANNER_BOTTOM")
			{
				size = FlurryAdSize.BANNER_BOTTOM;
			}
			else
			{
				size = FlurryAdSize.FULLSCREEN;
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			Log.d(TAG, "Couldn't retrieve ad size. Defaulting to fullscreen.");
			size = FlurryAdSize.FULLSCREEN;
		}
		
		// Retrieve the ad timeout
		long timeout;
		try
		{
			timeout = arg1[2].getAsInt();
		}
		catch (Exception e)
		{
			e.printStackTrace();
			Log.d(TAG, "Couldn't retrieve ad timout. Defaulting to 0 (asynchronous).");
			timeout = 0;
		}
		
		// Update space status
		ExtensionContext context = (ExtensionContext)arg0;
		context.setStatusForSpace(true, space);
		
		// Try to show an ad
		RelativeLayout adLayout = ((ExtensionContext)arg0).getNewAdLayout();
		Boolean result = FlurryAgent.getAd(arg0.getActivity(), space, adLayout, size, timeout);
		
		// Return the result (true if the ad was shown, false otherwise)
		try
		{
			return FREObject.newObject(result);
		}
		catch (FREWrongThreadException exception)
		{
			Log.d(TAG, exception.getLocalizedMessage());
			return null;
		}
	}

}
