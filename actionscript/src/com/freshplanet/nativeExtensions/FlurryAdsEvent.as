package com.freshplanet.nativeExtensions
{
	import flash.events.Event;

	public class FlurryAdsEvent extends Event
	{
		public static const SPACE_DID_DISMISS:String = "SPACE_DID_DISMISS";
		public static const SPACE_WILL_LEAVE_APPLICATION:String = "SPACE_WILL_LEAVE_APPLICATION";
		public static const SPACE_DID_FAIL_TO_RENDER:String = "SPACE_DID_FAIL_TO_RENDER";
		
		/** Name of the ad space related to the event. */
		public var adSpace:String;
		
		public function FlurryAdsEvent( type : String, adSpace : String, bubbles : Boolean = false, cancelable : Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.adSpace = adSpace;
		}
	}
}