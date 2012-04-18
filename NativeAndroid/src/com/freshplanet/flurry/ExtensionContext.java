
package com.freshplanet.flurry;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

public class ExtensionContext extends FREContext {

	private static String TAG = "FlurryContext";

	public ExtensionContext() {
		Log.d(TAG, "ExtensionContext.FlurryContext");
	}
	
	@Override
	public void dispose() {
		Log.d(TAG, "ExtensionContext.dispose");
		Extension.context = null;
	}

	/**
	 * Registers AS function name to Java Function Class
	 */
	@Override
	public Map<String, FREFunction> getFunctions() {
		Log.d(TAG, "ExtensionContext.getFunctions");
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("startSession", new StartSessionFunction());
		functionMap.put("stopSession", new StopSessionFunction());
		functionMap.put("logEvent", new LogEventFunction());
		functionMap.put("logError", new LogErrorFunction());
		functionMap.put("setAppVersion", new SetAppVersionFunction());
		functionMap.put("setUserId", new SetUserIdFunction());
		functionMap.put("setUserInfo", new SetUserInfoFunction());
		functionMap.put("setSendEventsOnPause", new SetSendEventsOnPauseFunction());
		return functionMap;	
	}

}
