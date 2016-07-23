//
//  AlephOne.m
//  AlephOne-tvOS
//
//  Created by Christoph Leimbrock on 07/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#import "AlephOne.h"
#import <AlephOne/AlephOne.h>

@implementation AlephOne
+ (void)display_main_menu {
	display_main_menu();
}

+ (void)begin_new_game {
	do_menu_item_command(mInterface, iNewGame, false);
}
@end
