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
import flash.display.Shape;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

/**
 * The NativeDisplayBridge class is an implementation of the IDisplayBridge interface for traditional flash.display.DisplayObject.
 *
 */
class NativeDisplayBridge implements IDisplayBridge
{
	/**
	 * @private
	 */
	private var _display:DisplayObject;
	
	/**
	 * @inheritDoc
	 */
	public var display (get, set): DisplayObject;
	 
	public function get_display():DisplayObject
	{
		return _display;
	}
	/**
	 * @private
	 */
	public function set_display(value:DisplayObject):DisplayObject
	{
		if (_display == value)
		{
			return value;
		}
		var parent:DisplayObjectContainer = null;
		var index:Int = 0;
		if (_display != null)
		{
			parent = _display.parent;
			if (parent != null)
			{
				index = _display.parent.getChildIndex(_display);
			}
			removeDisplay();
		}
		_display = value;
		addDisplay(parent, index);
		
		return value;
	}
	
	/**
	 * Creates a new NativeDisplayBridge instance.
	 */
	public function new()
	{
	}
	
	/**
	 * @inheritDoc
	 */
	public function update(matrix:Matrix, node:BoneTransform, colorTransform:ColorTransform, visible:Bool):Void
	{
		var pivotX:Float = node.pivotX;
		var pivotY:Float = node.pivotY;
		matrix.tx -= matrix.a * pivotX + matrix.c * pivotY;
		matrix.ty -= matrix.b * pivotX + matrix.d * pivotY;
		
		_display.transform.matrix = matrix;
		if (colorTransform != null)
		{
			_display.transform.colorTransform = colorTransform;
		}
		_display.visible = visible;
	}
	
	/**
	 * @inheritDoc
	 */
	public function addDisplay(container:DisplayObjectContainer, index:Int = -1):Void
	{
		if (container != null && _display != null)
		{
			if (index < 0)
			{
				container.addChild(_display);
			}
			else
			{
				container.addChildAt(_display, Std.int(Math.min(index, container.numChildren)));
			}
		}
	}
	
	/**
	 * @inheritDoc
	 */
	public function removeDisplay():Void
	{
		if (_display != null && _display.parent != null)
		{
			_display.parent.removeChild(_display);
		}
	}
}
