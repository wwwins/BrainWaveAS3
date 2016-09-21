/**
* VERSION: 1.0
* DATE: 3/12/2010
* ACTIONSCRIPT VERSION: 3.0
* @author Marco Di Giuseppe, marco[at]designmarco.com
* @link http://designmarco.com
* UPDATES AND DOCUMENTATION AT: http://www.TweenMax.com
**/
package com.greensock.plugins{
	import com.greensock.*;
	import flash.display.*;
	import flash.geom.*;
	/**
	    * WipeEffectPlugin provides a Wiping Transition Effect. <br /><br />
	    *
	    * <b>USAGE:</b><br /><br />
	    * <code>
	    *       import com.greensock.TweenLite; <br />
	    *       import com.greensock.plugins.TweenPlugin; <br />
	    *       import com.greensock.plugins.WipeEffectPlugin; <br />
	    *       TweenPlugin.activate([WipeEffectPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />
	    *
	    *      //Value is Number preset from 1 to 9 that represents the starting point-
	    *       //Top Left:<code>1</code>; Top Center:<code>2</code>, Top Right:<code>3</code>; Left Center:<code>4</code>; Center:<code>5</code>; Right Center:<code>6</code>; Bottom Left:<code>7</code>; Bottom Center:<code>8</code>, Bottom Right:<code>9</code>.</li></ul>
	    *       TweenLite.to(mc, 1, {wipe:1});
	    * </code>
	    *
	    * <b>Copyright 2010, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
	    *
	    * @author Jack Doyle, jack@greensock.com
	    */
	public class WipeEffectPlugin extends TweenPlugin {
		/** @private **/
		public static const API:Number=1.0;

		/** @private **/
		protected var _target:Object;
		protected var _mask:Sprite;
		protected var _innerMask:Shape;
		protected var _startPoint:uint;
		protected var _cornerMode:Boolean;
		protected var _innerBounds:Rectangle;

		/** @private **/
		public function WipeEffectPlugin() {
			super();
			this.propName="wipe";
			this.overwriteProps=[];
		}

		/** @private **/
		override public function onInitTween(target:Object, value:*, tween:TweenLite):Boolean {
			if (! target is DisplayObject) {
				return false;
			}

			_target=target;
			_innerBounds=_target.getBounds(_target);
			_startPoint=value;
			initMask();

			return true;
		}

		/** @private */
		protected function initMask():void {
			_mask = new Sprite();
			_mask.visible=false;
			_target.addChild(_mask);
			_innerMask = new Shape();
			_mask.addChild(_innerMask);
			_innerMask.x=_innerMask.y=50;
			_innerMask.graphics.beginFill(0xFF0000);
			drawBox(_innerMask, -50, -50, 100, 100);
			_innerMask.graphics.endFill();

			switch (_startPoint) {
				case 3 :
				case 2 :
					_innerMask.rotation=90;
					break;
				case 1 :
				case 4 :
				case 5 :
					_innerMask.rotation=0;
					break;
				case 9 :
				case 6 :
					_innerMask.rotation=180;
					break;
				case 7 :
				case 8 :
					_innerMask.rotation=-90;
					break;

				default :
					break;
			}

			if (_startPoint%2) {
				_cornerMode=true;
			}

			var ib:Rectangle=_innerBounds;
			_mask.x=ib.left;
			_mask.y=ib.top;
			_mask.width=ib.width;
			_mask.height=ib.height;

			_target.mask=_mask;
		}

		/** @private */
		protected function drawSlant(mc:Shape, p:Number):void {
			mc.graphics.moveTo(-50, -50);
			if (p<=0.5) {
				mc.graphics.lineTo(200 * (p - 0.25), -50);
				mc.graphics.lineTo(-50, 200 * (p - 0.25));
			} else {
				mc.graphics.lineTo(50, -50);
				mc.graphics.lineTo(50, 200 * (p - 0.75));
				mc.graphics.lineTo(200 * (p - 0.75), 50);
				mc.graphics.lineTo(-50, 50);
			}
			mc.graphics.lineTo(-50, -50);
		}

		/** @private */
		protected function drawBox(mc:Shape, x:Number, y:Number, w:Number, h:Number):void {
			mc.graphics.moveTo(x, y);
			mc.graphics.lineTo(x + w, y);
			mc.graphics.lineTo(x + w, y + h);
			mc.graphics.lineTo(x, y + h);
			mc.graphics.lineTo(x, y);
		}

		/** @private **/
		override public function set changeFactor(n:Number):void {
			_innerMask.graphics.clear();
			_innerMask.graphics.beginFill(0xFF0000);
			if (_cornerMode) {
				drawSlant(_innerMask, n);
			} else {
				drawBox(_innerMask, -50, -50, n * 100, 100);
			}
			_innerMask.graphics.endFill();
		}
	}
}