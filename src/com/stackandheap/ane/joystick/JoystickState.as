package com.stackandheap.ane.joystick
{

public class JoystickState
{

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickState( axes:Array, buttons:int )
	{
		_axes = axes;
		_buttons = buttons;
	}

	// --------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------

	private var _axes:Array;

	public function get axes():Array
	{
		return _axes;
	}

	private var _buttons:int;

	public function get buttons():int
	{
		return _buttons;
	}

}
}