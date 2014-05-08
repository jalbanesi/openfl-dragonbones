package ilmare.dragonbones.events;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/
import ilmare.dragonbones.Armature;

import flash.events.Event;

/**
 * The AnimationEvent provides and defines all events dispatched during an animation.
 *
 * @see dragonBones.Armature
 * @see dragonBones.animation.Animation
 */
class AnimationEvent extends Event
{
	/**
	 * Dispatched when the movement of animation is changed.
	 */
	public static inline var MOVEMENT_CHANGE:String = "movementChange";
	
	/**
	 * Dispatched when the playback of an animation starts.
	 */
	public static inline var START:String = "start";
	
	/**
	 * Dispatched when the playback of a movement stops.
	 */
	public static inline var COMPLETE:String = "complete";
	
	/**
	 * Dispatched when the playback of a movement completes a loop.
	 */
	public static inline var LOOP_COMPLETE:String = "loopComplete";
	/**
	 * The preceding MovementData id.
	 */
	public var exMovementID:String;
	/**
	 * The current MovementData id.
	 */
	public var movementID:String;
	
	/**
	 * The armature that is the taget of this event.
	 */
	public var armature (get, null): Armature;
	 
	public function get_armature():Armature
	{
		return target;
	}
	
	/**
	 * Creates a new AnimationEvent instance.
	 * @param	type
	 * @param	cancelable
	 */
	public function new(type:String, cancelable:Bool = false)
	{
		super(type, false, cancelable);
	}
	
	/**
	 * @private
	 * @return
	 */
	override public function clone():Event
	{
		var event:AnimationEvent = new AnimationEvent(type, cancelable);
		event.exMovementID = exMovementID;
		event.movementID = movementID;
		return event;
	}
}
