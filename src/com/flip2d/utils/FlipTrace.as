package com.flip2d.utils {
	/**
	 * @author emil
	 */
	public class FlipTrace {
		
		public static function trace(... args):void {
			var out:Array = [];
			for each (var arg in args){
				out.push(arg);
			}
			trace("[ Flip2D ] : [ " + out + " ]");
		}
	}
}
