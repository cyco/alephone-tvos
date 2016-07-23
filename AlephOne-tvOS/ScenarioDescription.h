//
//  Scenario.h
//  AlephOne
//
//  Created by Christoph Leimbrock on 05/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SavedGame.h"

@class SavedGame;
@interface ScenarioDescription : NSObject
@property (nullable, nonatomic, retain) NSNumber *sizeInBytes;
@property (nullable, nonatomic, retain) NSString *downloadHost;
@property (nullable, nonatomic, retain) NSNumber *isDownloaded;
@property (nullable, nonatomic, retain) NSString *downloadURL;
@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSNumber *version;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<SavedGame*>* savedGames;
@end

