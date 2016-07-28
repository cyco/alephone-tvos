//
//  AppDelegate
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AppDelegate.h"

#import "AlephOne-Swift.h"
#import <AVFoundation/AVAudioSession.h>
#import <AlephOne/AlephOne.h>

#import "GameViewController.h"

#import "SDL_uikitopenglview.h"
#import "AlephOne.h"

NSString * const kHasLaunchedBefore = @"launchedBefore";

int SDL_main(int argc, char **argv){
	return 0;
}

@implementation AppDelegate

+ (void)initialize {
	if(self != [AppDelegate class]) {
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary *appDefaults = @{kGamma: @"2.0",
								  kTapShoots: @"NO",
								  kSecondTapShoots: @"NO",
								  kHSensitivity: @"0.5",
								  kVSensitivity: @"0.5",
								  kSfxVolume: @"1.0",
								  kMusicVolume: @"1.0",
								  kEntryLevelNumber: @"0",
								  kCrosshairs: @"NO",
								  kAutocenter: @"NO",
								  kHaveTTEP: @"NO",
								  kUseTTEP: @"YES",
								  kUsageData: @"YES",
								  kHaveVidmasterMode: @"NO",
								  kUseVidmasterMode: @"YES",
								  kAlwaysPlayIntro: @"NO",
								  kHaveReticleMode: @"NO",
								  kInvertY: @"NO",
								  kAutorecenter: @"YES",
								  kFirstGame: @YES};
	[defaults registerDefaults:appDefaults];
}
#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	finishedStartup = NO;
	
	NSString *currentDirectory = [NSFileManager defaultManager].currentDirectoryPath;
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: [NSBundle mainBundle].resourcePath];
	currentDirectory = [NSFileManager defaultManager].currentDirectoryPath;
	
	[self _setupScenario];
	
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
	if (setCategoryError) {
		MLog(@"Error setting audio category");
	}
	
	[self _showInitialViewController];
	[self.window makeKeyAndVisible];
	
	SDL_SetMainReady();
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self startAlephOne];
	});
	
	return YES;
}

- (void)_setupScenario {
	self.scenario = [[ScenarioDescription alloc] init];
	self.scenario.isDownloaded = @NO;
	self.scenario.version = @1;
	self.scenario.name = @"Marathon";
	self.scenario.path = @"m1a1";
	self.scenario.sizeInBytes = @(150 * 1024 * 1024);  // 150 meg
	self.scenario.downloadURL = @"localhost";
	self.scenario.downloadHost = @"localhost";
}

- (void)_showInitialViewController {
	UIViewController *initialViewController = nil;
	if(![[NSUserDefaults standardUserDefaults] boolForKey:kHasLaunchedBefore]) {
		initialViewController = [[IntroViewController alloc] initWithNibName:nil bundle:nil];
	} else {
		initialViewController = [[MainMenuViewController alloc] initWithNibName:nil bundle:nil];
	}
	
	UIViewController *rootViewController = self.window.rootViewController;
	[rootViewController addChildViewController:initialViewController];
	[rootViewController.view addSubview:initialViewController.view];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	GameViewController *game = self.game;
	[game pauseForBackground:self];
	[game stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if ( finishedStartup ) {
		GameViewController *game = self.game;
		[game startAnimation];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// SDL_SendQuit();
	/* hack to prevent automatic termination.  See SDL_uikitevents.m for details */
	// DJB We really don't need the long jump...
	// longjmp(*(jump_env()), 1);
}

#pragma mark - Paths
- (NSString *)applicationDocumentsDirectory {
	return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
}

- (NSString*)getDataDirectory {
	return [NSBundle mainBundle].resourcePath;
}

#pragma mark - AlephOne startup
- (void)startAlephOne {
	finishedStartup = YES;
	
	AlephOneInitialize();
	MLog(@"AlephOneInitialize finished");
}

const char* argv[] = { "AlephOneHD" };

#pragma mark - Override SDL Delegate
+ (AppDelegate *)sharedAppDelegate {
	return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (GameViewController*)game {
	return [GameViewController sharedInstance];
}

- (void)oglWidth:(GLint)width oglHeight:(GLint)height {
	_oglWidth = width;
	_oglHeight = height;
}

- (void)setOpenGLView:(SDL_uikitopenglview*)oglView {
	[self.window.rootViewController.view addSubview:oglView];
	oglView.frame = self.window.rootViewController.view.bounds;
}

- (void)setSDLWindowData:(SDL_WindowData*)data {
	[data.viewcontroller removeFromParentViewController];
	[data.viewcontroller.view removeFromSuperview];
	
	[self.window.rootViewController addChildViewController:data.viewcontroller];
	[self.window.rootViewController.view addSubview:data.viewcontroller.view];
	
}
@end
