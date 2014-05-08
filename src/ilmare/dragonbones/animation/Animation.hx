package ilmare.dragonbones.animation;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0
* @langversion 3.0
* @version 2.0
*/
import ilmare.dragonbones.Armature;
import ilmare.dragonbones.Bone;
import ilmare.dragonbones.events.AnimationEvent;
import ilmare.dragonbones.events.FrameEvent;
import ilmare.dragonbones.objects.AnimationData;
import ilmare.dragonbones.objects.MovementBoneData;
import ilmare.dragonbones.objects.MovementData;
import ilmare.dragonbones.objects.MovementFrameData;

/**
 * An Animation instance is used to control the animation state of an Armature.
 * @example
 * <p>Download the example files <a href='http://dragonbones.github.com/downloads/DragonBones_Tutorial_Assets.zip'>here</a>: </p>
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
 *			private function handleParseData(e:Event):Void 
 *			{			
 *				armature = factory.buildArmature('Dragon');
 *				addChild(armature.display as Sprite); 			
 *				armature.animation.play();
 *				addEventListener(Event.ENTER_FRAME, updateAnimation);			
 *			}
 *			
 *			private function updateAnimation(e:Event):Void 
 *			{
 *				armature.advanceTime(stage.frameRate / 1000);
 *			}		
 *		}
 *	}
 * </listing>
 * @see dragonBones.Bone
 * @see dragonBones.Armature
 */
class Animation
{/**
 * @private
 */
	public static inline var SINGLE:Int = 0;
	/**
 * @private
 */
	public static inline var LIST_START:Int = 1;
	/**
 * @private
 */
	public static inline var LOOP_START:Int = 2;
	/**
 * @private
 */
	public static inline var LIST:Int = 3;
	/**
 * @private
 */
	public static inline var LOOP:Int = 4;		
	/**
	 * Whether animation tweening is enabled or not.
	 */
	public var tweenEnabled:Bool = true;
	
	private var _playType:Int;
	private var _duration:Float;
	private var _rawDuration:Float;		
	private var _nextFrameDataTimeEdge:Float;
	private var _nextFrameDataID:Int;
	private var _loop:Int;		
	private var _breakFrameWhile:Bool;		
	private var _armature:Armature;
	private var _movementData:MovementData;		
	private var _animationData:AnimationData;
	
	public var animationData (get, set): AnimationData;
	
	/**
	 * The AnimationData assiociated with this Animation instance.
	 * @see dragonBones.objects.AnimationData.
	 */
	public function get_animationData():AnimationData
	{
		return _animationData;
	}
	/**
	 * @private
	 */
	public function set_animationData(value)
	{
		if (value != null)
		{
			stop();
			_animationData = value;
		}
		return value;
	}
	
	private var _currentTime:Float;
	/**
	 * Get the current playhead time in seconds.
	 */
	public var currentTime (get, null): Float;
	public function get_currentTime():Float
	{
		return _currentTime;
	}
	
	private var _totalTime:Float;
	/**
	 * Get the total elapsed time in second.
	 */
	public var totalTime (get, null): Float;
	public function get_totalTime():Float
	{
		return _totalTime;
	}
	
	private var _isPlaying:Bool;
	
	/**
	 * Indicates whether the animation is playing or not.
	 */
	public var isPlaying (get, null): Bool;
	public function get_isPlaying():Bool
	{
		if (_isPlaying)
		{
			return _loop >= 0 || _currentTime < _totalTime;
		}
		return false;
	}
	
	/**
	 * Indicates whether the animation has completed or not.
	 */
	public var isComplete (get, null): Bool;
	public function get_isComplete():Bool
	{
		return _loop < 0 && _currentTime >= _totalTime;
	}
	
	/**
	 * Indicates whether the animation is paused or not.
	 */
	public var isPause (get, null): Bool;
	public function get_isPause():Bool
	{
		return !_isPlaying;
	}
	
	private var _timeScale:Float = 1;
	
	/**
	 * The amount by which passed time should be scaled. Used to slow down or speed up animations. Defaults to 1.
	 */
	public var timeScale (get, set): Float;
	public function get_timeScale():Float
	{
		return _timeScale;
	}
	/**
	 * @private
	 */
	public function set_timeScale(value: Float)
	{
		if (value < 0)
		{
			value = 0;
		}
		_timeScale = value;
		
		for (bone in _armature._boneDepthList)
		{
			if (bone.childArmature != null)
			{
				bone.childArmature.animation.timeScale = _timeScale;
			}
		}
		return value;
	}
	
	private var _movementID:String;
	
	/**
	 * The name ID of the current MovementData.
	 * @see dragonBones.objects.MovementData.
	 */
	public var movementID (get, null): String;
	public function get_movementID():String
	{
		return _movementID;
	}
	
	/**
	 * An vector containing all MovementData names the animation can play.
	 * @see dragonBones.objects.MovementData.
	 */
	public var movementList (get, null): Array<String>;
	public function get_movementList():Array<String>
	{
		return _animationData != null ? _animationData.movementList : null;
	}
	
	/**
	 * Creates a new Animation instance and attaches it to the passed Arnature.
	 * @param	An Armature to attach this Animation instance to.
	 */
	public function new(armature:Armature)
	{
		_armature = armature;
	}
	/**
	 * Qualifies all resources used by this Animation instance for garbage collection.
	 */
	public function dispose():Void
	{
		stop();
		_animationData = null;
		_movementData = null;
		_armature = null;
	}
	
	public function gotoAndStop(movementID:String, tweenTime:Float = -1, duration:Float = -1, ?loop:Bool) 
	{
		gotoAndPlay(movementID, tweenTime, duration, loop);
		stop();
	}	
	
	/**
	 * Move the playhead to that MovementData id
	 * @param	The id of the MovementData to play.
	 * @param	A tween time to apply (> 0)
	 * @param	The duration in seconds of that MovementData.
	 * @param	Whether that MovementData should loop or play only once (true/false).
	 * @see dragonBones.objects.MovementData.
	 */
	public function gotoAndPlay(movementID:String, tweenTime:Float = -1, duration:Float = -1, ?loop:Bool):Void
	{
		if (_animationData == null)
		{
			return;
		}
		var movementData:MovementData = _animationData.getMovementData(movementID);
		if (movementData == null)
		{
			return;
		}
		
		/* JIA don't override if it's already playing this animation */
		
		/*if (movementID == _movementID)
			return;*/
		
		/* /JIA */
		
		
		_movementData = movementData;
		_isPlaying = true;
		_currentTime = 0;
		_breakFrameWhile = true;
		
		var exMovementID:String = _movementID;
		_movementID = movementID;
		
		if (tweenTime >= 0)
		{
			_totalTime = tweenTime;
		}
		else if (tweenEnabled && exMovementID != null)
		{
			_totalTime = _movementData.durationTo;
		}
		else
		{
			_totalTime = 0;
		}
		
		if (_totalTime < 0)
		{
			_totalTime = 0;
		}
		
		_duration = duration >= 0 ? duration : _movementData.durationTween;
		if (_duration < 0)
		{
			_duration = 0;
		}
		
		loop = cast((loop == null ? _movementData.loop : loop), Bool); // https://github.com/SlavaRa/dragonbones-haxe3/blob/master/Source/dragonbones/animation/Animation.hx
		
		_rawDuration = _movementData.duration;
		
		_loop = loop ? 0 : -1;
		if (_rawDuration == 0)
		{
			_playType = SINGLE;
		}
		else
		{
			_nextFrameDataTimeEdge = 0;
			_nextFrameDataID = 0;
			if (loop)
			{
				_playType = LOOP_START;
			}
			else
			{
				_playType = LIST_START;
			}
		}
		
		var tweenEasing:Float = _movementData.tweenEasing;
		
		for (bone in _armature._boneDepthList)
		{
			var movementBoneData:MovementBoneData = _movementData.getMovementBoneData(bone.name);
			if (movementBoneData != null)
			{
				bone._tween.gotoAndPlay(movementBoneData, _rawDuration, loop, tweenEasing);
				if (bone.childArmature != null)
				{
					bone.childArmature.animation.gotoAndPlay(movementID);
				}
			}
			else
			{
				bone._tween.stop();
			}
		}
		
		if (_armature.hasEventListener(AnimationEvent.MOVEMENT_CHANGE))
		{
			var event:AnimationEvent = new AnimationEvent(AnimationEvent.MOVEMENT_CHANGE);
			event.exMovementID = exMovementID;
			event.movementID = _movementID;
			_armature.dispatchEvent(event);
		}
	}
	
	/**
	 * Play the animation from the current position.
	 */
	public function play():Void
	{
		if (_animationData == null)
		{
			return;
		}
		
		if (_movementID == null)
		{
			if (movementList != null)
			{
				gotoAndPlay(movementList[0]);
			}
			return;
		}
		
		if (isComplete)
		{
			gotoAndPlay(_movementID);
		}
		else if (!_isPlaying)
		{
			_isPlaying = true;
			for (bone in _armature._boneDepthList)
			{
				if (bone.childArmature != null)
				{
					bone.childArmature.animation.play();
				}
			}
		}
	}
	
	/**
	 * Stop the playhead.
	 */
	public function stop():Void
	{
		_isPlaying = false;
		
		for (bone in _armature._boneDepthList)
		{
			if (bone.childArmature != null)
			{
				bone.childArmature.animation.stop();
			}
		}
	}
	
	/** @private */
	public function advanceTime(passedTime:Float):Void
	{
		if (_isPlaying && (_loop > 0 || _currentTime < _totalTime || _totalTime == 0))
		{
			var progress:Float;
			if (_totalTime > 0)
			{
				_currentTime += passedTime * _timeScale;
				progress = _currentTime / _totalTime;
			}
			else
			{
				_currentTime = 1;
				_totalTime = 1;
				progress = 1;
			}
			
			var event:AnimationEvent = null;
			if (_playType == LOOP)
			{
				var loop:Int = Math.floor(progress);
				if (loop != _loop)
				{
					_loop = loop;
					_nextFrameDataTimeEdge = 0;
					if (_armature.hasEventListener(AnimationEvent.LOOP_COMPLETE))
					{
						event = new AnimationEvent(AnimationEvent.LOOP_COMPLETE);
						event.movementID = _movementID;
					}
				}
			}
			else if (progress >= 1)
			{
				switch (_playType)
				{
					case SINGLE: 
					case LIST: 
						progress = 1;
						if (_armature.hasEventListener(AnimationEvent.COMPLETE))
						{
							event = new AnimationEvent(AnimationEvent.COMPLETE);
							event.movementID = _movementID;
						}						
					case LIST_START: 
						progress = 0;
						_playType = LIST;
						_currentTime = 0;
						_totalTime = _duration;
						if (_armature.hasEventListener(AnimationEvent.START))
						{
							event = new AnimationEvent(AnimationEvent.START);
							event.movementID = _movementID;
						}						
					case LOOP_START: 
						progress = 0;
						_playType = LOOP;
						_currentTime = 0;
						_totalTime = _duration;
						if (_armature.hasEventListener(AnimationEvent.START))
						{
							event = new AnimationEvent(AnimationEvent.START);
							event.movementID = _movementID;
						}
						
				}
			}
			
			for (bone in _armature._boneDepthList)
			{
				bone._tween.advanceTime(progress, _playType);
			}
			
			if ((_playType == LIST || _playType == LOOP) && _movementData._movementFrameList.length > 0)
			{
				if (_loop > 0)
				{
					progress -= _loop;
				}
				updateFrameData(progress);
			}
			
			if (event != null)
			{
				_armature.dispatchEvent(event);
			}
		}
	}
	
	private function updateFrameData(progress:Float):Void
	{
		var playedTime:Float = _rawDuration * progress;
		if (playedTime >= _nextFrameDataTimeEdge)
		{
			_breakFrameWhile = false;
			var length:Int = _movementData._movementFrameList.length;
			do
			{
				var currentFrameDataID:Int = _nextFrameDataID;
				var currentFrameData:MovementFrameData = _movementData._movementFrameList[currentFrameDataID];
				var frameDuration:Float = currentFrameData.duration;
				_nextFrameDataTimeEdge += frameDuration;
				if (++_nextFrameDataID >= length)
				{
					_nextFrameDataID = 0;
				}
				arriveFrameData(currentFrameData);
				if (_breakFrameWhile)
				{
					break;
				}
			} while (playedTime >= _nextFrameDataTimeEdge);
		}
	}
	
	private function arriveFrameData(movementFrameData:MovementFrameData):Void
	{
		//Tracer.reveal(movementFrameData)
		if (movementFrameData.event != null && _armature.hasEventListener(FrameEvent.MOVEMENT_FRAME_EVENT))
		{
			var frameEvent:FrameEvent = new FrameEvent(FrameEvent.MOVEMENT_FRAME_EVENT);
			frameEvent.movementID = _movementID;
			frameEvent.frameLabel = movementFrameData.event;
			_armature.dispatchEvent(frameEvent);
		}
		/*
		if (movementFrameData.sound && _soundManager.hasEventListener(SoundEvent.SOUND))
		{
			var soundEvent:SoundEvent = new SoundEvent(SoundEvent.SOUND);
			soundEvent.movementID = _movementID;
			soundEvent.sound = movementFrameData.sound;
			soundEvent._armature = _armature;
			_soundManager.dispatchEvent(soundEvent);
		}*/
		if (movementFrameData.movement != null)
		{
			gotoAndPlay(movementFrameData.movement);
		}
	}
}

