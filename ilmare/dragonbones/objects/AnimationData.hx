package ilmare.dragonbones.objects;


/** @private */
class AnimationData
{
	public var _movementDataList:DataList;
	
	public var movementList (get, null): Array<String>;
	public function get_movementList():Array<String>
	{
		return _movementDataList.dataNames.copy();
	}
	
	public function new()
	{
		_movementDataList = new DataList();
	}
	
	public function dispose():Void
	{
		for (movementName in _movementDataList.dataNames)
		{
			var movementData:MovementData = cast _movementDataList.getData(movementName);
			movementData.dispose();			
		}
		_movementDataList.dispose();
		/*
		for (movementName in _movementDataList.dataNames)
		{
			var movementData:MovementData = _movementDataList.getData(movementName) as MovementData;
			movementData.dispose();
		}
		
		_movementDataList.dispose();*/
	}
	
	public function getMovementData(name:String):MovementData
	{
		return _movementDataList.getData(name);
	}
}
	
