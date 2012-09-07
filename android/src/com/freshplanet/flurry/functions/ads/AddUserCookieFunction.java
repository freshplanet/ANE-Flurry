package com.freshplanet.flurry.functions.ads;

import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;
import com.freshplanet.flurry.ExtensionContext;

public class AddUserCookieFunction implements FREFunction
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
			Map<String, String> userCookies = ((ExtensionContext)arg0).getUserCookies();
			userCookies.put(key, value);
			FlurryAgent.setUserCookies(userCookies);
		}
		else
		{
			Log.d("Flurry", "Cannot add cookies");
		}
		
		
		return null;
	}

}
