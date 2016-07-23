//
//  SavedGame.h
//  AlephOne
//
//  Created by Christoph Leimbrock on 05/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScenarioDescription.h"

@class ScenarioDescription;
@interface SavedGame : NSObject
@property (nullable, retain) NSNumber *kills;
@property (nullable, retain) NSString *filename;
@property (nullable, retain) NSNumber *damageTaken;
@property (nullable, retain) NSString *mapFilename;
@property (nullable, retain) NSString *level;
@property (nullable, retain) NSNumber *timeInSeconds;
@property (nullable, retain) NSNumber *shotsFired;
@property (nullable, retain) NSDate *lastSaveTime;
@property (nullable, retain) NSString *difficulty;
@property (nullable, retain) NSNumber *accuracy;
@property (nullable, retain) NSNumber *damageGiven;
@property (nullable, retain) NSNumber *numberOfSessions;
@property (nullable, assign) ScenarioDescription *scenario;
@property (nullable, retain) NSNumber *bobsLeftAlive;
@property (nullable, retain) NSNumber *aliensLeftAlive;
@property (nullable, retain) NSNumber *killsByFist;
@property (nullable, retain) NSNumber *killsByPistol;
@property (nullable, retain) NSNumber *killsByPlasmaPistol;
@property (nullable, retain) NSNumber *killsByAssaultRifle;
@property (nullable, retain) NSNumber *killsByFlamethrower;
@property (nullable, retain) NSNumber *killsByAlienShotgun;
@property (nullable, retain) NSNumber *killsByShotgun;
@property (nullable, retain) NSNumber *killsBySMG;
@property (nullable, retain) NSNumber *killsByMissileLauncher;
@property (nullable, retain) NSNumber *score;
@property (nullable, retain) NSNumber *numberOfDeaths;
@property (nullable, retain) NSNumber *haveCheated;
@end
