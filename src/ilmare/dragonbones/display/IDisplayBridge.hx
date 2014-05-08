package ilmare.dragonbones.display;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0
* @langversion 3.0
* @version 2.0
*/

import ilmare.dragonbones.objects.BoneTransform;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

/**
 * Provides an interface for display classes that can be used in this skeleton animation system.
 *
 */
interface IDisplayBridge
{
	/**
	 * Indicates the original display object relative to specific display engine.
	 */
	var display (get, set): DisplayObject;
	 
	/*function getDisplay():Dynamic;
	function setDisplay(value:Dynamic):Void;*/
	/**
	 * Updates the transform of the display object
	 * @param	matrix
	 * @param	node
	 * @param	colorTransform
	 * @param	visible
	 */
	function update(matrix:Matrix, node:BoneTransform, colorTransform:ColorTransform, visible:Bool):Void;
	/**
	 * Adds the original display object to another display object.
	 * @param	container
	 * @param	index
	 */
	function addDisplay(container:DisplayObjectContainer, index:Int = -1):Void;
	/**
	 * remove the original display object from its parent.
	 */
	function removeDisplay():Void;

}