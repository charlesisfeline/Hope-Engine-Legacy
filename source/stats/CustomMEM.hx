package stats;

import openfl.events.Event;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class CustomMEM extends TextField
{
	private var memPeak:Float = 0;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0x000000)
	{
		super();

		x = inX;
		y = inY;

		selectable = false;

		defaultTextFormat = new TextFormat("VCR OSD Mono", 12, inCol);

		text = "";

		addEventListener(Event.ENTER_FRAME, onEnter);

		width = 150;
		height = 70;
	}

	private function onEnter(_)
	{
		var mem:Float = Math.round(System.totalMemory / 1024 / 1024 * 100) / 100;

		if (mem > memPeak)
			memPeak = mem;

		if (visible)
			text = "MEM: " + mem + " MB\nMEM peak: " + memPeak + " MB";
	}
}
