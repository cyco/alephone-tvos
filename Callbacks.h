//
//  platform.h
//  aleph
//
//  Created by Christoph Leimbrock on 06/07/16.
//  Copyright © 2016 chris. All rights reserved.
//

#ifndef platform_h
#define platform_h
#if defined(__cplusplus)
extern "C" {
#endif
	char *getDataDir(void);
	char* getLocalDataDir();
	void helperBringUpHUD();

    void setOpenGLView(void* view);
    
	int helperNewGame();
	void helperSaveGame();
	void helperHideHUD();
	void helperBeginTeleportOut();
	void helperTeleportInLevel();
	void helperEpilog();
	void helperGameFinished();
	void helperHandleLoadGame();
	void helperDoPreferences();
	void printGLError(const char* message);
	void printGLErrorL(const char* message, int line);
	void pumpEvents();
	void startProgress ( int t );
	void progressCallback ( int d );
	void stopProgress();
	void helperPlayerKilled();
	int helperAlwaysPlayIntro();
	int helperAutocenter();
	void helperGetMouseDelta ( int *dx, int *dy );
	void helperSwitchWeapons(int weapon);
	void helperQuit();
	void helperNetwork();
	void helperEndReplay();
	void helperSetPreferences(int notifySoundManager);
	void helperHandleSaveFilm();
	void helperHandleLoadFilm();
	void helperNewProjectile ( short projectile_index, short which_weapon, short which_trigger );
	void helperProjectileHit ( short projectile_index, int damage );
	void helperProjectileKill ( short projectile_index );
	short helperGetEntryLevelNumber();
	void helperPickedUp ( short itemType );
	float helperGamma();
	float helperPauseAlpha();
	int helperOpenGLWidth();
	int helperOpenGLHeight();
	void setOpenGLESVersion(int version);
	int getOpenGLESVersion();
	int helperRunningOniPad(void);
	int helperRetinaDisplay();
	
#pragma mark - 
	
	void helperLoadingStart(size_t total);
	void helperLoadingProgress(size_t delta);
	void helperLoadingFinish();
	
	void helperCheckCurrentContext();
#if defined(__cplusplus)
}
#endif
#endif /* platform_h */
