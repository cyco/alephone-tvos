//
//  InputManager.m
//  ControllerTest
//
//  Created by Christoph Leimbrock on 04/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import "InputManager.h"
#define BOOL_STR(arg) (arg ? "YES" : "NO")
#if defined(__cplusplus)
/*
extern "C" {
#endif
	extern  int
	SDL_SendMouseMotion(int relative, int x, int y);

#import "SDL_keyboard_c.h"
#import "SDL_keyboard.h"
#import "SDL_stdinc.h"
#import "SDL_mouse_c.h"
#import "SDL_mouse.h"
#import "SDL_events.h"
#if defined(__cplusplus)
}
 */
#endif
#import <AlephOne/AlephOne.h>
#import <SDL.h>
#import "Callbacks.h"

@interface InputManager () {
	SDL_Keycode primaryFireKey;
	SDL_Keycode secondaryFireKey;
	SDL_Keycode nextWeaponKey;
	SDL_Keycode previousWeaponKey;
	SDL_Keycode inventoryKey;
	SDL_Keycode actionKey;
	SDL_Keycode forwardKey;
	SDL_Keycode backwardKey;
	SDL_Keycode leftKey;
	SDL_Keycode rightKey;
	SDL_Keycode runKey;
	SDL_Keycode mapKey;

	SDL_Keycode lookUpKey;
	SDL_Keycode lookDownKey;
	SDL_Keycode lookLeftKey;
	SDL_Keycode lookRightKey;

	int deltaX, deltaY;
}
@property (readwrite) GCExtendedGamepad *currentController;
@end

@implementation InputManager

+ (instancetype)sharedInputManager {
	static InputManager *sharedInputManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInputManager = [[InputManager alloc] init];
	});
	return sharedInputManager;
}

- (instancetype)init {
	if((self = [super init])) {
		[self setupFieldDefinitions];

		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidConnect:) name:GCControllerDidConnectNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidDisconnect:) name:GCControllerDidDisconnectNotification object:nil];

		[[GCController controllers] enumerateObjectsUsingBlock:^(GCController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self noticeController:obj];
		}];
	}
	return self;
}


- (void)setupFieldDefinitions {
	/*
	key_definition *key = current_key_definitions;
	for (unsigned i=0; i<NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++, key++) {
		if ( key->action_flag == _left_trigger_state ){
			primaryFireKey = key->offset;
		} else if ( key->action_flag == _right_trigger_state ){
			secondaryFireKey = key->offset;
		} else if ( key->action_flag == _toggle_map ){
			mapKey = key->offset;
		} else if ( key->action_flag == _action_trigger_state ) {
			actionKey = key->offset;
		} else if ( key->action_flag == _cycle_weapons_forward ) {
			nextWeaponKey = key->offset;
		} else if ( key->action_flag == _cycle_weapons_backward ) {
			previousWeaponKey = key->offset;
		} else if ( key->action_flag == _moving_forward ) {
			forwardKey = key->offset;
		} else if ( key->action_flag == _moving_backward ) {
			backwardKey = key->offset;
		} else if ( key->action_flag == _sidestepping_left ){
			leftKey = key->offset;
		} else if ( key->action_flag == _sidestepping_right ) {
			rightKey = key->offset;
		} else if ( key->action_flag == _run_dont_walk ) {
			runKey = key->offset;
		} else if ( key->action_flag == _looking_up ) {
			lookUpKey = key->offset;
		} else if ( key->action_flag == _looking_down ) {
			lookDownKey = key->offset;
		} else if ( key->action_flag == _looking_left ) {
			lookLeftKey = key->offset;
		} else if ( key->action_flag == _looking_right ) {
			lookRightKey = key->offset;
		}
	}
	 */
}

- (void)_registerNotifications {

}

- (void)_unregisterNotifications {

}

- (void)startWatching {
	NSLog(@"startWatching");
	[GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
		NSLog(@"Did complete discovery or found something");
	}];
}

- (void)stopWatching {
	NSLog(@"stopWatching");
	[GCController stopWirelessControllerDiscovery];
}

#define mapButton(__key__, __key_identifier__) do{} while(0);
// self.currentController.__key__.valueChangedHandler = ^(GCControllerButtonInput *button, float val, bool pressed) { \
NSLog(@"button: %s (-> %d), down: %s", #__key__, __key_identifier__, BOOL_STR(pressed)); \
Uint8 *key_map = SDL_GetKeyboardState(NULL); \
key_map[__key_identifier__] = pressed ? 1 : 0; \
}
- (void)noticeController:(GCController*)controller {
	if(controller.extendedGamepad && !self.currentController) {
		MLog(@"Found new gamepad");
		self.currentController = controller.extendedGamepad;
		self.currentController.controller.playerIndex = GCControllerPlayerIndex1;

		mapButton(leftShoulder, previousWeaponKey);
		mapButton(rightShoulder, nextWeaponKey);
		mapButton(rightTrigger, primaryFireKey);
		mapButton(leftTrigger, secondaryFireKey);
		mapButton(dpad.up, forwardKey);
		mapButton(dpad.down, backwardKey);
		mapButton(dpad.left, leftKey);
		mapButton(dpad.right, rightKey);

		mapButton(buttonA, actionKey);
		mapButton(buttonB, mapKey);

		self.currentController.leftThumbstick.valueChangedHandler = ^(GCControllerDirectionPad *axis, float x, float y) {
			/*
			Uint8 *key_map = SDL_GetKeyboardState(NULL);
			key_map[runKey] = (sqrt(pow(x, 2) + pow(y, 2)) > 0.5) ? 1 : 0;
			key_map[leftKey] = (x < -0.01) ? 1 : 0;
			key_map[rightKey] = (x > 0.01) ? 1 : 0;
			key_map[backwardKey] = (y < -0.01) ? 1 : 0;
			key_map[forwardKey]  = (y > 0.01) ? 1 : 0;
			 */
		};

		self.currentController.rightThumbstick.valueChangedHandler = ^(GCControllerDirectionPad *axis, float x, float y) {
			/*
			Uint8 *key_map = SDL_GetKeyboardState(NULL);

			deltaX = x * xFactor;
			deltaY = y * yFactor;
			 */
			// SDL_SendMouseMotion(true, x, y);
		};
	}
}
static float xFactor = 8.0;
static float yFactor = 8.0;
#undef mapButton
- (void)mouseDeltaX:(int*)dx deltaY:(int*)dy {
	*dx = deltaX;
	*dy = deltaY;
}
#pragma mark -
- (void)controllerDidConnect:(NSNotification*)notification {
	GCController *controller = notification.object;
	NSLog(@"controllerDidConnect: %@", controller);
	[self noticeController:controller];
}

- (void)controllerDidDisconnect:(NSNotification*)notification {
	GCController *controller = notification.object;
	NSLog(@"controllderDidDisconnect: %@", controller);
	if(controller.extendedGamepad == self.currentController && self.currentController) {
		self.currentController = nil;
	}
}
@end
