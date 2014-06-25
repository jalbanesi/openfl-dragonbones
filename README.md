openfl-dragonbones
==================

Haxe/OpenFL port of DragonBones api

<b>
This is a beta release, tested with DragonBones 2.1 Flash Plugin

<b>Currently only supports assets exported as xml + png

<b>Tested targets: Flash, Android, Blackberry, iOS and Windows


Install via haxelib git:
```Bash
haxelib git dragonbones https://github.com/jalbanesi/openfl-dragonbones.git
```

Then add to your application.xml:
```Xml
<haxelib name="dragonbones" />
```


Usage:

- Load armatures (if you want a local copy of the Factory use BaseFactory instead of ArmatureManager):

```Haxe
ArmatureManager.instance.parseData(		
		"images/skeleton.xml", 
		"images/texture.xml",
		"images/texture.png" 
	);	
```

- Create armature:

```Haxe
  var armature: Armature = ArmatureManager.instance.buildArmature(armatureName);
```

- Play animation:

```Haxe
  WorldClock.clock.add(armature);
  armature.animation.gotoAndPlay("run");
  
  // add to the update loop:
  WorldClock.clock.advanceTime(-1);
```  

- Access individual bones and child armatures:  

```Haxe
  var bone: Bone = armature.getBone("aBone");
  
  bone.childArmature.animation.gotoAndPlay("run");
```

- Full example:
 
```Haxe
  // 1 - Create
  var armatureName: String = "Sprites/anArmature");
  var armature: Armature = ArmatureManager.instance.buildArmature(armatureName);
  
  WorldClock.add(armature); // This is necessary to play animations
  parent.addChild(armature.display); // This is necessary to display the armature. parent is a DisplayObjectContainer, like a Sprite
  
  // 2 - Animate
  armature.animation.gotoAndPlay("jump");
  armature.addEventListener(AnimationEvent.COMPLETE, onAnimationComplete); 

  // 3 - Dispose (very important in cpp tartets to prevent memory leaks
  WorldClock.remove(armature);
  parent.removeChild(armature.display);
  armature.dispose();
```
