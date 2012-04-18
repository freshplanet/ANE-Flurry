package com.freshplanet.flurry;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.flurry.android.FlurryAgent;

public class StopSessionFunction implements FREFunction {


	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {
		FlurryAgent.onEndSession(arg0.getActivity());
		return null;
	}

}
