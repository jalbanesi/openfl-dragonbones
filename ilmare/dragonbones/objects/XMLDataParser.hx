package ilmare.dragonbones.objects;

import flash.geom.ColorTransform;
import ilmare.dragonbones.animation.Tween;
import ilmare.dragonbones.objects.AnimationData;
import ilmare.dragonbones.objects.ArmatureData;
import ilmare.dragonbones.objects.BoneData;
import ilmare.dragonbones.objects.BoneTransform;
import ilmare.dragonbones.objects.DisplayData;
import ilmare.dragonbones.objects.FrameData;
import ilmare.dragonbones.objects.MovementBoneData;
import ilmare.dragonbones.objects.MovementData;
import ilmare.dragonbones.objects.SkeletonData;
import ilmare.dragonbones.utils.ConstValues;
import ilmare.dragonbones.utils.TransformUtils;

/**
 * ...
 * @author Juan Ignacio Albanesi
 */
class XMLDataParser
{
	private static var ANGLE_TO_RADIAN:Float = Math.PI / 180;
	private static var HALF_PI:Float = Math.PI * 0.5;	
	
	private static var _currentSkeletonData: SkeletonData;
	
	private static var _helpNode:BoneTransform = new BoneTransform();
	private static var _helpFrameData:FrameData = new FrameData();	
	
	public function new() 
	{
	
		
	}

	public static function parseSkeletonData(skeletonXML:Xml):SkeletonData
	{
		// checkSkeletonXMLVersion(skeletonXML); TODO
		var skeletonData:SkeletonData = new SkeletonData();
		skeletonData._name = skeletonXML.get(ConstValues.A_NAME);
		skeletonData._frameRate = Std.parseInt(skeletonXML.get(ConstValues.A_FRAME_RATE));
		_currentSkeletonData = skeletonData;
		//for (armaturesXML in skeletonXML.elementsNamed(ConstValues.ARMATURES).elementsNamed(ConstValues.ARMATURE))
		for (armaturesXML in skeletonXML.elementsNamed(ConstValues.ARMATURES))
		{	
			for (armatureXML in armaturesXML)
			{
				if (armatureXML.nodeType != Xml.Element)
					continue;
									
				var armatureName:String = armatureXML.get(ConstValues.A_NAME);
				//trace(armatureName);
			
				var armatureData:ArmatureData = skeletonData.getArmatureData(armatureName);
				if (armatureData != null)
				{
					parseArmatureData(armatureXML, armatureData);
				}
				else
				{
					armatureData = new ArmatureData();
					parseArmatureData(armatureXML, armatureData);			
					skeletonData._armatureDataList.addData(armatureData, armatureName);
				}
			}
			
			
		}
		for (animationsXML in skeletonXML.elementsNamed(ConstValues.ANIMATIONS))
		{
			for (animationXML in animationsXML)
			{
				if (animationXML.nodeType != Xml.Element)
					continue;				
				var animationName:String = animationXML.get(ConstValues.A_NAME);
				var armatureData:ArmatureData = skeletonData.getArmatureData(animationName);
				var animationData:AnimationData = skeletonData.getAnimationData(animationName);
				if (animationData != null)
				{
					parseAnimationData(animationXML, animationData, armatureData);
				}
				else
				{
					animationData = new AnimationData();
					parseAnimationData(animationXML, animationData, armatureData);
					skeletonData._animationDataList.addData(animationData, animationName);
				}			
			}			
		}
		_currentSkeletonData = null;
		return skeletonData;
	}	
	
	private static function parseArmatureData(armatureXML:Xml, armatureData:ArmatureData):Void
	{
		var parents: Map<String,Xml> = new Map<String,Xml>();		
		for (boneXML in armatureXML.elements())
		{
			var boneName:String = boneXML.get(ConstValues.A_NAME);
			parents.set(boneName, boneXML);
		}
		
		for (boneXML in armatureXML.elements())
		{
			var boneName:String = boneXML.get(ConstValues.A_NAME);
			var parentName:String = boneXML.get(ConstValues.A_PARENT);
			//var parentXML:Xml = getElementsByAttribute(armatureXML.elementsNamed(ConstValues.BONE), ConstValues.A_NAME, parentName).firstElement();			
			var parentXML:Xml = parentName == null ? null : parents.get(parentName);
			//trace("-----------------------------------------------------");
			var boneData:BoneData = armatureData.getBoneData(boneName);
			//trace(parentXML);
			
			if (boneData != null)
			{
				parseBoneData(boneXML, parentXML, boneData);
			}
			else
			{
				boneData = new BoneData();
				parseBoneData(boneXML, parentXML, boneData);						
				armatureData._boneDataList.addData(boneData, boneName);		
			}
			
		}
		
		armatureData.updateBoneList();	
	}

	private static function parseBoneData(boneXML:Xml, parentXML:Xml, boneData:BoneData):Void
	{
		parseNode(boneXML, boneData.node);		

		if (parentXML != null)
		{
			boneData._parent = parentXML.get(ConstValues.A_NAME);
			parseNode(parentXML, _helpNode);			
			TransformUtils.transformPointWithParent(boneData.node, _helpNode);
		}
		else
		{
			boneData._parent = null;
		}
		
		if (_currentSkeletonData != null)
		{
			for (displayXML in boneXML.elementsNamed(ConstValues.DISPLAY))
			{
				var displayName:String = displayXML.get(ConstValues.A_NAME);

				boneData._displayNames.push(displayName);
				var displayData:DisplayData = _currentSkeletonData.getDisplayData(displayName);
				if (displayData != null)
				{
					parseDisplayData(displayXML, displayData);
				}
				else
				{
					displayData = new DisplayData();
					parseDisplayData(displayXML, displayData);
					_currentSkeletonData._displayDataList.addData(displayData, displayName);
				}				
			}
		}
/*		var names: String = "";
		for (name in boneData._displayNames)
			names += name + "-";
		trace("parseBoneData -> " + names + " parent: " + boneData.parent);*/
	}	
	
	private static function parseNode(xml:Xml, node:BoneTransform):Void
	{
		node.x = getNumber(xml, ConstValues.A_X, 0);
		node.y = getNumber(xml, ConstValues.A_Y, 0);
		node.skewX = getNumber(xml, ConstValues.A_SKEW_X, 0) * ANGLE_TO_RADIAN;
		node.skewY = getNumber(xml, ConstValues.A_SKEW_Y, 0) * ANGLE_TO_RADIAN;
		node.scaleX = getNumber(xml, ConstValues.A_SCALE_X, 1);
		node.scaleY = getNumber(xml, ConstValues.A_SCALE_Y, 1);
		node.pivotX = getNumber(xml, ConstValues.A_PIVOT_X, 0);
		node.pivotY = getNumber(xml, ConstValues.A_PIVOT_Y, 0);
		node.z = Std.int(getNumber(xml, ConstValues.A_Z, 0));
	}	
	
	private static function parseDisplayData(displayXML:Xml, displayData:DisplayData):Void
	{		
		displayData._isArmature = getBoolean(displayXML, ConstValues.A_IS_ARMATURE, false);		
		displayData.pivotX = getNumber(displayXML, ConstValues.A_PIVOT_X, 0);
		displayData.pivotY = getNumber(displayXML, ConstValues.A_PIVOT_Y, 0);
	}	
	
	private static function parseAnimationData(animationXML:Xml, animationData:AnimationData, armatureData:ArmatureData):Void
	{
		for (movementXML in animationXML.elementsNamed(ConstValues.MOVEMENT))
		{
			var movementName:String = movementXML.get(ConstValues.A_NAME);
			var movementData:MovementData = animationData.getMovementData(movementName);
			if (movementData != null)
			{
				parseMovementData(movementXML, armatureData, movementData);
			}
			else
			{
				movementData = new MovementData();
				parseMovementData(movementXML, armatureData, movementData);
				animationData._movementDataList.addData(movementData, movementName);
			}
		}
	}	

	private static function parseMovementData(movementXML:Xml, armatureData:ArmatureData, movementData:MovementData):Void
	{
		if (_currentSkeletonData != null)
		{
			var frameRate:Int = _currentSkeletonData._frameRate;
			var duration:Int = Std.int(getNumber(movementXML, ConstValues.A_DURATION, 1));
			movementData.duration = (duration > 1) ? (duration / frameRate) : 0;
			movementData.durationTo = getNumber(movementXML, ConstValues.A_DURATION_TO, 1) / frameRate;			
			movementData.durationTween = getNumber(movementXML, ConstValues.A_DURATION_TWEEN, 1) / frameRate;
			movementData.loop = getBoolean(movementXML, ConstValues.A_LOOP, false);
			movementData.tweenEasing = getNumber(movementXML, ConstValues.A_TWEEN_EASING, Math.NaN);
			//var tweenEasing: String = movementXML.exists(ConstValues.A_TWEEN_EASING) ? movementXML.get(ConstValues.A_TWEEN_EASING) : "NaN";
			//movementData.tweenEasing = tweenEasing == "NaN" ? Math.NaN : Std.parseFloat(tweenEasing);			
		}
		var boneNames:Array<String> = armatureData.boneNames;
		//var movementBoneXMLList:XMLList = movementXML.elements(ConstValues.BONE);
		for (movementBoneXML in movementXML.elementsNamed(ConstValues.BONE))
		{
			var boneName:String = movementBoneXML.get(ConstValues.A_NAME);
			var boneData:BoneData = armatureData.getBoneData(boneName);
			var parentMovementBoneXML:Xml = null; //BUG? getElementsByAttribute(movementXML.elementsNamed(ConstValues.BONE), ConstValues.A_NAME, boneData.parent).firstElement();
			var movementBoneData:MovementBoneData = movementData.getMovementBoneData(boneName);
			if (movementBoneXML != null)
			{
				if (movementBoneData != null)
				{
					parseMovementBoneData(movementBoneXML, parentMovementBoneXML, boneData, movementBoneData);
				}
				else
				{
					movementBoneData = new MovementBoneData();
					parseMovementBoneData(movementBoneXML, parentMovementBoneXML, boneData, movementBoneData);
					movementData._movementBoneDataList.addData(movementBoneData, boneName);
				}
			}
			boneNames.remove(boneName);
		}
		
		for (boneName in boneNames)
		{
			movementData._movementBoneDataList.addData(MovementBoneData.HIDE_DATA, boneName);
		}
		
		var movementFrameXMLList:Array<Xml> = new Array<Xml>();
		var length:Int = 0;
		for (frame in movementXML.elementsNamed(ConstValues.FRAME))
		{
			movementFrameXMLList.push(frame);
			length++;
		}		
		var movementFrameList:Array<MovementFrameData> = movementData._movementFrameList;
		for (i in 0...length)
		{
			var movementFrameXML: Xml = movementFrameXMLList[i];
			var movementFrameData:MovementFrameData = movementFrameList.length > i ? movementFrameList[i] : null;
			if (movementFrameData != null)
			{
				parseMovementFrameData(movementFrameXML, movementFrameData);
			}
			else
			{
				movementFrameData = new MovementFrameData();
				parseMovementFrameData(movementFrameXML, movementFrameData);
				if (Lambda.indexOf(movementFrameList, movementFrameData) < 0)
				{
					movementFrameList.push(movementFrameData);
				}
			}
		}
	}	

	private static function parseMovementBoneData(movementBoneXML:Xml, parentMovementBoneXML:Xml, boneData:BoneData, movementBoneData:MovementBoneData):Void
	{
		movementBoneData.setValues(
			getNumber(movementBoneXML, ConstValues.A_MOVEMENT_SCALE, 1),
			getNumber(movementBoneXML, ConstValues.A_MOVEMENT_DELAY, 0)
		);
		
		var i:Int = 0;
		var parentTotalDuration:Float = 0;
		var totalDuration:Float = 0;
		var currentDuration:Float = 0;
		
		var parentFrameXMLList: Array<Xml> = null;
		var parentFrameCount:Int = 0;
		var parentFrameXML:Xml = null;
		
		if (parentMovementBoneXML != null)
		{
			parentFrameXMLList = new Array<Xml>();
			for (parentFrame in parentMovementBoneXML.elementsNamed(ConstValues.FRAME))
			{
				parentFrameXMLList.push(parentFrame);
				parentFrameCount++;			
			}
		}
		
		var frameXMLList:Array<Xml> = new Array<Xml>();
		var frameCount:Int = 0;
		for (frame in movementBoneXML.elementsNamed(ConstValues.FRAME))
		{
			frameXMLList.push(frame);
			frameCount++;
		}
		var frameList:Array<FrameData> = movementBoneData._frameList;
		
		for (j in 0...frameCount)
		{
			var frameXML:Xml = frameXMLList[j];
			var frameData:FrameData = frameList.length > j ? frameList[j] : null;
			
			if (frameData != null)
			{
				parseFrameData(frameXML, frameData);
			}
			else
			{
				frameData = new FrameData();
				parseFrameData(frameXML, frameData);
				if (Lambda.indexOf(frameList, frameData) < 0)
				{
					frameList.push(frameData);
				}
			}
			if (parentMovementBoneXML != null)
			{
				while (i < parentFrameCount && (parentFrameXML != null ? (totalDuration < parentTotalDuration || totalDuration >= parentTotalDuration + currentDuration) : true))
				{
					parentFrameXML = parentFrameXMLList[i];
					parentTotalDuration += currentDuration;
					currentDuration = Std.parseInt(parentFrameXML.get(ConstValues.A_DURATION));
					i++;
				}
				parseFrameData(parentFrameXML, _helpFrameData);
				var tweenFrameXML:Xml = parentFrameXMLList[i];
				var progress:Float;
				if (tweenFrameXML != null)
				{
					progress = (totalDuration - parentTotalDuration) / currentDuration;
				}
				else
				{
					tweenFrameXML = parentFrameXML;
					progress = 0;
				}
				if (Math.isNaN(_helpFrameData.tweenEasing))
				{
					progress = 0;
				}
				else
				{
					progress = Tween.getEaseValue(progress, _helpFrameData.tweenEasing);
				}
				parseNode(tweenFrameXML, _helpNode);
				TransformUtils.setOffSetNode(_helpFrameData.node, _helpNode, _helpNode, _helpFrameData.tweenRotate);
				
				_helpNode.setValues(
					_helpFrameData.node.x + progress * _helpNode.x,
					_helpFrameData.node.y + progress * _helpNode.y,
					_helpFrameData.node.skewX + progress * _helpNode.skewX,
					_helpFrameData.node.skewY + progress * _helpNode.skewY,
					_helpFrameData.node.scaleX + progress * _helpNode.scaleX,
					_helpFrameData.node.scaleY + progress * _helpNode.scaleY,
					_helpFrameData.node.pivotX + progress * _helpNode.pivotX,
					_helpFrameData.node.pivotY + progress * _helpNode.pivotY
				);
				
				TransformUtils.transformPointWithParent(frameData.node, _helpNode);
			}
			totalDuration += getNumber(frameXML, ConstValues.A_DURATION, 1);
			frameData.node.x -= boneData.node.x;
			frameData.node.y -= boneData.node.y;
			frameData.node.skewX -= boneData.node.skewX;
			frameData.node.skewY -= boneData.node.skewY;
			frameData.node.scaleX -= boneData.node.scaleX;
			frameData.node.scaleY -= boneData.node.scaleY;
			frameData.node.pivotX -= boneData.node.pivotX;
			frameData.node.pivotY -= boneData.node.pivotY;
			frameData.node.z -= boneData.node.z;
			
			
		}//*/
	}	
	
	static function parseFrameData(frameXML:Xml, frameData:FrameData):Void
	{
		parseNode(frameXML, frameData.node);
		
		if (_currentSkeletonData != null)
		{
			var colorTransformXML:Iterator<Xml> = frameXML.elementsNamed(ConstValues.COLOR_TRANSFORM);
			if (colorTransformXML.hasNext())
			{
				parseColorTransform(colorTransformXML.next(), frameData.colorTransform);
			}
			frameData.duration = getNumber(frameXML, ConstValues.A_DURATION, 1) / _currentSkeletonData._frameRate;
			frameData.tweenEasing = getNumber(frameXML, ConstValues.A_TWEEN_EASING, 0);
			frameData.tweenRotate = Std.int(getNumber(frameXML, ConstValues.A_TWEEN_ROTATE, 0));
			frameData.displayIndex = Std.int(getNumber(frameXML, ConstValues.A_DISPLAY_INDEX, 0));
			frameData.movement = frameXML.get(ConstValues.A_MOVEMENT);
			frameData.event = frameXML.get(ConstValues.A_EVENT);
			frameData.sound = frameXML.get(ConstValues.A_SOUND);
			frameData.soundEffect = frameXML.get(ConstValues.A_SOUND_EFFECT);			
			frameData.visible = getBoolean(frameXML, ConstValues.A_VISIBLE, true);
		}
	}
	
	private static function parseColorTransform(xml:Xml, colorTransform:ColorTransform):Void
	{
		colorTransform.alphaOffset = getNumber(xml, ConstValues.A_ALPHA, 0);
		colorTransform.alphaMultiplier = getNumber(xml, ConstValues.A_ALPHA_MULTIPLIER, 1) * 0.01;
#if tuvieja-flash		
		// TODO: El color transform se veia invertido... bizarro, revisar bien que pasa y testearlo en las otras plataformas
		colorTransform.redOffset = 255 - getNumber(xml, ConstValues.A_RED, 0);
		colorTransform.greenOffset = 255 - getNumber(xml, ConstValues.A_GREEN, 0);
		colorTransform.blueOffset = 255 - getNumber(xml, ConstValues.A_BLUE, 0);
		
		colorTransform.redMultiplier = 1 - getNumber(xml, ConstValues.A_RED_MULTIPLIER, 1) * 0.01;
		colorTransform.greenMultiplier = 1 - getNumber(xml, ConstValues.A_GREEN_MULTIPLIER, 1) * 0.01;
		colorTransform.blueMultiplier = 1 - getNumber(xml, ConstValues.A_BLUE_MULTIPLIER, 1) * 0.01;
#else
		colorTransform.redOffset = getNumber(xml, ConstValues.A_RED, 0);
		colorTransform.greenOffset = getNumber(xml, ConstValues.A_GREEN, 0);
		colorTransform.blueOffset = getNumber(xml, ConstValues.A_BLUE, 0);
		
		colorTransform.redMultiplier = getNumber(xml, ConstValues.A_RED_MULTIPLIER, 1) * 0.01;
		colorTransform.greenMultiplier = getNumber(xml, ConstValues.A_GREEN_MULTIPLIER, 1) * 0.01;
		colorTransform.blueMultiplier = getNumber(xml, ConstValues.A_BLUE_MULTIPLIER, 1) * 0.01;
#end
	}	
		
	private static function parseMovementFrameData(movementFrameXML:Xml, movementFrameData:MovementFrameData):Void
	{
		movementFrameData.setValues(
			getNumber(movementFrameXML, ConstValues.A_DURATION, 1) / _currentSkeletonData._frameRate,
			movementFrameXML.get(ConstValues.A_MOVEMENT),
			movementFrameXML.get(ConstValues.A_EVENT),
			movementFrameXML.get(ConstValues.A_SOUND)
		);
	}
	
	public static function getElementsByAttribute(xmlList:Iterator<Xml>, attribute:String, value:String):Xml
	{
		// TODO: chequear que esto funciona como debe
		var result:Xml = Xml.parse("");
		
		for (xml in xmlList)
		{
			if (xml.get(attribute) == value)
			{
				result.addChild(xml);
			}
		}
		return result;
	}	
	
	
	static function getBoolean(data:Xml, key:String, defaultValue:Bool):Bool
	{
		if (data == null)
			return defaultValue;

		if (!data.exists(key))
			return defaultValue;
			
		var str: String = data.get(key);
		if (str == null)
			return defaultValue;
		
		return switch(str)
		{
			case "0" | "NaN" | "" | "false" | "null" | "undefined": false;
			case "1" | "true": true;
			case _: true;
		}
	}
	
	static function getNumber(data:Xml, key:String, defaultValue:Float):Float
	{
		if (data == null)
			return defaultValue;
		
		var str: String = data.get(key);
		if (str == null)
			return defaultValue;
		
		return switch(str)
		{
			case "NaN" | "" | "false" | "null" | "undefined": Math.NaN;
			case _: return Std.parseFloat(str);
		}
	}	
}