Air Native Extension for Flurry Analytics & Ads (iOS + Android)
======================================

This is an [Air native extension](http://www.adobe.com/devnet/air/native-extensions-for-air.html) for [Flurry](http://flurry.com) SDK on iOS and Android. It has been developed by [FreshPlanet](http://freshplanet.com) and is used in the game [SongPop](http://songpop.fm).


Flurry SDK
---------

This ANE uses Flurry SDK version 4.0.2 on iOS and 3.0.2 on Android.

It supports most features of Flurry Analytics and Flurry Ads. See the documentation of the Actioncript **Flurry** class for more information.

The following third-party ad networks are supported:

* AdMob
* Greystripe
* InMobi
* Jumptap
* Millenial Media (iOS only)
* Mobclix


Installation
---------

The ANE binary (AirFlurry.ane) is located in the *bin* folder. You should add it to your application project's Build Path and make sure to package it with your app (more information [here](http://help.adobe.com/en_US/air/build/WS597e5dadb9cc1e0253f7d2fc1311b491071-8000.html)).

On iOS:

* you will need to package against the iOS SDK 4.3. If you want to use iOS SDK 5 or 6, you need to edit *build/platform.xml* and replace *-lz.1.2.3* with *-lz.1.2.5*.
* if you want to use third-party networks, you need to add your credentials as an Info.plist addition in your application descriptor:

    <iPhone>
        <InfoAdditions><![CDATA[
            ...
            <key>AppSpotCredentials</key>
            <dict>
                <key>AdMobPublisherID</key>
                <string>...</string>
                <key>GreystripeApplicationID</key>
                <string>...</string>
                <key>InMobiAppKey</key>
                <string>...</string>
                <key>JumptapApplicationID</key>
                <string>...</string>
                <key>MillenialAppKey</key>
                <string>...</string>
                <key>MillenialInterstitialAppKey</key>
                <string>...</string>
                <key>MobclixApplicationID</key>
                <string>...</string>
            </dict>
        ]]></InfoAdditions>
        ...
    </iPhone>

On Android:

* you might run into a Java.lang.OutOfMemoryError when trying to package your application. This is due to Flurry SDK containing too many files. We provide a solution on [our blog](http://freshplanet-xp.tumblr.com/post/30344545748/packaging-ane-with-large-third-party-sdks).
* if you want to use third-party networks, you need to add the proper permissions, activities and metadata as a Manifest addition in your application descriptor:

    <android>
        <manifestAdditions><![CDATA[
            <manifest android:installLocation="auto">
                
                ...

                <uses-permission android:name="android.permission.INTERNET"/>
                <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
                <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
                
                ...

                <application>

                    ...
                    
                    <!-- Flurry Fullscreen Takeover Activity -->
                    <activity android:name="com.flurry.android.FlurryFullscreenTakeoverActivity" android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize" android:screenOrientation="portrait"></activity>
                    
                    <!-- Flurry 3rd-Party Networks Activities -->
                    <!-- AdMob -->
                    <activity android:name="com.google.ads.AdActivity" android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"/>
                    <!-- InMobi -->
                    <activity android:name="com.inmobi.androidsdk.IMBrowserActivity" android:configChanges="keyboardHidden|orientation|keyboard"/>
                    <!-- Mobclix -->
                    <activity android:name="com.mobclix.android.sdk.MobclixBrowserActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:hardwareAccelerated="true"/>
                     
                    <!-- Flurry 3rd-Party Networks MetaData -->
                    <!-- AdMob -->
                    <meta-data android:name="com.flurry.admob.MY_AD_UNIT_ID" android:value="..."/>
                    <!-- InMobi -->
                    <meta-data android:name="com.flurry.inmobi.MY_APP_ID" android:value="..."/>
                    <!-- <meta-data android:name="com.flurry.inmobi.test" android:value="true"/> -->
                    <!-- Mobclix -->
                    <meta-data android:name="com.mobclix.APPLICATION_ID" android:value="..."/>
                    <!-- Jumptap -->
                    <meta-data android:name="com.flurry.jumptap.PUBLISHER_ID" android:value="..."/>
                    
                </application>

            </manifest>
        ]]></manifestAdditions>
    </android>


Build script
---------

Should you need to edit the extension source code and/or recompile it, you will find an ant build script (build.xml) in the *build* folder:

    cd /path/to/the/ane/build
    mv example.build.config build.config
    #edit the build.config file to provide your machine-specific paths
    ant


Authors
------

This ANE has been written by [Thibaut Crenn](https://github.com/titi-us) (Analytics) and [Alexis Taugeron](http://alexistaugeron.com) (Ads). It belongs to [FreshPlanet Inc.](http://freshplanet.com) and is distributed under the [Apache Licence, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).