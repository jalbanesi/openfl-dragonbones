package ilmare.dragonbones.objects;
/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0
* @langversion 3.0
* @version 2.0
*/

/**
 * The BoneTransform class provides transformation properties and methods for Bone instances.
 * @example
 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
 * <p>This example gets the BoneTransform of the head bone and adjust the x and y registration by 60 pixels.</p>
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
 * 				bone.origin.pivotX = 60;//origin BoneTransform
 *				bone.origin.pivotY = 60;//origin BoneTransform
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
class BoneTransform
{
	/**
	 * Position on the x axis.
	 */
	public var x:Float;
	/**
	 * Position on the y axis.
	 */
	public var y:Float;
	/**
	 * Scale on the x axis.
	 */
	public var scaleX:Float;
	/**
	 * Scale on the y axis.
	 */
	public var scaleY:Float;
	/**
	 * Skew on the x axis.
	 */
	public var skewX:Float;
	/**
	 * skew on the y axis.
	 */
	public var skewY:Float;
	/**
	 * pivot point on the x axis (registration)
	 */
	public var pivotX:Float;
	/**
	 * pivot point on the y axis (registration)
	 */
	public var pivotY:Float;
	/**
	 * Z order.
	 */
	public var z:Int;
	
	/**
	 * The rotation of that BoneTransform instance.
	 */
	public function getRotation():Float
	{
		return skewX;
	}
	/**
	 * @private
	 */
	public function setRotation(value:Float):Void
	{
		skewX = skewY = value;
	}
	/**
	 * Creat a new BoneTransform instance.
	 */
	public function new()
	{
		setValues();
	}
	/**
	 * Sets all properties at once.
	 * @param	x The x position.
	 * @param	y The y position.
	 * @param	skewX The skew value on x axis.
	 * @param	skewY The skew value on y axis.
	 * @param	scaleX The scale on x axis.
	 * @param	scaleY The scale on y axis.
	 * @param	pivotX The pivot value on x axis (registration)
	 * @param	pivotY The pivot valule on y axis (registration)
	 * @param	z The z order.
	 */
	public function setValues(x:Float = 0, y:Float = 0, skewX:Float = 0, skewY:Float = 0, scaleX:Float = 0, scaleY:Float = 0, pivotX:Float = 0, pivotY:Float = 0, z:Int = 0):Void
	{
		this.x = x;
		this.y = y;
		this.skewX = skewX;
		this.skewY = skewY;
		this.scaleX = scaleX;
		this.scaleY = scaleY;
		this.pivotX = pivotX;
		this.pivotY = pivotY;
		this.z = z;
	}
	/**
	 * Copy all properties from this BoneTransform instance to the passed BoneTransform instance.
	 * @param	node
	 */
	public function copy(node:BoneTransform):Void
	{
		x = node.x;
		y = node.y;
		scaleX = node.scaleX;
		scaleY = node.scaleY;
		skewX = node.skewX;
		skewY = node.skewY;
		pivotX = node.pivotX;
		pivotY = node.pivotY;
		z = node.z;
	}
	/**
	 * Get a string representing all BoneTransform property values.
	 * @return String All property values in a formatted string.
	 */
	public function toString():String
	{
		var string:String = "x:" + x + " y:" + y + " skewX:" + skewX + " skewY:" + skewY + " scaleX:" + scaleX + " scaleY:" + scaleY;
		return string;
	}

}