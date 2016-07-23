//
//  AlephOneHelper.m
//  AlephOne
//
//  Created by Daniel Blezek on 5/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Callbacks.h"

#import "GameViewController.h"
#import <AlephOne/AlephOne.h>
#import "AlephOneAppDelegate.h"

#import "PreferenceKeys.h"

#import "InputManager.h"

NSString *dataDir;

void printGLError( const char* message ) {
	switch ( glGetError() ) {
  case GL_NO_ERROR: {
	  return;
  }
  case GL_INVALID_ENUM: {
	  MLog ( @"%s GL_INVALID_ENUM", message );
	  break;
  }
  case GL_INVALID_VALUE: {
	  MLog ( @"%s GL_INVALID_VALUE", message );
	  break;
  }
  case GL_INVALID_OPERATION: {
	  MLog ( @"%s GL_INVALID_OPERATION", message );
	  break;
  }
  case GL_STACK_OVERFLOW: {
	  MLog ( @"%s GL_STACK_OVERFLOW", message );
	  break;
  }
  case GL_STACK_UNDERFLOW: {
	  MLog ( @"%s GL_STACK_UNDERFLOW", message );
	  break;
  }
  case GL_OUT_OF_MEMORY: {
	  MLog ( @"%s GL_OUT_OF_MEMORY", message );
	  break;
  }
	}
}
void printGLErrorL( const char* message, int line) {
	@autoreleasepool {
		NSString *errorName = nil;
		switch ( glGetError() ) {
			case GL_NO_ERROR: {
				return;
			}
			case GL_INVALID_ENUM: {
				errorName = @"GL_INVALID_ENUM";
				break;
			}
			case GL_INVALID_VALUE: {
				errorName = @"GL_INVALID_VALUE";
				break;
			}
			case GL_INVALID_OPERATION: {
				errorName = @"GL_INVALID_OPERATION";
				break;
			}
			case GL_STACK_OVERFLOW: {
				errorName = @"GL_STACK_OVERFLOW";
				break;
			}
			case GL_STACK_UNDERFLOW: {
				errorName = @"GL_STACK_UNDERFLOW";
				break;
			}
			case GL_OUT_OF_MEMORY: {
				errorName = @"GL_OUT_OF_MEMORY";
				break;
			}
		}
		
		if (errorName) {
			NSLog(@"%s:%d %@", message, line, errorName);
			helperCheckCurrentContext();
		}
	}
}

char* getDataDir() {
	// NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	// dataDir = [paths objectAtIndex:0];
	dataDir = [[AlephOneAppDelegate sharedAppDelegate] getDataDirectory];
	dataDir = [NSString stringWithFormat:@"%@/%@/", dataDir, [AlephOneAppDelegate sharedAppDelegate].scenario.path];
	MLog ( @"DataDir: %@", dataDir );
	return (char*)dataDir.UTF8String;

}


char* getLocalDataDir() {
	NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
	return (char*)docsDir.UTF8String;
}

void helperQuit() {
	MLog ( @"helperQuit()" );
	[[GameViewController sharedInstance] quitPressed];
}

void helperNetwork() {
	MLog ( @"helperNetwork()" );
	[[GameViewController sharedInstance] networkPressed];
}

void helperBringUpHUD () {
	[[GameViewController sharedInstance] bringUpHUD];
}

void helperSaveGame () {
}

void helperDoPreferences() {
}

int openGLESVersion = 1;
void setOpenGLESVersion(int v) {
	openGLESVersion = v;
}

int getOpenGLESVersion() {
	return openGLESVersion;
}


// Should we start a new game?
int helperNewGame () {
	if ( [GameViewController sharedInstance].haveNewGamePreferencesBeenSet ) {
		[GameViewController sharedInstance].haveNewGamePreferencesBeenSet = NO;
		return true;
	} else {
		// We need to handle some preferences here
		[[GameViewController sharedInstance] performSelector:@selector(newGame) withObject:nil afterDelay:0.01];
		return false;
	}
}

void pumpEvents() {
	SInt32 result;
	do {
		// MoreEvents = [theRL runMode:currentMode beforeDate:future];
		result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, TRUE);
	} while(result == kCFRunLoopRunHandledSource);

}

void helperPlayerKilled() {
	[[GameViewController sharedInstance] playerKilled];
}

void helperHideHUD() {
	[[GameViewController sharedInstance] hideHUD];
}

void helperBeginTeleportOut() {
}

void helperTeleportInLevel() {
}

void helperEpilog() {
	[[GameViewController sharedInstance] epilog];
	pumpEvents();
}

void helperEndReplay() {
	[[GameViewController sharedInstance] endReplay];
	pumpEvents();
}

float helperGamma() {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	float g = [defaults floatForKey:kGamma];
	return g;
};

int helperAlwaysPlayIntro () {
	return 0;
};

int helperAutocenter () {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL g = [defaults boolForKey:kAutocenter];
	if ( g ) {
		return 1;
	} else {
		return 0;
	}
};

void helperGetMouseDelta ( int *dx, int *dy ) {
	// Get the mouse delta from the JoyPad HUD controller, if possible
	[[InputManager sharedInputManager] mouseDeltaX:dx deltaY:dy];
}

GLfloat helperPauseAlpha() {
	return [[GameViewController sharedInstance] getPauseAlpha];
}

void helperSetPreferences( int notify) {
	MLog(@"helperSetPreferences: %d", notify);
}

short pRecord[128][2];
void helperNewProjectile( short projectile_index, short which_weapon, short which_trigger ) {
	if ( projectile_index >= 128 ) { return; };
	pRecord[projectile_index][0] = which_weapon;
	pRecord[projectile_index][1] = which_trigger;
}

void helperProjectileHit ( short projectile_index, int damage ) {
}

void helperProjectileKill ( short projectile_index ) {
}

void helperGameFinished() {
}

void helperHandleLoadGame ( ) {
	return;
}

short helperGetEntryLevelNumber() {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:kEntryLevelNumber];
}

void helperHandleSaveFilm() {}
void helperHandleLoadFilm() {}

extern void helperPickedUp ( short itemType ) {
	// picked something up
	MLog ( @"Picked something up");
}

int helperOpenGLWidth() {
	return [AlephOneAppDelegate sharedAppDelegate].oglWidth;
}
int helperOpenGLHeight() {
	return [AlephOneAppDelegate sharedAppDelegate].oglHeight;
}
int helperRetinaDisplay() {
	return [AlephOneAppDelegate sharedAppDelegate].retinaDisplay;
}
int helperRunningOniPad() {
	return false;
}
void helperSwitchWeapons(int weapon) {
	[[GameViewController sharedInstance] updateReticule:weapon];
}

#pragma mark -
static size_t progressTotal = 0;
static size_t progressDone = 0;
void helperLoadingStart(size_t total) {
	printf("Loading %ld items\n", total);
	progressTotal = total;
	progressDone = 0;
}
void helperLoadingProgress(size_t delta) {
	progressDone += delta,
	printf("%zu (%2.2f)\n", delta, (progressDone / (double)progressTotal) * 100.0);
}
void helperLoadingFinish() {
	printf("Loading done\n");
}

extern "C" void helperCheckCurrentContext(){
	NSLog(@"Context: %@ == %@: %s", [EAGLContext currentContext], SDL_GL_GetCurrentContext(), [EAGLContext currentContext] == SDL_GL_GetCurrentContext() ? "YES" : "NO");
}