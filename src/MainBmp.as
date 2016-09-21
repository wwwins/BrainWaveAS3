package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import frocessing.display.*;
	
	/**
	 * F5MovieClip2DBmp
	 * @author isobar
	 */
	public class MainBmp extends F5MovieClip2DBmp 
	{
		private var stage_width: Number = stage.stageWidth;
		private var stage_height: Number = stage.stageHeight;
		private var n: int = 5;
		private var t: Number = 0;
		
		public function MainBmp() 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			size(stage_width, stage_height);
			background(0);
			noFill();
			// https://processing.org/reference/colorMode_.html
			// 切換顏色模式預設為RGB
			colorMode( HSV, 2, 1, 1 );
			//stroke(255, .1);
		}
		
		public function draw(): void {
			if (isMousePressed)
				background(0, 1);

			translate(0, stage_height / 2);
			// stroke 用法可以看 http://gihyo.jp/design/feature/01/frocessing/0002
			// https://processing.org/reference/stroke_.html
			// HSV
			stroke( t, 1, 0.75, 0.2 );
			
			beginShape();
			// curveVertex: 最少需要四個點，只能用在beginShape/endShape
			// http://gihyo.jp/design/feature/01/frocessing/0003?page=2
			// https://processing.org/reference/curveVertex_.html
			curveVertex(-100, 0);
			for (var i: int = 0; i <= n; i++) {
				var xx: Number = i * stage_width / n;
				var yy: Number = noise(i * 0.25, t) * 300 - 150;
				curveVertex(xx, yy);
			}
			curveVertex(stage_width + 100, 0);
			endShape();
			t += 0.01;
		}
	}
	
}