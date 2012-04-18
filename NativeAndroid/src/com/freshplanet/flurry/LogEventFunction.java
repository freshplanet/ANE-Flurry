package com.freshplanet.flurry;

import java.util.HashMap;

import android.util.Log;

import com.adobe.fre.FREArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.FlurryAgent;

public class LogEventFunction implements FREFunction {

	private static String TAG = "LogEventFunction";

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		
		String eventName = null;
		
		try {
			eventName = arg1[0].getAsString();
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
		

		HashMap<String, String> params = new HashMap<String, String>();
		
		if ( arg1[1]  != null && arg1[2] != null)
		{
			FREArray paramsKeys = (FREArray) arg1[1];
			FREArray paramsValue = (FREArray) arg1[2];
			
			try {
				long paramsLength = paramsKeys.getLength();
				for (long i = 0; i < paramsLength; i++)
				{
					FREObject key = paramsKeys.getObjectAt(i);
					FREObject value = paramsValue.getObjectAt(i);
					String keyString = key.getAsString();
					String valueString = value.getAsString();
					params.put(keyString, valueString);
				}
			
			} catch (FREInvalidObjectException e) {
				e.printStackTrace();
			} catch (FREWrongThreadException e) {
				e.printStackTrace();
			} catch (IllegalStateException e) {
				e.printStackTrace();
			} catch (FRETypeMismatchException e) {
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}
		} else if (arg1[1] != null)
		{
			Log.e(TAG, "parameterValues is null while parameterKeys is not");
		} else if (arg1[2] != null)
		{
			Log.e(TAG, "parameterKeys is null while parameterValues is not");
		}
		
		if (eventName != null) {
			if (params != null && params.size() > 0) {
				FlurryAgent.logEvent(eventName, params);
			} else {
				FlurryAgent.logEvent(eventName);
			}
		} else {
			Log.d(Extension.TAG, "null event name");
		}
		
		
		
		return null;
	}

}
