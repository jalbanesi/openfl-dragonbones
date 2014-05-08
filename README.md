openfl-dragonbones
==================

Haxe/OpenFL port of DragonBones api

This is an alpha release, tested with DragonBones 2.1 Flash Plugin

Currently only supports assets exported as xml + png

Usage:

- Load armatures (if you want a local copy of the Factory use BaseFactory instead of ArmatureManager):

<code>
	ArmatureManager.instance.parseData(		
		"images/skeleton.xml", 
		"images/texture.xml",
		"images/texture.png" 
	);	
</code>

- Create armature:

<code>
  var armature: Armature = ArmatureManager.instance.buildArmature(armatureName);
</code>  

- Play animation:

<code>
  WorldClock.clock.add(armature);
  armature.animation.gotoAndPlay("run");
  
  // add to the update loop:
  WorldClock.clock.advanceTime(-1);
</code>  

- Access individual bones and child armatures:  

<code>
  var bone: Bone = armature.getBone("aBone");
  
  bone.childArmature.animation.gotoAndPlay("run");
</code>
