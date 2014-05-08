package ilmare.dragonbones.objects;

import flash.geom.ColorTransform;

/** @private */
class FrameData
{
	public var duration:Float;
	public var tweenEasing:Float;
	public var tweenRotate:Int;
	public var displayIndex:Int;
	public var movement:String;
	public var visible:Bool;
	public var event:String;
	public var sound:String;
	public var soundEffect:String;
	public var node:BoneTransform;
	public var colorTransform:ColorTransform;
	
	public function new()
	{
		duration = 0;
		//NaN: no tweens;  -1: ease out; 0: linear; 1: ease in; 2: ease in&out
		tweenEasing = 0;
		node = new BoneTransform();
		colorTransform = new ColorTransform();
	}
}
