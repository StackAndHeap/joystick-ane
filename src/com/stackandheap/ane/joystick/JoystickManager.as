package com.stackandheap.ane.joystick
{

import com.stackandheap.ane.joystick.event.JoystickButtonEvent;
import com.stackandheap.ane.joystick.event.JoystickEvent;
import com.stackandheap.ane.joystick.event.JoystickMoveEvent;

import flash.events.EventDispatcher;
import flash.events.StatusEvent;
import flash.events.TimerEvent;
import flash.external.ExtensionContext;
import flash.utils.Timer;

public class JoystickManager extends EventDispatcher
{
	private static const CAPABILITY_MANUFACTURER_ID:uint = 0;
	private static const CAPABILITY_PRODUCT_ID:uint = 1;
	private static const CAPABILITY_PRODUCT_NAME:uint = 2;
	private static const CAPABILITY_NUM_BUTTONS:uint = 3;
	private static const CAPABILITY_NUM_AXES:uint = 4;
	private static const CAPABILITY_MIN_X:uint = 5;
	private static const CAPABILITY_MAX_X:uint = 6;
	private static const CAPABILITY_MIN_Y:uint = 7;
	private static const CAPABILITY_MAX_Y:uint = 8;
	private static const CAPABILITY_MIN_Z:uint = 9;
	private static const CAPABILITY_MAX_Z:uint = 10;

	//MMSYSERR_NODRIVER 6
	//MMSYSERR_INVALPARAM 11
	private static const JOYERR_UNPLUGGED:uint = 167;

	private static const POLL_INTERVAL_IN_MS:int = 50;

	private static var isInstantiated:Boolean = false;
	private static var context:ExtensionContext;

	private var _timer:Timer;
	private var _numSupportedJoysticks:int = -1;
	private var _previousConnectionErrors:Array;
	private var _connectedJoysticks:Array = [];
	private var _joysticks:Vector.<Joystick> = new Vector.<Joystick>();

	// --------------------------------------------------------------------
	//
	// Constructor
	//
	// --------------------------------------------------------------------

	public function JoystickManager()
	{
		super();

		if (isInstantiated)
			return;

		try
		{
			context = ExtensionContext.createExtensionContext( "com.stackandheap.ane.joystick.JoystickManager", "" );
			context.addEventListener( StatusEvent.STATUS, context_statusHandler );

			checkConnectionStatus();

			_timer = new Timer( POLL_INTERVAL_IN_MS );
			_timer.addEventListener( TimerEvent.TIMER, timerHandler );
			_timer.start();

			isInstantiated = true;
		}
		catch (e:Error)
		{
			trace( "Error creating extensions context: " + e.message );
		}
	}

	// --------------------------------------------------------------------
	//
	// Public Methods
	//
	// --------------------------------------------------------------------

	public function getJoystickState( index:uint ):JoystickState
	{
		var state:Array = context.call( "getJoystickState", index ) as Array;
		return new JoystickState( [state[0], state[1], state[2]], state[3] );
	}

	public function get numSupportedJoysticks():uint
	{
		if (_numSupportedJoysticks == -1)
		{
			_numSupportedJoysticks = parseInt( String( context.call( "getNumSupportedJoysticks" ) ) );
		}
		return _numSupportedJoysticks;
	}

	public function get connectedJoysticks():Array
	{
		return _connectedJoysticks;
	}

	public function getJoystickCapabilities( index:uint ):JoystickCapabilities
	{
		var caps:Array = context.call( "getJoystickCapabilities", index ) as Array;
		return new JoystickCapabilities(
				caps[CAPABILITY_MANUFACTURER_ID],
				caps[CAPABILITY_PRODUCT_ID],
				caps[CAPABILITY_PRODUCT_NAME],
				caps[CAPABILITY_NUM_BUTTONS],
				caps[CAPABILITY_NUM_AXES],
				caps[CAPABILITY_MIN_X],
				caps[CAPABILITY_MAX_X],
				caps[CAPABILITY_MIN_Y],
				caps[CAPABILITY_MAX_Y],
				caps[CAPABILITY_MIN_Z],
				caps[CAPABILITY_MAX_Z]
		);
	}

	// --------------------------------------------------------------------
	//
	// Private Methods
	//
	// --------------------------------------------------------------------

	private function context_statusHandler( event:StatusEvent ):void
	{
		trace( event.level + " " + event.code );
	}

	private function timerHandler( event:TimerEvent ):void
	{
		checkConnectionStatus();
		queryJoysticks();
	}

	private function queryJoysticks():void
	{
		for (var i:uint = 0; i < _connectedJoysticks.length; i++)
		{
			queryJoystick( _connectedJoysticks[i] );
		}
	}

	private function checkConnectionStatus():void
	{
		var connectionErrors:Array = context.call( "getConnectedJoysticks" ) as Array;

		if (_previousConnectionErrors)
		{
			for (var i:uint = 0; i < numSupportedJoysticks; i++)
			{
				var previousError:uint = _previousConnectionErrors[i];
				var error:uint = connectionErrors[i];
				if (previousError != error)
				{
					if (error == 0)
					{
						handleJoystickConnected( i );
						dispatchEvent( new JoystickEvent( JoystickEvent.CONNECTED, i ) );
					} else if (error == JOYERR_UNPLUGGED)
					{
						if (_connectedJoysticks.indexOf( i ) > -1)
						{
							_connectedJoysticks.splice( _connectedJoysticks.indexOf( i ), 1 );
						}
						dispatchEvent( new JoystickEvent( JoystickEvent.DISCONNECTED, i ) );
					}
				}
			}
		}
		else
		{
			checkInitialConnectionStatus( connectionErrors );
		}

		_previousConnectionErrors = connectionErrors;
	}

	private function checkInitialConnectionStatus( connectionErrors:Array ):void
	{
		for (var i:uint = 0; i < numSupportedJoysticks; i++)
		{
			var error:uint = connectionErrors[i];

			if (error == 0)
			{
				handleJoystickConnected( i );
			}
		}
	}

	private function handleJoystickConnected( index:uint ):void
	{
		if (_connectedJoysticks.indexOf( index ) == -1)
		{
			_connectedJoysticks.push( index );
		}

		var joystick:Joystick = new Joystick();
		joystick.caps = getJoystickCapabilities( index );
		joystick.previousAxes = new Array( 3 );
		joystick.previousButtons = 0;
		joystick.rangeX = (joystick.caps.maxX - joystick.caps.minX);
		joystick.rangeY = (joystick.caps.maxY - joystick.caps.minY);
		joystick.rangeZ = (joystick.caps.maxZ - joystick.caps.minZ);

		_joysticks[index] = joystick;
	}

	private function queryJoystick( index:uint ):void
	{
		var state:JoystickState = getJoystickState( index );
		checkButtonState( index, state );
		checkAxesState( index, state );
	}

	private function checkButtonState( index:uint, state:JoystickState ):void
	{
		var joystick:Joystick = _joysticks[index];
		var diff:Number = joystick.previousButtons;
		diff ^= state.buttons;

		if (diff > 0)
		{
			var numButtons:uint = joystick.caps.numButtons;
			for (var i:uint = 0; i < numButtons; i++)
			{
				var flag:uint = Math.pow( 2, i );
				if (diff & flag)
				{
					if (state.buttons & flag)
					{
						dispatchEvent( new JoystickButtonEvent( JoystickEvent.PRESS, index, i ) );
					} else
					{
						dispatchEvent( new JoystickButtonEvent( JoystickEvent.RELEASE, index, i ) );
					}
				}
			}
			joystick.previousButtons = state.buttons;
		}
	}

	private function checkAxesState( index:uint, state:JoystickState ):void
	{
		var joystick:Joystick = _joysticks[index];
		var rawX:Number = state.axes[0];
		var rawY:Number = state.axes[1];
		var rawZ:Number = state.axes[2];

		if (rawX != joystick.previousAxes[0])
		{
			var normalizedX:int = (Math.floor( (rawX / joystick.rangeX) * 200 )) - 100;
			dispatchEvent( new JoystickMoveEvent( index, 0, normalizedX, rawX ) );
		}

		if (rawY != joystick.previousAxes[1])
		{
			var normalizedY:int = (Math.floor( (rawY / joystick.rangeY) * 200 )) - 100;
			dispatchEvent( new JoystickMoveEvent( index, 1, normalizedY, rawY ) );
		}

		if (rawZ != joystick.previousAxes[2])
		{
			var normalizedZ:int = (Math.floor( (rawZ / joystick.rangeZ) * 200 )) - 100;
			dispatchEvent( new JoystickMoveEvent( index, 2, normalizedZ, rawZ ) );
		}

		joystick.previousAxes = state.axes;
	}

}
}

import com.stackandheap.ane.joystick.JoystickCapabilities;

class Joystick
{
	public var caps:JoystickCapabilities;
	public var previousButtons:Number;
	public var previousAxes:Array;
	public var rangeX:Number;
	public var rangeY:Number;
	public var rangeZ:Number;

	public function Joystick()
	{
	}
}