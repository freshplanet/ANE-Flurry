package com.freshplanet.flurry;

import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREInvalidObjectException;
import com.adobe.fre.FREObject;
import com.adobe.fre.FRETypeMismatchException;
import com.adobe.fre.FREWrongThreadException;
import com.flurry.android.Constants;
import com.flurry.android.FlurryAgent;

public class SetUserInfoFunction implements FREFunction {

	private static String TAG = "SetUserInfoFunction";

	@Override
	public FREObject call(FREContext arg0, FREObject[] arg1) {

		int age = 0;
		
		try {
			age = arg1[0].getAsInt();
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
		
		if (age > 0)
		{
			FlurryAgent.setAge(age);
		}  else
		{
			Log.d(TAG, "age is null");
		}
		
		String genderString = null;
		
		byte gender = 0;
		
		try {
			genderString = arg1[1].getAsString();
			if (genderString == "m")
			{
				gender = Constants.MALE;
			}
			else if (genderString == "f")
			{
				gender = Constants.FEMALE;
			}
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
		
		
		if (genderString != null)
		{
			FlurryAgent.setGender(gender);
		} else
		{
			Log.d(TAG, "gender is null");
		}

		return null;
	}

}
