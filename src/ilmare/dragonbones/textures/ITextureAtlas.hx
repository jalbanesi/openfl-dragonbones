package ilmare.dragonbones.textures;
import flash.geom.Rectangle;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
interface ITextureAtlas
{
	/**
	* The name of this ITextureAtlas.
	*/
	var name (get, null):String;
	/**
	* Clean up resources.
	*/
	function dispose():Void;
	/**
	* Get the specific region of the TextureAtlas occupied by assets defined by that name.
	* @param name The name of the assets represented by that name.
	* @return Rectangle The rectangle area occupied by those assets.
	*/
	function getRegion(name:String):SubTextureData;
}