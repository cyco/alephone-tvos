//
//  AlephOneAppDelegate.m
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AlephOneAppDelegate.h"

#import "AlephOne-Swift.h"
#import <AVFoundation/AVAudioSession.h>
#import <AlephOne/AlephOne.h>

#import "GameViewController.h"

extern "C" {
	// #import "SDL_sysvideo.h"
	// #import "SDL_events_c.h"
}
#import "SDL_uikitopenglview.h"
#import "AlephOneShell.h"
#import "AlephOne.h"

NSString * const kHasLaunchedBefore = @"launchedBefore";
int SDL_main(int argc, char **argv){
	return 0;
}

@implementation AlephOneAppDelegate

+ (void)initialize {
	if(self != [AlephOneAppDelegate class]) {
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
	// [super application:application didFinishLaunchingWithOptions:launchOptions];
	
	finishedStartup = NO;
	
	NSString *currentDirectory = [NSFileManager defaultManager].currentDirectoryPath;
	NSLog (@"Current Directory: %@", currentDirectory);
	/* Set working directory to resource path */
	[[NSFileManager defaultManager] changeCurrentDirectoryPath: [NSBundle mainBundle].resourcePath];
	currentDirectory = [NSFileManager defaultManager].currentDirectoryPath;
	NSLog(@"Current Directory: %@", currentDirectory);
	
	[self _setupScenario];
	
	NSError *setCategoryError = nil;
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:&setCategoryError];
	if (setCategoryError) {
		MLog(@"Error setting audio category");
	}
	
	// [self.window makeKeyAndVisible];
	[self _showInitialViewController];
	
	SDL_SetMainReady();
	
	[self performSelector:@selector(startAlephOne) withObject:nil afterDelay:0.0];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[[GameViewController sharedInstance] startAnimation];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[GameViewController sharedInstance] startNewGame:nil];
		});
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
		// initialViewController = [[IntroViewController alloc] initWithNibName:nil bundle:nil];
	} else {
		// initialViewController = [[MainMenuViewController alloc] initWithNibName:nil bundle:nil];
	}
	
	// UIViewController *rootViewController = self.window.rootViewController;
	// [rootViewController addChildViewController:initialViewController];
	// [rootViewController.view addSubview:initialViewController.view];
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
- (void)postFinishLaunch {
	// int exit_status = SDL_main(1, (char**)argv);
	// exit(exit_status);
}
#pragma mark - Override SDL Delegate
+ (AlephOneAppDelegate *)sharedAppDelegate {
	return (AlephOneAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (GameViewController*)game {
	return [GameViewController sharedInstance];
}

- (void)oglWidth:(GLint)width oglHeight:(GLint)height {
	_oglWidth = width;
	_oglHeight = height;
}
@end
