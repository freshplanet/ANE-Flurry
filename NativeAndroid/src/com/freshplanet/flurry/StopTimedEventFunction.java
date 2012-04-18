package com.freshplanet.flurry;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.FlurryAgent;

public class StopTimedEventFunction implements FREFunction {

	private static String TAG = "StopTimedEventFunction";

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

		if (eventName != null) {
			FlurryAgent.endTimedEvent(eventName);
		} else {
			Log.d(TAG, "null event name");
		}
		
		return null;
	}

}
