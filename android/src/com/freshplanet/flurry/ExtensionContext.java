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

package com.freshplanet.flurry;

import java.util.HashMap;
import java.util.Map;

import android.util.Log;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.FrameLayout.LayoutParams;
import android.widget.RelativeLayout;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.flurry.android.FlurryAdListener;
import com.flurry.android.FlurryAdType;
import com.freshplanet.flurry.functions.ads.AddTargetingKeywordFunction;
import com.freshplanet.flurry.functions.ads.AddUserCookieFunction;
import com.freshplanet.flurry.functions.ads.ClearCookieFunction;
import com.freshplanet.flurry.functions.ads.ClearTargetingKeywordsFunction;
import com.freshplanet.flurry.functions.ads.FetchAdFunction;
import com.freshplanet.flurry.functions.ads.RemoveAdFunction;
import com.freshplanet.flurry.functions.ads.ShowAdFunction;
import com.freshplanet.flurry.functions.analytics.LogErrorFunction;
import com.freshplanet.flurry.functions.analytics.LogEventFunction;
import com.freshplanet.flurry.functions.analytics.SetAppVersionFunction;
import com.freshplanet.flurry.functions.analytics.SetSendEventsOnPauseFunction;
import com.freshplanet.flurry.functions.analytics.SetUserIdFunction;
import com.freshplanet.flurry.functions.analytics.SetUserInfoFunction;
import com.freshplanet.flurry.functions.analytics.StartSessionFunction;
import com.freshplanet.flurry.functions.analytics.StartTimedEventFunction;
import com.freshplanet.flurry.functions.analytics.StopSessionFunction;
import com.freshplanet.flurry.functions.analytics.StopTimedEventFunction;

public class ExtensionContext extends FREContext implements FlurryAdListener
{
	private RelativeLayout _adLayout = null;
	
	private Map<String, String> _userCookies = null;
	private Map<String, String> _targetingKeywords = null;
	private Map<String, Boolean> _spacesStatus = null;
	

	public ExtensionContext()
	{
		Log.d(Extension.TAG, "Context created.");
	}
	
	@Override
	public void dispose()
	{
		Log.d(Extension.TAG, "Context disposed.");
		Extension.context = null;
	}

	@Override
	public Map<String, FREFunction> getFunctions()
	{
		Map<String, FREFunction> functionMap = new HashMap<String, FREFunction>();
		functionMap.put("startSession", new StartSessionFunction());
		functionMap.put("stopSession", new StopSessionFunction());
		functionMap.put("logEvent", new LogEventFunction());
		functionMap.put("logError", new LogErrorFunction());
		functionMap.put("setAppVersion", new SetAppVersionFunction());
		functionMap.put("setUserId", new SetUserIdFunction());
		functionMap.put("setUserInfo", new SetUserInfoFunction());
		functionMap.put("setSendEventsOnPause", new SetSendEventsOnPauseFunction());
		functionMap.put("startTimedEvent", new StartTimedEventFunction());
		functionMap.put("stopTimedEvent", new StopTimedEventFunction());
		
		functionMap.put("showAd", new ShowAdFunction());
		functionMap.put("fetchAd", new FetchAdFunction());
		functionMap.put("removeAd", new RemoveAdFunction());
		functionMap.put("addUserCookie", new AddUserCookieFunction());
		functionMap.put("clearCookie", new ClearCookieFunction());
		functionMap.put("addTargetingKeyword", new AddTargetingKeywordFunction());
		functionMap.put("clearTargetingKeywords", new ClearTargetingKeywordsFunction());
		
		return functionMap;	
	}
	
	
	// Ad layout
	
	public RelativeLayout getNewAdLayout()
	{
		// Retrieve the game container
		ViewGroup mainContainer = (ViewGroup)getActivity().findViewById(android.R.id.content);
		mainContainer = (ViewGroup)mainContainer.getChildAt(0);
		
		// Remove the previous ad layout (if any)
		if (_adLayout != null) mainContainer.removeView(_adLayout);
		
		// Create a new ad layout
		_adLayout = new RelativeLayout(getActivity());
		mainContainer.addView(_adLayout, new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
		
		return _adLayout;
	}
	
	public RelativeLayout getCurrentAdLayout()
	{
		return _adLayout;
	}
	
	
	// User cookies
	
	public Map<String, String> getUserCookies()
	{
		if (_userCookies == null)
		{
			_userCookies = new HashMap<String, String>();
		}
		
		return _userCookies;
	}
	
	// Targeting keywords
	
	public Map<String, String> getTargetingKeywords()
	{
		if (_targetingKeywords == null)
		{
			_targetingKeywords = new HashMap<String, String>();
		}
		
		return _targetingKeywords;
	}
	
	// Spaces status (true when a space should be displayed, false otherwise)
	
	private Map<String, Boolean> spacesStatus()
	{
		if (_spacesStatus == null)
		{
			_spacesStatus = new HashMap<String, Boolean>();
		}
		
		return _spacesStatus;
	}
	
	public Boolean getStatusForSpace(String space)
	{
		return this.spacesStatus().containsKey(space) ? this.spacesStatus().get(space) : false;
	}
	
	public void setStatusForSpace(Boolean status, String space)
	{
		this.spacesStatus().put(space, status);
	}
	
	
	// Flurry IListener
	
	@Override
	public void onRenderFailed(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Ad render failed: " + myAdSpaceName);
		
		dispatchStatusEventAsync("SPACE_DID_FAIL_TO_RENDER", myAdSpaceName);
	}
	
	@Override
	public boolean shouldDisplayAd(String myAdSpaceName, FlurryAdType type)
	{
		return getStatusForSpace(myAdSpaceName);
	}
	
	@Override
	public void onAdClosed(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Closed ad: " + myAdSpaceName);
		
		dispatchStatusEventAsync("SPACE_DID_DISMISS", myAdSpaceName);
	}
	
	@Override
	public void onApplicationExit(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Exit application after clicking on ad: " + myAdSpaceName);
		
		dispatchStatusEventAsync("SPACE_WILL_LEAVE_APPLICATION", myAdSpaceName);
	}
	
	@Override
	public void spaceDidReceiveAd(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Space did receive ad: " + myAdSpaceName);
	}
	
	@Override
	public void spaceDidFailToReceiveAd(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Space did fail to receive ad: " + myAdSpaceName);
		
		dispatchStatusEventAsync("SPACE_DID_FAIL_TO_RENDER", myAdSpaceName);
	}
	
	@Override
	public void onAdOpened(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Ad opened: " + myAdSpaceName);
	}
	
	@Override
	public void onAdClicked(String myAdSpaceName)
	{
		Log.d(Extension.TAG, "Ad clicked: " + myAdSpaceName);
	}
}
