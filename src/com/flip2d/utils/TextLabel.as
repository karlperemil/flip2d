package com.flip2d.utils {
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.display.Sprite;

	/**
	 * @author emil
	 */
	public class TextLabel extends Sprite {
		public var txt:TextField = new TextField();
		public function TextLabel(value:String,xval:Number=10, yval:Number=10) {
			addChild(txt);
			var txf:TextFormat = new TextFormat("Arial",14,0xffffff);
			txt.background = true;
			txt.defaultTextFormat = txf;
			txt.setTextFormat(txf);
			txt.backgroundColor = 0x000000;
			txt.x = xval;
			txt.y = yval;
			txt.text = value;
			txt.width = 350;
			txt.height = txt.textHeight + 100;
			
			
		}
	}
}
