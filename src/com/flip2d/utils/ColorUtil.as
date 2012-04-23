package com.flip2d.utils {
	/**
	 * @author emil
	 */
	public class ColorUtil {
		public static function vec3cColorToHex(hexVal:Number):Array {
			var r:Number = ((hexVal >> 16) & 0xff)/255;
			var g:Number = ((hexVal >> 8) & 0xff)/255;
			var b:Number = (hexVal & 0xff)/255; 
			
			return [r,g,b];
		}
	}
}
