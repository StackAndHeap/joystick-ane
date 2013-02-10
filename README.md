Joystick Library for Adobe AIR
==============================

Adobe AIR Native Extension

This library enables you to extend the Adobe AIR runtime with native support for working with joysticks and gamepads. Currently the library supports only Windows.

To build the extension and the sample application, simply run the build.xml Ant script.

Example usage
-------------

    var joystickManager:JoystickManager = new JoystickManager();
    joystickManager.addEventListener( JoystickEvent.CONNECTED, ext_connectedHandler );
    joystickManager.addEventListener( JoystickEvent.DISCONNECTED, ext_disconnectedHandler );
    joystickManager.addEventListener( JoystickEvent.MOVE, ext_moveHandler );
    joystickManager.addEventListener( JoystickEvent.PRESS, ext_pressHandler );
    joystickManager.addEventListener( JoystickEvent.RELEASE, ext_releaseHandler );
    
    private function ext_connectedHandler( event:JoystickEvent ):void {
      trace( "Joystick " + event.index + " connected" );
    }
    
    private function ext_disconnectedHandler( event:JoystickEvent ):void {
      trace( "Joystick " + event.index + " disconnected" );
    }
    
    private function ext_moveHandler( event:JoystickMoveEvent ):void {
      trace( "Axis " + event.axisIndex + " moved to value " + event.value + " (raw value: " + event.rawValue + ") on joystick " + event.index );
    }
    
    private function ext_pressHandler( event:JoystickButtonEvent ):void {
      trace("Button " + event.buttonIndex + " pressed on joystick " + event.index );
    }
    
    private function ext_releaseHandler( event:JoystickButtonEvent ):void {
      trace( "Button " + event.buttonIndex + " released on joystick " + event.index );
    }
