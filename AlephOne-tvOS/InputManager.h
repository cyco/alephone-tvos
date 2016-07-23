//
//  InputManager.h
//  ControllerTest
//
//  Created by Christoph Leimbrock on 04/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

@interface InputManager : NSObject
+ (instancetype)sharedInputManager;
- (void)startWatching;
- (void)stopWatching;

- (void)mouseDeltaX:(int*)dx deltaY:(int*)dy;
@property (readonly) GCExtendedGamepad *currentController;
@end
