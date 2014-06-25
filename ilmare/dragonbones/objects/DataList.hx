package ilmare.dragonbones.objects;

class DataList
{
	private var _dataDic: Map<String,Dynamic>;
	public var dataNames: Array<String>;
	
	public function new()
	{		
		_dataDic = new Map<String,Dynamic>();
		dataNames = new Array<String>();
	}
	
	public function dispose():Void
	{
		_dataDic = null;// new Map<String,Dynamic>();
		//dataNames.length = 0;
		dataNames = null;// new Array<String>();
	}
	
	public function getData(dataName:String):Dynamic
	{
		return _dataDic.get(dataName);
	}
	
	public function getDataAt(index:Int):Dynamic
	{
		return _dataDic.get(dataNames[index]);
	}
	
	public function addData(data:Dynamic, dataName:String):Void
	{
		if(data != null && dataName != null)
		{
			_dataDic.set(dataName, data);
			//_dataDic[dataName] = data;
			if(Lambda.indexOf(dataNames, dataName) < 0)
			{
				dataNames.push(dataName);
			}
		}
	}
	
	public function removeData(data:Dynamic):Void
	{
		// TODO: testear que funciona
		if(data)
		{
			for(dataName in _dataDic)
			{
				if(_dataDic.get(dataName) == data)
				{
					removeDataByName(dataName);
					return;
				}
			}
		}
	}
	
	public function removeDataByName(dataName:String):Void
	{
		// TODO: testear que funciona
		var data:Dynamic = _dataDic.get(dataName);
		if(data)
		{
			_dataDic.remove(dataName); // delete _dataDic[dataName];
			dataNames.splice(Lambda.indexOf(dataNames,  dataName), 1); // dataNames.splice(dataNames.indexOf(dataName), 1);			
		}
	}
}
