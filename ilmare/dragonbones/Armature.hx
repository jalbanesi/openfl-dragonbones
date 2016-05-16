package ilmare.dragonbones;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/

import ilmare.dragonbones.animation.Animation;
import ilmare.dragonbones.animation.IAnimatable;
import ilmare.dragonbones.events.ArmatureEvent;
import flash.display.DisplayObject;
import flash.display.Graphics;
import openfl.display.Sprite;

import flash.events.EventDispatcher;
import flash.geom.ColorTransform;
/**
 * Dispatched when the movement of animation is changed.
 */
//[Event(name="movementChange", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when the playback of a animation starts.
 */
//[Event(name="start", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when the playback of a animation stops.
 */
//[Event(name="complete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when the playback of a animation completes a loop.
 */
//[Event(name="loopComplete", type="dragonBones.events.AnimationEvent")]

/**
 * Dispatched when the animation of the armature enter a frame.
 */
//[Event(name="movementFrameEvent", type="dragonBones.events.FrameEvent")]

/**
 * Dispatched when a bone of the armature enters a frame.
 */
//[Event(name="boneFrameEvent", type="dragonBones.events.FrameEvent")]

/**
 * A Armature instance is the core of the skeleton animation system. It contains the object to display, all sub-bones and the object animation(s).
 * @example
 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
 * <p>This example builds an Armature instance called "dragon" and stores it into the member varaible called 'armature'.</p>
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
class Armature extends EventDispatcher implements IAnimatable
{
	/**
	 * The name of the Armature.
	 */
	public var name:String;
	
	/**
	 * An object containing user data.
	 */
	public var userData:Dynamic;
	
	/** @private */
	public var _bonesIndexChanged:Bool;
	/** @private */
	public var _boneDepthList:Array<Bone>;
	/** @private */
	public var _rootBoneList:Array<Bone>;
	
	/** @private */
	public var _colorTransformChange:Bool;
	
	/** @private */
	public var _colorTransform:ColorTransform;

	
	/** @private */
	public var colorTransform (get, set): ColorTransform;
	
	private function set_colorTransform(value)
	{
		_colorTransform = value;
		_colorTransformChange = true;
		return value;
	}
	/**
	 * The ColorTransform instance assiociated with this instance.
	 * @param	The ColorTransform instance assiociated with this Armature instance.
	 */
	private function get_colorTransform():ColorTransform
	{
		return _colorTransform;
	}
	
	/** @private */
	private var _display:DisplayObject;
	/**
	 * Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 */
	
	public var display (get, never): DisplayObject;
	private function get_display():DisplayObject
	{
		return _display;
	}
	
	/** @private */
	private var _animation:Animation;
	/**
	 * An Animation instance
	 * @see dragonBones.animation.Animation
	 */
	public var animation (get, never): Animation;
	private function get_animation():Animation
	{
		return _animation;
	}
	

	/**
	 * Creates a Armature blank instance.
	 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 */
	public function new(display:DisplayObject)
	{
		super();
		_display = display;
		
		_boneDepthList = new Array<Bone>();
		_rootBoneList = new Array<Bone>();
		
		_animation = new Animation(this);
		_bonesIndexChanged = false;
	}
	
	/**
	 * Cleans up resources used by this Armature instance.
	 */
	public function dispose():Void
	{
		for (bone in _rootBoneList)
		{
			bone.dispose();
		}
		
		_boneDepthList = new Array<Bone>();
		_rootBoneList = new Array<Bone>();
		
		_animation.dispose();
		_animation = null;
		
		_display = null;
		//_display = null;
		
		userData = null;
		
		if(_colorTransform != null)
		{
			_colorTransform = null;
		}
	}
	

	/**
	 * Retreives a Bone by name
	 * @param	The name of the Bone to retreive.
	 * @return A Bone instance or null if no Bone with that name exist.
	 * @see dragonBones.Bone
	 */
	public function getBone(name:String):Bone
	{
		if(name != null) 
		{
			for (bone in _boneDepthList)
			{
				if(bone.name == name)
				{
					return bone;
				}
			}
		}
		return null;
	}
	
	/**
	 * Gets the Bone assiociated with this DisplayObject.
	 * @param	Instance type of this object varies from flash.display.DisplayObject to startling.display.DisplayObject and subclasses.
	 * @return A bone instance.
	 * @see dragonBones.Bone
	 */
	public function getBoneByDisplay(display:DisplayObject):Bone
	{
		if(display != null)
		{
			for (bone in _boneDepthList)
			{
				if(bone.display == display)
				{
					return bone;
				}
			}
		}
		return null;
	}
	
	/**
	 * Get all Bone instance assiociated with this armature.
	 * @return A Vector.&lt;Bone&gt; instance.
	 * @see dragonBones.Bone
	 */
	public function getBones():Array<Bone>
	{
		return _boneDepthList;
	}
	/**
	 * Add a Bone instance to this Armature instance.
	 * @param	A Bone instance
	 * @param	(optional) The parent's name of this Bone instance.
	 * @see dragonBones.Bone
	 */
	public function addBone(bone:Bone, parentName:String = null):Void
	{
		if (bone != null)
		{
			var boneParent:Bone = getBone(parentName);
			if (boneParent != null)
			{
				boneParent.addChild(bone);
			}
			else
			{
				bone.removeFromParent();
				addToBones(bone, true);
			}
		}
	}
	/**
	 * Remove a Bone instance from this Armature instance.
	 * @param	A Bone instance
	 * @see dragonBones.Bone
	 */
	public function removeBone(bone:Bone):Void
	{
		if (bone != null)
		{
			if(bone.parent != null)
			{
				bone.removeFromParent();
			}
			else
			{
				removeFromBones(bone);
			}
		}
	}
	/**
	 * Remove a Bone instance from this Armature instance.
	 * @param	The name of the Bone instance to remove.
	 * @see dragonBones.Bone
	 */
	public function removeBoneByName(boneName:String):Void
	{
		var bone:Bone = getBone(boneName);
		removeBone(bone);
	}
	/**
	 * Update the animation using this method typically in an ENTERFRAME Event or with a Timer.
	 * @param	The amount of second to move the playhead ahead.
	 */
	public function advanceTime(passedTime:Float):Void
	{
		for (bone in _boneDepthList)
		{
			if(bone._isOnStage)
			{
				var childArmature:Armature = bone.childArmature;
				if(childArmature != null)
				{
					childArmature.advanceTime(passedTime);
				}
			}
		}
		animation.advanceTime(passedTime);
		update();
	}
	
	/**
	 * Update the z-order of the display. 
	 */
	public function updateBonesZ():Void
	{
		_boneDepthList.sort(sortBoneZIndex);
		for (bone in _boneDepthList)
		{
			if(bone._isOnStage)
			{
				bone._displayBridge.addDisplay(cast _display);
			}
		}
		_bonesIndexChanged = false;
		
		if(hasEventListener(ArmatureEvent.Z_ORDER_UPDATED))
		{
			dispatchEvent(new ArmatureEvent(ArmatureEvent.Z_ORDER_UPDATED));
		}
	}
	
	/** @private */
	public function update():Void
	{
		for (bone in _rootBoneList)
		{
			bone.update();
		}
		
		_colorTransformChange = false;
		
		if(_bonesIndexChanged)
		{
			updateBonesZ();
		}
	}
	
	/** @private */
	public function addToBones(bone:Bone, _root:Bool = false):Void
	{
		var boneIndex:Int = Lambda.indexOf(_boneDepthList, bone);
		if(boneIndex < 0)
		{
			_boneDepthList.push(bone);
		}
		
		boneIndex = Lambda.indexOf(_rootBoneList, bone);
		if(_root)
		{
			if(boneIndex < 0)
			{
				_rootBoneList.push(bone);
			}
		}
		else if(boneIndex >= 0)
		{
			_rootBoneList.splice(boneIndex, 1);
		}
		
		bone._armature = this;
		bone._displayBridge.addDisplay(cast _display, bone.global.z);
		for (child in bone._children)
		{
			addToBones(child);
		}
		_bonesIndexChanged = true;
	}
	
	/** @private */
	public function removeFromBones(bone:Bone):Void
	{
		var boneIndex:Int = Lambda.indexOf(_boneDepthList, bone);
		if(boneIndex >= 0)
		{
			_boneDepthList.splice(boneIndex, 1);
		}
		
		boneIndex = Lambda.indexOf(_rootBoneList, bone);
		if(boneIndex >= 0)
		{
			_rootBoneList.splice(boneIndex, 1);
		}
		
		bone._armature = null;
		bone._displayBridge.removeDisplay();
		for (child in bone._children)
		{
			removeFromBones(child);
		}
		_bonesIndexChanged = true;
	}
	
	private function sortBoneZIndex(bone1:Bone, bone2:Bone):Int
	{
		return bone1.global.z >= bone2.global.z?1: -1;
	}

	public function tooString(): String
	{
		var ret: String = "";
	
		for (bone in _boneDepthList)
		{
			// TODO: el cast hace que el display se muestre bien en cpp, por alguna razon vuelve como null (debe ser por el dynamic)
			if (bone.node != null)
				ret += "\n" + bone.name +"\t" + bone.display +"\t"+ cast(bone.display, Sprite).x +"\t" + bone.display.y;
		}
		
		return ret;
	}
	
	/* TODO: implementar el drawTiles
	public function getTilesData(): Array<Float>
	{
		var data: Array<Float> = new Array<Float>();
		for (bone in _rootBoneList)
		{
			var flags = Graphics.TILE_SCALE | Graphics.TILE_ROTATION | Graphics.TILE_ALPHA | Graphics.TILE_RGB;
			data.push(bone.global.x);
			data.push(bone.global.y);
			data.push(0); // ID of nonflipped tile
			data.push(bone.global.scaleX);
			data.push(bone.global.getRotation()); // in radians
			data.push(red);
			data.push(green);
			data.push(blue);
			data.push(alpha);
			
			data.push(1);
			
			trace(bone.name + bone.global.scaleX);
		}
		return null;
	}*/
	
}