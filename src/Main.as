package 
{
	import com.flip2d.RenderConstants;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import com.greensock.TweenLite;
	import flash.events.Event;
	import com.flip2d.renderables.Sprite2D;
	import com.flip2d.Flip2DCanvas;
	import flash.display.Sprite;

	public class Main extends Sprite {
		private var canvas : Flip2DCanvas;
		private var s : Sprite2D;
		public function Main()
		{
			canvas = new Flip2DCanvas(500,500);
			addChild(canvas);
			
			s = new Sprite2D();
			canvas.add(s);
			var s2:Sprite2D = new Sprite2D();
			s2.x = 250;
			s2.y = 250;
			s2.renderMode = RenderConstants.SEPIA_RENDER;
			canvas.add(s2);
			
			addEventListener(Event.RESIZE, onResize);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			TweenLite.to(s,3,{x:250});
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
		}

		private function onEnterFrame(event : Event) : void {

		}

		private function onResize(event : Event) : void {
			canvas.canvasWidth = stage.stageWidth;
			canvas.canvasHeight = stage.stageHeight;
		}
	}
}
