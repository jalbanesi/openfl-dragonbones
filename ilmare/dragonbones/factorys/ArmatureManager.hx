package ilmare.dragonbones.factorys;
import ilmare.dragonbones.Armature;
import ilmare.dragonbones.objects.SkeletonData;
import ilmare.dragonbones.objects.XMLDataParser;
import ilmare.dragonbones.textures.BitmapTextureAtlas;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
class ArmatureManager extends BaseFactory
{
	private static var _instance: ArmatureManager = null;
	public static var instance (get, null): ArmatureManager;
	
	private static function get_instance(): ArmatureManager
	{
		if (_instance == null)
			_instance = new ArmatureManager();
		
		return _instance;
	}
	
	public function armatureToBitmapData(armatureName: String): BitmapData
	{
		var armature: Armature = buildArmature(armatureName);
		
		var rect: Rectangle = armature.display.getBounds(armature.display);
		var bitmapData: BitmapData = new BitmapData(Std.int(rect.width), Std.int(rect.height), true, 0);
		
		var matrix: Matrix = new Matrix();
		matrix.translate( -rect.x, -rect.y);
		bitmapData.draw(armature.display, matrix);
		armature.dispose();
		return bitmapData;
	}
	
	public function parseSkeleton(skeletonXmlPath: String): Void
	{
		var xmlString: String = Assets.getText(skeletonXmlPath);
		var xml: Xml = Xml.parse(xmlString);							
		var skeletonData: SkeletonData = XMLDataParser.parseSkeletonData(xml.firstElement());

		_skeletonDataDic.set(skeletonData.name, skeletonData);		
		_currentSkeletonData = skeletonData;
		_currentSkeletonName = skeletonData.name;
		
	}
	
	public function parseTexture(textureXmlPath: String, textureImgPath: String, name: String = null): Void
	{
		var atlas: BitmapTextureAtlas = new BitmapTextureAtlas(textureImgPath, textureXmlPath);
		
		_textureAtlasDic.set(name != null ? name : atlas.name, atlas);
		_currentTextureAtlas = atlas;
		_currentTextureAtlasName = name != null ? name : atlas.name;
		
	}
	
	
	
}