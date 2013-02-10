#include<stdio.h>
#include<Windows.h>

#include "FlashRuntimeExtensions.h"

FREContext _freContext;

__declspec(dllexport) void JoystickManagerInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer);
__declspec(dllexport) void JoystickManagerFinalizer(void* extData);

FREObject getNumSupportedJoysticks(FREContext ctx, void*functionData, uint32_t argc, FREObject argv[]) {
	FREObject result;
	UINT numDevices = joyGetNumDevs();
	FRENewObjectFromInt32(numDevices, &result);
	fprintf(stdout, "getNumSupportedJoysticks() %d\n", numDevices);
	return result;
}

FREObject getConnectedJoysticks(FREContext ctx, void*functionData, uint32_t argc, FREObject argv[]) {
	FREObject result;
	JOYINFO joyinfo;
	UINT numDevices = joyGetNumDevs();
	FREObject joystickID;
	UINT i;
	MMRESULT getPosResult;

	FRENewObject((const uint8_t*)"Array", 0, NULL, &result, NULL);

	for (i = 0; i<numDevices; i++) {
		getPosResult = joyGetPos(i, &joyinfo);
		FRENewObjectFromUint32( getPosResult, &joystickID );
		FRESetArrayElementAt( result, i, joystickID );
	}

	return result;
}

FREObject getJoystickCapabilities(FREContext ctx, void*functionData, uint32_t argc, FREObject argv[]) {
	FREObject result;
	JOYCAPS capabilities;
	FREObject name;
	FREObject numButtons;
	FREObject numAxes;
	FREObject wMid;
	FREObject wPid;
	FREObject minX;
	FREObject maxX;
	FREObject minY;
	FREObject maxY;
	FREObject minZ;
	FREObject maxZ;
	uint32_t joystickID;

    FREGetObjectAsUint32(argv[0], &joystickID);

	joyGetDevCaps(joystickID, &capabilities, sizeof(JOYCAPS));

	FRENewObject((const uint8_t*)"Array", 0, NULL, &result, NULL);
	FRESetArrayLength( result, 11 );
	
	FRENewObjectFromInt32( capabilities.wMid, &wMid );
	FRESetArrayElementAt( result, 0, wMid );

	FRENewObjectFromInt32( capabilities.wPid, &wPid );
	FRESetArrayElementAt( result, 1, wPid );

	FRENewObjectFromUTF8( strlen((const char*)capabilities.szPname), (const uint8_t*)capabilities.szPname, &name );
	FRESetArrayElementAt( result, 2, name );

	FRENewObjectFromInt32( capabilities.wNumButtons, &numButtons );
	FRESetArrayElementAt( result, 3, numButtons );

	FRENewObjectFromInt32( capabilities.wNumAxes, &numAxes );
	FRESetArrayElementAt( result, 4, numAxes );

	FRENewObjectFromInt32(capabilities.wXmin, &minX );
	FRESetArrayElementAt( result, 5, minX );

	FRENewObjectFromInt32(capabilities.wXmax, &maxX );
	FRESetArrayElementAt( result, 6, maxX );

	FRENewObjectFromInt32(capabilities.wYmin, &minY );
	FRESetArrayElementAt( result, 7, minY );

	FRENewObjectFromInt32(capabilities.wYmax, &maxY );
	FRESetArrayElementAt( result, 8, maxY );

	FRENewObjectFromInt32(capabilities.wZmin, &minZ );
	FRESetArrayElementAt( result, 9, minZ );

	FRENewObjectFromInt32(capabilities.wZmax, &maxZ );
	FRESetArrayElementAt( result, 10, maxZ );

	return result;
}

FREObject getJoystickState(FREContext ctx, void*functionData, uint32_t argc, FREObject argv[]) {
	FREObject result;
	FREObject xPos;
	FREObject yPos;
	FREObject zPos;
	FREObject rPos;
	FREObject buttons;
	JOYINFO joystickInfo;
	uint32_t joystickID;
	MMRESULT errorCode;

    FREGetObjectAsUint32(argv[0], &joystickID);
	errorCode = joyGetPos(joystickID, &joystickInfo);
	FRENewObject((const uint8_t*)"Array", 0, NULL, &result, NULL);
	FRESetArrayLength( result, 4 );

	switch(errorCode)
	{
	case JOYERR_NOERROR:
		FRENewObjectFromUint32( joystickInfo.wXpos, &xPos );
			FRESetArrayElementAt( result, 0, xPos );

			FRENewObjectFromUint32( joystickInfo.wYpos, &yPos );
			FRESetArrayElementAt( result, 1, yPos );

			FRENewObjectFromUint32( joystickInfo.wZpos, &zPos );
			FRESetArrayElementAt( result, 2, zPos );

			FRENewObjectFromUint32( joystickInfo.wButtons, &buttons );
			FRESetArrayElementAt( result, 3, buttons );

			break;
		
	case JOYERR_PARMS:
		fprintf(stderr, "Invalid parameters to joyGetPos.");
		break;

	case JOYERR_NOCANDO:
		fprintf(stderr, " Failed to capture joystick input.");
		break;

	case JOYERR_UNPLUGGED:
		fprintf(stderr, "The joystick identified by joystickId isn't plugged in.");
		break;

	case MMSYSERR_NODRIVER:
		fprintf(stderr, "No (active) joystick driver available.");
		break;
	}

	return result;
}

void contextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToSet, const FRENamedFunction** functionsToSet) {
	FRENamedFunction* func;
	_freContext = ctx;

	*numFunctionsToSet = 4;
	func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * (*numFunctionsToSet));

	func[0].name = (const uint8_t*)"getJoystickState";
	func[0].functionData = NULL;
	func[0].function = &getJoystickState;

	func[1].name = (const uint8_t*)"getNumSupportedJoysticks";
	func[1].functionData = NULL;
	func[1].function = &getNumSupportedJoysticks;

	func[2].name = (const uint8_t*)"getJoystickCapabilities";
	func[2].functionData = NULL;
	func[2].function = &getJoystickCapabilities;

	func[3].name = (const uint8_t*)"getConnectedJoysticks";
	func[3].functionData = NULL;
	func[3].function = &getConnectedJoysticks;

	*functionsToSet = func;
}

void contextFinalizer(FREContext ctx) {
	return;
}

void JoystickManagerInitializer(void** extData, FREContextInitializer* ctxInitializer, FREContextFinalizer* ctxFinalizer)
{
	*ctxInitializer = &contextInitializer;
	*ctxFinalizer = &contextFinalizer;
}

void JoystickManagerFinalizer(void* extData)
{
	FREContext nullCTX;
	nullCTX = 0;
	contextFinalizer(nullCTX);
	return;
}