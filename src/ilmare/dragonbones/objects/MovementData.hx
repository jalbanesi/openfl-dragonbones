package ilmare.dragonbones.objects;

/** @private */
class MovementData
{
	public var _movementBoneDataList:DataList;
	public var _movementFrameList:Array<MovementFrameData>;
	
	public var duration:Float;
	public var durationTo:Float;
	public var durationTween:Float;
	public var loop:Bool;
	public var tweenEasing:Float;
	
	public function new()
	{
		duration = 0;
		durationTo = 0;
		durationTween = 0;
		
		_movementBoneDataList = new DataList();
		_movementFrameList = new Array<MovementFrameData>();
	}
	
	public function dispose():Void
	{
		for (movementBoneName in _movementBoneDataList.dataNames)
		{
			var movementBoneData:MovementBoneData = cast _movementBoneDataList.getData(movementBoneName);
			movementBoneData.dispose();
		}
		
		_movementBoneDataList.dispose();
		_movementFrameList = null;
		/*
		for each(var movementBoneName:String in _movementBoneDataList.dataNames)
		{
			var movementBoneData:MovementBoneData = _movementBoneDataList.getData(movementBoneName) as MovementBoneData;
			movementBoneData.dispose();
		}
		
		_movementBoneDataList.dispose();
		_movementFrameList.length = 0;*/
	}
	
	public function getMovementBoneData(name:String):MovementBoneData
	{
		//return _movementBoneDataList.getData(name) as MovementBoneData;
		return _movementBoneDataList.getData(name);
	}
}
