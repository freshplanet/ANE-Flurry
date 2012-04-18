package com.freshplanet.flurry;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class SetSendEventsOnPauseFunction implements FREFunction {

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {

		// dont do anything, created only for ios compatibility
		
		return null;
	}

}
