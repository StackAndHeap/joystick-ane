package com.stackandheap.ane.joystick.event
{

public class JoystickButtonEvent extends JoystickEvent
{

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickButtonEvent( type:String, index:uint, buttonIndex:uint )
	{
		super( type, index );
		m_buttonIndex = buttonIndex;
	}

	// --------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------

	private var m_buttonIndex:uint = 0;

	public function get buttonIndex():uint
	{
		return m_buttonIndex;
	}

}

}