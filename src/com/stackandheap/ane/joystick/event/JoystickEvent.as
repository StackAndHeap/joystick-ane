package com.stackandheap.ane.joystick.event
{
import flash.events.Event;

public class JoystickEvent extends Event
{
	public static const CONNECTED:String = "connected";
	public static const DISCONNECTED:String = "disconnected";
	public static const PRESS:String = "press";
	public static const RELEASE:String = "release";
	public static const MOVE:String = "move";

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickEvent( type:String, index:uint )
	{
		super( type );
		_index = index;
	}

	// --------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------

	private var _index:uint;

	public function get index():uint
	{
		return _index;
	}
}
}
