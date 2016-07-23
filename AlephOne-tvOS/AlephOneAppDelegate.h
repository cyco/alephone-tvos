//
//  AlephOneAppDelegate.h
//  AlephOne
//
//  Created by Daniel Blezek on 8/22/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScenarioDescription.h"
#import "SavedGame.h"
#import "PreferenceKeys.h"
#import "SDL_uikitappdelegate.h"

@class GameViewController;
@interface AlephOneAppDelegate : SDLUIKitDelegate <UIApplicationDelegate> {
		bool finishedStartup;
}

+ (AlephOneAppDelegate *)sharedAppDelegate;
- (void)startAlephOne;
- (void)oglWidth:(GLint)width oglHeight:(GLint)height;

@property (nonatomic, retain, readonly) GameViewController *game;
@property (nonatomic, retain) ScenarioDescription *scenario;
@property (nonatomic, readonly, copy) NSString *applicationDocumentsDirectory;
@property (nonatomic, readonly, copy, getter=getDataDirectory) NSString *dataDirectory;
@property (nonatomic) int oglHeight;
@property (nonatomic) int oglWidth;
@property (nonatomic) int retinaDisplay;
@end


