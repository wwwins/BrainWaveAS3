package
{
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import frocessing.display.*;
	import com.greensock.TweenMax;
	
	/**
	 * Philips Brain Wave Project
	 * @author isobar
	 */
	public class Main extends F5MovieClip2D
	{
		public static const BAR_FPS:int = 10;
		public static const RANDOM_BAR_DATA:Boolean = true;
		public static const ENABLE_XY_AXIS:Boolean = false;
		
		public static const PAGE_STAND_BY:int = 0;
		public static const PAGE_START:int = 1;
		public static const PAGE_MAIN:int = 2;
		public static const PAGE_FROCESSING:int = 3;
		public static const PAGE_ANALYZING_EEG:int = 4;
		public static const PAGE_FINISH:int = 5;
		public static const PAGE_END:int = 6;
		
		public static const KEYPOINT_COORD_SYSTEM_TEXT:Number = 25.4; // 座標文字出現(alpha/beta...)
		public static const KEYPOINT_CIRCLE_END:Number = 26.8; // 線條圈圈畫完
		public static const KEYPOINT_ANALYZING:Number = 40.7; // 分析中
		
		private var stage_width:Number = stage.stageWidth;
		private var stage_height:Number = stage.stageHeight;
		private var rect_w:Number = 30;
		private var rect_h:Number = 5;
		private var c:int = 7;
		private var t:Number = 0;
		private var status:int = 0;
		private var eegArray:Array;
		private var attentionArray:Array;
		private var emotionArray:Array;
		private var emotionTxtArray:Array;
		private var arrBar:Array;
		private var arrWave:Array;
		private var userId:int = 0;
		
		private var tm:Timer;
		private var demoTm:Timer;
		
		private var black:Black;
		
		private var startPage:StartPage;
		
		public function Main()
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			eegArray = [];
			attentionArray = [];
			emotionArray = [0, 0, 0, 0];
			emotionTxtArray = ['樂天型', '壓力型', '多慮型', '淡定型'];;
			
			initExternalInterface();
			setupStandByFrame();
			
			// demo code
			//status = PAGE_MAIN;
			//setupFrocessing();
			demoTm = new Timer(1000);
			demoTm.addEventListener(TimerEvent.TIMER, demoTimerHandler);
			demoTm.start();
/*
 * http://jsonviewer.stack.hu/
{
    "male": {
		"text0": ["emotion0-1","emotion0-2","emotion0-3","emotion0-4"],
		"text1": ["emotion1-1","emotion1-2","emotion1-3","emotion1-4"],
		"text2": ["emotion2-1","emotion2-2","emotion2-3","emotion2-4"],
		"text3": ["emotion3-1","emotion3-2","emotion3-3","emotion3-4"]
    },
	"female": {
		"text0": ["emotion0-1","emotion0-2","emotion0-3","emotion0-4"],
		"text1": ["emotion1-1","emotion1-2","emotion1-3","emotion1-4"],
		"text2": ["emotion2-1","emotion2-2","emotion2-3","emotion2-4"],
		"text3": ["emotion3-1","emotion3-2","emotion3-3","emotion3-4"]
	}
}
*/
			//var data:Object = JSON.parse('{"male":{"text0":["emotion0-1","emotion0-2","emotion0-3","emotion0-4"],"text1":["emotion1-1","emotion1-2","emotion1-3","emotion1-4"],"text2":["emotion2-1","emotion2-2","emotion2-3","emotion2-4"],"text3":["emotion3-1","emotion3-2","emotion3-3","emotion3-4"]},"female":{"text0":["emotion0-1","emotion0-2","emotion0-3","emotion0-4"],"text1":["emotion1-1","emotion1-2","emotion1-3","emotion1-4"],"text2":["emotion2-1","emotion2-2","emotion2-3","emotion2-4"],"text3":["emotion3-1","emotion3-2","emotion3-3","emotion3-4"]}}');
			//trace("data:"+data.male.text0[1]);
			
			// demo code
		}
		
		private function demoTimerHandler(e:TimerEvent):void 
		{
			fromJs_setEEG(random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215));
		}
		
		// 進入待機畫面
		private function setupStandByFrame():void
		{
			var page:MovieClip = new StandBy();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
		
			black = new Black();
			black.width = stage_width;
			black.height = stage_height;
			black.alpha = 0;
			addChild(black);
			
			status = PAGE_STAND_BY;
			
			if (ExternalInterface.available) ExternalInterface.call("Flash_onReady");
		}
		
		private function startFrameFadeIn():void 
		{
			TweenMax.to(black, .25, {alpha:1, onComplete:function():void { setupStartFrame(); }});
			TweenMax.delayedCall(KEYPOINT_COORD_SYSTEM_TEXT, function():void { coordSystemTextFadeIn(); });
			TweenMax.delayedCall(KEYPOINT_CIRCLE_END, function():void { setupFrocessing(); });
		}
		
		// 座標文字(alpha/beta...)
		private function coordSystemTextFadeIn():void 
		{
			var page:MovieClip = new CoordText();
			page.x = 396;
			page.y = 318;
			addChild(page);
		}
		
		// 進入遊戲 intro 畫面
		private function setupStartFrame():void
		{
			//this.removeChildAt(this.numChildren - 1);
			
			startPage = new StartPage();
			startPage.x = 0;
			startPage.y = 0;
			this.addChild(startPage);
			
			status = PAGE_START;
		
			setupMainFrame();
		}
		
		// 遊戲主畫面
		private function setupMainFrame():void
		{
			//this.removeChildAt(this.numChildren - 1);
			
			//setupFrocessing();
			//var page:MovieClip = new MainPage();
			//page.x = (stage_width - page.width) * .5;
			//page.y = (stage_height - page.height) * .5;
			//addChild(page);
			
			TweenMax.delayedCall(40.5, function():void
			{
				setupAnalyzingEEGFrame();
			});

			status = PAGE_MAIN;
		}
		
		// 計算情緒代碼，顯示"腦波分析中"
		private function setupAnalyzingEEGFrame():void
		{
			this.removeChild(black);
			
			//this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new AnalyzingEEG();
			page.scaleX = page.scaleY = 1.5;
			page.x = 765;
			page.y = 475;
			addChild(page);
			status = PAGE_ANALYZING_EEG;
			
			if (ENABLE_XY_AXIS) {
				var line:Shape = new Shape();
				line.graphics.lineStyle(2, 0xFFFFFF);
				line.graphics.moveTo(1920 * 0.5, 0);
				line.graphics.lineTo(1920 * 0.5, 1080);
				line.graphics.moveTo(0, 1080 * 0.5);
				line.graphics.lineTo(1920, 1080 * 0.5);
				addChild(line);
			}
		
		}
		
		// 結果畫面
		private function setupFinishFrame(__gender:String, __age:String):void
		{
			// demo code
			var idx:int = handleEEGData(); trace(emotionTxtArray[idx]);

			this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new Finish();
			page.x = 0;
			page.y = 0;
			addChild(page);
			page.title1.txt.text = "第一行一二三四五六七八九十";
			page.title2.txt.text = "第二行一二三四五六七八九十";
			page.title3.txt.text = "第三行一二三四五六七八九十";
			status = PAGE_FINISH;
			
			stopDrawingChart();
			startPage.stop();
			
			TweenMax.delayedCall(20, function():void
			{
				setupEnding();
			});
			
			if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
		}
		
		// ENDING
		private function setupEnding():void
		{
			while (this.numChildren) {
				this.removeChildAt(0);
			}
			
			var page:MovieClip = new Ending();
			page.x = (stage_width - page.width) * .5;
			page.y = (stage_height - page.height) * .5;
			addChild(page);
			status = PAGE_END;
		}
		
		private function setupFrocessing():void
		{
			if (ExternalInterface.available) ExternalInterface.call("Flash_onStarted");
			
			arrWave = [];
			arrBar = [];
			for (var i:int = 0; i <= c; i++)
			{
				var bar:Bar = new Bar();
				bar.id = i;
				bar.x = (rect_w + 5) * i;
				arrBar.push(bar);
				TweenMax.from(bar, .25, {alpha:0});
				addChild(bar);
			}
			
			//var wave:Wave = new Wave();
			//var wave:HeartBeatWave = new HeartBeatWave();
			var wave:SineWave = new SineWave();
			arrWave.push(wave);
			addChild(wave);

			var format:TextFormat = new TextFormat();
			format.color = 0xFFFFFF;
			format.size = 12;
			format.font = "Arial";

			for (i = 0; i <= c; i++) {
				var myText:TextField = new TextField();
				//myText.embedFonts = true;
				myText.autoSize = TextFieldAutoSize.LEFT;
				myText.antiAliasType = AntiAliasType.NORMAL;
				myText.defaultTextFormat = format;
				myText.selectable = false;
				myText.mouseEnabled = false;
				if (i == 0) {
					myText.text = "0Hz";
				}
				if (i > 0 && i < 3) {
					myText.visible = false;
				}
				if (i == 3) {
					myText.text = "10Hz";
				}
				if (i == 4) {
					myText.text = "20Hz";
				}
				if (i == 5) {
					myText.text = "30Hz";
				}
				if (i == 6) {
					myText.text = "40Hz";
				}
				if (i == 7) {
					myText.text = "50Hz";
				}
				myText.x = stage_width - 320 + (rect_w + 5) * i;
				myText.y = stage_height - 20;
				addChild(myText);
			}

			status = PAGE_FROCESSING;
		}
		
		private function handleEEGData():int
		{
			trace("emotionArray:" + emotionArray);
			var maxValue:int=0;
			var maxIndex:int = 0;
			for (var i:int = 0; i < emotionArray.length; i++) {
				if (emotionArray[i] > maxValue) {
					maxValue = emotionArray[i];
					maxIndex = i;
				}
			}
			return maxIndex;
		}
		
		public function stopDrawingChart():void
		{
			for (var i:int = 0; i < arrBar.length; i++)
			{
				arrBar[i].noLoop();
			}
			arrWave[0].noLoop();
			noLoop();

		}

		public function draw():void
		{
			if (status > PAGE_MAIN && status < PAGE_FINISH)
			{
				if (t % BAR_FPS == 1)
				{
					for (var i:int = 0; i < arrBar.length; i++)
					{
						// random data
						if (RANDOM_BAR_DATA) {
							arrBar[i].to = random(1, 25);
						}
						else {
							//arrBar[i].to = eegArray.shift();
							//16777215/(26=bar.n+1) = 645278
							var v:Number = eegArray.shift();
							var v_to:int = int( v / 645278);
							arrBar[i].to = v_to;
						}
					}
				}
				t = t + 1;
			}
			if (status > PAGE_FINISH) {
				trace("PAGE_FINISH");
				noLoop();
			}
		}
		
		public function mousePressed():void
		{
			trace("mousePressed:" + status);
			//////////////////////////////
			// demo code
			if (status == PAGE_STAND_BY)
			{
				trace("Flash_onReady");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onReady");
				//setupStartFrame();
				startFrameFadeIn();
			}
			if (status == PAGE_START)
			{
				trace("Flash_onStarted");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onStarted");
			}
			if (status == PAGE_MAIN)
			{
			}
			if (status == PAGE_FROCESSING)
			{
			}
			if (status == PAGE_ANALYZING_EEG)
			{
				trace("Flash_onLoading");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onLoading", 1);
				setupFinishFrame("女","18");
			}
			if (status == PAGE_FINISH)
			{
				trace("Flash_onFinish");
				if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
			}
			// demo code
			//////////////////////////////
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
			if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
		}
		
		//showLoading()
		//在主遊戲畫面顯示Loading, 並計算情緒代碼
		private function fromJs_showLoading():void
		{
			//setupAnalyzingEEGFrame();
			var idx:int = handleEEGData();
			if (ExternalInterface.available) ExternalInterface.call("Flash_onLoading", emotionTxtArray[idx]);
		}
		
		//start(no)
		//由待機畫面進場到主遊戲畫面
		//no參數: int : 體驗編號
		private function fromJs_start(__no:int):void
		{
			userId = __no;
			//setupStartFrame();
			startFrameFadeIn();
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
			eegArray.push(__delta, __theta, __lowAlpha, __highAlpha, __lowBeta, __highBeta, __lowGamma, __highGamma);
			var alpha:Number = __lowAlpha + __highAlpha;
			var beta:Number = __lowBeta + __highBeta;
			var arousal:Number = beta / alpha;
			var valence:Number = (__highAlpha / __highBeta) - (__lowAlpha / __lowBeta);
			// +,+:Happy(樂天型)
			if (valence > 0 && arousal > 1) {
				emotionArray[0] += 1;
			}
			// -,+:Angry(壓力型)
			if (valence < 0 && arousal > 1) {
				emotionArray[1] += 1;
			}
			// -,-:Sad(想太多型)
			if (valence < 0 && arousal < 1) {
				emotionArray[2] += 1;
			}
			// +,-:Relaxed(淡定型)
			if (valence > 0 && arousal < 1) {
				emotionArray[3] += 1;
			}
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
		//Happy(樂天型)/Relaxed(淡定型)/Angry(壓力型)/Sad(想太多型)
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
	private var stage_width:Number = 1920;
	private var stage_height:Number = 1080;
	private var _id:int = 0;
	private var _n:int = 25;
	private var _to:int = 0;
	private var c:int = 0;
	private var t:Number = 0;
	private var rect_w:Number = 30;
	private var rect_h:Number = 5;
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
		
		translate(1600, stage_height - 200);
		
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
	private var stage_width:Number = 280;
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
		
		translate(1600 - 2, stage_height + 220 + 360);
		//translate(0, 50);
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
		
		t += 0.02;
	}
}

import frocessing.display.F5MovieClip2DBmp;

class HeartBeatWave extends F5MovieClip2DBmp
{
	private var stage_width:Number = 280;
	private var stage_height:Number = 360;
	private var amplitude:Number = 50;
	private var xspacing:Number = 20;
	private var rand:Number = 1000;
	private var sx0:Number = 0;
	private var sy0:Number = 0;
	private var sx:Number = 0;
	private var sy:Number = 0;
	private var t:Number = 0;
	
	public function HeartBeatWave()
	{
		super();
	}
	
	public function setup():void
	{
		size(stage_width, stage_height);
		background(0, 0);
		strokeWeight(2);
		rand = random(1200, 800);
	}
	
	public function draw():void
	{
		translate(1600 - 2, stage_height + 220 + 360);
		//translate(0, 50);
		stroke(255);
		sx0 = sx;
		sy0 = sy;
		sx += 0.1;
		//sy = sin(sx);
		sy = sin(sx * 0.5) * cos(rand / sx) * 2 * sin(sx) * cos(sx);
		line(sx0 * xspacing, sy0 * amplitude, sx * xspacing, sy * amplitude);
		if (sx0 * xspacing > stage_width)
		{
			background(0, 0);
			rand = random(1200, 800);
			sx = 0;
		}
	}

}

class SineWave extends F5MovieClip2D
{
	private var stage_width:Number = 280;
	private var stage_height:Number = 360;
	private var w:Number = 0;
	private var xspacing:int = 1;
	private var theta:Number = 0;
	private var amplitude:Number = 50;
	private var period:Number = 500;
	private var dx:Number;
	private var yvalues:Array;
	private var maxwaves:int = 8;
	
	public function SineWave()
	{
		super();
	}
	
	public function setup():void
	{
		size(stage_width, stage_height);
		w = stage_width + xspacing;
		dx = (2 * Math.PI / period) * xspacing;
		var idx:int = int(w / xspacing)
		yvalues = new Array(idx);
	
	}
	
	public function draw():void
	{
		translate(1600 - 2, stage_height + 220 + 360);
		//translate(0, 50);
		stroke(255);
		calcWave();
		renderWave();
	}
	
	private function renderWave():void
	{
		for (var i:int = 0; i < yvalues.length; i++)
		{
			point(i * xspacing, amplitude * yvalues[i]);
		}
	}
	
	private function calcWave():void
	{
		theta = theta + 0.1;
		var xx:Number = theta;
		for (var i:int = 0; i < yvalues.length; i++)
		{
			//yvalues[i] = sin(xx) * amplitude;
			yvalues[i] = sin(xx * 0.5) * cos(1000 / xx) * 2 * sin(xx) * cos(xx);
			xx = xx + dx;
		}
	}

}