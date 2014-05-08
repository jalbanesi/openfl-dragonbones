package ilmare.dragonbones.objects;

/** @private */
class BoneData
{
	public var _displayNames:Array<String>;
	
	public var _parent:String;
	
	public var parent (get, null): String;
	public function get_parent():String
	{
		return _parent;
	}
	
	public var node:BoneTransform;
	
	public function new()
	{
		_displayNames = new Array<String>();
		node = new BoneTransform();
	}
	
	public function dispose():Void
	{
		//_displayNames.length = 0;
		_displayNames = null;//new Array<String>();
	}
}
