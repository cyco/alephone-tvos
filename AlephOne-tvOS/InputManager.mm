//
//  InputManager.m
//  ControllerTest
//
//  Created by Christoph Leimbrock on 04/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import "InputManager.h"
#import <AlephOne/AlephOne.h>
#import <SDL.h>

extern "C" {
	#import "SDL_mouse_c.h"
}
#import "Callbacks.h"
#define BOOL_STR(arg) (arg ? "YES" : "NO")

@interface InputManager () {
	struct {
		SDL_Keycode rightTrigger;
		SDL_Keycode leftTrigger;
		SDL_Keycode nextWeapon;
		SDL_Keycode previousWeapon;
		SDL_Keycode inventoryKey;
		SDL_Keycode forward;
		SDL_Keycode backward;
		SDL_Keycode left;
		SDL_Keycode right;
		SDL_Keycode action;
		SDL_Keycode map;
		SDL_Keycode run;
		
		SDL_Keycode lookUpKey;
		SDL_Keycode lookDownKey;
		SDL_Keycode lookLeftKey;
		SDL_Keycode lookRightKey;
	} keys;

	float deltaX, deltaY;
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
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidConnect:) name:GCControllerDidConnectNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidDisconnect:) name:GCControllerDidDisconnectNotification object:nil];

		[[GCController controllers] enumerateObjectsUsingBlock:^(GCController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			[self noticeController:obj];
		}];
		
		[self _determineKeyMapping];
		
		deltaX = 0;
		deltaY = 0;
	}
	return self;
}

- (void)_determineKeyMapping {
	for(size_t i=0; i < NUMBER_OF_STANDARD_KEY_DEFINITIONS; i++) {
		key_definition &definition = standard_key_definitions[i];
#define MapKey(_KEY_) keys._KEY_ = definition.offset; break
		switch(definition.action_flag) {
			case _moving_forward: MapKey(forward);
			case _moving_backward: MapKey(backward);
			case _sidestepping_left: MapKey(left);
			case _sidestepping_right: MapKey(right);
				
			case _cycle_weapons_forward: MapKey(nextWeapon);
			case _cycle_weapons_backward: MapKey(previousWeapon);
			case _right_trigger_state: MapKey(rightTrigger);
			case _left_trigger_state: MapKey(leftTrigger);
			case _run_dont_walk: MapKey(run);
			case _action_trigger_state: MapKey(action);
			case _toggle_map: MapKey(map);
			default:break;
#undef MapKey
		}	
	}
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

static float xFactor = 0.5;
static float yFactor = 0.5;
- (void)noticeController:(GCController*)controller {
	if(controller.extendedGamepad && !self.currentController) {
		MLog(@"Found new gamepad");
		self.currentController = controller.extendedGamepad;
		self.currentController.controller.playerIndex = GCControllerPlayerIndex1;
		
#define mapButton(__key__, __key_identifier__) self.currentController.__key__.valueChangedHandler = ^(GCControllerButtonInput *button, float val, bool pressed) { \
		NSLog(@"button %s %s", #__key__, pressed ? "pressed" : "released");				\
		Uint8 *state = SDL_GetMutableKeyboardState(NULL);								\
		state[__key_identifier__] = pressed;											\
	};
		
		mapButton(leftTrigger, keys.rightTrigger);
		mapButton(rightTrigger, keys.leftTrigger);
		mapButton(leftShoulder, keys.previousWeapon);
		mapButton(rightShoulder, keys.nextWeapon);
		mapButton(dpad.up, keys.forward);
		mapButton(dpad.down, keys.backward);
		mapButton(dpad.left, keys.left);
		mapButton(dpad.right, keys.right);
		
		mapButton(buttonA, keys.action);
		mapButton(buttonX, keys.map);
		mapButton(buttonB, keys.map);
		mapButton(buttonY, keys.action);

		self.currentController.leftThumbstick.valueChangedHandler = ^(GCControllerDirectionPad *axis, float x, float y) {
			Uint8 *key_map = SDL_GetMutableKeyboardState(NULL);
			// key_map[keys.run] = (sqrt(pow(x, 2) + pow(y, 2)) > 0.5) ? 1 : 0;
			key_map[keys.left] = (x < -0.01) ? 1 : 0;
			key_map[keys.right] = (x > 0.01) ? 1 : 0;
			key_map[keys.backward] = (y < -0.01) ? 1 : 0;
			key_map[keys.forward]  = (y > 0.01) ? 1 : 0;
		};

		self.currentController.rightThumbstick.valueChangedHandler = ^(GCControllerDirectionPad *axis, float x, float y) {
			deltaX = x*xFactor;
			deltaY = y*yFactor;
		};
	}
}
#undef mapButton
- (void)mouseDeltaX:(float*)dx deltaY:(float*)dy {
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
