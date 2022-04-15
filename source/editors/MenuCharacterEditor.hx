package editors;

import MenuCharacter.MenuCharacterJSON;

class MenuCharacterEditor extends MusicBeatState
{
	var _char:MenuCharacterJSON = {
		character: "bf",
		animations: {
			idle: {
				prefix: "idle0",
				offset: null,
				indices: null,
				fps: null,
				looped: null
			},
			hey: {
				prefix: "hey0",
				offset: null,
				indices: null,
				fps: null,
				looped: null
			},
			danceLeft: null,
			danceRight: null
		},
		settings: {
			x: 0,
			y: -20,
			flipped: true,
			scale: null
		}
	}

	public function new(?char:MenuCharacterJSON)
	{
		super();

		if (char != null)
			this._char = char;
	}

	override function create()
	{
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
