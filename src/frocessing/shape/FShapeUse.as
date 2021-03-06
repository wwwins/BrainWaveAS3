﻿// --------------------------------------------------------------------------
// Project Frocessing
// ActionScript 3.0 drawing library like Processing.
// --------------------------------------------------------------------------
//
// This library is based on Processing.(http://processing.org)
// Copyright (c) 2004-08 Ben Fry and Casey Reas
// Copyright (c) 2001-04 Massachusetts Institute of Technology
// 
// Frocessing drawing library
// Copyright (C) 2008-10  TAKANAWA Tomoaki (http://nutsu.com) and
//					   	  Spark project (www.libspark.org)
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
// 
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// contact : face(at)nutsu.com
//

package frocessing.shape 
{
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import frocessing.geom.FMatrix2D;
	import frocessing.geom.FViewBox;
	
	/**
	* Use Container.
	* 
	* @author nutsu
	* @version 0.6
	*/
	public class FShapeUse extends FShapeContainer
	{		
		/**
		 * 
		 */
		public function FShapeUse( parent_group:IFShapeContainer=null ) 
		{
			super( parent_group );
		}
		
		//-------------------------------------------------------------------------------------------------------------------
		// Container
		//-------------------------------------------------------------------------------------------------------------------
		
		/**
		 * add shape object to the container.
		 * shape parent not updated.
		 */
		override public function addChild( shape:IFShape ):IFShape
		{
			_children[_childCount] = shape;
			_childCount++;
			_geom_changed = true;
			return shape;
		}
		
		/**
		 * remove shape object from the container.
		 * shape parent not updated.
		 */
		override public function removeChild( shape:IFShape ):IFShape
		{
			var index:int = _children.indexOf( shape );
			if ( index > -1 ){
				_children.splice( index, 1 );
				_childCount--;
				_geom_changed = true;
				return shape;
			}
			return null;
		}
	}
}