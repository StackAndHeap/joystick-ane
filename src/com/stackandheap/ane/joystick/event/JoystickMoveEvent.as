package com.stackandheap.ane.joystick.event
{
public class JoystickMoveEvent extends JoystickEvent
{

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickMoveEvent( index:uint, axisIndex:uint, value:Number, rawValue:Number )
	{
		super( JoystickEvent.MOVE, index );
		_axisIndex = axisIndex;
		_value = value;
		_rawValue = rawValue;
	}

	// --------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------

	private var _axisIndex:uint;

	public function get axisIndex():uint
	{
		return _axisIndex;
	}

	private var _value:Number;

	public function get value():Number
	{
		return _value;
	}

	private var _rawValue:Number;

	public function get rawValue():Number
	{
		return _rawValue;
	}
}
}
