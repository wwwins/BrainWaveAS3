package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import frocessing.display.*;
	import com.greensock.*; 
	import com.greensock.easing.*;
	
	/**
	 * ...
	 * @author isobar
	 */
	public class Main extends F5MovieClip2D
	{
		//private var stage_width:Number = stage.stageWidth;
		//private var stage_height:Number = stage.stageHeight;
		private var rect_w:Number = 40;
		private var rect_h:Number = 10;
		private var c:int = 7;
		private var t:Number = 0;
		
		private var myArray:Array = [0];
		private var arrMc:Array;
				
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			arrMc = [];
			for (var i:int = 0; i <= c; i++)
			{
				var bar:Bar = new Bar();
				bar.id = i;
				bar.x = (rect_w+5) * i;
				arrMc.push(bar);
				addChild(bar);
			}
			
			myArray = [0, 0, 0, 0, 0, 0, 0, 0];
			TweenMax.to( myArray, 1, { endArray:[25,25,25,25,25,25,25,25] } );
			
		}
				
		public function draw():void
		{
			if (t % 2 == 1)
			{
				for (var i:int = 0; i < arrMc.length; i++) {
					//arrMc[i].n = random(1, 25);
					arrMc[i].n = int(myArray[i]);
				}
			}
			t = t + 1;
		}
		
		public function mousePressed():void
		{
			trace("mousePressed");
			noLoop();
		}
		
		public function mouseReleased():void
		{
			trace("mouseReleased");
			loop();
		}
	
	}

}

import frocessing.display.F5MovieClip2D;

class Bar extends F5MovieClip2D
{
	private var stage_width:Number = 1280;
	private var stage_height:Number = 720;
	private var _id:int = 0;
	private var _n:int = 25;
	private var c:int = 0;
	private var t:Number = 0;
	private var rect_w:Number = 40;
	private var rect_h:Number = 10;
	private var bar_h:Number = n * (rect_h + 2);
	
	public function Bar(useStageEvent:Boolean = true)
	{
		super(useStageEvent);
		
		// 無線條
		this.noStroke()
		this.colorMode(HSV, n, 1, n);

		//this.translate(100, 100);
		
	}
	
	public function drawingBar(n:int):void
	{
		//trace("drawingBar:" + n);
		
		for (var i:int = 0; i <= c; i++)
		{
			for (var j:int = 0; j <= n; j++)
			{
				// 填色
				fill(_id, 1, j);
				
				// 畫方格
				var cx:Number = (rect_w + 2) * i;
				var cy:Number = bar_h - (rect_h + 2) * j;
				rect(cx, cy, rect_w, rect_h);

				// 畫圓
				//var cx:Number = 33 + 40 * i;
				//var cy:Number = 33 + 40 * j;
				//circle( cx, cy, 19 );
			}
		}
	}
	
	public function draw():void {
		drawingBar(n);
	}
	
	public function get n():int 
	{
		return _n;
	}
	
	public function set n(value:int):void 
	{
		_n = value;
	}
	
	public function set id(value:int):void 
	{
		_id = value;
	}

}