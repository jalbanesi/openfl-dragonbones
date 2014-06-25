package ilmare.dragonbones.objects;

import haxe.xml.Fast;
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
import openfl.Assets;
import flash.geom.ColorTransform;
import flash.Lib;

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
			var parentXML:Xml = parents.get(parentName);

			//trace("-----------------------------------------------------");
			//trace("boneName: " + boneName + " parentName: " + parentName);
			//trace(parentXML);
			
			var boneData:BoneData = armatureData.getBoneData(boneName);
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
		var names: String = "";
		for (name in boneData._displayNames)
			names += name + "-";
		//trace("parseBoneData -> " + names + " parent: " + boneData.parent);
	}	
	
	private static function parseNode(xml:Xml, node:BoneTransform):Void
	{
		node.x = Std.parseFloat(xml.get(ConstValues.A_X));
		node.y = Std.parseFloat(xml.get(ConstValues.A_Y));
		node.skewX = Std.parseFloat(xml.get(ConstValues.A_SKEW_X)) * ANGLE_TO_RADIAN;
		node.skewY = Std.parseFloat(xml.get(ConstValues.A_SKEW_Y)) * ANGLE_TO_RADIAN;
		node.scaleX = Std.parseFloat(xml.get(ConstValues.A_SCALE_X));
		node.scaleY = Std.parseFloat(xml.get(ConstValues.A_SCALE_Y));
		node.pivotX =  Std.parseFloat(xml.get(ConstValues.A_PIVOT_X));
		node.pivotY =  Std.parseFloat(xml.get(ConstValues.A_PIVOT_Y));
		node.z = Std.parseInt(xml.get(ConstValues.A_Z));
	}	
	
	private static function parseDisplayData(displayXML:Xml, displayData:DisplayData):Void
	{		
		if (displayXML.exists(ConstValues.A_IS_ARMATURE))		
			displayData._isArmature = (Std.parseInt(displayXML.get(ConstValues.A_IS_ARMATURE))) == 0 ? false : true;
		else
			displayData._isArmature = false; // TODO: ver si realmente esto es asi
		displayData.pivotX = Std.parseFloat(displayXML.get(ConstValues.A_PIVOT_X));
		displayData.pivotY = Std.parseFloat(displayXML.get(ConstValues.A_PIVOT_Y));
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
			var duration:Int = Std.parseInt(movementXML.get(ConstValues.A_DURATION));
			movementData.duration = (duration > 1) ? (duration / frameRate) : 0;
			movementData.durationTo = Std.parseInt(movementXML.get(ConstValues.A_DURATION_TO)) / frameRate;
			movementData.durationTween = Std.parseInt(movementXML.get(ConstValues.A_DURATION_TWEEN)) / frameRate;
			movementData.loop = movementXML.exists(ConstValues.A_LOOP) ? (Std.parseInt(movementXML.get(ConstValues.A_LOOP)) == 1 ? true : false) : false;
			var tweenEasing: String = movementXML.exists(ConstValues.A_TWEEN_EASING) ? movementXML.get(ConstValues.A_TWEEN_EASING) : "NaN";
			movementData.tweenEasing = tweenEasing == "NaN" ? Math.NaN : Std.parseFloat(tweenEasing);
		}
		var boneNames:Array<String> = armatureData.boneNames;
		
		//var movementBoneXMLList:XMLList = movementXML.elements(ConstValues.BONE);
		for (movementBoneXML in movementXML.elementsNamed(ConstValues.BONE))
		{
			var boneName:String = movementBoneXML.get(ConstValues.A_NAME);
			var boneData:BoneData = armatureData.getBoneData(boneName);
			var parentMovementBoneXML:Xml = getElementsByAttribute(movementXML.elementsNamed(ConstValues.BONE), ConstValues.A_NAME, boneData.parent).firstElement();
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
			var index:Int = Lambda.indexOf(boneNames, boneName);
			if (index >= 0)
			{
				boneNames.splice(index, 1);
			}
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
		}//*/
	}	

	private static function parseMovementBoneData(movementBoneXML:Xml, parentMovementBoneXML:Xml, boneData:BoneData, movementBoneData:MovementBoneData):Void
	{
		movementBoneData.setValues(
			Std.parseFloat(movementBoneXML.get(ConstValues.A_MOVEMENT_SCALE)),
			Std.parseFloat(movementBoneXML.get(ConstValues.A_MOVEMENT_DELAY))
		);
		
		var i:Int = 0;
		var parentTotalDuration:Int = 0;
		var totalDuration:Int = 0;
		var currentDuration:Int = 0;
		
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
			totalDuration += Std.parseInt(frameXML.get(ConstValues.A_DURATION));
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
			frameData.duration = Std.parseInt(frameXML.get(ConstValues.A_DURATION)) / _currentSkeletonData._frameRate;
			// DJJIA TODO: always getting a NaN in tweenEasing
			frameData.tweenEasing = 0;// Std.parseFloat(frameXML.get(ConstValues.A_TWEEN_EASING));
			frameData.tweenRotate = Std.parseInt(frameXML.get(ConstValues.A_TWEEN_ROTATE));
			frameData.displayIndex = Std.parseInt(frameXML.get(ConstValues.A_DISPLAY_INDEX));
			frameData.movement = frameXML.get(ConstValues.A_MOVEMENT);
			frameData.event = frameXML.get(ConstValues.A_EVENT);
			frameData.sound = frameXML.get(ConstValues.A_SOUND);
			frameData.soundEffect = frameXML.get(ConstValues.A_SOUND_EFFECT);
			var visibleStr:String = frameXML.get(ConstValues.A_VISIBLE);
			frameData.visible = visibleStr == null || visibleStr == "1" ? true : false;
		}
	}
	
	private static function parseColorTransform(xml:Xml, colorTransform:ColorTransform):Void
	{
		colorTransform.alphaOffset = Std.parseInt(xml.get(ConstValues.A_ALPHA));
		colorTransform.redOffset = Std.parseInt(xml.get(ConstValues.A_RED));
		colorTransform.greenOffset = Std.parseInt(xml.get(ConstValues.A_GREEN));
		colorTransform.blueOffset = Std.parseInt(xml.get(ConstValues.A_BLUE));
		colorTransform.alphaMultiplier = Std.parseInt(xml.get(ConstValues.A_ALPHA_MULTIPLIER)) * 0.01;
		colorTransform.redMultiplier = Std.parseInt(xml.get(ConstValues.A_RED_MULTIPLIER)) * 0.01;
		colorTransform.greenMultiplier = Std.parseInt(xml.get(ConstValues.A_GREEN_MULTIPLIER)) * 0.01;
		colorTransform.blueMultiplier = Std.parseInt(xml.get(ConstValues.A_BLUE_MULTIPLIER)) * 0.01;
	}	
		
	private static function parseMovementFrameData(movementFrameXML:Xml, movementFrameData:MovementFrameData):Void
	{
		movementFrameData.setValues(
			Std.parseFloat(movementFrameXML.get(ConstValues.A_DURATION)) / _currentSkeletonData._frameRate,
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
}