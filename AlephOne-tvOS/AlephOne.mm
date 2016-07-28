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

#pragma mark -

#import <stdlib.h>
#import <string.h>
#import <ctype.h>

#import <sstream>
#import <boost/lexical_cast.hpp>

#ifdef HAVE_CONFIG_H
#import "confpaths.h"
#endif

#import <ctime>
#import <exception>
#import <algorithm>
#import <vector>

#ifdef HAVE_UNISTD_H
#import <unistd.h>
#endif

#ifdef HAVE_SDL_NET_H
#import <SDL_net.h>
#endif

#ifdef HAVE_PNG
#import "IMG_savepng.h"
#endif

#ifdef HAVE_SDL_IMAGE
#import <SDL_image.h>
#endif

#import <AlephOne/AlephOne.h>

// ccl
#import "Callbacks.h"

extern char *application_name;
extern char *application_identifier;
extern char *bundle_resource_path;
extern char *app_log_directory;
extern char *app_preferences_directory;
extern char *app_support_directory;
extern char *app_screenshots_directory;


// Prototypes
void main_event_loop(void);
extern int process_keyword_key(char key);
extern void handle_keyword(int type_of_cheat);

void PlayInterfaceButtonSound(short SoundID);

// From preprocess_map_sdl.cpp
extern bool get_default_music_spec(FileSpecifier &file);
extern bool get_default_theme_spec(FileSpecifier& file);

// From vbl_sdl.cpp
void execute_timer_tasks(uint32 time);

extern void process_event(const SDL_Event &event);
extern void execute_timer_tasks(uint32 time);
extern void InitDefaultStringSets(void);
extern "C" char* getDataDir(void);
extern "C" char* getLocalDataDir(void);
DirectorySpecifier local_data_dir;
DirectorySpecifier default_data_dir;
vector <DirectorySpecifier> data_search_path;
DirectorySpecifier preferences_dir;
DirectorySpecifier saved_games_dir;
DirectorySpecifier quick_saves_dir;
DirectorySpecifier image_cache_dir;
DirectorySpecifier recordings_dir;
DirectorySpecifier screenshots_dir;
DirectorySpecifier log_dir;
std::string arg_directory;
std::vector<std::string> arg_files;
extern void initialize_resources(void);

bool option_nogl = false;             // Disable OpenGL
bool option_nosound = false;          // Disable sound output
bool option_nogamma = false;	      // Disable gamma table effects (menu fades)
bool option_debug = true;
bool option_nojoystick = false;
bool insecure_lua = false;
static bool force_fullscreen = true; // Force fullscreen mode
static bool force_windowed = false;   // Force windowed mode
short vidmasterStringSetID = -1; // can be set with MML

bool contract_symbolic_paths_helper(char *dest, const char *src, int maxlen, const char *symbol, DirectorySpecifier &dir)
{
	const char *dpath = dir.GetPath();
	int dirlen = strlen(dpath);
	if (!strncmp(src, dpath, dirlen))
	{
		strncpy(dest, symbol, maxlen);
		dest[maxlen] = '\0';
		strncat(dest, &src[dirlen], maxlen-strlen(dest));
		return true;
	}
	return false;
}

bool expand_symbolic_paths_helper(char *dest, const char *src, int maxlen, const char *symbol, DirectorySpecifier& dir)
{
	int symlen = strlen(symbol);
	if (!strncmp(src, symbol, symlen))
	{
		strncpy(dest, dir.GetPath(), maxlen);
		dest[maxlen] = '\0';
		strncat(dest, &src[symlen], maxlen-strlen(dest));
		return true;
	}
	return false;
}

char *expand_symbolic_paths(char *dest, const char *src, int maxlen)
{
	bool expanded =
#if defined(HAVE_BUNDLE_NAME)
#endif
	expand_symbolic_paths_helper(dest, src, maxlen, "$local$", local_data_dir) ||
	expand_symbolic_paths_helper(dest, src, maxlen, "$default$", default_data_dir);
	if (!expanded)
	{
		strncpy(dest, src, maxlen);
		dest[maxlen] = '\0';
	}
	return dest;
}

bool quit_without_saving(void)
{
	return 1;
}


char *contract_symbolic_paths(char *dest, const char *src, int maxlen)
{
	bool contracted =
	contract_symbolic_paths_helper(dest, src, maxlen, "$local$", local_data_dir) ||
	contract_symbolic_paths_helper(dest, src, maxlen, "$default$", default_data_dir);
	if (!contracted)
	{
		strncpy(dest, src, maxlen);
		dest[maxlen] = '\0';
	}
	return dest;
}

// LP: the rest of the code has been moved to Jeremy's shell_misc.file.

void PlayInterfaceButtonSound(short SoundID)
{
	if (TEST_FLAG(input_preferences->modifiers,_inputmod_use_button_sounds))
		SoundManager::instance()->PlaySound(SoundID, (world_location3d *) NULL, NONE);
}


static void initialize_marathon_music_handler(void)
{
	FileSpecifier file;
	if (get_default_music_spec(file))
		Music::instance()->SetupIntroMusic(file);
}

bool networking_available(void)
{
#if !defined(DISABLE_NETWORKING)
	return true;
#else
	return false;
#endif
}


static int char_is_not_filesafe(int c)
{
	return (c != ' ' && !std::isalnum(c));
}

void shutdown_application(void){}
static bool _ParseMMLDirectory(DirectorySpecifier& dir)
{
	// Get sorted list of files in directory
	vector<dir_entry> de;
	if (!dir.ReadDirectory(de))
		return false;
	sort(de.begin(), de.end());
	
	// Parse each file
	vector<dir_entry>::const_iterator i, end = de.end();
	for (i=de.begin(); i!=end; i++) {
		if (i->is_directory)
			continue;
		if (i->name[i->name.length() - 1] == '~')
			continue;
		// people stick Lua scripts in Scripts/
		// if (boost::algorithm::ends_with(i->name, ".lua"))
		//continue;
		
		// Construct full path name
		FileSpecifier file_name = dir + i->name;
		
		// Parse file
		ParseMMLFromFile(file_name);
	}
	
	return true;
}

void AlephOneInitialize() {	
	// Initialize SDL
	int retval = SDL_Init(SDL_INIT_VIDEO |
						  (0 ? 0 : SDL_INIT_AUDIO) |
						  (0 ? 0 : SDL_INIT_JOYSTICK) |
						  (1 ? SDL_INIT_NOPARACHUTE : 0));
	if (retval < 0)
	{
		const char *sdl_err = SDL_GetError();
		if (sdl_err)
			fprintf(stderr, "Couldn't initialize SDL (%s)\n", sdl_err);
		else
			fprintf(stderr, "Couldn't initialize SDL\n");
		exit(1);
	}
#if defined(HAVE_SDL_IMAGE)
	IMG_Init(IMG_INIT_JPG | IMG_INIT_PNG);
#endif
	
	// Find data directories, construct search path
	InitDefaultStringSets();
#if TARGET_OS_TV 
	default_data_dir = getDataDir();
	local_data_dir = getLocalDataDir();
#elif defined(unix) || defined(__NetBSD__) || defined(__OpenBSD__) || (defined(__APPLE__) && defined(__MACH__) && !defined(HAVE_BUNDLE_NAME))
	
	default_data_dir = PKGDATADIR;
	const char *home = getenv("HOME");
	if (home)
		local_data_dir = home;
	local_data_dir += ".alephone";
	log_dir = local_data_dir;
	
#elif defined(__APPLE__) && defined(__MACH__)
	bundle_data_dir = bundle_resource_path;
	bundle_data_dir += "DataFiles";
	
	data_search_path.push_back(bundle_data_dir);
	
#ifndef SCENARIO_IS_BUNDLED
	{
		char* buf = getcwd(0, 0);
		default_data_dir = buf;
		free(buf);
	}
#endif
	
	log_dir = app_log_directory;
	preferences_dir = app_preferences_directory;
	local_data_dir = app_support_directory;
	
#else
	default_data_dir = "";
	local_data_dir = "";
	//#error Data file paths must be set for this platform.
#endif
	
#define LIST_SEP ':'
	
	// in case we need to redo search path later:
	size_t dsp_insert_pos = data_search_path.size();
	size_t dsp_delete_pos = (size_t)-1;
	
	if (arg_directory != "")
	{
		default_data_dir = arg_directory;
		dsp_delete_pos = data_search_path.size();
		data_search_path.push_back(arg_directory);
	}
	
	const char *data_env = getenv("ALEPHONE_DATA");
	if (data_env) {
		// Read colon-separated list of directories
		string path = data_env;
		string::size_type pos;
		while ((pos = path.find(LIST_SEP)) != string::npos) {
			if (pos) {
				string element = path.substr(0, pos);
				data_search_path.push_back(element);
			}
			path.erase(0, pos + 1);
		}
		if (!path.empty())
			data_search_path.push_back(path);
	} else {
		if (arg_directory == "")
		{
			dsp_delete_pos = data_search_path.size();
			data_search_path.push_back(default_data_dir);
		}
		data_search_path.push_back(local_data_dir);
	}
	
	// Subdirectories
#if defined(__MACH__) && defined(__APPLE__)
	DirectorySpecifier legacy_preferences_dir = local_data_dir;
#else
	preferences_dir = local_data_dir;
#endif	
	saved_games_dir = local_data_dir + "Saved Games";
	quick_saves_dir = local_data_dir + "Quick Saves";
	image_cache_dir = local_data_dir + "Image Cache";
	recordings_dir = local_data_dir + "Recordings";
	screenshots_dir = local_data_dir + "Screenshots";
	
	DirectorySpecifier local_mml_dir = local_data_dir + "MML";
	DirectorySpecifier local_themes_dir = local_data_dir + "Themes";
	
	// Setup resource manager
	initialize_resources();
	
	init_physics_wad_data();
	initialize_fonts(false);
	
	load_film_profile(FILM_PROFILE_DEFAULT, false);
	
	// Parse MML files
	LoadBaseMMLScripts();
	
	// Check for presence of strings
	if (!TS_IsPresent(strERRORS) || !TS_IsPresent(strFILENAMES)) {
		fprintf(stderr, "Can't find required text strings (missing MML?).\n");
		exit(1);
	}
	
	// Check for presence of files (one last chance to change data_search_path)
	if (!have_default_files()) {
		char chosen_dir[256];
		if (alert_choose_scenario(chosen_dir)) {
			// remove original argument (or fallback) from search path
			if (dsp_delete_pos < data_search_path.size())
				data_search_path.erase(data_search_path.begin() + dsp_delete_pos);
			// add selected directory where command-line argument would go
			data_search_path.insert(data_search_path.begin() + dsp_insert_pos, chosen_dir);
			
			default_data_dir = chosen_dir;
			
			// Parse MML files again, now that we have a new dir to search
			initialize_fonts(false);
			LoadBaseMMLScripts();
		}
	}
	
	initialize_fonts(true);
	Plugins::instance()->enumerate();
	
	// Load preferences
	initialize_preferences();
	
	local_data_dir.CreateDirectory();
	saved_games_dir.CreateDirectory();
	quick_saves_dir.CreateDirectory();
	{
		std::string scen = Scenario::instance()->GetName();
		if (scen.length())
			scen.erase(std::remove_if(scen.begin(), scen.end(), char_is_not_filesafe), scen.end());
		if (!scen.length())
			scen = "Unknown";
		quick_saves_dir += scen;
		quick_saves_dir.CreateDirectory();
	}
	image_cache_dir.CreateDirectory();
	recordings_dir.CreateDirectory();
	screenshots_dir.CreateDirectory();
	local_mml_dir.CreateDirectory();
	local_themes_dir.CreateDirectory();
	
	WadImageCache::instance()->initialize_cache();
	graphics_preferences->screen_mode.fullscreen = true;
	write_preferences();
	
	Plugins::instance()->load_mml();
	
	//	SDL_WM_SetCaption(application_name, application_name);
	
	// #if defined(HAVE_SDL_IMAGE) && !(defined(__APPLE__) && defined(__MACH__))
	// 	SDL_WM_SetIcon(IMG_ReadXPMFromArray(const_cast<char**>(alephone_xpm)), 0);
	// #endif
	atexit(shutdown_application);
	
#if !defined(DISABLE_NETWORKING)
	// Initialize SDL_net
	if (SDLNet_Init () < 0) {
		fprintf (stderr, "Couldn't initialize SDL_net (%s)\n", SDLNet_GetError());
		exit(1);
	}
#endif
	
	if (TTF_Init() < 0) {
		fprintf (stderr, "Couldn't initialize SDL_ttf (%s)\n", TTF_GetError());
		exit(1);
	}
	HTTPClient::Init();
	
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	// Initialize everything
	mytm_initialize();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	//	initialize_fonts();
	SoundManager::instance()->Initialize(*sound_preferences);
	initialize_marathon_music_handler();
	initialize_keyboard_controller();
	// enter_mouse(-1);
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_gamma();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	alephone::Screen::instance()->Initialize(&graphics_preferences->screen_mode);
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_marathon();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_screen_drawing();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_dialogs();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_terminal_manager();
	initialize_shape_handler();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_fades();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	initialize_images_manager();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	load_environment_from_preferences();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	helperCheckCurrentContext();
	initialize_game_state();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
	helperCheckCurrentContext();
	// ccl
	printGLErrorL(__PRETTY_FUNCTION__, __LINE__);
}

static uint32 lastTimeThroughLoop = 0;

// Unlike the original, we just want to run one pass through.  Leave the scheduling to
// CADisplayLink
const uint32 TICKS_BETWEEN_EVENT_POLL = 167; // 6 Hz
void AlephOneMainLoop()
{
	uint32 last_event_poll = 0;
	short game_state;
	
	game_state = get_game_state();
	uint32 cur_time = SDL_GetTicks();
	bool yield_time = false;
	bool poll_event = false;
	
	switch (game_state) {
		case _game_in_progress:
		case _change_level:
			if (Console::instance()->input_active() || cur_time - last_event_poll >=
				TICKS_BETWEEN_EVENT_POLL) {
				poll_event = true;
				last_event_poll = cur_time;
			}
			else {
				SDL_PumpEvents (); // This ensures a responsive keyboard control
			}
			break;
			
		case _display_intro_screens:
		case _display_main_menu:
		case _display_chapter_heading:
		case _display_prologue:
		case _display_epilogue:
		case _begin_display_of_epilogue:
		case _display_credits:
		case _display_intro_screens_for_demo:
		case _display_quit_screens:
		case _displaying_network_game_dialogs:
			yield_time = interface_fade_finished();
			poll_event = true;
			break;
			
		case _close_game:
		case _switch_demo:
		case _revert_game:
			yield_time = poll_event = true;
			break;
	}
	
	if (poll_event) {
		global_idle_proc();
		
		while (true) {
			SDL_Event event;
			event.type = SDL_FIRSTEVENT;
			SDL_PollEvent(&event);
			yield_time = false;
			if (yield_time) {
				// The game is not in a "hot" state, yield time to other
				// processes by calling SDL_Delay() but only try for a maximum
				// of 30ms
				int num_tries = 0;
				while (event.type == SDL_FIRSTEVENT && num_tries < 3) {
					SDL_Delay(10);
					SDL_PollEvent(&event);
					num_tries++;
				}
				yield_time = false;
			}
			else if (event.type == SDL_FIRSTEVENT) {
				break;
			}
			
			process_event(event);
		}
	}
	
	execute_timer_tasks(SDL_GetTicks());
	idle_game_state(SDL_GetTicks());
	
#ifndef __MACOS__
	if (game_state == _game_in_progress &&
		!graphics_preferences->hog_the_cpu &&
		(TICKS_PER_SECOND - (SDL_GetTicks() - cur_time)) > 10) {
		SDL_Delay(1);
	}
#endif
	if ( cur_time - lastTimeThroughLoop > 1000 ) {
		// printf( "This time took %d ticks\n", SDL_GetTicks() - cur_time );
		lastTimeThroughLoop = cur_time;
	}
}

short get_level_number_from_user(void)
{	
	// Redraw main menu
	update_game_window();
	return NONE;
}

void dump_screen(void){}

void LoadBaseMMLScripts()
{
	vector <DirectorySpecifier>::const_iterator i = data_search_path.begin(), end = data_search_path.end();
	while (i != end) {
		DirectorySpecifier path = *i + "MML";
		_ParseMMLDirectory(path);
		path = *i + "Scripts";
		_ParseMMLDirectory(path);
		i++;
	}
}

const char *get_application_name(void)
{
	return application_name;
}

void process_event(const SDL_Event &event)
{
	switch (event.type) {
		case SDL_MOUSEMOTION:
			if (get_game_state() == _game_in_progress)
			{
				mouse_moved(event.motion.xrel, event.motion.yrel);
			}
			break;
		case SDL_MOUSEWHEEL:
			if (get_game_state() == _game_in_progress)
			{
				bool up = (event.wheel.y > 0);
#if SDL_VERSION_ATLEAST(2,0,4)
				if (event.wheel.direction == SDL_MOUSEWHEEL_FLIPPED)
					up = !up;
#endif
				mouse_scroll(up);
			}
			break;
		case SDL_MOUSEBUTTONDOWN:
			if (get_game_state() == _game_in_progress) 
			{
				if (!get_keyboard_controller_status())
				{
					hide_cursor();
					validate_world_window();
					set_keyboard_controller_status(true);
				}
				else
				{
					SDL_Event e2;
					memset(&e2, 0, sizeof(SDL_Event));
					e2.type = SDL_KEYDOWN;
					e2.key.keysym.sym = SDLK_UNKNOWN;
					e2.key.keysym.scancode = (SDL_Scancode)(AO_SCANCODE_BASE_MOUSE_BUTTON + event.button.button - 1);
					//					process_game_key(e2);
				}
			}
			else
				;//	process_screen_click(event);
			break;
			
		case SDL_JOYBUTTONDOWN:
			if (get_game_state() == _game_in_progress)
			{
				SDL_Event e2;
				memset(&e2, 0, sizeof(SDL_Event));
				e2.type = SDL_KEYDOWN;
				e2.key.keysym.sym = SDLK_UNKNOWN;
				; //e2.key.keysym.scancode = (SDL_Scancode)(AO_SCANCODE_BASE_JOYSTICK_BUTTON + event.button.button);
				; //process_game_key(e2);
				
			}
			break;
			
		case SDL_KEYDOWN:
			; //process_game_key(event);
			break;
			
		case SDL_TEXTINPUT:
			if (Console::instance()->input_active()) {
				Console::instance()->textEvent(event);
			}
			break;
			
		case SDL_QUIT:
			set_game_state(_quit_game);
			break;
			
		case SDL_WINDOWEVENT:
			switch (event.window.event) {
				case SDL_WINDOWEVENT_FOCUS_LOST:
					if (get_game_state() == _game_in_progress && get_keyboard_controller_status() && !Movie::instance()->IsRecording()) {
						darken_world_window();
						set_keyboard_controller_status(false);
						show_cursor();
					}
					break;
				case SDL_WINDOWEVENT_EXPOSED:
#if !defined(__APPLE__) && !defined(__MACH__) // double buffering :)
#ifdef HAVE_OPENGL
					if (MainScreenIsOpenGL())
						MainScreenSwap();
					else
#endif
						update_game_window();
#endif
					break;
			}
			break;
	}
	
}

@end
