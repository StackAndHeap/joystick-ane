package com.stackandheap.ane.joystick
{

public class JoystickCapabilities
{

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickCapabilities( manufacturerID:uint, productID:uint, productName:String, numButtons:uint, numAxes:uint, minX:Number, maxX:Number, minY:Number, maxY:Number, minZ:Number, maxZ:Number )
	{
		m_manufacturerID = manufacturerID;
		m_productID = productID;
		m_productName = productName;
		m_numButtons = numButtons;
		m_numAxes = numAxes;
		m_minX = minX;
		m_maxX = maxX;
		m_minY = minY;
		m_maxY = maxY;
		m_minZ = minZ;
		m_maxZ = maxZ;
	}

	// --------------------------------------------------------------------
	//
	// Properties
	//
	// --------------------------------------------------------------------

	private var m_manufacturerID:uint;
	public function get manufacturerID():uint
	{
		return m_manufacturerID;
	}

	private var m_productID:uint;
	public function get productID():uint
	{
		return m_productID;
	}

	private var m_productName:String;
	public function get productName():String
	{
		return m_productName;
	}

	private var m_numButtons:uint;
	public function get numButtons():uint
	{
		return m_numButtons;
	}

	private var m_numAxes:uint;
	public function get numAxes():uint
	{
		return m_numAxes;
	}

	private var m_minX:Number;
	public function get minX():Number
	{
		return m_minX;
	}

	private var m_maxX:Number;
	public function get maxX():Number
	{
		return m_maxX;
	}

	private var m_minY:Number;
	public function get minY():Number
	{
		return m_minY;
	}

	private var m_maxY:Number;
	public function get maxY():Number
	{
		return m_maxY;
	}

	private var m_minZ:Number;
	public function get minZ():Number
	{
		return m_minZ;
	}

	private var m_maxZ:Number;
	public function get maxZ():Number
	{
		return m_maxZ;
	}

	public function toString():String
	{
		return "[JoystickCapabilities(" + m_productName + ", " + m_numButtons + ", " + m_numAxes + ", " + m_minX + ", " + m_maxX + ")]";
	}

}
}