package ilmare.dragonbones.objects;
/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/


/**
 * A SkeletonData instance holds all data related to an Armature instance. 
 * @example
 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
 * <p>This example parse the 'Dragon1.swf' data and stores its SkeletonData into the local variable named skeleton.</p>
 * <listing>	
 *	package  
 *	{
 *		import dragonBones.Armature;
 *		import dragonBones.factorys.BaseFactory;
 *  	import flash.display.Sprite;
 *		import flash.events.Event;	
 * 		import dragonBones.objects.SkeletonData;
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
 *				var skeleton:SkeletonData = factory.parseData(new ResourcesData(), 'Dragon');
 *			}		
 *		}
 *	}
 * </listing>
 * @see dragonBones.Bone
 * @see dragonBones.animation.Animation
 */
class SkeletonData
{
	public var _armatureDataList:DataList;
	public var _animationDataList:DataList;
	public var _displayDataList:DataList;
	public var _name:String;
	/**
	 * the name of this Skeletondata instance.
	 */
	public var name (get, null): String;
	public function get_name():String
	{
		return _name;
	}
	
	public var _frameRate:Int;
	/**
	 * The frameRate of this Skeltondata instance.
	 */
	public var frameRate (get, null): Int;
	public function get_frameRate():Int
	{
		return _frameRate;
	}
	/**
	 * All Armature instance names belonging to this Skeletondata instance.
	 */
	public var armatureNames (get, null): Array<String>;
	public function get_armatureNames():Array<String>
	{
		return _armatureDataList.dataNames.copy();
	}
	/**
	 * All Animation instance names belonging to this Skeletondata instance.
	 */
	public var animationNames (get, null): Array<String>;
	public function get_animationNames():Array<String>
	{
		return _animationDataList.dataNames.copy();
	}
	/**
	 * Creates a new SkeletonData instance.
	 */
	public function new()
	{
		_armatureDataList = new DataList();
		_animationDataList = new DataList();
		_displayDataList = new DataList();
	}
	/**
	 * Clean up all resources used by this SkeletonData instance.
	 */
	public function dispose():Void
	{
		for (armatureName in _armatureDataList.dataNames)
		{
			var armatureData:ArmatureData = cast _armatureDataList.getData(armatureName);
			armatureData.dispose();
		}
		for (animationName in _animationDataList.dataNames)
		{
			var animationData:AnimationData = cast _animationDataList.getData(animationName);
			animationData.dispose();
		}
		_armatureDataList.dispose();
		_animationDataList.dispose();
		_displayDataList.dispose();
	}
	/**
	 * Get the ArmatureData instance with this name.
	 * @param	name The name of the ArmatureData instance to retreive.
	 * @return ArmatureData The ArmatureData instance by that name.
	 */
	public function getArmatureData(name:String):ArmatureData
	{
		return _armatureDataList.getData(name);
	}
	/**
	 * Get the AnimationData instance with this name.
	 * @param	name The name of the AnimationData instance to retreive. 
	 * @return AnimationData The AnimationData instance by that name.
	 */
	public function getAnimationData(name:String):AnimationData
	{
		return _animationDataList.getData(name);
	}
	/**
	 * Get the DisplayData instance with this name.
	 * @param	name The name of the DisplayData instance to retreive. 
	 * @return AnimationData The DisplayData instance by that name.
	 */
	public function getDisplayData(name:String):DisplayData
	{
		return _displayDataList.getData(name);
	}

}