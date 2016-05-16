package ilmare.dragonbones.textures;

import haxe.xml.Fast;
import ilmare.dragonbones.textures.SubTextureData;
import ilmare.dragonbones.utils.ConstValues;
import openfl.Assets;
import flash.display.BitmapData;
import openfl.display.Tilesheet;
import flash.geom.Point;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
class NMETextureAtlas extends Tilesheet implements ITextureAtlas
{
	private var _name: String;
	private var _subTextureDataDic: Map<String,SubTextureData>;
	
	private var _width: Int;
	private var _height: Int;
	
	public function new(bitmapDataPath: String, textureAtlasXMLPath: String) 
	{
		super(Assets.getBitmapData(bitmapDataPath));
		
		_subTextureDataDic = new Map<String,SubTextureData>();
		
		var xmlString: String = Assets.getText(textureAtlasXMLPath);
		var xml: Xml = Xml.parse(xmlString);		
		
		parseData(new Fast(xml.firstElement()));
	}

	private function parseData(textureAtlasXML: Fast):Void
	{
		_name = textureAtlasXML.att.resolve(ConstValues.A_NAME);
		_width = Std.parseInt(textureAtlasXML.att.resolve(ConstValues.A_WIDTH));
		_height = Std.parseInt(textureAtlasXML.att.resolve(ConstValues.A_HEIGHT));
		//var scale: Float = _isDifferentXML ? _scale : 1;
		var scale: Float = 1;
		
		//for (subTextureXML in textureAtlasXML.elements(ConstValues.SUB_TEXTURE))
		var id: Int = 0;
		for (subTextureXML in textureAtlasXML.elements)
		{
			var subTextureName: String = subTextureXML.att.resolve(ConstValues.A_NAME);
			var subTextureData: SubTextureData = new SubTextureData();
			subTextureData.x = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_X)) / scale;
			subTextureData.y = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_Y)) / scale;
			subTextureData.width = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_WIDTH)) / scale;
			subTextureData.height = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_HEIGHT)) / scale;	
			if (subTextureXML.has.resolve(ConstValues.A_PIVOT_X))
				subTextureData.pivotX = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_PIVOT_X));
			if (subTextureXML.has.resolve(ConstValues.A_PIVOT_Y))
				subTextureData.pivotY = Std.parseFloat(subTextureXML.att.resolve(ConstValues.A_PIVOT_Y));
			subTextureData.tileId = id;
				
			addTileRect(subTextureData, new Point(subTextureData.pivotX, subTextureData.pivotY));			
			_subTextureDataDic.set(subTextureName, subTextureData);			
			//_subTextureDataDic[subTextureName] = subTextureData;
			id++;
		}
		
	}	
	
	public var name (get, null): String;
	
	public function get_name(): String
	{
		return _name;
	}
	
	public function dispose():Void
	{
		// TODO
	}
	
	public function getRegion(name:String): SubTextureData
	{
		return name == null ? null : _subTextureDataDic.get(name);
	}
	
}