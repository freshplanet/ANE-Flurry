/*
 * Copyright 2017 FreshPlanet
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package {


import com.freshplanet.ane.AirFlurry.AirFlurry;
import com.freshplanet.ane.AirFlurry.enums.AirFlurryGender;
import com.freshplanet.ane.AirFlurry.events.AirFlurryEvent;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;

import com.freshplanet.ui.ScrollableContainer;
import com.freshplanet.ui.TestBlock;

[SWF(backgroundColor="#057fbc", frameRate='60')]
public class Main extends Sprite {

    public static var stageWidth:Number = 0;
    public static var indent:Number = 0;

    private var _scrollableContainer:ScrollableContainer = null;

    public function Main() {
        this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
    }

    private function _onAddedToStage(event:Event):void {
        this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
        this.stage.align = StageAlign.TOP_LEFT;

        stageWidth = this.stage.stageWidth;
        indent = stage.stageWidth * 0.025;

        _scrollableContainer = new ScrollableContainer(false, true);
        this.addChild(_scrollableContainer);

        if (!AirFlurry.isSupported) {
            trace("AirFlurry ANE is NOT supported on this platform!");
            return;
        }

	    AirFlurry.instance.addEventListener(
                AirFlurryEvent.SESSION_STARTED,
                onSessionStarted);

        var blocks:Array = [];

        blocks.push(new TestBlock("init", function():void {
	        AirFlurry.instance.init("V5SY5PXDJFSTQHNZ839D", "1.0.1", 1000);
        }));
        blocks.push(new TestBlock("logEvent", function():void {
	        if(AirFlurry.instance.isSessionOpen)
	            AirFlurry.instance.logEvent("testing_event");
        }));
	    blocks.push(new TestBlock("logPageView", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.logPageView();
	    }));
	    blocks.push(new TestBlock("startTimedEvent", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.startTimedEvent("timed_event");
	    }));
	    blocks.push(new TestBlock("stopTimedEvent", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.stopTimedEvent("timed_event");
	    }));
	    blocks.push(new TestBlock("logError", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.logError("test_error", "test error occured");
	    }));
	    blocks.push(new TestBlock("setUserAge", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.setUserAge(21);
	    }));
	    blocks.push(new TestBlock("setUserGender", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.setUserGender(AirFlurryGender.FEMALE);
	    }));
	    blocks.push(new TestBlock("setUserId", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.setUserId("test_user_id");
	    }));
	    blocks.push(new TestBlock("setLocation", function():void {
		    if(AirFlurry.instance.isSessionOpen)
		        AirFlurry.instance.setLocation(40.730610, -73.935242, 60.0, 60.0);
	    }));


        /**
         * add ui to screen
         */

        var nextY:Number = indent;

        for each (var block:TestBlock in blocks) {

            _scrollableContainer.addChild(block);
            block.y = nextY;
            nextY +=  block.height + indent;
        }
    }

	private function onSessionStarted(event:AirFlurryEvent):void {
		trace("onSessionStarted");
	}


}
}
