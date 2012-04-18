package com.freshplanet.flurry;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.FlurryAgent;

public class StartSessionFunction implements FREFunction {

	private static String TAG = "StartSessionFunction";
	
	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String apiKey = null;
		try {
			apiKey = arg1[0].getAsString();
		} catch (IllegalStateException e) {
			e.printStackTrace();
		} catch (FRETypeMismatchException e) {
			e.printStackTrace();
		} catch (FREInvalidObjectException e) {
			e.printStackTrace();
		} catch (FREWrongThreadException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		if (apiKey != null)
		{
			FlurryAgent.onStartSession(arg0.getActivity(), apiKey);
		} else
		{
			Log.e(TAG, "API Key is null");
		}
		
		return null;
	}

}
