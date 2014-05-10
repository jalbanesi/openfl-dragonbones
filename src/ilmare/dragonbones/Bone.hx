package ilmare.dragonbones;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0
* @langversion 3.0
* @version 2.0
*/

import flash.display.Sprite;
import ilmare.dragonbones.animation.Tween;
import ilmare.dragonbones.display.IDisplayBridge;
import ilmare.dragonbones.objects.BoneTransform;
import flash.display.DisplayObject;
import flash.errors.ArgumentError;

import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;


/**
 * A Bone instance represents a single joint in an Armature instance. An Armature instance can be made up of many Bone instances.
 * @example
 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
 * <p>This example retrieves the Bone instance assiociated with the character's head and apply to its Display property an 0.5 alpha.</p>
 * <listing>	
 *	package  
 *	{
 *		import dragonBones.Armature;
 *		import dragonBones.factorys.BaseFactory;
 *  	import flash.display.Sprite;
 *		import flash.events.Event;	
 *
 *		public class DragonAnimation extends Sprite 
 *		{		
 *			[Embed(source = "Dragon1.swf", mimeType = "application/octet-stream")]  
 *			private static const ResourcesData:Class;
 *			
 *			private var factory:BaseFactory;
 *			private var armature:Armature;		
 *			
 *			public function DragonAnimation() 
 *			{				
 *				factory = new BaseFactory();
 *				factory.addEventListener(Event.COMPLETE, handleParseData);
 *				factory.parseData(new ResourcesData(), 'Dragon');
 *			}
 *			
 *			private function handleParseData(e:Event):void 
 *			{			
 *				armature = factory.buildArmature('Dragon');
 *				addChild(armature.display as Sprite); 			
 *				armature.animation.play();
 * 				var bone:Bone = armature.getBone("head");
 * 				bone.display.alpha = 0.5;//make the DisplayObject belonging to this bone semi transparent.
 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
 *			}
 *			
 *			private function updateAnimation(e:Event):void 
 *			{
 *				armature.advanceTime(stage.frameRate / 1000);
 *			}		
 *		}
 *	}
 * </listing>
 * @see dragonBones.Bone
 * @see dragonBones.animation.Animation
 */
class Bone extends EventDispatcher
{
	private static var _helpPoint:Point = new Point();
	/**
	 * The name of this Bone instance's Armature instance.
	 */
	public var name:String;
	/**
	 * An object that can contain any user extra data.
	 */
	public var userData:Dynamic;
	/**
	 * This Bone instance global Node instance.
	 * @see dragonBones.objects.Node
	 */
	public var global:BoneTransform;
	/**
	 * This Bone instance origin Node Instance.
	 * @see dragonBones.objects.Node
	 */
	public var origin:BoneTransform;
	/**
	 * This Bone instance Node Instance.
	 * @see dragonBones.objects.Node
	 */
	public var node:BoneTransform;
	
	/** @private */
	public var _tween:Tween;
	/** @private */
	public var _tweenNode:BoneTransform;
	/** @private */
	public var _tweenColorTransform:ColorTransform;
	/** @private */
	public var _visible:Bool;
	/** @private */
	public var _children:Array<Bone>;
	/** @private */
	public var _displayBridge:IDisplayBridge;
	/** @private */
	public var _isOnStage:Bool;
	/** @private */
	public var _armature:Armature;
	
	private var _globalTransformMatrix:Matrix;
	private var _displayList:Array<Dynamic>;
	private var _displayIndex:Int;
	private var _parent:Bone;
	
	private var _colorTransformChange:Bool;
	private var _colorTransform:ColorTransform;
	private var _boneVisible:Bool = true;
	
	/**
	 * @private
	 */
	public var visible (get, set): Bool;
	 
	public function set_visible(value)
	{
		_boneVisible = value;
		return value;
		/*
		if(value == null)
		{
			_boneVisible = value;
		}
		else
		{
			_boneVisible = Boolean(value);
		}*/
	}
	
	/**
	 * Whether this Bone instance and its associated DisplayObject are visible or not (true/false/null). null means that the visible will be controled by animation data.
	 * 
	 */
	public function get_visible():Bool
	{
		return _boneVisible;
	}
	
	
	public var colorTransform (get, set): ColorTransform;
	/**
	 * @private
	 */
	private function set_colorTransform(value)
	{
		_colorTransform = value;
		_colorTransformChange = true;
		return value;
	}
	
	/**
	 * The ColorTransform instance assiociated with this Bone instance. null means that the ColorTransform will be controled by animation data.
	 */
	public function get_colorTransform():ColorTransform
	{
		return _colorTransform;
	}
	
	/**
	 * The armature this Bone instance belongs to.
	 */
	public var armature (get, null): Armature;
	 
	public function get_armature():Armature
	{
		return _armature;
	}
	
	/**
	 * The sub-armature of this Bone instance.
	 */
	public var childArmature (get, null): Armature;
	 
	public function get_childArmature():Armature
	{
		if (Std.is(_displayList[_displayIndex], Armature))		
			return cast _displayList[_displayIndex];
		return null;
	}
	
	/**
	 * Indicates the Bone instance that directly contains this Bone instance if any.
	 */
	public var parent (get, null): Bone;
	 
	public function get_parent():Bone
	{
		return _parent;
	}
	
	/**
	 * The DisplayObject belonging to this Bone instance. Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 */
	public var display (get, set): Dynamic;
	 
	public function get_display():Dynamic
	{
		return _displayBridge.display;
	}
	/**
	 * @private
	 */
	public function set_display(value:Dynamic):Dynamic
	{
		if(_displayBridge.display == value)
		{
			return value;
		}
		_displayList[_displayIndex] = value;
		
		if (Std.is(value, Armature))		
		{
			var armature: Armature = cast value; // without this, the class isn't located properly... maybe a haxe bug

			_displayBridge.display = armature.display;
			return armature.display;
		}
		_displayBridge.display = value;
		return value;
		
	}
	
	/** @private */
	public function changeDisplay(displayIndex:Int):Void
	{
		if(displayIndex < 0)
		{
			if(_isOnStage)
			{
				_isOnStage = false;
				//removeFromStage
				_displayBridge.removeDisplay();
			}
		}
		else
		{
			if(!_isOnStage)
			{
				_isOnStage = true;
				//addToStage
				if(_armature != null)
				{
					_displayBridge.addDisplay(cast _armature.display, global.z);
					_armature._bonesIndexChanged = true;
				}
			}
			if(_displayIndex != displayIndex)
			{
				var length:Int = _displayList.length;
				if(displayIndex >= length && length > 0)
				{
					displayIndex = length - 1;
				}
				_displayIndex = displayIndex;
				
				//change
				display = _displayList[_displayIndex];
			}
		}
	}
	
	/**
	 * Creates a new Bone instance and attaches to it a IDisplayBridge instance. 
	 * @param	dragonBones.display.IDisplayBridge
	 */
	public function new(displayBrideg:IDisplayBridge)
	{
		super();
		
		origin = new BoneTransform();
		origin.scaleX = 1;
		origin.scaleY = 1;
		global = new BoneTransform();
		node = new BoneTransform();			
		_displayBridge = displayBrideg;			
		_children = new Array<Bone>();			
		_globalTransformMatrix = new Matrix();
		_displayList = new Array<Dynamic>();
		_displayIndex = -1;
		_visible = true;			
		_tweenNode = new BoneTransform();
		_tweenColorTransform = new ColorTransform();			
		_tween = new Tween(this);
	}
	/**
	 * Change all DisplayObject attached to this Bone instance.
	 * @param	displayList An array of valid DisplayObject to attach to this Bone.
	 */
	public function changeDisplayList(displayList:Array<DisplayObject>):Void
	{
		var indexBackup:Int = _displayIndex;
		var length:Int = displayList.length;
		
		// _displayList.length = length; // TODO: no se como resolver esto
				
		for (i in 0...length)
		//for(var i:int = 0;i < length;i ++)
		{
			changeDisplay(i);
			display = displayList[i];
		}			
		changeDisplay(indexBackup);
	}
	
	/**
	 * Cleans up any resources used by this Bone instance.
	 */
	public function dispose():Void
	{
		for (_child in _children)
		{
			_child.dispose();
		}
		
		_displayList = null;
		_children = null;
		//_children.length = 0;			
		_armature = null;
		_parent = null;			
		userData = null;
	}
	/**
	 * Returns true if the passed Bone Instance is a child of this Bone instance (deepLevel false) or true if the passed Bone instance is in the child hierarchy of this Bone instance (deepLevel true) false otherwise.
	 * @param	deepLevel Check against child heirarchy.
	 * @return
	 */
	public function contains(bone:Bone, deepLevel:Bool = false):Bool
	{
		if(deepLevel)
		{
			var ancestor:Bone = this;
			while (ancestor != bone && ancestor != null)
			{
				ancestor = ancestor.parent;
			}
			if (ancestor == bone)
			{
				return true;
			}
			return false;
		}			
		return bone.parent == this;
	}
	
	/** @private */
	public function addChild(child:Bone):Void
	{
		if (_children.length > 0?(Lambda.indexOf(_children, child) < 0):true)
		{
			child.removeFromParent();
			
			_children.push(child);
			child.setParent(this);
			
			if (_armature != null)
			{
				_armature.addToBones(child);
			}
		}
	}
	
	/** @private */
	public function removeChild(child:Bone):Void
	{
		var index:Int = Lambda.indexOf(_children, child);
		if (index >= 0)
		{
			if (_armature != null)
			{
				_armature.removeFromBones(child);
			}
			child.setParent(null);
			_children.splice(index, 1);
		}
	}
	
	/** @private */
	public function removeFromParent():Void
	{
		if(_parent != null)
		{
			_parent.removeChild(this);
		}
	}
	
	/** @private */
	public function update():Void
	{
		//trace("node: " + node.toString() + " tweenNode: " + _tweenNode.toString());
		
		//update global
		global.x = origin.x + node.x + _tweenNode.x;
		global.y = origin.y + node.y + _tweenNode.y;
		global.skewX = origin.skewX + node.skewX + _tweenNode.skewX;
		global.skewY = origin.skewY + node.skewY + _tweenNode.skewY;
		global.scaleX = origin.scaleX + node.scaleX + _tweenNode.scaleX;
		global.scaleY = origin.scaleY + node.scaleY + _tweenNode.scaleY;
		global.pivotX = origin.pivotX + node.pivotX + _tweenNode.pivotX;
		global.pivotY = origin.pivotY + node.pivotY + _tweenNode.pivotY;
		global.z = origin.z + node.z + _tweenNode.z;
		
		//transform
		if(_parent != null)
		{
			_helpPoint.x = global.x;
			_helpPoint.y = global.y;
			_helpPoint = _parent._globalTransformMatrix.transformPoint(_helpPoint);
			global.x = _helpPoint.x;
			global.y = _helpPoint.y;
			global.skewX += _parent.global.skewX;
			global.skewY += _parent.global.skewY;
		}
		
		//Note: this formula of transform is defined by Flash pro
		_globalTransformMatrix.a = global.scaleX * Math.cos(global.skewY);
		_globalTransformMatrix.b = global.scaleX * Math.sin(global.skewY);
		_globalTransformMatrix.c = -global.scaleY * Math.sin(global.skewX);
		_globalTransformMatrix.d = global.scaleY * Math.cos(global.skewX);
		_globalTransformMatrix.tx = global.x;
		_globalTransformMatrix.ty = global.y;
		
		//update children
		if (_children.length > 0)
		{
			for (child in _children)
			{
				child.update();
			}
		}
		
		var childArmature:Armature = this.childArmature;
		if(childArmature != null)
		{
			childArmature.update();
		}
		
		var currentDisplay:Dynamic = _displayBridge.display;
		//update display
		if(currentDisplay != null)
		{
			//currentColorTransform
			var currentColorTransform:ColorTransform = null;
			
			if(_tween._differentColorTransform)
			{
				if(_colorTransform != null)
				{
					_tweenColorTransform.concat(_colorTransform);
				}
				if(_armature.colorTransform != null)
				{
					_tweenColorTransform.concat(_armature.colorTransform);
				}
				currentColorTransform = _tweenColorTransform;
			}
			else if(_armature._colorTransformChange || _colorTransformChange)
			{
				if (_colorTransformChange)
					currentColorTransform = _colorTransform;
				else
					currentColorTransform = _armature.colorTransform;
				//currentColorTransform = _colorTransform || _armature.colorTransform;
				_colorTransformChange = false;
			}
			// TODO: ver como hacer bien lo del bone visible
			//_displayBridge.update(_globalTransformMatrix, global, currentColorTransform, (_boneVisible != null)?_boneVisible:_visible);
			_displayBridge.update(_globalTransformMatrix, global, currentColorTransform, _visible ? _boneVisible : _visible);
		}
	}
	
	private function setParent(parent:Bone):Void
	{
		if (parent != null && parent.contains(this, true))
		{
			throw new ArgumentError("An Bone cannot be added as a child to itself or one of its children (or children's children, etc.)");
		}
		_parent = parent;
		
		if(_parent != null)
		{
			_isOnStage = _parent._isOnStage;
		}			
	}
}
