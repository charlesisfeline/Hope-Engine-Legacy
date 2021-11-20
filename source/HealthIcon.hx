package;

import flixel.FlxSprite;
import lime.utils.Assets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;

	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	public static var splitWhitelist:Array<String> = [];

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna be annoying
	 */
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		// implementing new way of handling icons from kade 1.6+ or smth

		this.char = char;
		this.isPlayer = isPlayer;
		isPlayer = isOldIcon = false;
		
		changeIcon(char);
		scrollFactor.set();
	}

	/**
	 * Y'know, the thing that happens 
	 * when you press 9 while playing a song?
	 */
	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	/**
	 * Change the current `HealthIcon`. Use this instead of creating new ones.
	 */
	public final function changeIcon(char:String)
	{
		var pissOffMate:Array<String> = CoolUtil.coolTextFile('assets/images/icons/_dontSplitThese.txt');


		if (splitWhitelist != pissOffMate)
			splitWhitelist = pissOffMate;
			
		if (!splitWhitelist.contains(char))
			char = char.split("-")[0];

		loadGraphic(Paths.image('icons/face'), true, 150, 150);
		
		if (Paths.image('icons/' + char) != null)
			loadGraphic(Paths.image('icons/' + char), true, 150, 150);

		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false;
		else
			antialiasing = true;

		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y + (sprTracker.height / 2) - (height / 2));
	}
}
