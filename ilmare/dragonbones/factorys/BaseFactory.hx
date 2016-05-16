package ilmare.dragonbones.factorys;

/**
* Copyright 2012-2013. DragonBones. All Rights Reserved.
* @playerversion Flash 10.0, Flash 10
* @langversion 3.0
* @version 2.0
*/

import ilmare.dragonbones.Armature;
import ilmare.dragonbones.Bone;
import ilmare.dragonbones.display.NativeDisplayBridge;
import ilmare.dragonbones.objects.AnimationData;
import ilmare.dragonbones.objects.ArmatureData;
import ilmare.dragonbones.objects.BoneData;
import ilmare.dragonbones.objects.DecompressedData;
import ilmare.dragonbones.objects.DisplayData;
import ilmare.dragonbones.objects.SkeletonData;
import ilmare.dragonbones.objects.XMLDataParser;
import ilmare.dragonbones.textures.ITextureAtlas;
import ilmare.dragonbones.textures.NMETextureAtlas;
import ilmare.dragonbones.textures.SubTextureData;
import openfl.Assets;
import flash.display.DisplayObject;
import flash.errors.ArgumentError;
//import ilmare.dragonbones.utils.BytesType;

import flash.display.Bitmap;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix;
import flash.utils.ByteArray;


/** Dispatched after a sucessful call to parseData(). */
//[Event(name="complete", type="flash.events.Event")]

/**
 * A BaseFactory instance manages the set of armature resources for the tranditional Flash DisplayList. It parses the raw data (ByteArray), stores the armature resources and creates armature instances.
 * <p>Create an instance of the BaseFactory class that way:</p>
 * <listing>
 * import flash.events.Event; 
 * import ilmare.dragonbones.factorys.BaseFactory;
 * 
 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]  
 *	private static const ResourcesData:Class;
 * var factory:BaseFactory = new BaseFactory(); 
 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
 * factory.parseData(new ResourcesData());
 * </listing>
 * @see ilmare.dragonbones.Armature
 */
class BaseFactory extends EventDispatcher
{
	/** @private */
	private static var _helpMatirx:Matrix = new Matrix();		
	/** @private */
	private var _skeletonDataDic:Map<String,SkeletonData>;
	/** @private */
	private var _textureAtlasDic:Map<String,NMETextureAtlas>;
	/** @private */
	private var _currentSkeletonData:SkeletonData;
	/** @private */
	private var _currentTextureAtlas:NMETextureAtlas;
	/** @private */
	private var _currentSkeletonName:String;
	/** @private */
	private var _currentTextureAtlasName:String;
	
	/**
	 * Create a Basefactory instance.
	 * 
	 * @example 
	 * <listing>		
	 * import ilmare.dragonbones.factorys.BaseFactory;
	 * var factory:BaseFactory = new BaseFactory(); 
	 * </listing>
	 */
	public function new()
	{
		super();
		_skeletonDataDic = new Map<String,SkeletonData>();
		_textureAtlasDic = new Map<String,NMETextureAtlas>();
		//_textureAtlasLoadingDic = {};			
		//_loaderContext.allowCodeImport = true;
	}
	
	/**
	 * Parses the raw data and returns a SkeletonData instance.	
	 * @example 
	 * <listing>
	 * import flash.events.Event; 
	 * import ilmare.dragonbones.factorys.BaseFactory;
	 * 
	 * [Embed(source = "../assets/Dragon1.swf", mimeType = "application/octet-stream")]  
	 *	private static const ResourcesData:Class;
	 * var factory:BaseFactory = new BaseFactory(); 
	 * factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	 * factory.parseData(new ResourcesData());
	 * </listing>
	 * @param	ByteArray. Represents the raw data for the whole skeleton system.
	 * @param	String. (optional) The SkeletonData instance name.
	 * @return A SkeletonData instance.
	 */
	public function parseData(skeletonXmlPath: String, textureXmlPath: String, textureImgPath: String):SkeletonData
	{
		var xmlString: String = Assets.getText(skeletonXmlPath);
		var xml: Xml = Xml.parse(xmlString);					
		var skeletonData: SkeletonData = XMLDataParser.parseSkeletonData(xml.firstElement());
		var atlas: NMETextureAtlas = new NMETextureAtlas(textureImgPath, textureXmlPath);
		_textureAtlasDic.set(atlas.name, atlas);
		_currentTextureAtlas = atlas;
		_currentTextureAtlasName = atlas.name;
		
		_skeletonDataDic.set(skeletonData.name, skeletonData);		
		_currentSkeletonData = skeletonData;
		_currentSkeletonName = skeletonData.name;
		
		/*
		
		var decompressedData:DecompressedData = XMLDataParser.decompressData(bytes);			
		var skeletonData:SkeletonData = XMLDataParser.parseSkeletonData(decompressedData.skeletonXML);
		skeletonName = skeletonName || skeletonData.name;
		addSkeletonData(skeletonData, skeletonName);			
		var loader:Loader = new Loader();
		loader.name = skeletonName;
		_textureAtlasLoadingDic[skeletonName] = decompressedData.textureAtlasXML;
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
		loader.loadBytes(decompressedData.textureBytes, _loaderContext);			
		decompressedData.dispose();*/
		return skeletonData;
	}
	
	/**
	 * Returns a SkeletonData instance.
	 * @example 
	 * <listing>
	 * var skeleton:SkeletonData = factory.getSkeletonData('dragon');
	 * </listing>
	 * @param	The name of an existing SkeletonData instance.
	 * @return A SkeletonData instance with given name (if exist).
	 */
	public function getSkeletonData(name:String):SkeletonData
	{
		return _skeletonDataDic.get(name);
	}
	
	/**
	 * Add a SkeletonData instance to this BaseFactory instance.
	 * @example 
	 * <listing>
	 * factory.addSkeletonData(skeletondata, 'dragon');
	 * </listing>
	 * @param	A skeletonData instance.
	 * @param	(optional) A name for this SkeletonData instance.
	 */
	public function addSkeletonData(skeletonData:SkeletonData, name:String = null):Void
	{		
		if (name == null)
			name = skeletonData.name;		
		if(name == null)
		{
			throw new ArgumentError("Unnamed data!");
		}
		if(skeletonData != null)
		{
			_skeletonDataDic.set(name, skeletonData);
		}
	}
	
	/**
	 * Remove a SkeletonData instance from this BaseFactory instance.
	 * @example 
	 * <listing>
	 * factory.removeSkeletonData('dragon');
	 * </listing>
	 * @param	The name for the SkeletonData instance to remove.
	 */
	public function removeSkeletonData(name:String):Void
	{
		_skeletonDataDic.remove(name);
	}
	
	/**
	 * Return the TextureAtlas by that name.
	 * @example 
	 * <listing>
	 * var atlas:Object = factory.getTextureAtlas('dragon');
	 * </listing>
	 * @param	The name of the TextureAtlas to return.
	 * @return A textureAtlas.
	 */
	public function getTextureAtlas(name:String):NMETextureAtlas
	{
		return _textureAtlasDic.get(name);
	}
	
	/**
	 * Add a textureAtlas to this BaseFactory instance.
	 * @example 
	 * <listing>
	 * factory.addTextureAtlas(textureatlas, 'dragon');
	 * </listing>
	 * @param	A textureAtlas to add to this BaseFactory instance.
	 * @param	(optional) A name for this TextureAtlas.
	 */
	public function addTextureAtlas(textureAtlas:NMETextureAtlas, name:String = null):Void
	{
		
		if(name == null)
		{
			name = textureAtlas.name;
		}
		
		if(name == null)
		{
			throw new ArgumentError("Unnamed data!");
		}
		if(textureAtlas != null)
		{
			_textureAtlasDic.set(name, textureAtlas);
		}
	}
	
	/**
	 * Remove a textureAtlas from this baseFactory instance.
	 * @example 
	 * <listing>
	 * factory.removeTextureAtlas('dragon');
	 * </listing>
	 * @param	The name of the TextureAtlas to remove.
	 */
	public function removeTextureAtlas(name:String):Void
	{
		_textureAtlasDic.remove(name);
	}
	

	
	 /**
	  * Cleans up resources used by this BaseFactory instance.
	 * @example 
	 * <listing>
	 * factory.dispose();
	 * </listing>
	  * @param	(optional) Destroy all internal references.
	  */
	public function dispose(disposeData:Bool = true):Void
	{
		if(disposeData)
		{
			for (skeletonData in _skeletonDataDic)
			{
				skeletonData.dispose();
			}
			for (textureAtlas in _textureAtlasDic)
			{
				textureAtlas.dispose();
			}
		}
		_skeletonDataDic = new Map<String,SkeletonData>();
		_textureAtlasDic = new Map<String,NMETextureAtlas>();
		//_textureAtlasLoadingDic = {} ;			
		_currentSkeletonData = null;
		_currentTextureAtlas = null;
		_currentSkeletonName = null;
		_currentTextureAtlasName = null;
	}
	
	 /**
	  * Build and returns a new Armature instance.
	 * @example 
	 * <listing>
	 * var armature:Armature = factory.buildArmature('dragon');
	 * </listing>
	  * @param	The name of this Armature instance.
	  * @param	The name of this animation.
	  * @param	The name of this skeleton.
	  * @param	The name of this textureAtlas.
	  * @return A Armature instance.
	  */
	public function buildArmature(armatureName:String, animationName:String = null, skeletonName:String = null, textureAtlasName:String = null):Armature
	{
		if (animationName == null)
			animationName = armatureName;
		var skeletonData:SkeletonData = null;
		var armatureData:ArmatureData = null;
		if(skeletonName != null)
		{
			skeletonData = _skeletonDataDic.get(skeletonName);
			if(skeletonData != null)
			{
				armatureData = skeletonData.getArmatureData(armatureName);
			}
		}
		else
		{
			for (skeletonNameIt in _skeletonDataDic.keys())
			{
				skeletonName = skeletonNameIt;
				skeletonData = _skeletonDataDic.get(skeletonName);
				armatureData = skeletonData.getArmatureData(armatureName);
				if(armatureData != null)
				{					
					break;
				}
			}
		}
		if(armatureData == null)
		{
			return null;
		}
		_currentSkeletonName = skeletonName;
		_currentSkeletonData = skeletonData;
		if (textureAtlasName == null)
			_currentTextureAtlasName = skeletonName;
		else
			_currentTextureAtlasName = textureAtlasName;		
		_currentTextureAtlas = _textureAtlasDic.get(_currentTextureAtlasName);
		var animationData:AnimationData = _currentSkeletonData.getAnimationData(animationName);			
		if(animationData == null)
		{
			for (skeletonName in _skeletonDataDic.keys())
			{
				skeletonData = _skeletonDataDic.get(skeletonName);
				animationData = skeletonData.getAnimationData(animationName);
				if(animationData != null)
				{
					break;
				}
			}
		}			
		var armature:Armature = generateArmature();
		armature.name = armatureName;
		armature.animation.animationData = animationData;
		var boneNames:Array<String> = armatureData.boneNames;		
		for (boneName in boneNames)
		{
			//trace("boneName:" + boneName);
			var boneData:BoneData = armatureData.getBoneData(boneName);
			if(boneData != null)
			{
				var bone:Bone = buildBone(boneData);
				bone.name = boneName;
				armature.addBone(bone, boneData.parent);
			}
		}
		armature._bonesIndexChanged = true;
		armature.update();
		return armature;
	}
	
	/**
	 * Return the TextureDisplay.
	 * @example 
	 * <listing>
	 * var texturedisplay:Object = factory.getTextureDisplay('dragon');
	 * </listing>
	 * @param	The name of this Texture.
	 * @param	The name of the TextureAtlas.
	 * @param	The registration pivotX position.
	 * @param	The registration pivotY position.
	 * @return An Object.
	 */
	public function getTextureDisplay(textureName:String, textureAtlasName:String = null, pivotX:Float = 0, pivotY:Float = 0):DisplayObject
	{
		var textureAtlas:NMETextureAtlas;
		if(textureAtlasName != null)
		{
			textureAtlas = _textureAtlasDic.get(textureAtlasName);
		}
		else
		{
			for (textureAtlasName in _textureAtlasDic.keys())
			{
				textureAtlas = _textureAtlasDic.get(textureAtlasName);
/*			for (textureAtlasIt in _textureAtlasDic)
			{
				textureAtlas = textureAtlasIt;*/
				if(textureAtlas.getRegion(textureName) != null)
				{
					break;
				}
				textureAtlas = null;
			}
		}
		if(textureAtlas != null)
		{
			if(Math.isNaN(pivotX) || Math.isNaN(pivotY))
			{
				var skeletonData:SkeletonData = _skeletonDataDic.get(textureAtlasName);
				if(skeletonData != null)
				{
					var displayData:DisplayData = skeletonData.getDisplayData(textureName);
					if(displayData != null)
					{
						pivotX = pivotX == Math.NaN ? displayData.pivotX : pivotX;
						pivotY = pivotY == Math.NaN ? displayData.pivotY : pivotY;
					}
				}
			}
			
			return generateTextureDisplay(textureAtlas, textureName, pivotX, pivotY);
		}
		return null;
	}
	/** @private */
	private function buildBone(boneData:BoneData):Bone
	{
		var bone:Bone = generateBone();
		bone.origin.copy(boneData.node);
		
		var displayData:DisplayData;
		var len: Int = boneData._displayNames.length-1;
		for (i in -len...1) // iteracion reversa http://haxe.org/doc/snip/countdownintiter
		//for(var i:int = boneData._displayNames.length - 1;i >= 0;i --)
		{
			var displayName:String = boneData._displayNames[-i];
			displayData = _currentSkeletonData.getDisplayData(displayName);
			bone.changeDisplay(-i);
			if (displayData.isArmature)
			{
				var childArmature:Armature = buildArmature(displayName, null, _currentSkeletonName, _currentTextureAtlasName);
				if(childArmature != null)
				{
					childArmature.animation.play();
					//bone.display = childArmature; // this doesn't work in every platform
					bone.setDisplayArmature(childArmature);
				}
			}
			else
			{
				bone.display = generateTextureDisplay(_currentTextureAtlas, displayName, displayData.pivotX, displayData.pivotY);
			}
		}
		return bone;
	}
	/** @private */
	private function loaderCompleteHandler(e:Event):Void
	{
		/*
		e.target.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
		var loader:Loader = e.target.loader;
		var content:Object = e.target.content;
		loader.unloadAndStop();
		
		var skeletonName:String = loader.name;
		var textureAtlasXML:Xml = _textureAtlasLoadingDic.get(skeletonName);
		_textureAtlasLoadingDic.remove(skeletonName);
		if(skeletonName != null && textureAtlasXML != null)
		{
			if (Std.is(content, Bitmap))
			{
				content =  (cast content).bitmapData;
			}
			else if (content is Sprite)
			{
				content = (content as Sprite).getChildAt(0) as MovieClip;
			}
			else
			{
				//
			}
			
			var textureAtlas:Object = generateTextureAtlas(content, textureAtlasXML);
			addTextureAtlas(textureAtlas, skeletonName);
			
			skeletonName = null;
			for(skeletonName in _textureAtlasLoadingDic)
			{
				break;
			}
			//
			if(!skeletonName && hasEventListener(Event.COMPLETE))
			{
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}*/
	}
	/** @private */
	/*private function generateTextureAtlas(content:Object, textureAtlasXML:XML):Object
	{
		var textureAtlas: NMETextureAtlas = new NMETextureAtlas(content, textureAtlasXML);
		return textureAtlas;
	}*/
	/** @private */
	private function generateArmature():Armature
	{
		var display:Sprite = new Sprite();
		var armature:Armature = new Armature(display);
		return armature;
	}
	/** @private */
	private function generateBone():Bone
	{
		var bone:Bone = new Bone(new NativeDisplayBridge());
		return bone;
	}
	
	private function generateTextureDisplay(textureAtlas:NMETextureAtlas, fullName:String, pivotX:Float, pivotY:Float): DisplayObject
	{
		var spr: Sprite = new Sprite();
		
		var subTextureData: SubTextureData = textureAtlas.getRegion(fullName);
#if html5		
		// TODO: chequear si esto se arregla alguna vez...
		var child: Sprite = new Sprite();		
		textureAtlas.drawTiles(child.graphics, [ 0, 0, subTextureData.tileId ]);
		spr.addChild(child);
		child.x = -pivotX;
		child.y = -pivotY;
#else
		textureAtlas.drawTiles(spr.graphics, [ -pivotX, -pivotY, subTextureData.tileId ], true);
#end
		
		return spr;
		
		/*
		var nativeTextureAtlas:NMETextureAtlas = NMETextureAtlas;
		if (nativeTextureAtlas)
		{
			var movieClip:MovieClip = nativeTextureAtlas.movieClip;
			if (movieClip && movieClip.totalFrames >= 3)
			{
				movieClip.gotoAndStop(movieClip.totalFrames);
				movieClip.gotoAndStop(fullName);
				if (movieClip.numChildren > 0)
				{
					try
					{
						var displaySWF:Object = movieClip.getChildAt(0);
						displaySWF.x = 0;
						displaySWF.y = 0;
						return displaySWF;
					}
					catch(e:Error)
					{
						throw "Can not get the movie clip, please make sure the version of the resource compatible with app version!";
					}
				}
			}
			else if(nativeTextureAtlas.bitmapData)
			{
				var subTextureData:SubTextureData = nativeTextureAtlas.getRegion(fullName) as SubTextureData;
				if (subTextureData)
				{
					var displayShape:Shape = new Shape();
					//1.4
					pivotX = pivotX || subTextureData.pivotX;
					pivotY = pivotY || subTextureData.pivotY;
					_helpMatirx.a = 1;
					_helpMatirx.b = 0;
					_helpMatirx.c = 0;
					_helpMatirx.d = 1;
					_helpMatirx.scale(nativeTextureAtlas.scale, nativeTextureAtlas.scale);
					_helpMatirx.tx = -subTextureData.x - pivotX;
					_helpMatirx.ty = -subTextureData.y - pivotY;
					
					displayShape.graphics.beginBitmapFill(nativeTextureAtlas.bitmapData, _helpMatirx, false, true);
					displayShape.graphics.drawRect(-pivotX, -pivotY, subTextureData.width, subTextureData.height);
					return displayShape;
				}
			}
		}*/
		return null;
	}

}