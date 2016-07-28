//
//  GameViewController.m
//  AlephOne
//
//  Created by Daniel Blezek on 6/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"

#import "AlephOne-Swift.h"
#import <AlephOne/AlephOne.h>

#import "AlephOne.h"
#import "AppDelegate.h"
#import "GameViewController.h"

#import "InputManager.h"

extern float DifficultyMultiplier[];
extern bool save_game(void);
extern void AddItemsToPlayer(short ItemType, short MaxNumber);
extern void AddOneItemToPlayer(short ItemType, short MaxNumber);
extern "C" void setOpenGLView ( SDL_uikitopenglview* view );

#import <string.h>
#import <stdlib.h>

extern struct view_data *world_view;
enum
{
	_activating_sound,
	_deactivating_sound,
	_unusuable_sound,

	NUMBER_OF_CONTROL_PANEL_SOUNDS
};

struct control_panel_definition
{
	int16 _class;
	uint16 flags;

	int16 collection;
	int16 active_shape, inactive_shape;

	int16 sounds[NUMBER_OF_CONTROL_PANEL_SOUNDS];
	_fixed sound_frequency;

	int16 item;
};

#define kPauseAlphaDefault 0.5;
@interface GameViewController () {
	SDL_uikitopenglview *_viewGL;
}
@end

@implementation GameViewController
#pragma mark - Singleton
+ (GameViewController*)sharedInstance
{
	static GameViewController* sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:[NSBundle mainBundle]];
	});
	return sharedInstance;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		// Custom initialization
		NSLog ( @"inside initWithNib" );
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Bogus reticule
	currentReticleImage = -1000;

	// Kill a warning
	(void)all_key_definitions;
	mode = GameMode;
	_haveNewGamePreferencesBeenSet = YES;
	pauseAlpha = kPauseAlphaDefault;

	isPaused = NO;
	animating = NO;
	[super viewDidLoad];
}

- (void)_loadReticuleImageNames {
	NSMutableArray *imageNames = [NSMutableArray arrayWithCapacity:MAXIMUM_NUMBER_OF_WEAPONS];
	[imageNames insertObject:@"" atIndex:_weapon_fist];
	[imageNames insertObject:@"ret_pistol" atIndex:_weapon_pistol];
	[imageNames insertObject:@"ret_plasma" atIndex:_weapon_plasma_pistol];
	[imageNames insertObject:@"ret_machinegun" atIndex:_weapon_assault_rifle];
	[imageNames insertObject:@"ret_rocket" atIndex:_weapon_missile_launcher];
	[imageNames insertObject:@"ret_flame" atIndex:_weapon_flamethrower];
	[imageNames insertObject:@"ret_alien" atIndex:_weapon_alien_shotgun];
	[imageNames insertObject:@"ret_shotgun" atIndex:_weapon_shotgun];
	[imageNames insertObject:@"ret_shotgun" atIndex:_weapon_ball];
	[imageNames insertObject:@"ret_machinegun" atIndex:_weapon_smg];

	self.reticuleImageNames = imageNames;
}

- (void)viewDidAppear:(BOOL)animated
{
	[self startAnimation];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}
#pragma mark - Game control

- (void)closeEvent {
	switch ( mode ) {
		case MenuMode:
			// [Tracking trackPageview:@"/menu"];
			// [Tracking tagEvent:@"menu"];
			break;
		case CutSceneMode:
			// [Tracking trackPageview:@"/cutscene"];
			// [Tracking tagEvent:@"cutsecene"];
			break;
		case AutoMapMode:
			// [Tracking trackPageview:@"/automap"];
			// [Tracking tagEvent:@"automap"];
			break;
		case DeadMode:
			// [Tracking trackPageview:@"/dead"];
			// [Tracking tagEvent:@"dead"];
			break;
		case GameMode:
		default:
			// [Tracking trackPageview:@"/game"];
			// [Tracking tagEvent:@"game"];
			break;
	}
}

- (IBAction)quitPressed {
}

- (IBAction)networkPressed {
#if ! TARGET_OS_TV
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Networking not available"
																							 message:@"Network play is not available, but the button can not be removed due to license resctictions, sorry..."
																							delegate:nil
																		 cancelButtonTitle:@"Bummer"
																		 otherButtonTitles:nil];
	[av show];
	[av release];
#endif
}

- (IBAction)newGame {
	self.currentSavedGame = nil;
}

- (IBAction)beginGame {
	_haveNewGamePreferencesBeenSet = YES;
	/*
  CGPoint location = lastMenuTap;
  SDL_SendMouseMotion(0, location.x, location.y);
  SDL_SendMouseButton(SDL_PRESSED, SDL_BUTTON_LEFT);
  SDL_SendMouseButton(SDL_RELEASED, SDL_BUTTON_LEFT);
  SDL_GetRelativeMouseState(NULL, NULL);
	 */
	mode = GameMode;
	self.currentSavedGame = nil;
	MLog ( @"Current world ticks %d", dynamic_world->tick_count );

	// Do we show the overview?
	if ( dynamic_world->current_level_number == 0 ) {
	}

	[self cancelNewGame];
	// [self performSelector:@selector(cancelNewGame) withObject:nil afterDelay:0.0];

	// New menus
	do_menu_item_command(mInterface, iNewGame, false);
}

- (IBAction)cancelNewGame {
	[self closeEvent];
	// [self.newGameView performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.3];
}

- (void)hideHUD {
}

- (void)endReplay {
	MLog ( @"End Replay" );
	mode = MenuMode;
	[self closeEvent];
}

- (void)epilog {
	mode = CutSceneMode;
}

- (void)playerKilled {
	mode = DeadMode;
}

- (void)bringUpHUD {
	mode = GameMode;

	[self updateReticule:get_player_desired_weapon(current_player_index)];
	Crosshairs_SetActive(false);
}

- (GLfloat) getPauseAlpha {
	return pauseAlpha;
}

- (void)setOpenGLView:(SDL_uikitopenglview*)oglView {
	[self stopAnimation];
	
	if(_viewGL) {
		[_viewGL removeFromSuperview];
		_viewGL = nil;
	}
	
	[oglView removeFromSuperview];
	oglView.frame = self.view.frame;
	[self.view addSubview:oglView];
	_viewGL = oglView;

	[self startAnimation];
}

- (SDL_uikitopenglview*)viewGL {
	return _viewGL;
}

#pragma mark - Pause actions
- (IBAction) resume:(id)sender {
	[self closeEvent];
	[self pause:sender];
}

- (IBAction) gotoMenu:(id)sender {
	MLog ( @"How do we go back?!" );
	mode = MenuMode;
	[self closeEvent];
	set_game_state(_close_game);
}

extern SDL_Surface *draw_surface;

#pragma mark - Film Methods
extern bool handle_open_replay(FileSpecifier& File);

#pragma mark - Reticule
- (void)updateReticule:(int)index {
	if ( mode == DeadMode ) { return; }
	if ( world_view->overhead_map_active || world_view->terminal_mode_active ) {
		return;
	}

	if ( ![[NSUserDefaults standardUserDefaults] boolForKey:kCrosshairs] ) {
		return;
	}

	if ( index < 0 ) {
		index = get_player_desired_weapon(current_player_index);
	}
	if ( index == currentReticleImage ) {
		return;
	}
	currentReticleImage = index;

	if ( [[NSUserDefaults standardUserDefaults] boolForKey:kHaveReticleMode] ) {
		// Fancy reticule
		// self.reticule.image = [UIImage imageNamed:[reticuleImageNames objectAtIndex:index]];
	} else {
		// Basic reticule
		// self.reticule.image = [UIImage imageNamed:@"ret_default"];
	}

	return;
}

#pragma mark - Game controls
// If we are playing, pause...
- (IBAction)pauseForBackground:(id)from {
	if ( mode == GameMode && !isPaused ) {
		[self pause:from];
	}
	return;
}

- (IBAction)pause:(id)from {
	return;
	// If we are dead, don't do anything
	if ( mode == DeadMode ) { return; }
	if ( from != nil ) {
	}
	// Level name is
	// static_world->level_name
	MLog (@"Camera Polygon Index: %d", local_player->camera_polygon_index );
	MLog (@"Supporting Polygon Index: %d", local_player->supporting_polygon_index );

	// Normally would just darken the screen, here we may want to popup a list of things to do.
	if ( isPaused ) {
		resume_game();
		[self closeEvent];
	} else {
		// [Tracking trackPageview:@"/pause"];
		pause_game();
		// self.pauseView.hidden = NO;
		// self.pauseView.alpha = 0.0;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:.5];
		// self.pauseView.alpha = 1.0;
		[UIView commitAnimations];
	}
	[self updateReticule:get_player_desired_weapon(current_player_index)];
	isPaused = !isPaused;
}

short items[]=
{
	// Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
	_i_smg_ammo,
#endif
	_i_assault_rifle_magazine, _i_assault_grenade_magazine,
	_i_magnum_magazine, _i_missile_launcher_magazine,
	_i_flamethrower_canister,
	_i_plasma_magazine, _i_shotgun_magazine, _i_shotgun

};

#pragma mark - Animation Methods
- (void)startAnimation {
	if ( !animating ) {
		// A system version of 3.1 or greater is required to use CADisplayLink. The NSTimer
		// class is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [UIDevice currentDevice].systemVersion;
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending) {
			displayLinkSupported = TRUE;
		}

		NSInteger animationFrameInterval = 2;
		if (displayLinkSupported) {
			// CADisplayLink is API new to iPhone SDK 3.1. Compiling against earlier versions will result in a warning, but can be dismissed
			// if the system version runtime check for CADisplayLink exists in -initWithCoder:. The runtime check ensures this code will
			// not be called in system versions earlier than 3.1.
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(runMainLoopOnce:)];
			displayLink.frameInterval = animationFrameInterval;
			[displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		} else {
			animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(runMainLoopOnce:) userInfo:nil repeats:TRUE];
		}
		inMainLoop = NO;
		animating = YES;
	}
}

- (void)stopAnimation
{
	if (animating)
	{
		inMainLoop = NO;
		if (displayLinkSupported)
		{
			[displayLink invalidate];
			displayLink = nil;
		}
		else
		{
			[animationTimer invalidate];
			animationTimer = nil;
		}

		animating = FALSE;
	}
}

- (void)runMainLoopOnce:(id)sender {	
	if ( !inMainLoop ) {
		inMainLoop = YES;
		AlephOneMainLoop();
		inMainLoop = NO;
	}
}
#pragma mark -
- (IBAction)startNewGame:(id)sender {
	MLog(@"startNewGame:");
	player_preferences->difficulty_level = _easy_level;
	[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:kEntryLevelNumber];
	
	[sender setEnabled:false];
	
	[InputManager sharedInputManager];
	
	[self beginGame];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self cheatWeapons:nil];
		[self cheatAmmo:nil];
	});
}

- (IBAction)cheatAmmo:(id)sender {
	short items[]=
	{ 
		// Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
		_i_smg_ammo,
#endif
		_i_assault_rifle_magazine, _i_assault_grenade_magazine,
		_i_magnum_magazine, _i_missile_launcher_magazine,
		_i_flamethrower_canister,
		_i_plasma_magazine, _i_shotgun_magazine, _i_shotgun
	};
	
	for(unsigned index= 0; index<sizeof(items)/sizeof(short); ++index)
	{
		switch(get_item_kind(items[index]))
		{
			case _ammunition:
				AddItemsToPlayer(items[index],10);
				break;        
			default:
				break;
		}
		process_new_item_for_reloading(local_player_index, items[index]);
	}
}

- (IBAction)cheatWeapons:(id)sender {
	short items[]=
	{
		// Only get the SMG/Flechette gun in Infinity
#if SCENARIO == 3
		_i_smg,
#endif
		_i_assault_rifle, _i_magnum, _i_missile_launcher, _i_flamethrower,
		_i_plasma_pistol, _i_alien_shotgun, _i_shotgun
		
	};
	
	for(unsigned index= 0; index<sizeof(items)/sizeof(short); ++index)
	{
		switch(get_item_kind(items[index]))
		{
			case _weapon:
				if(items[index]==_i_shotgun || items[index]==_i_magnum) {
					AddOneItemToPlayer(items[index],2);
				} else {
					AddItemsToPlayer(items[index],1);
				}
				break;
			default:
				break;
		}
		process_new_item_for_reloading(local_player_index, items[index]);
	}
}

@end
