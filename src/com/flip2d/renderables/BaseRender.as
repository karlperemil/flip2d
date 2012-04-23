package com.flip2d.renderables {
	import com.flip2d.RenderConstants;
	/**
	 * @author emil
	 */
	public class BaseRender {
		public var width:Number = 250;
		public var height:Number = 250;
		public var alpha:Number = 1;
		public var filters : Array = [];
		public var x : Number = 0;
		public var y : Number = 0;
		public var color:Number = 0xff0000;
		public var renderMode:String = RenderConstants.HUE_RENDER;
	}
}
