package ilmare.dragonbones.objects;

/** @private */
class ArmatureData
{
	public var _boneDataList:DataList;
	
	public var boneNames (get, null): Array<String>;	
	public function get_boneNames():Array<String>
	{
		return _boneDataList.dataNames.copy();
	}
	
	public function new()
	{
		_boneDataList = new DataList();
	}
	
	public function dispose():Void
	{
		for (boneName in _boneDataList.dataNames)
		{
			var boneData: BoneData = cast _boneDataList.getData(boneName);
			boneData.dispose();
		}
		
		_boneDataList.dispose();
		/*
		for each(var boneName:String in _boneDataList.dataNames)
		{
			var boneData:BoneData = _boneDataList.getData(boneName) as BoneData;
			boneData.dispose();
		}
		
		_boneDataList.dispose();*/
	}
	
	public function getBoneData(name:String):BoneData
	{
		return _boneDataList.getData(name);
	}
	
	public function updateBoneList():Void
	{
		var boneNames:Array<String> = _boneDataList.dataNames;
		
		var sortList:Array<Dynamic> = new Array<Dynamic>();
		//trace("PRE");
		for (boneName in boneNames)
		{
			var boneData:BoneData = _boneDataList.getData(boneName);
			var levelValue: Int = boneData.node.z;
			var level: Int = 0;
			while(boneData != null)
			{
				level ++;
				levelValue += 1000 * level;
				boneData = getBoneData(boneData.parent);
			}
			//trace("---------- BONE: " + boneName + " level: " + levelValue);
			sortList.push( { level:levelValue, boneName:boneName } );
		}
		
		//trace("POST");
		var length:Int = sortList.length;
		if(length > 0)
		{
			sortList.sort(
				function(a: Dynamic, b: Dynamic): Int 
				{ 
					if (a.level == b.level)
						return 0;
					else if (a.level > b.level)
						return 1;					
					return -1;					
				} 
			);//sortOn("level", Array.NUMERIC);			
			boneNames = new Array<String>();
			var i:Int = 0;
			while(i < length)
			{
				//trace("---------- BONE: " + sortList[i].boneName + " level: " + sortList[i].level);
				_boneDataList.dataNames[i] = sortList[i].boneName;
				i ++;
			}
		}
			
	}

}