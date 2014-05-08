package ilmare.dragonbones.objects;


/** @private */
class DisplayData
{
	public var pivotX:Float;
	public var pivotY:Float;
	
	public var _isArmature:Bool;
	
	public var isArmature (get, null): Bool;
	
	public function get_isArmature():Bool
	{
		return _isArmature;
	}
	
	public function new()
	{
		pivotX = 0;
		pivotY = 0;
	}
}