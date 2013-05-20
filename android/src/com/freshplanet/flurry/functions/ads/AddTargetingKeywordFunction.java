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

import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.Extension;
import com.freshplanet.flurry.ExtensionContext;

public class AddTargetingKeywordFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		String key = null;
		String value = null;
		
		try
		{
			key = arg1[0].getAsString();
			value = arg1[1].getAsString();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		if (key != null && value != null)
		{
			Map<String, String> targetingKeywords = ((ExtensionContext)arg0).getTargetingKeywords();
			targetingKeywords.put(key, value);
			FlurryAds.setTargetingKeywords(targetingKeywords);
		}
		else
		{
			Log.d(Extension.TAG, "Cannot add targeting keyword");
		}
		
		return null;
	}
}
