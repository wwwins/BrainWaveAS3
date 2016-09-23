package
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import frocessing.display.*;
	
	/**
	 * Philips Brain Wave Project
	 * @author isobar
	 */
	public class Main extends F5MovieClip2D
	{
		public static const BAR_FPS:int = 10;
		
		public static const PAGE_STAND_BY:int = 0;
		public static const PAGE_START:int = 1;
		public static const PAGE_MAIN:int = 2;
		public static const PAGE_ANALYZING_EEG:int = 3;
		public static const PAGE_FINISH:int = 4;
		
		private var stage_width:Number = stage.stageWidth;
		private var stage_height:Number = stage.stageHeight;
		private var rect_w:Number = 40;
		private var rect_h:Number = 10;
		private var c:int = 7;
		private var t:Number = 0;
		private var status:int = 0;
		private var eegArray:Array;
		private var attentionArray:Array;
		private var arrBar:Array;
		private var userId:int = 0;
		
		private var tm:Timer;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			initExternalInterface();
			setupStandByFrame();
		}
		
		// 進入待機畫面
		private function setupStandByFrame():void
		{
			var page:MovieClip = new StandBy();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_STAND_BY;
		
		}
		
		// 進入遊戲 intro 畫面
		private function setupStartFrame():void
		{
			this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new StartPage();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_START;
		
		}
		
		// 遊戲主畫面
		private function setupMainFrame():void
		{
			this.removeChildAt(this.numChildren - 1);
			
			//setupFrocessing();
			var page:MovieClip = new MainPage();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_MAIN;
		}
		
		// 計算情緒代碼，顯示 Loading
		private function setupAnalyzingEEGFrame():void
		{
			this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new AnalyzingEEG();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_ANALYZING_EEG;
		
		}
		
		// 結果畫面
		private function setupFinishFrame(__gender:String, __age:String):void
		{
			this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new Finish();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_FINISH;
		}
		
		private function setupFrocessing():void
		{
			eegArray = [];
			attentionArray = [];
			arrBar = [];
			for (var i:int = 0; i <= c; i++)
			{
				var bar:Bar = new Bar();
				bar.id = i;
				bar.x = (rect_w + 5) * i;
				arrBar.push(bar);
				addChild(bar);
			}
			
			var wave:Wave = new Wave();
			addChild(wave);
		
		}
		
		public function draw():void
		{
			if (status == PAGE_MAIN)
			{
				if (t % BAR_FPS == 1)
				{
					for (var i:int = 0; i < arrBar.length; i++)
					{
						arrBar[i].to = random(1, 25);
							//arrBar[i].to = eegArray.shift()[i];
					}
				}
				t = t + 1;
			}
		}
		
		public function mousePressed():void
		{
			trace("mousePressed");
			if (status == PAGE_STAND_BY)
			{
				trace("Flash_onReady");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onReady");
			}
			if (status == PAGE_START)
			{
				trace("Flash_onStarted");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onStarted");
			}
			if (status == PAGE_MAIN)
			{
				
			}
			if (status == PAGE_ANALYZING_EEG)
			{
				trace("Flash_onLoading");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onLoading", 1);
			}
			if (status == PAGE_FINISH)
			{
				trace("Flash_onFinish");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
			}
			noLoop();
		}
		
		public function mouseReleased():void
		{
			trace("mouseReleased");
			loop();
		}
		
		private function timerHandler(e:TimerEvent):void
		{
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback("setEEG", fromJs_setEEG);
					ExternalInterface.addCallback("setAttention", fromJs_setAttention);
					ExternalInterface.addCallback("start", fromJs_start);
					ExternalInterface.addCallback("showLoading", fromJs_showLoading);
					ExternalInterface.addCallback("showFinish", fromJs_showFinish);
					tm.stop();
					tm.removeEventListener(TimerEvent.TIMER, timerHandler);
				}
				catch (e:Error)
				{
				}
			}
		}
		
		private function initExternalInterface():void
		{
			tm = new Timer(100);
			tm.addEventListener(TimerEvent.TIMER, timerHandler);
			if (ExternalInterface.available)
			{
				try
				{
					ExternalInterface.addCallback("setEEG", fromJs_setEEG);
					ExternalInterface.addCallback("setAttention", fromJs_setAttention);
					ExternalInterface.addCallback("start", fromJs_start);
					ExternalInterface.addCallback("showLoading", fromJs_showLoading);
					ExternalInterface.addCallback("showFinish", fromJs_showFinish);
				}
				catch (e:Error)
				{
					tm.start();
				}
			}
		
		}
		
		//
		// javascript call falsh
		//
		//showFinish()
		//在主遊戲畫面顯示結果畫面
		//gender: string (男, 女)
		//age: string (年齡區間: 內容還未定)
		private function fromJs_showFinish(__gender:String, __age:String):void
		{
			setupFinishFrame(__gender, __age);
		}
		
		//showLoading()
		//在主遊戲畫面顯示Loading, 並計算情緒代碼
		private function fromJs_showLoading():void
		{
			setupAnalyzingEEGFrame();
		}
		
		//start(no)
		//由待機畫面進場到主遊戲畫面
		//no參數: int : 體驗編號
		private function fromJs_start(__no:int):void
		{
			userId = __no;
			setupStartFrame();
		}
		
		//setAttention(attention)
		//設定專注度
		//attention參數值的範圍: 0~100
		private function fromJs_setAttention(__attention:int):void
		{
			attentionArray.push(__attention);
		}
		
		//setEEG(delta, theta, lowAlpha, highAlpha, lowBeta, highBeta, lowGamma, highGamma)
		//設定腦波值
		//每個參數值的範圍: 0~16777215(0xFFFFFF 3Byte的長整數)
		private function fromJs_setEEG(__delta:int, __theta:int, __lowAlpha:int, __highAlpha:int, __lowBeta:int, __highBeta:int, __lowGamma:int, __highGamma:int):void
		{
			eegArray.push([__delta, __theta, __lowAlpha, __highAlpha, __lowBeta, __highBeta, __lowGamma, __highGamma]);
		}
	
		//
		// flash call javascript
		//
		//Flash_onReady()
		//當已進入待機畫面時呼叫
		// ExternalInterface.call("Flash_onReady");
		//
		//Flash_onStarted()
		//當已進入到主遊戲畫面時呼叫
		//ExternalInterface.call("Flash_onStarted");
		//
		//Flash_onLoading(emotion)
		//當已進入到Loading畫面, 並且計算出情緒值時呼叫
		//emotion參數: int 情緒代碼
		//ExternalInterface.call("Flash_onLoading", 1);
		//
		//Flash_onFinish()
		//當已進入到結果畫面時呼叫
		//ExternalInterface.call("Flash_onFinish");
	
	}

}

import frocessing.display.F5MovieClip2D;

class Bar extends F5MovieClip2D
{
	private var stage_width:Number = 1280;
	private var stage_height:Number = 720;
	private var _id:int = 0;
	private var _n:int = 25;
	private var _to:int = 0;
	private var c:int = 0;
	private var t:Number = 0;
	private var rect_w:Number = 40;
	private var rect_h:Number = 10;
	private var bar_h:Number = n * (rect_h + 2);
	
	public function Bar(useStageEvent:Boolean = true)
	{
		super(useStageEvent);
		
		// 無線條
		noStroke()
		colorMode(HSV, n, 1, n);
	
	}
	
	public function drawingBar(n:int):void
	{
		//trace("drawingBar:" + n);
		
		//translate(900, stage_height * 0.5);
		
		for (var i:int = 0; i <= c; i++)
		{
			for (var j:int = 0; j <= n; j++)
			{
				// 填色
				//fill(_id, 1, j);
				fill(_id, 1, j * 1.5);
				
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
	
	public function draw():void
	{
		if (_n > _to)
		{
			_n = _n - 1;
		}
		if (_n < _to)
		{
			_n = _n + 1;
		}
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
	
	public function set to(value:int):void
	{
		_to = value;
	}

}

//import frocessing.display.F5MovieClip2DBmp;

class Wave extends F5MovieClip2D
{
	private var stage_width:Number = 360;
	private var stage_height:Number = 360;
	private var n:int = 8;
	private var t:Number = 0;
	
	public function Wave()
	{
		super();
	}
	
	public function setup():void
	{
		size(stage_width, stage_height);
		//background(0);
		noFill();
		colorMode(HSV, 2, 1, 1);
		strokeWeight(2);
	}
	
	public function draw():void
	{
		//background(0, 0);
		
		translate(0, 150);
		//translate(897, 500);
		
		//stroke(t, 1, 0.75, 0.2);
		stroke(t, 1, 0.75, .8);
		beginShape();
		
		curveVertex(-100, 0);
		for (var i:int = 0; i <= n; i++)
		{
			var xx:Number = i * stage_width / n;
			var yy:Number = noise(i * 0.5, t) * 100 - 50;
			curveVertex(xx, yy);
		}
		curveVertex(stage_width + 100, 0);
		
		endShape();
		
		t += 0.01;
	}
}
