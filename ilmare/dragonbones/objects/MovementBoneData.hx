package ilmare.dragonbones.objects;

/** @private */
class MovementBoneData
{
	public static var HIDE_DATA:MovementBoneData = new MovementBoneData();
	
	public var _frameList:Array<FrameData>;
	
	
	public var scale:Float;
	public var delay:Float;
	
	public function new()
	{
		scale = 1;
		delay = 0;
		
		_frameList = new Array<FrameData>();
	}
	
	public function dispose():Void
	{
		_frameList = null;
		//_frameList.length = 0;
	}
	
	public function setValues(scale:Float= 1, delay:Float= 0):Void
	{
		this.scale = scale > 0?scale:1;
		//this.delay = (delay || 0) % 1;
		this.delay = delay;
		if (this.delay > 0)
		{
			this.delay -= 1;
		}
		this.delay *= -1;
	}
}
