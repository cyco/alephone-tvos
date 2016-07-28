//
//  CallbacksC.c
//  AlephOne-tvOS
//
//  Created by Christoph Leimbrock on 08/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import "Callbacks.h"

#import "GameViewController.h"
#import "AppDelegate.h"
#import "PreferenceKeys.h"
#import "InputManager.h"

SDL_uikitopenglview* getOpenGLView() {
	GameViewController *game = [GameViewController sharedInstance];
	return game.viewGL;
}

void setOpenGLView (void* view) {
	// DJB
	// Construct the Game view controller
	GameViewController *game = [GameViewController sharedInstance];
	[game setOpenGLView:(__bridge SDL_uikitopenglview *)(view)];
}

void setSDLWindowData(void* data) {
	AppDelegate *dele = [UIApplication sharedApplication].delegate;
	[dele setSDLWindowData:(__bridge SDL_WindowData *)(data)];
}