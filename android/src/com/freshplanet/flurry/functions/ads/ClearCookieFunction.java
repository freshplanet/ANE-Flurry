package com.freshplanet.flurry.functions.ads;

import java.util.Map;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAds;
import com.freshplanet.flurry.ExtensionContext;

public class ClearCookieFunction implements FREFunction
{
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1)
	{
		Map<String, String> userCookies = ((ExtensionContext)arg0).getUserCookies();
		userCookies.clear();
		FlurryAds.clearUserCookies();
		return null;
	}

}
