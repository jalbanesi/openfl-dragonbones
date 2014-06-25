package ilmare.dragonbones.textures;

import flash.geom.Rectangle;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
class SubTextureData extends Rectangle
{
	public var tileId: Int;
	public var pivotX:Float;
	public var pivotY:Float;

	public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0) 
	{
		super(x, y, width, height);
		pivotX = 0;
		pivotY = 0;		
		tileId = 0;
	}
	
}
