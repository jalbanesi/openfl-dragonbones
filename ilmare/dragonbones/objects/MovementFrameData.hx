package ilmare.dragonbones.objects;
/** @private */
class MovementFrameData
{
	public var duration:Float;
	public var movement:String;
	public var event:String;
	public var sound:String;
	public var soundEffect:String;
	
	public function new()
	{
	}
	
	public function setValues(duration:Float, movement:String, event:String, sound:String):Void
	{
		this.duration = duration;
		this.movement = movement;
		this.event = event;
		this.sound = sound;
	}
}