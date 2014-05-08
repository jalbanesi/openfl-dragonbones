package ilmare.dragonbones.animation;

/**
* Copyright 2012-2013. ilmare.dragonbones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/
import ilmare.dragonbones.Armature;	
import flash.Lib;
/**
 * A WorldClock instance lets you conveniently update many number of Armature instances at once. You can add/remove Armature instance and set a global timescale that will apply to all registered Armature instance animations.
 * @example
 * <p>Download the example files <a href='http://ilmare.dragonbones.github.com/downloads/ilmare.dragonbones_Tutorial_Assets.zip'>here</a>: </p>
 * <listing>	
 *	package  
 *	{
 *		import ilmare.dragonbones.Armature;
 *		import ilmare.dragonbones.factorys.BaseFactory;
 *  	import flash.display.Sprite;
 *		import flash.events.Event;	
 * 	import ilmare.dragonbones.animation.WorldClock;
 * 
 *
 * public class DragonAnimation extends Sprite 
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
 *			private function handleParseData(e:Event):Void 
 *			{			
 *				armature = factory.buildArmature('Dragon');
 *				addChild(armature.display as Sprite); 			
 *				armature.animation.play(); 				
 * 				WorldClock.clock.add(armature);
 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
 *			}
 *			
 *			private function updateAnimation(e:Event):Void 
 *			{
 *				WorldClock.clock.advanceTime(stage.frameRate / 1000);
 *			}		
 *		}
 *	}
 * </listing>
 * @see ilmare.dragonbones.Armature
 * @see ilmare.dragonbones.Bone
 * @see ilmare.dragonbones.animation.Animation
 */
class WorldClock implements IAnimatable
{
	/**
	 * A global static WorldClock instance ready to use.
	 */
	public static var clock:WorldClock = new WorldClock();
	
	private var animatableList:Array<IAnimatable>;			
	
	/**
	 * @private
	 */
	public var time (get, null): Float;
	private var _time:Float;
	private function get_time():Float
	{
		return _time;
	}
	
	
	/**
	 * The time scale to apply to the number of second passed to the advanceTime() method.
	 * @param A Number to use as a time scale (NaN or < 0 to disable).
	 */
	public var timeScale (get, set): Float;	 
	private var _timeScale:Float = 1;
	private function get_timeScale():Float
	{
		return _timeScale;
	}
	/**
	 * @private
	 */
	private function set_timeScale(value:Float):Float
	{
		if (value < 0 || Math.isNaN(value))
		{
			value = 0;
		}
		_timeScale = value;
		return value;
	}
	/**
	 * Creates a new WorldClock instance. (use the static var WorldClock.clock instead).
	 */
	public function new()
	{
		_time = Lib.getTimer() * 0.001;
		animatableList = new Array<IAnimatable>();
	}
	
	/** 
	 * Returns true if the IAnimatable instance is contained by WorldClock instance.
	 * @param	An IAnimatable instance (Armature or custom)
	 * @return true if the IAnimatable instance is contained by WorldClock instance.
	 */
	public function contains(animatable:IAnimatable):Bool
	{
		return Lambda.indexOf(animatableList, animatable) >= 0;
	}
	/**
	 * Add a IAnimatable instance (Armature or custom) to this WorldClock instance.
	 * @param	An IAnimatable instance (Armature, WorldClock or custom)
	 */
	public function add(animatable:IAnimatable):Void
	{
		if (animatable != null && Lambda.indexOf(animatableList, animatable) == -1)
		{
			animatableList.push(animatable);
		}
	}
	/**
	 * Remove a IAnimatable instance (Armature or custom) from this WorldClock instance.
	 * @param	An IAnimatable instance (Armature or custom)
	 */
	public function remove(animatable:IAnimatable):Void
	{
		var index:Int = Lambda.indexOf(animatableList, animatable);
		if (index >= 0)
		{
			//animatableList[index] = null;
			animatableList.splice(index, 1);
		}
	}
	/**
	 * Remove all IAnimatable instance (Armature or custom) from this WorldClock instance.
	 *
	 */
	public function clear():Void
	{
		animatableList = new Array<IAnimatable>();
	}
	/**
	 * Update all registered IAnimatable instance animations using this method typically in an ENTERFRAME Event or with a Timer.
	 * @param	The amount of second to move the playhead ahead.
	 */
	public function advanceTime(passedTime:Float):Void
	{
		if (passedTime < 0)
		{
			var currentTime:Float = Lib.getTimer();// * 0.001;
			passedTime = (currentTime - _time) / 1000;// * 0.001;
			_time = currentTime;
		}
		
		passedTime *= _timeScale;
		
		var length:Int = animatableList.length;
		if (length == 0)
		{
			return;
		}
		var currentIndex:Int = 0;
		var iIndex: Int = 0;
		
		for (animatable in animatableList)
		{
			if (animatable != null)
			{
				animatable.advanceTime(passedTime);
			}
		}
		
		/*for (i in 0...length)
		//for (var i:Int = 0; i < length; i++)
		{
			var animatable:IAnimatable = animatableList[i];
			if (animatable != null)
			{
				if (currentIndex != i)
				{
					animatableList[currentIndex] = animatable;
					animatableList[i] = null;
				}
				animatable.advanceTime(passedTime);
				currentIndex++;
			}
			iIndex = i;
		}
		
		if (currentIndex != iIndex)
		{
			length = animatableList.length;
			while (iIndex < length)
			{
				animatableList[currentIndex++] = animatableList[iIndex++];
			}
			// animatableList.length = currentIndex; TODO
		}*/
	}
	
	public function animCount(): Int
	{
		return animatableList.length;
	}
}
