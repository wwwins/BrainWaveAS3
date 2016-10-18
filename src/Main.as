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
		public static const BAR_FPS:int = 30;
		public static const RANDOM_BAR_DATA:Boolean = false;
		public static const ENABLE_XY_AXIS:Boolean = false;
		public static const ENABLE_SCALE_XY:Boolean = false;
		public static const DEMO:Boolean = false;
		
		public static const PAGE_STAND_BY:int = 0;
		public static const PAGE_START:int = 1;
		public static const PAGE_MAIN:int = 2;
		public static const PAGE_FROCESSING:int = 3;
		public static const PAGE_ANALYZING_EEG:int = 4;
		public static const PAGE_FINISH:int = 5;
		public static const PAGE_END:int = 6;
		
		public static const KEYPOINT_COORD_SYSTEM_TEXT:Number = 25.4; // 座標文字出現(alpha/beta...)
		public static const KEYPOINT_CIRCLE_END:Number = 26.8; // 線條圈圈畫完
		public static const KEYPOINT_ANALYZING:Number = 27.0; // 分析中
		public static const FINISH_DURATION:Number = 8.0;	// 結果頁顯示時間
		
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
		private var userId:String = "000";
		
		private var tm:Timer;
		private var demoTm:Timer;
		
		private var black:Black;
		
		private var startPage:StartPage;
		private var sn:SerialNumber;
		
		private var rdata:Object; // result data
		private var emotion_idx:int;
		
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
			emotionTxtArray = ['樂天型', '壓力型', '多慮型', '淡定型'];
			emotion_idx = -1;
			
			initExternalInterface();
			setupStandByFrame();
			
			// demo code
			if (DEMO) {
				//status = PAGE_MAIN;
				//setupFrocessing();
				demoTm = new Timer(1000);
				demoTm.addEventListener(TimerEvent.TIMER, demoTimerHandler);
				demoTm.start();
			}
			/*
			 * http://jsonviewer.stack.hu/
			 * see messages.json
			*/
			rdata = JSON.parse('{"male":{"text0":[["快樂讓體內的能量滿檔","不只外在有型，健康也滿分","快樂情緒讓精神飽滿","全身都很有力量！","青春不留白才開心","但健康不能交白卷喔！"],["長期累積壓力讓身體生氣","小心健康離你遠去！"],["想太多容易累積身體負擔","好日子壞日子都要笑著前進"],["心情放鬆，身體更有力量","每個細胞都在微笑呢～","好空氣好心情","讓周圍變成我的正向磁場！","心寬不能體胖","代謝良好，體脂肪就不高。"]],"text1":[["盡情享受各種質感生活","健康當然不能落後！","開心就盡情笑吧","可以活化免疫細胞哦！","愉悅心情會產生腦內啡","讓全身更有衝勁。"],["有壓力就要適度釋放","留點力氣才能繼續拚！"],["有些事不要想那麼多","你難過身體也會難過。"],["放鬆可以加速新陳代謝","加強體內的恢復力。","維持良好的身體循環","健康才能好好享受生活。","保持穩定情緒，多吃多動","健康就是最好的體態。"]],"text2":[["正向心理加上健康身體","就是面面俱到。","精神愉悅，代謝良好","全身都振奮起來！","多笑會產生化學作用","減少壓力、提高免疫力。"],["別讓怒氣引起的衝動","打亂健康的節奏。"],["煩惱需要排解過濾","還心情和身體一份清淨。"],["良好的循環會反映到外在","自信顏值渾然天成。","穩定的正向情緒促進代謝","每個呼吸都是活力來源。","愉悅的心情、健康的笑容","最能釋放幸福荷爾蒙。"]],"text3":[["快樂的笑可以舒緩壓力","活化身體各個細胞。","健康的臉龐自然散發光采","怎麼看都有型！","身體健康才是真正的快樂","記得為自己聰明選擇。"],["別生氣了。細胞容易衰老","臉色也會變差。"],["煩惱太多身體會喘不過氣","要時常給自己透透氣！"],["只要心情定下來","自然散發健康的光彩。","穩定呼吸帶給身體正能量","心平氣和就是一種養生。","身心調和、養分均衡","讓體內的良性循環散發健康的光彩。"]]},"female":{"text0":[["每天笑一個！心情年輕了","身體也跟著年輕起來。","我的快樂為氣色加分","健康亮眼是理所當然的囉！","身心健康的樣子最迷人了","距離再遠都魅力難擋！"],["別被怒氣破壞高顏值","適度減壓就能喚回迷人氣色"],["心情倦怠會影響身體表現","不小心就把心事寫臉上。"],["穩定情緒能促進體循環","健康氣色讓顏值破錶！","就是這樣！維持淡定呼吸","平凡日子也能充滿活力。","健康從身心調適開始","元氣好，自然散發蘋果光！"]],"text1":[["好心情給我好氣色","從頭到腳都散發健康美。","大小煩惱不上身","用笑容凍結青春元素！","快樂在體內產生化學作用","讓愛笑的眼睛特別放電～"],["愛生氣會加快細胞老化","別讓壞情緒傷了身體。"],["丟掉煩惱才能好好入眠","用美容覺把青春睡回來！"],["心情輕鬆身體也跟著放鬆","整個人都輕盈了起來！","身心協調、代謝力提升","就是最好的健康狀況。","與各種負面情緒保持距離","健康就能輕鬆到手。"]],"text2":[["快樂的祕密在於適度調整","身體和心情的節奏。","健康不只是吃得開心","更要吃出均衡營養。","心情愉快能減緩壓力","展現健康氣色的魅力。"],["給自己留一點空間","別讓壓力威脅妳的健康！"],["深呼吸。阿雜的事會過去","但健康要一直守護下去。"],["平衡呼吸能強化能量","整個人更有元氣。","愉悅情緒能幫助新陳代謝","從頭到腳形成正循環。","代謝調和幫助氣色紅潤","均衡飲食則為魅力加分！"]],"text3":[["好心情讓身體放輕鬆","外在壞因子都不怕。","愉快心情讓生活更精采","但要對身體好才有意義。","開心時腦細胞含氧量提升","也能讓精神振奮。"],["適度紓解心中的怒氣","身體才能釋放緊繃。"],["難過別往心裡去，放輕鬆","就是給身體好日子過。"],["心境輕鬆，代謝狀況良好","給我犯規的好氣色。","淡定可以維持代謝平衡","讓妳的魅力不降溫。","呼吸健康，充滿活力","身體修復力也會變強唷！"]]}}');
			// 姓別.年齡.情緒.第一行
			// 姓別.年齡.情緒.第二行
			// rdata.male.text0[1][0]
			//trace("rdata:"+data.male.text0[0][1]);
			
			// demo code
		}
		
		private function demoTimerHandler(e:TimerEvent):void 
		{
			fromJs_setEEG(random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215), random(0, 16777215));
			fromJs_setAttention(random(0, 100));
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
			
			TweenMax.delayedCall(KEYPOINT_ANALYZING, function():void
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
			
			// 加入序號
			sn = new SerialNumber();
			sn.x = 60;
			sn.y = 938;
			sn.alpha = 0;
			sn.txt.text = userId.substr(userId.length - 3, 3);
			addChild(sn);
			TweenMax.to(sn, 0.25, {alpha:1});

			var page:MovieClip = new AnalyzingEEG();
			page.scaleX = page.scaleY = 1.5;
			page.x = 700;
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

		private function delayFinishFrame(__gender:String, __age:String):void
		{
			trace("currentFrame:"+startPage.currentFrame+","+startPage.totalFrames);
			//var frame:int =  random(startPage.currentFrame, startPage.totalFrames);
			//TweenMax.delayedCall(frame-startPage.currentFrame, setupFinishFrame, [__gender, __age], true);
			var frame:int =  random(10, 90);
			TweenMax.delayedCall(frame, setupFinishFrame, [__gender, __age], true);
		}
		
		// 結果畫面
		private function setupFinishFrame(__gender:String, __age:String):void
		{
			if (emotion_idx < 0) {
				emotion_idx = handleEEGData(); trace(emotionTxtArray[emotion_idx]);
			}
			
			var gender:String = 'male';
			if (__gender == '女性') {
				gender = 'female'
			}
			var age:String = 'text0';
			if (__age == '26-35歲') {
				age = 'text1';
			}
			if (__age == '36-45歲') {
				age = 'text2';
			}
			if (__age == '46歲以上') {
				age = 'text3';
			}
			//data[gender][age][idx]

			this.removeChildAt(this.numChildren - 1);
			
			var page:MovieClip = new Finish();
			page.x = 0;
			page.y = 0;
			addChild(page);
			
			var rand_msgid:int = 2 * (int(userId) % 3);
			var buf:String = rdata[gender][age][emotion_idx][0] + "\r" + rdata[gender][age][emotion_idx][1];
			if (emotion_idx == 0 || emotion_idx == 3) {
				buf = rdata[gender][age][emotion_idx][rand_msgid] + "\r" + rdata[gender][age][emotion_idx][rand_msgid+1];
			}
			//page.title1.txt.text = "分析結果";
			page.title2.txt.text = "["+emotionTxtArray[emotion_idx]+"]";
			page.title3.txt.text = buf;
			
			addChild(sn); // 將序號搬到最上層
			
			status = PAGE_FINISH;
			
			stopDrawingChart();
			startPage.stop();
			
			TweenMax.delayedCall(FINISH_DURATION, function():void
			{
				setupEnding();
			});
			
			if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
		}
		
		// ENDING
		private function setupEnding():void
		{
			/* Remove all movieclips
			while (this.numChildren) {
				this.removeChildAt(0);
			}
			*/
			
			//var page:MovieClip = new Ending();
			//page.x = (stage_width - page.width) * .5;
			//page.y = (stage_height - page.height) * .5;
			//addChild(page);
			var page:MovieClip = new EndingFLV();
			page.alpha = 0;
			addChild(page);
			// alpha in
			TweenMax.to(page, .5, {alpha:1});

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
				myText.y = stage_height - 70;
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
			if (DEMO) {
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
					delayFinishFrame("女","18");
				}
				if (status == PAGE_FINISH)
				{
					trace("Flash_onFinish");
					if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
				}
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
			delayFinishFrame(__gender, __age);
			if (ExternalInterface.available) ExternalInterface.call("Flash_onFinish");
		}
		
		//showLoading()
		//在主遊戲畫面顯示Loading, 並計算情緒代碼
		private function fromJs_showLoading():void
		{
			//setupAnalyzingEEGFrame();
			emotion_idx = handleEEGData();
			if (ExternalInterface.available) ExternalInterface.call("Flash_onLoading", emotionTxtArray[emotion_idx]);
		}
		
		//start(no)
		//由待機畫面進場到主遊戲畫面
		//no參數: int : 體驗編號
		private function fromJs_start(__no:int):void
		{
			userId = "000"+__no;
			//setupStartFrame();
			startFrameFadeIn();
		}
		
		//setAttention(attention)
		//設定專注度
		//attention參數值的範圍: 0~100
		private function fromJs_setAttention(__attention:int):void
		{
			attentionArray.push(__attention);
			if (ENABLE_SCALE_XY) {
				if (status > PAGE_MAIN && status < PAGE_FINISH) {
					var scale:Number = (100 - int(__attention / 10))/100;
					TweenMax.to(startPage, .5, {scaleX:scale, scaleY:scale});
				}
			}
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
			var valence:Number = (__lowAlpha / __lowBeta) - (__highAlpha / __highBeta);
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
		
		translate(1600, stage_height - 250);
		
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
		
		translate(1600 - 2, stage_height + 220 + 310);
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
		translate(1600 - 2, stage_height + 220 + 310);
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
		translate(1600 - 2, stage_height + 220 + 310);
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