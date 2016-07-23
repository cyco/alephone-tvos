//
//  GameViewController.h
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameController/GameController.h>
#import "SDL_uikitopenglview.h"
#import "SDL_keyboard.h"

#import "ScenarioDescription.h"
#import "SavedGame.h"

typedef NS_ENUM(unsigned int, HUDMode) {
  MenuMode,
  GameMode,
  CutSceneMode,
  AutoMapMode,
  DeadMode
};

@class CrosshairView;
@interface GameViewController : GCEventViewController {
  HUDMode mode;
  int currentReticleImage;
  BOOL isPaused;
  GLfloat pauseAlpha;

  BOOL displayLinkSupported;
  CADisplayLink *displayLink;
  bool animating;
  bool inMainLoop;
  NSTimer *animationTimer;

  int ticks;
}

+ (GameViewController*)sharedInstance;

- (void)startAnimation;
- (void)stopAnimation;
- (void)runMainLoopOnce:(id)sender;

- (IBAction)pause:(id)from;
- (IBAction)pauseForBackground:(id)from;
- (IBAction)newGame;
- (IBAction)beginGame;
- (IBAction)cancelNewGame;
- (void)playerKilled;
- (IBAction)quitPressed;
- (IBAction)networkPressed;

// Pause actions
- (IBAction) resume:(id)sender;
@property (nonatomic, getter=getPauseAlpha, readonly) GLfloat pauseAlpha;

// Reticules
- (void)updateReticule:(int)index;

- (void)bringUpHUD;
- (void)hideHUD;
- (void)epilog;
- (void)endReplay;
- (void)setOpenGLView:(SDL_uikitopenglview*)oglView;
- (void)closeEvent;

// Menu Sounds
- (IBAction)startNewGame:(id)sender;

@property (nonatomic, retain, setter=setOpenGLView:) SDL_uikitopenglview *viewGL;
@property (nonatomic, assign) bool haveNewGamePreferencesBeenSet;
@property (nonatomic, retain) SavedGame *currentSavedGame;
#pragma mark -
@property (strong) NSArray *reticuleImageNames;
#pragma mark -
@property (assign) IBOutlet CrosshairView *crosshairView;
@end
