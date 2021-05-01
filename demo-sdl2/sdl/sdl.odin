package sdl

import "core:os"

when os.OS == "windows" do foreign import lib "SDL2.lib";
when os.OS == "linux" do foreign import lib "system:SDL2";
when os.OS == "darwin" do foreign import lib "system:SDL2";

@(default_calling_convention="c")
foreign lib {
	// This one is missing from my source of SDL2 ???
	//@(link_name="SDL_DYNAPI_entry") // dynapi_entry :: proc() ->																																										 ---;

	// The source for this one says you should never call it directly, but rather use the macros provided. Need to port those over still
	//@(link_name="SDL_ReportAssertion") //report_assertion :: proc() ->																																										 ---;

	@(link_name="SDL_AddEventWatch") add_event_watch :: proc(filter: Event_Filter, userdata: rawptr)																													---;
	@(link_name="SDL_AddHintCallback") add_hint_callback :: proc(name: cstring, callback: Hint_Callback, userdata: rawptr)  																									---;
	@(link_name="SDL_AddTimer") add_timer :: proc(interval: u32, callback: Timer_Callback, param: rawptr) -> Timer_Id																						---;
	@(link_name="SDL_AllocFormat") alloc_format :: proc(pixel_format: u32) -> ^Pixel_Format																														---;
	@(link_name="SDL_AllocPalette") alloc_palette :: proc(ncolors: i32) -> ^Palette																																---;
	@(link_name="SDL_AllocRW") alloc_rw :: proc() -> ^Rw_Ops 																																			---;
	@(link_name="SDL_AtomicAdd") atomic_add :: proc(a: ^Atomic, v: i32) -> i32																																---;
	@(link_name="SDL_AtomicCAS") atomic_cas :: proc(a: ^Atomic, oldval: i32, newval: i32) -> Bool																											---;
	@(link_name="SDL_AtomicCASPtr") atomic_cas_ptr :: proc(a: ^rawptr, oldval: rawptr, newval: rawptr) -> Bool																										---;
	@(link_name="SDL_AtomicGet") atomic_get :: proc(a: ^Atomic) -> i32																																		---;
	@(link_name="SDL_AtomicGetPtr") atomic_get_ptr :: proc(a: ^rawptr) -> rawptr																																	---;
	@(link_name="SDL_AtomicLock") atomic_lock :: proc(lock: ^Spin_Lock)																																		---;
	@(link_name="SDL_AtomicSet") atomic_set :: proc(a: ^Atomic, v: i32) -> i32																																---;
	@(link_name="SDL_AtomicSetPtr") atomic_set_ptr :: proc(a: ^rawptr, v: rawptr) -> rawptr																														---;
	@(link_name="SDL_AtomicTryLock") atomic_try_lock :: proc(lock: ^Spin_Lock) -> Bool																																---;
	@(link_name="SDL_AtomicUnlock") atomic_unlock :: proc(lock: ^Spin_Lock)																																		---;
	@(link_name="SDL_AudioInit") audio_init :: proc(driver_name: cstring) -> i32																																---;
	@(link_name="SDL_AudioQuit") audio_quit :: proc()																																						---;
	@(link_name="SDL_BuildAudioCVT") build_audio_cvt :: proc(cvt: ^Audio_Cvt, src_format: Audio_Format, src_channels: u8, src_rate: i32, dst_format: Audio_Format, dst_channels: u8, dst_rate: i32) -> i32			---;
	@(link_name="SDL_CalculateGammaRamp") calculate_gamma_ramp :: proc(gamma: f32, ramp: ^u16)																																	---;
	@(link_name="SDL_CaptureMouse") capture_mouse :: proc(enabled: Bool) -> i32																																	---;
	@(link_name="SDL_ClearError") clear_error :: proc()																																						---;
	@(link_name="SDL_ClearHints") clear_hints :: proc()																																						---;
	@(link_name="SDL_ClearQueuedAudio") clear_queued_audio :: proc(dev: Audio_Device)																																		---;
	@(link_name="SDL_CloseAudio") close_audio :: proc()																																						---;
	@(link_name="SDL_CloseAudioDevice") close_audio_device :: proc(dev: Audio_Device)																																		---;
	@(link_name="SDL_CondBroadcast") cond_broadcast :: proc(cond: ^Cond) -> i32																																		---;
	@(link_name="SDL_CondSignal") cond_signal :: proc(cond: ^Cond) -> i32																																		---;
	@(link_name="SDL_CondWait") cond_wait :: proc(cond: ^Cond, mutex: ^Mutex) -> i32																														---;
	@(link_name="SDL_CondWaitTimeout") cond_wait_timeout :: proc(cond: ^Cond, mutex: ^Mutex, ms: u32) -> i32																												---;
	@(link_name="SDL_ConvertAudio") convert_audio :: proc(cvt: ^Audio_Cvt) -> i32																																	---;
	@(link_name="SDL_ConvertPixels") convert_pixels :: proc(width: i32, height: i32, src_format: u32, src: rawptr, src_pitch: i32, dst_format: u32, dst: rawptr, dst_pitch: i32) -> i32								---;
	@(link_name="SDL_ConvertSurface") convert_surface :: proc(src: ^Surface, fmt: ^Pixel_Format, flags: u32) -> ^Surface																								---;
	@(link_name="SDL_ConvertSurfaceFormat") convert_surface_format :: proc(src: ^Surface, pixel_format: u32, flags: u32) -> ^Surface																								---;
	@(link_name="SDL_CreateColorCursor") create_color_cursor :: proc(surface: ^Surface, hot_x, hot_y: i32) -> ^Cursor																										---;
	@(link_name="SDL_CreateCond") create_cond :: proc() -> ^Cond																																				---;
	@(link_name="SDL_CreateCursor") create_cursor :: proc(data: ^u8, mask: ^u8, w, h: i32, hot_x, hot_y: i32) -> ^Cursor																							---;
	@(link_name="SDL_CreateMutex") create_mutex :: proc() -> ^Mutex																																				---;
	@(link_name="SDL_CreateRGBSurface") create_rgb_surface :: proc(flags: u32, width, height, depth: i32, Rmask, Gmask, Bmask, Amask: u32) -> ^Surface																		---;
	@(link_name="SDL_CreateRGBSurfaceFrom") create_rgb_surface_from :: proc(pixels: rawptr, width, height, depth, pitch: i32, Rmask, Gmask, Bmask, Amask: u32) -> ^Surface															---;
	@(link_name="SDL_CreateRGBSurfaceWithFormat") create_rgb_surface_with_format :: proc(flags: u32, width, height, depth: i32, format: u32) -> ^Surface																							---;
	@(link_name="SDL_CreateRGBSurfaceWithFormatFrom") create_rgb_surface_with_format_from :: proc(pixels: rawptr, width, height, depth, pitch: i32, format: u32) -> ^Surface																				---;
	@(link_name="SDL_CreateRenderer") create_renderer :: proc(window: ^Window, index: i32, flags: Renderer_Flags) -> ^Renderer																						---;
	@(link_name="SDL_CreateSemaphore") create_semaphore :: proc(initial_value: u32) -> ^Sem																																---;
	@(link_name="SDL_CreateShapedWindow") create_shaped_window :: proc(title: cstring, x, y, w, h: u32, flags: Window_Flags) -> ^Window																							---;
	@(link_name="SDL_CreateSoftwareRenderer") create_software_renderer :: proc(surface: ^Surface) -> ^Renderer																															---;
	@(link_name="SDL_CreateSystemCursor") create_system_cursor :: proc(id: System_Cursor) -> ^Cursor																															---;
	@(link_name="SDL_CreateTexture") create_texture :: proc(renderer: ^Renderer, format: u32, access: i32, w, h: i32) -> ^Texture																					---;
	@(link_name="SDL_CreateTextureFromSurface") create_texture_from_surface :: proc(renderer: ^Renderer, surface: ^Surface) -> ^Texture																										---;
	@(link_name="SDL_CreateThread") create_thread :: proc(fn: Thread_Function, name: cstring, data: rawptr) -> ^Thread 																								---;
	@(link_name="SDL_CreateWindow") create_window :: proc(title: cstring, x, y, w, h: i32, flags: Window_Flags) -> ^Window																							---;
	@(link_name="SDL_CreateWindowAndRenderer") create_window_and_renderer :: proc(width, height: i32, window_flags: Window_Flags, window: ^^Window, renderer: ^^Renderer) -> i32															---;
	@(link_name="SDL_CreateWindowFrom") create_window_from :: proc(data: rawptr) -> ^Window																																---;
	@(link_name="SDL_DXGIGetOutputInfo") dxgi_get_output_info :: proc(display_index: i32, adapter_index: ^i32, output_index: ^i32) -> Bool																					---;
	@(link_name="SDL_DelEventWatch") del_event_watch :: proc(filter: Event_Filter, userdata: rawptr)																													---;
	@(link_name="SDL_DelHintCallback") del_hint_callback :: proc(name: cstring, callback: Hint_Callback, userdata: rawptr)																									---;
	@(link_name="SDL_Delay") delay :: proc(ms: u32)																																				---;
	@(link_name="SDL_DequeueAudio") dequeue_audio :: proc(dev: Audio_Device_Id, data: rawptr, len: u32) -> u32																									---;
	@(link_name="SDL_DestroyCond") destroy_cond :: proc(cond: ^Cond)																																			---;
	@(link_name="SDL_DestroyMutex") destroy_mutex :: proc(mutex: ^Mutex)																																			---;
	@(link_name="SDL_DestroyRenderer") destroy_renderer :: proc(renderer: ^Renderer)																																	---;
	@(link_name="SDL_DestroySemaphore") destroy_semaphore :: proc(sem: ^Sem)																																				---;
	@(link_name="SDL_DestroyTexture") destroy_texture :: proc(texture: ^Texture)																																		---;
	@(link_name="SDL_DestroyWindow") destroy_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_DetachThread") detach_thread :: proc(thread: ^Thread)																																		---;
	@(link_name="SDL_Direct3D9GetAdapterIndex") direct_3d9_get_adapter_index :: proc(display_index: i32) -> i32																																---;
	@(link_name="SDL_DisableScreenSaver") disable_screen_saver :: proc()																																						---;
	@(link_name="SDL_EnableScreenSaver") enable_screen_saver :: proc()																																						---;
	@(link_name="SDL_EnclosePoints") enclose_points :: proc(points: ^Point, count: i32, clip: ^Rect, result: ^Rect) -> Bool																							---;
	@(link_name="SDL_Error") error :: proc(code: Error_Code) -> i32																																---;
	@(link_name="SDL_EventState") event_state :: proc(event_type: u32, state: i32) -> u8																														---;
	@(link_name="SDL_FillRect") fill_rect :: proc(dst: ^Surface, rect: ^Rect, color: u32) -> i32																											---;
	@(link_name="SDL_FillRects") fill_rects :: proc(dst: ^Surface, rect: ^Rect, count: i32, color: u32) -> i32																								---;
	@(link_name="SDL_FilterEvents") filter_events :: proc(filter: Event_Filter, userdata: rawptr)																													---;
	@(link_name="SDL_FlushEvent") flush_event :: proc(event_type: u32)																																		---;
	@(link_name="SDL_FlushEvents") flush_events :: proc(min_type: u32, max_type: u32)																															---;
	@(link_name="SDL_FreeCursor") free_cursor :: proc(cursor: ^Cursor)																																		---;
	@(link_name="SDL_FreeFormat") free_format :: proc(format: ^Pixel_Format)																																	---;
	@(link_name="SDL_FreePalette") free_palette :: proc(palette: ^Palette)																																		---;
	@(link_name="SDL_FreeRW") free_rw :: proc(area: ^Rw_Ops)																																			---;
	@(link_name="SDL_FreeSurface") free_surface :: proc(surface: ^Surface)																																		---;
	@(link_name="SDL_FreeWAV") free_wav :: proc(audio_buf: ^u8)																																			---;
	@(link_name="SDL_GL_BindTexture") gl_bind_texture :: proc(texture: ^Texture, texw, texh: ^f32) -> i32																												---;
	@(link_name="SDL_GL_CreateContext") gl_create_context :: proc(window: ^Window) -> GL_Context																															---;
	@(link_name="SDL_GL_DeleteContext") gl_delete_context :: proc(gl_context: GL_Context)																																	---;
	@(link_name="SDL_GL_ExtensionSupported") gl_extension_supported :: proc(extension: cstring) -> Bool																																	---;
	@(link_name="SDL_GL_GetAttribute") gl_get_attribute :: proc(attr: GL_Attr, value: ^i32) -> i32																														---;
	@(link_name="SDL_GL_GetCurrentContext") gl_get_current_context :: proc() -> GL_Context																																			---;
	@(link_name="SDL_GL_GetCurrentWindow") gl_get_current_window :: proc() -> ^Window																																			---;
	@(link_name="SDL_GL_GetDrawableSize") gl_get_drawable_size :: proc(window: ^Window, w, h: ^i32)																															---;
	@(link_name="SDL_GL_GetProcAddress") gl_get_proc_address :: proc(name: cstring) -> rawptr																																	---;
	@(link_name="SDL_GL_GetSwapInterval") gl_get_swap_interval :: proc() -> i32																																				---;
	@(link_name="SDL_GL_LoadLibrary") gl_load_library :: proc(path: cstring) -> i32																																		---;
	@(link_name="SDL_GL_MakeCurrent") gl_make_current :: proc(window: ^Window, gl_context: GL_Context) -> i32																											---;
	@(link_name="SDL_GL_ResetAttributes") gl_reset_attributes :: proc()																																						---;
	@(link_name="SDL_GL_SetAttribute") gl_set_attribute :: proc(attr: GL_Attr, value: i32) -> i32																														---;
	@(link_name="SDL_GL_SetSwapInterval") gl_set_swap_interval :: proc(interval: i32) -> i32																																	---;
	@(link_name="SDL_GL_SwapWindow") gl_swap_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_GL_UnbindTexture") gl_unbind_texture :: proc(texture: ^Texture) -> i32																																---;
	@(link_name="SDL_GL_UnloadLibrary") gl_unload_library :: proc()																																						---;
	@(link_name="SDL_GameControllerAddMapping") game_controller_add_mapping :: proc(mapping_string: cstring) -> i32																																---;
	@(link_name="SDL_GameControllerAddMappingsFromRW") game_controller_add_mappings_from_rw :: proc(area: ^Rw_Ops, freerw: i32) -> i32																														---;
	@(link_name="SDL_GameControllerClose") game_controller_close :: proc(game_controller: ^Game_Controller)																														---;
	@(link_name="SDL_GameControllerEventState") game_controller_event_state :: proc(state: i32) -> i32																																		---;
	@(link_name="SDL_GameControllerFromInstanceID") game_controller_from_instance_id :: proc(joy_id: Joystick_Id) ->	^Game_Controller																												---;
	@(link_name="SDL_GameControllerGetAttached") game_controller_get_attached :: proc(game_controller: ^Game_Controller) -> Bool																												---;
	@(link_name="SDL_GameControllerGetAxis") game_controller_get_axis :: proc(game_controller: ^Game_Controller, axis: Game_Controller_Axis) -> i16																					---;
	@(link_name="SDL_GameControllerGetAxisFromString") game_controller_get_axis_from_string :: proc(pch_string: cstring) -> cstring																																	---;
	@(link_name="SDL_GameControllerGetBindForAxis") game_controller_get_bind_for_axis :: proc(game_controller: ^Game_Controller, axis: Game_Controller_Axis) -> Game_Controller_Button_Bind															---;
	@(link_name="SDL_GameControllerGetBindForButton") game_controller_get_bind_for_button :: proc(game_controller: ^Game_Controller, button: Game_Controller_Button) -> Game_Controller_Button_Bind														---;
	@(link_name="SDL_GameControllerGetButton") game_controller_get_button :: proc(game_controller: ^Game_Controller, button: Game_Controller_Button) -> u8																				---;
	@(link_name="SDL_GameControllerGetButtonFromString") game_controller_get_button_from_string :: proc(pch_string: cstring) -> Game_Controller_Button																												---;
	@(link_name="SDL_GameControllerGetJoystick") game_controller_get_joystick :: proc(game_controller: ^Game_Controller) -> ^Joystick																											---;
	@(link_name="SDL_GameControllerGetStringForAxis") game_controller_get_string_for_axis :: proc(axis: Game_Controller_Axis) -> cstring																														---;
	@(link_name="SDL_GameControllerGetStringForButton") game_controller_get_string_for_button :: proc(button: Game_Controller_Button) -> cstring																													---;
	@(link_name="SDL_GameControllerMapping") game_controller_mapping :: proc(game_controller: ^Game_Controller) -> cstring																												---;
	@(link_name="SDL_GameControllerMappingForGUID") game_controller_mapping_for_guid :: proc(guid: Joystick_Guid) -> cstring																																---;
	@(link_name="SDL_GameControllerName") game_controller_name :: proc(game_controller: ^Game_Controller) -> cstring																												---;
	@(link_name="SDL_GameControllerNameForIndex") game_controller_name_for_index :: proc(joystick_index: i32) -> cstring																																---;
	@(link_name="SDL_GameControllerOpen") game_controller_open :: proc(joystick_index: i32) -> ^Game_Controller																												---;
	@(link_name="SDL_GameControllerUpdate") game_controller_update :: proc()																																						---;
	@(link_name="SDL_GetAssertionHandler") get_assertion_handler :: proc(userdata: ^rawptr) -> Assertion_Handler																													---;
	@(link_name="SDL_GetAssertionReport") get_assertion_report :: proc() -> ^Assert_Data																																		---;
	@(link_name="SDL_GetAudioDeviceName") get_audio_device_name :: proc(index: i32, iscapture: i32) -> cstring																														---;
	@(link_name="SDL_GetAudioDeviceStatus") get_audio_device_status :: proc(dev: Audio_Device_Id) -> Audio_Status																													---;
	@(link_name="SDL_GetAudioDriver") get_audio_driver :: proc(index: i32) -> cstring																																		---;
	@(link_name="SDL_GetAudioStatus") get_audio_status :: proc() -> Audio_Status																																		---;
	@(link_name="SDL_GetBasePath") get_base_path :: proc() -> cstring																																				---;
	@(link_name="SDL_GetCPUCacheLineSize") get_cpu_cache_line_size :: proc() -> i32																																				---;
	@(link_name="SDL_GetCPUCount") get_cpu_count :: proc() -> i32																																				---;
	@(link_name="SDL_GetClipRect") get_clip_rect :: proc(surface: ^Surface, rect: ^Rect)																															---;
	@(link_name="SDL_GetClipboardText") get_clipboard_text :: proc() -> cstring																																				---;
	@(link_name="SDL_GetClosestDisplayMode") get_closest_display_mode :: proc(display_index: i32, mode: ^Display_Mode, closest: ^Display_Mode) -> ^Display_Mode																		---;
	@(link_name="SDL_GetColorKey") get_color_key :: proc(surface: ^Surface, key: ^u32) -> i32																													---;
	@(link_name="SDL_GetCurrentAudioDriver") get_current_audio_driver :: proc() -> cstring																																				---;
	@(link_name="SDL_GetCurrentDisplayMode") get_current_display_mode :: proc(display_index: i32, mode: ^Display_Mode) -> i32																											---;
	@(link_name="SDL_GetCurrentVideoDriver") get_current_video_driver :: proc() -> cstring																																				---;
	@(link_name="SDL_GetCursor") get_cursor :: proc() -> ^Cursor																																			---;
	@(link_name="SDL_GetDefaultAssertionHandler") get_default_assertion_handler :: proc() -> Assertion_Handler																																	---;
	@(link_name="SDL_GetDefaultCursor") get_default_cursor :: proc() -> ^Cursor																																			---;
	@(link_name="SDL_GetDesktopDisplayMode") get_desktop_display_mode :: proc(display_index: i32, mode: ^Display_Mode) -> i32																											---;
	@(link_name="SDL_GetDisplayBounds") get_display_bounds :: proc(display_index: i32, rect: ^Rect) -> i32																													---;
	@(link_name="SDL_GetDisplayDPI") get_display_dpi :: proc(display_index: i32, ddpi, hdpi, vdpi: ^f32) -> i32																										---;
	@(link_name="SDL_GetDisplayMode") get_display_mode :: proc(display_index: i32, mode_index: i32, mode: ^Display_Mode) -> i32																						---;
	@(link_name="SDL_GetDisplayName") get_display_name :: proc(display_index: i32) -> cstring																																---;
	@(link_name="SDL_GetDisplayUsableBounds") get_display_usable_bounds :: proc(display_index: i32, rect: ^Rect) -> i32																													---;
	@(link_name="SDL_GetError") get_error :: proc() -> cstring																																				---;
	@(link_name="SDL_GetEventFilter") get_event_filter :: proc(filter: ^Event_Filter, userdata: ^rawptr) -> Bool																										---;
	@(link_name="SDL_GetGlobalMouseState") get_global_mouse_state :: proc(x, y: ^i32) -> u32																																		---;
	@(link_name="SDL_GetGrabbedWindow") get_grabbed_window :: proc() -> ^Window																																			---;
	@(link_name="SDL_GetHint") get_hint :: proc(name: cstring) -> cstring																																		---;
	@(link_name="SDL_GetHintBoolean") get_hint_boolean :: proc(name: cstring, default_value: Bool) -> Bool																													---;
	@(link_name="SDL_GetKeyFromName") get_key_from_name :: proc(name: cstring) -> Keycode																																	---;
	@(link_name="SDL_GetKeyFromScancode") get_key_from_scancode :: proc(scancode: Scancode) -> Keycode																															---;
	@(link_name="SDL_GetKeyName") get_key_name :: proc(key: Keycode) -> cstring																																	---;
	@(link_name="SDL_GetKeyboardFocus") get_keyboard_focus :: proc() -> ^Window																																			---;
	@(link_name="SDL_GetKeyboardState") get_keyboard_state :: proc(numkeys: ^i32) -> ^u8																																	---;
	@(link_name="SDL_GetModState") get_mod_state :: proc() -> Keymod																																				---;
	@(link_name="SDL_GetMouseFocus") get_mouse_focus :: proc() -> ^Window																																			---;
	@(link_name="SDL_GetMouseState") get_mouse_state :: proc(x, y: ^i32) -> u32																																		---;
	@(link_name="SDL_GetNumAudioDevices") get_num_audio_devices :: proc(iscapture: i32) -> i32																																	---;
	@(link_name="SDL_GetNumAudioDrivers") get_num_audio_drivers :: proc() -> i32																																				---;
	@(link_name="SDL_GetNumDisplayModes") get_num_display_modes :: proc(display_index: i32) -> i32																																---;
	@(link_name="SDL_GetNumRenderDrivers") get_num_render_drivers :: proc() -> i32																																				---;
	@(link_name="SDL_GetNumTouchDevices") get_num_touch_devices :: proc() -> i32																																				---;
	@(link_name="SDL_GetNumTouchFingers") get_num_touch_fingers :: proc(touch_id: Touch_Id) -> i32																																---;
	@(link_name="SDL_GetNumVideoDisplays") get_num_video_displays :: proc() -> i32																																				---;
	@(link_name="SDL_GetNumVideoDrivers") get_num_video_drivers :: proc() -> i32																																				---;
	@(link_name="SDL_GetPerformanceCounter") get_performance_counter :: proc() -> u64																																				---;
	@(link_name="SDL_GetPerformanceFrequency") get_performance_frequency :: proc() -> u64																																				---;
	@(link_name="SDL_GetPixelFormatName") get_pixel_format_name :: proc(format: u32) -> cstring																																		---;
	@(link_name="SDL_GetPlatform") get_platform :: proc() -> cstring																																				---;
	@(link_name="SDL_GetPowerInfo") get_power_info :: proc(secs, pct: ^i32) -> Power_State																															---;
	@(link_name="SDL_GetPrefPath") get_pref_path :: proc(org, app: cstring) -> cstring																																	---;
	@(link_name="SDL_GetQueuedAudioSize") get_queued_audio_size :: proc(dev: Audio_Device_Id) -> u32																															---;
	@(link_name="SDL_GetRGB") get_rgb :: proc(pixel: u32, format: ^Pixel_Format, r, g, b: ^u8)																										---;
	@(link_name="SDL_GetRGBA") get_rgba :: proc(pixel: u32, format: ^Pixel_Format, r, g, b, a: ^u8)																										---;
	@(link_name="SDL_GetRelativeMouseMode") get_relative_mouse_mode :: proc() -> Bool																																				---;
	@(link_name="SDL_GetRelativeMouseState") get_relative_mouse_state :: proc(x, y: ^i32) -> u32																																		---;
	@(link_name="SDL_GetRenderDrawBlendMode") get_render_draw_blend_mode :: proc(renderer: ^Renderer, blend_mode: ^Blend_Mode) -> i32																									---;
	@(link_name="SDL_GetRenderDrawColor") get_render_draw_color :: proc(renderer: ^Renderer, r, g, b, a: ^u8) -> i32																											---;
	@(link_name="SDL_GetRenderDriverInfo") get_render_driver_info :: proc(index: i32, info: ^Renderer_Info) -> i32																												---;
	@(link_name="SDL_GetRenderTarget") get_render_target :: proc(renderer: ^Renderer) -> ^Texture																														---;
	@(link_name="SDL_GetRenderer") get_renderer :: proc(window: ^Window) -> ^Renderer																															---;
	@(link_name="SDL_GetRendererInfo") get_renderer_info :: proc(renderer: ^Renderer, info: ^Renderer_Info) -> i32																										---;
	@(link_name="SDL_GetRendererOutputSize") get_renderer_output_size :: proc(renderer: ^Renderer, w, h: ^i32) -> i32																													---;
	@(link_name="SDL_GetRevision") get_revision :: proc() -> cstring																																				---;
	@(link_name="SDL_GetRevisionNumber") get_revision_number :: proc() -> i32																																				---;
	@(link_name="SDL_GetScancodeFromKey") get_scancode_from_key :: proc(key: Keycode) -> Scancode																																---;
	@(link_name="SDL_GetScancodeFromName") get_scancode_from_name :: proc(name: cstring) -> Scancode																																	---;
	@(link_name="SDL_GetScancodeName") get_scancode_name :: proc(scancode: Scancode) -> cstring																																---;
	@(link_name="SDL_GetShapedWindowMode") get_shaped_window_mode :: proc(window: ^Window, shape_mode: ^Window_Shape_Mode) -> i32																									---;
	@(link_name="SDL_GetSurfaceAlphaMod") get_surface_alpha_mod :: proc(surface: ^Surface, alpha: ^u8) -> i32																													---;
	@(link_name="SDL_GetSurfaceBlendMode") get_surface_blend_mode :: proc(surface: ^Surface, blend_mode: ^Blend_Mode) -> i32																										---;
	@(link_name="SDL_GetSurfaceColorMod") get_surface_color_mod :: proc(surface: ^Surface, r, g, b: ^u8) -> i32																													---;
	@(link_name="SDL_GetSystemRAM") get_system_ram :: proc() -> i32																																				---;
	@(link_name="SDL_GetTextureAlphaMod") get_texture_alpha_mod :: proc(texture: ^Texture, alpha: ^u8) -> i32																													---;
	@(link_name="SDL_GetTextureBlendMode") get_texture_blend_mode :: proc(texture: ^Texture, blend_mode: ^Blend_Mode) -> i32																										---;
	@(link_name="SDL_GetTextureColorMod") get_texture_color_mod :: proc(texture: ^Texture, r, g, b: ^u8) -> i32																													---;
	@(link_name="SDL_GetThreadID") get_thread_id :: proc(thread: ^Thread) -> Thread_Id																															---;
	@(link_name="SDL_GetThreadName") get_thread_name :: proc(thread: ^Thread) -> cstring																																	---;
	@(link_name="SDL_GetTicks") get_ticks :: proc() -> u32																																				---;
	@(link_name="SDL_GetTouchDevice") get_touch_device :: proc(index: i32) -> Touch_Id																																	---;
	@(link_name="SDL_GetTouchFinger") get_touch_finger :: proc(touch_id: Touch_Id, index: i32) -> ^Finger																												---;
	@(link_name="SDL_GetVersion") get_version :: proc(ver: ^Version)																																			---;
	@(link_name="SDL_GetVideoDriver") get_video_driver :: proc(index: i32) -> cstring																																		---;
	@(link_name="SDL_GetWindowBordersSize") get_window_borders_size :: proc(window: ^Window, top, left, bottom, right: ^i32) -> i32																									---;
	@(link_name="SDL_GetWindowBrightness") get_window_brightness :: proc(window: ^Window) -> f32																																	---;
	@(link_name="SDL_GetWindowData") get_window_data :: proc(window: ^Window, name: cstring) -> rawptr																													---;
	@(link_name="SDL_GetWindowDisplayIndex") get_window_display_index :: proc(window: ^Window) -> i32																																	---;
	@(link_name="SDL_GetWindowDisplayMode") get_window_display_mode :: proc(window: ^Window, mode: ^Display_Mode) -> i32																											---;
	@(link_name="SDL_GetWindowFlags") get_window_flags :: proc(window: ^Window) -> u32																																	---;
	@(link_name="SDL_GetWindowFromID") get_window_fromid :: proc(id: u32) -> ^Window																																		---;
	@(link_name="SDL_GetWindowGammaRamp") get_window_gammaramp :: proc(window: ^Window, r, g, b: u16) -> i32																													---;
	@(link_name="SDL_GetWindowGrab") get_window_grab :: proc(window: ^Window) -> Bool																																---;
	@(link_name="SDL_GetWindowID") get_window_id :: proc(window: ^Window) -> u32																																	---;
	@(link_name="SDL_GetWindowMaximumSize") get_window_maximum_size :: proc(window: ^Window, w, h: ^i32)																															---;
	@(link_name="SDL_GetWindowMinimumSize") get_window_minimum_size :: proc(window: ^Window, w, h: ^i32)																															---;
	@(link_name="SDL_GetWindowOpacity") get_window_opacity :: proc(window: ^Window, opacity: ^f32) -> i32																													---;
	@(link_name="SDL_GetWindowPixelFormat") get_window_pixel_format :: proc(window: ^Window) -> u32																																	---;
	@(link_name="SDL_GetWindowPosition") get_window_position :: proc(window: ^Window, x, y: ^i32)																															---;
	@(link_name="SDL_GetWindowSize") get_window_size :: proc(window: ^Window, w, h: ^i32)																															---;
	@(link_name="SDL_GetWindowSurface") get_window_surface :: proc(window: ^Window) -> ^Surface																															---;
	@(link_name="SDL_GetWindowTitle") get_window_title :: proc(window: ^Window) -> cstring																																	---;
	@(link_name="SDL_GetWindowWMInfo") get_window_wm_info :: proc(window: ^Window, info: ^Sys_Wm_Info) -> Bool																											---;
	@(link_name="SDL_HapticClose") haptic_close :: proc(haptic: ^Haptic)																																		---;
	@(link_name="SDL_HapticDestroyEffect") haptic_destroy_effect :: proc(haptic: ^Haptic, effect: i32)																															---;
	@(link_name="SDL_HapticEffectSupported") haptic_effect_supported :: proc(haptic: ^Haptic, effect: ^Haptic_Effect) -> i32																											---;
	@(link_name="SDL_HapticGetEffectStatus") haptic_get_effect_status :: proc(haptic: ^Haptic, effect: i32) -> i32																													---;
	@(link_name="SDL_HapticIndex") haptic_index :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticName") haptic_name :: proc(device_index: i32) -> cstring																																---;
	@(link_name="SDL_HapticNewEffect") haptic_new_effect :: proc(haptic: ^Haptic, effect: ^Haptic_Effect) -> i32																											---;
	@(link_name="SDL_HapticNumAxes") haptic_num_axes :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticNumEffects") haptic_num_effects :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticNumEffectsPlaying") haptic_num_effects_playing :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticOpen") haptic_open :: proc(device_index: i32) -> ^Haptic																															---;
	@(link_name="SDL_HapticOpenFromJoystick") haptic_open_from_joystick :: proc(joystick: ^Joystick) -> ^Haptic																															---;
	@(link_name="SDL_HapticOpenFromMouse") haptic_open_from_mouse :: proc() -> ^Haptic																																			---;
	@(link_name="SDL_HapticOpened") haptic_opened :: proc(device_index: i32) -> i32																																---;
	@(link_name="SDL_HapticPause") haptic_pause :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticQuery") haptic_query :: proc(haptic: ^Haptic) ->	u32																																	---;
	@(link_name="SDL_HapticRumbleInit") haptic_rumble_init :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticRumblePlay") haptic_rumble_play :: proc(haptic: ^Haptic, strength: f32, length: u32) -> i32																										---;
	@(link_name="SDL_HapticRumbleStop") haptic_rumble_stop :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticRumbleSupported") haptic_rumble_supported :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticRunEffect") haptic_run_effect :: proc(haptic: ^Haptic, effect: i32, iterations: u32) -> i32																									---;
	@(link_name="SDL_HapticSetAutocenter") haptic_set_autocenter :: proc(haptic: ^Haptic, autocenter: i32) -> i32																												---;
	@(link_name="SDL_HapticSetGain") haptic_set_gain :: proc(haptic: ^Haptic, gain: i32) -> i32																														---;
	@(link_name="SDL_HapticStopAll") haptic_stop_all :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticStopEffect") haptic_stop_effect :: proc(haptic: ^Haptic, effect: i32) -> i32																													---;
	@(link_name="SDL_HapticUnpause") haptic_unpause :: proc(haptic: ^Haptic) -> i32																																	---;
	@(link_name="SDL_HapticUpdateEffect") haptic_update_effect :: proc(haptic: ^Haptic, effect: i32, data: ^Haptic_Effect) -> i32																								---;
	@(link_name="SDL_Has3DNow") has_3d_now :: proc() -> Bool																																				---;
	@(link_name="SDL_HasAVX") has_avx :: proc() -> Bool																																				---;
	@(link_name="SDL_HasAVX2") has_avx2 :: proc() -> Bool																																				---;
	@(link_name="SDL_HasAltiVec") has_alti_vec :: proc() -> Bool																																				---;
	@(link_name="SDL_HasClipboardText") has_clipboard_text :: proc() -> Bool																																				---;
	@(link_name="SDL_HasEvent") has_event :: proc(event_type: u32) -> Bool																																---;
	@(link_name="SDL_HasEvents") has_events :: proc(min_type: u32, max_type: u32) -> Bool																													---;
	@(link_name="SDL_HasIntersection") has_intersection :: proc(a, b: ^Rect) -> Bool																																	---;
	@(link_name="SDL_HasMMX") has_mmx :: proc() -> Bool																																				---;
	@(link_name="SDL_HasRDTSC") has_rdtsc :: proc() -> Bool																																				---;
	@(link_name="SDL_HasSSE") has_sse :: proc() -> Bool																																				---;
	@(link_name="SDL_HasSSE2") has_sse2 :: proc() -> Bool																																				---;
	@(link_name="SDL_HasSSE3") has_sse3 :: proc() -> Bool																																				---;
	@(link_name="SDL_HasSSE41") has_sse41 :: proc() -> Bool																																				---;
	@(link_name="SDL_HasSSE42") has_sse42 :: proc() -> Bool																																				---;
	@(link_name="SDL_HasScreenKeyboardSupport") has_screen_keyboard_support :: proc() -> Bool																																				---;
	@(link_name="SDL_HideWindow") hide_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_Init") init :: proc(flags: Init_Flags) -> i32																																---;
	@(link_name="SDL_InitSubSystem") init_sub_system :: proc(flags: u32) -> i32																																		---;
	@(link_name="SDL_IntersectRect") intersect_rect :: proc(a, b, result: ^Rect) -> Bool																															---;
	@(link_name="SDL_IntersectRectAndLine") intersect_rect_and_line :: proc(rect: ^Rect, x1, y1, x2, y2: ^i32) -> Bool																												---;
	@(link_name="SDL_IsGameController") is_game_controller :: proc(joystick_index: i32) -> Bool																															---;
	@(link_name="SDL_IsScreenKeyboardShown") is_screen_keyboard_shown :: proc(window: ^Window) -> Bool																																---;
	@(link_name="SDL_IsScreenSaverEnabled") is_screen_saver_enabled :: proc() -> Bool																																				---;
	@(link_name="SDL_IsShapedWindow") is_shaped_window :: proc(window: Window) -> Bool																																	---;
	@(link_name="SDL_IsTextInputActive") is_text_input_active :: proc() -> Bool																																				---;
	@(link_name="SDL_JoystickClose") joystick_close :: proc(joystick: ^Joystick)																																	---;
	@(link_name="SDL_JoystickCurrentPowerLevel") joystick_current_power_level :: proc(joystick: ^Joystick) -> Joystick_Power_Level																											---;
	@(link_name="SDL_JoystickEventState") joystick_event_state :: proc(state: i32) -> i32																																		---;
	@(link_name="SDL_JoystickFromInstanceID") joystick_from_instance_id :: proc(joystick_id: ^Joystick_Id) -> ^Joystick																													---;
	@(link_name="SDL_JoystickGetAttached") joystick_get_attached :: proc(joystick: ^Joystick) -> Bool																															---;
	@(link_name="SDL_JoystickGetAxis") joystick_get_axis :: proc(joystick: ^Joystick, axis: i32) -> i16																													---;
	@(link_name="SDL_JoystickGetBall") joystick_get_ball :: proc(joystick: ^Joystick, ball: i32, dx, dy: ^i32) -> i32																									---;
	@(link_name="SDL_JoystickGetButton") joystick_get_button :: proc(joystick: ^Joystick, button: i32) -> u8																													---;
	@(link_name="SDL_JoystickGetDeviceGUID") joystick_get_device_guid :: proc(device_index: i32) -> Joystick_Guid																														---;
	@(link_name="SDL_JoystickGetGUID") joystick_get_guid :: proc(joystick: ^Joystick) -> Joystick_Guid																													---;
	@(link_name="SDL_JoystickGetGUIDFromString") joystick_get_guid_from_string :: proc(pch_guid: cstring) -> Joystick_Guid																															---;
	@(link_name="SDL_JoystickGetGUIDString") joystick_get_guid_string :: proc(guid: Joystick_Guid, psz_guid: ^u8, cb_guid: i32)																										---;
	@(link_name="SDL_JoystickGetHat") joystick_get_hat :: proc(joystick: ^Joystick, hat: i32) -> u8																													---;
	@(link_name="SDL_JoystickInstanceID") joystick_instance_id :: proc(joystick: ^Joystick) -> Joystick_Id																														---;
	@(link_name="SDL_JoystickIsHaptic") joystick_is_haptic :: proc(joystick: ^Joystick) -> i32																																---;
	@(link_name="SDL_JoystickName") joystick_name :: proc(joystick: ^Joystick) -> cstring																																---;
	@(link_name="SDL_JoystickNameForIndex") joystick_name_for_index :: proc(device_index: i32) -> cstring																																---;
	@(link_name="SDL_JoystickNumAxes") joystick_num_axes :: proc(joystick: ^Joystick) -> i32																																---;
	@(link_name="SDL_JoystickNumBalls") joystick_num_balls :: proc(joystick: ^Joystick) -> i32																																---;
	@(link_name="SDL_JoystickNumButtons") joystick_num_buttons :: proc(joystick: ^Joystick) ->	i32																																---;
	@(link_name="SDL_JoystickNumHats") joystick_num_hats :: proc(joystick: ^Joystick) -> i32 																															---;
	@(link_name="SDL_JoystickOpen") joystick_open :: proc(device_index: i32) -> ^Joystick																															---;
	@(link_name="SDL_JoystickUpdate") joystick_update :: proc()																																						---;
	@(link_name="SDL_LoadBMP_RW") load_bmp_rw :: proc(src: ^Rw_Ops, freerw: i32) -> ^Surface																													---;
	@(link_name="SDL_LoadDollarTemplates") load_dollar_templates :: proc(touch_id: Touch_Id, src: ^Rw_Ops) -> i32																												---;
	@(link_name="SDL_LoadFunction") load_function :: proc(handle: rawptr, name: cstring) -> rawptr																													---;
	@(link_name="SDL_LoadObject") load_object :: proc(sofile: cstring) -> cstring																																		---;
	@(link_name="SDL_LoadWAV_RW") load_wav_rw :: proc(src: ^Rw_Ops, freesrc: i32, spec: ^Audio_Spec, audio_buf: ^^u8, audio_len: ^u32) -> ^Audio_Spec															---;
	@(link_name="SDL_LockAudio") lock_audio :: proc()																																						---;
	@(link_name="SDL_LockAudioDevice") lock_audio_device :: proc(dev: Audio_Device_Id)																																	---;
	@(link_name="SDL_LockMutex") lock_mutex :: proc(mutex: ^Mutex) -> i32																																	---;
	@(link_name="SDL_LockSurface") lock_surface :: proc(surface: ^Surface) -> i32																																---;
	@(link_name="SDL_LockTexture") lock_texture :: proc(texture: ^Texture, rect: ^Rect, pixels: ^rawptr, pitch: ^i32) -> i32																					---;
	@(link_name="SDL_Log") log :: proc(fmt: ..cstring)																																			---;
	@(link_name="SDL_LogCritical") log_critical :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LogDebug") log_debug :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LogError") log_error :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LogGetOutputFunction") log_get_output_function :: proc(callback: ^Log_Output_Function, userdata: ^rawptr)																										---;
	@(link_name="SDL_LogGetPriority") log_get_priority :: proc(category: Log_Category) -> Log_Priority																															---;
	@(link_name="SDL_LogInfo") log_info :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LogMessage") log_message :: proc(category: Log_Category, priority: Log_Priority, fmt: ..cstring)																										---;
	@(link_name="SDL_LogMessageV") log_message_v :: proc(category: Log_Category, priority: Log_Priority, fmt: cstring, va_list: cstring)																							---;
	@(link_name="SDL_LogResetPriorities") log_reset_priorities :: proc()																																						---;
	@(link_name="SDL_LogSetAllPriority") log_set_all_priority :: proc(priority: Log_Priority)																																	---;
	@(link_name="SDL_LogSetOutputFunction") log_set_output_function :: proc(callback: Log_Output_Function, userdata: rawptr)																										---;
	@(link_name="SDL_LogSetPriority") log_set_priority :: proc(category: Log_Category, priority: Log_Priority)																													---;
	@(link_name="SDL_LogVerbose") log_verbose :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LogWarn") log_warn :: proc(category: Log_Category, fmt: ..cstring)																																---;
	@(link_name="SDL_LowerBlit") lower_blit :: proc(src: ^Surface, srcrect: ^Rect, dst: ^Surface, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_LowerBlitScaled") lower_blit_scaled :: proc(src: ^Surface, srcrect: ^Rect, dst: ^Surface, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_MapRGB") map_rgb :: proc(format: ^Pixel_Format, r, g, b: u8) -> u32																												---;
	@(link_name="SDL_MapRGBA") map_rgba :: proc(format: ^Pixel_Format, r, g, b, a: u8) -> u32																											---;
	@(link_name="SDL_MasksToPixelFormatEnum") masks_to_pixel_format_enum :: proc(bpp: i32, r_mask, g_mask, b_mask, a_mask: u32) -> u32																									---;
	@(link_name="SDL_MaximizeWindow") maximize_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_MinimizeWindow") minimize_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_MixAudio") mix_audio :: proc(dst, src: ^u8, len: u32, volume: i32)																													---;
	@(link_name="SDL_MixAudioFormat") mix_audio_format :: proc(dst, src: ^u8, format: Audio_Format, len: u32, volume: i32)																								---;
	@(link_name="SDL_MouseIsHaptic") mouse_is_haptic :: proc() -> i32																																				---;
	@(link_name="SDL_NumHaptics") num_haptics :: proc() -> i32																																				---;
	@(link_name="SDL_NumJoysticks") num_joysticks :: proc() -> i32																																				---;
	@(link_name="SDL_OpenAudio") open_audio :: proc(desired, obtained: ^Audio_Spec) -> i32																													---;
	@(link_name="SDL_OpenAudioDevice") open_audio_device :: proc(device: cstring, iscapture: i32, desired, obtained: ^Audio_Spec, allowed_changed: i32) -> Audio_Device_Id													---;
	@(link_name="SDL_PauseAudio") pause_audio :: proc(pause_on: i32)																																			---;
	@(link_name="SDL_PauseAudioDevice") pause_audio_device :: proc(dev: Audio_Device_Id, pause_on: i32)																													---;
	@(link_name="SDL_PeepEvents") peep_events :: proc(events: ^Event, num_events: i32, action: Event_Action, min_type, max_type: u32) -> i32																	---;
	@(link_name="SDL_PixelFormatEnumToMasks") pixel_format_enum_to_masks :: proc(format: u32, bpp: ^i32, r_mask, g_mask, b_mask, a_mask: ^u32) -> Bool																					---;
	@(link_name="SDL_PollEvent") poll_event :: proc(event: ^Event) -> i32																																	---;
	@(link_name="SDL_PumpEvents") pump_events :: proc()																																						---;
	@(link_name="SDL_PushEvent") push_event :: proc(event: ^Event) -> i32																																	---;
	@(link_name="SDL_QueryTexture") query_texture :: proc(texture: ^Texture, format: ^u32, access, w, h: ^i32) -> i32																								---;
	@(link_name="SDL_QueueAudio") queue_audio :: proc(dev: Audio_Device_Id, data: rawptr, len: u32) -> i32																									---;
	@(link_name="SDL_Quit") quit :: proc()																																						---;
	@(link_name="SDL_QuitSubSystem") quit_sub_system :: proc(flags: u32)																																				---;
	@(link_name="SDL_RaiseWindow") raise_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_ReadBE16") read_be16 :: proc(src: ^Rw_Ops) -> u16																																	---;
	@(link_name="SDL_ReadBE32") read_be32 :: proc(src: ^Rw_Ops) -> u32																																	---;
	@(link_name="SDL_ReadBE64") read_be64 :: proc(src: ^Rw_Ops) -> u64																																	---;
	@(link_name="SDL_ReadLE16") read_le16 :: proc(src: ^Rw_Ops) -> u16																																	---;
	@(link_name="SDL_ReadLE32") read_le32 :: proc(src: ^Rw_Ops) -> u32																																	---;
	@(link_name="SDL_ReadLE64") read_le64 :: proc(src: ^Rw_Ops) -> u64																																	---;
	@(link_name="SDL_ReadU8") read_u8 :: proc(src: ^Rw_Ops) -> u8																																		---;
	@(link_name="SDL_RecordGesture") record_gesture :: proc(touch_id: Touch_Id) -> i32																																---;
	@(link_name="SDL_RegisterApp") register_app :: proc(name: cstring, style: u32, h_inst: rawptr) -> i32																											---;
	@(link_name="SDL_RegisterEvents") register_events :: proc(num_events: i32) -> u32																																	---;
	@(link_name="SDL_RemoveTimer") remove_timer :: proc(id: Timer_Id) -> Bool																																	---;
	@(link_name="SDL_RenderClear") render_clear :: proc(renderer: ^Renderer) -> i32																																---;
	@(link_name="SDL_RenderCopy") render_copy :: proc(renderer: ^Renderer, texture: ^Texture, srcrect, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_RenderCopyEx") render_copy_ex :: proc(renderer: ^Renderer, texture: ^Texture, srcrect, dstrect: ^Rect, angle: f64, center: ^Point, flip: Renderer_Flip) -> i32								---;
	@(link_name="SDL_RenderDrawLine") render_draw_line :: proc(renderer: ^Renderer, x1, y1, x2, y2: i32) -> i32																										---;
	@(link_name="SDL_RenderDrawLines") render_draw_lines :: proc(renderer: ^Renderer, points: ^Point, count: i32) -> i32																									---;
	@(link_name="SDL_RenderDrawPoint") render_draw_point :: proc(renderer: ^Renderer, x, y: i32) -> i32																													---;
	@(link_name="SDL_RenderDrawPoints") render_draw_points :: proc(renderer: ^Renderer, points: ^Point, count: i32) -> i32																									---;
	@(link_name="SDL_RenderDrawRect") render_draw_rect :: proc(renderer: ^Renderer, rect: ^Rect) -> i32																												---;
	@(link_name="SDL_RenderDrawRects") render_draw_rects :: proc(renderer: ^Renderer, rects: ^Rect, count: i32) -> i32																									---;
	@(link_name="SDL_RenderFillRect") render_fill_rect :: proc(dst: ^Renderer, rect: ^Rect) -> i32																														---;
	@(link_name="SDL_RenderFillRects") render_fill_rects :: proc(dst: ^Renderer, rect: ^Rect, count: i32) -> i32																											---;
	@(link_name="SDL_RenderGetClipRect") render_get_clip_rect :: proc(surface: ^Surface, rect: ^Rect)																															---;
	@(link_name="SDL_RenderGetD3D9Device") render_get_d3d9_device :: proc(renderer: ^Renderer) ->	^IDirect3D_Device9																												---;
	@(link_name="SDL_RenderGetIntegerScale") render_get_integer_scale :: proc(renderer: ^Renderer) -> Bool																															---;
	@(link_name="SDL_RenderGetLogicalSize") render_get_logical_size :: proc(renderer: ^Renderer, w, h: ^i32)																														---;
	@(link_name="SDL_RenderGetScale") render_get_scale :: proc(renderer: ^Renderer, scale_x, scale_y: ^f32)																											---;
	@(link_name="SDL_RenderGetViewport") render_get_viewport :: proc(renderer: ^Renderer, rect: ^Rect)																														---;
	@(link_name="SDL_RenderIsClipEnabled") render_is_clip_enabled :: proc(renderer: ^Renderer) -> Bool																															---;
	@(link_name="SDL_RenderPresent") render_present :: proc(renderer: ^Renderer)																																	---;
	@(link_name="SDL_RenderReadPixels") render_read_pixels :: proc(renderer: ^Renderer, rect: ^Rect, format: u32, pixels: rawptr, pitch: i32) -> i32																		---;
	@(link_name="SDL_RenderSetClipRect") render_set_clip_rect :: proc(renderer: ^Renderer, rect: ^Rect) -> i32																													---;
	@(link_name="SDL_RenderSetIntegerScale") render_set_integer_scale :: proc(renderer: ^Renderer, enable: Bool) -> i32																												---;
	@(link_name="SDL_RenderSetLogicalSize") render_set_logical_size :: proc(renderer: ^Renderer, w, h: i32) -> i32																													---;
	@(link_name="SDL_RenderSetScale") render_set_scale :: proc(renderer: ^Renderer, scale_x, scale_y: f32) -> i32																										---;
	@(link_name="SDL_RenderSetViewport") render_set_viewport :: proc(renderer: ^Renderer, rect: ^Rect)																														---;
	@(link_name="SDL_RenderTargetSupported") render_target_supported :: proc(renderer: ^Renderer) -> Bool																															---;
	@(link_name="SDL_ResetAssertionReport") reset_assertion_report :: proc()																																						---;
	@(link_name="SDL_RestoreWindow") restore_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_RWFromConstMem") rw_from_const_mem :: proc(mem: rawptr, size: i32) -> ^Rw_Ops																														---;
	@(link_name="SDL_RWFromFP") rw_from_fp :: proc(fp: rawptr, auto_close: Bool) -> ^Rw_Ops																												---;
	@(link_name="SDL_RWFromFile") rw_from_file :: proc(file: cstring, mode: cstring) -> ^Rw_Ops																														---;
	@(link_name="SDL_RWFromMem") rw_from_mem :: proc(mem: rawptr, size:i32) -> ^Rw_Ops																														---;
	@(link_name="SDL_SaveAllDollarTemplates") save_all_dollar_templates :: proc(dst: ^Rw_Ops) -> i32																																	---;
	@(link_name="SDL_SaveBMP_RW") save_bmp_rw :: proc(surface: ^Surface, dst: ^Rw_Ops, free_dst: i32) -> i32																									---;
	@(link_name="SDL_SaveDollarTemplate") save_dollar_template :: proc(gesture_id: Gesture_Id, dst: ^Rw_Ops) -> i32																											---;
	@(link_name="SDL_SemPost") sem_post :: proc(sem: Sem) -> i32																																		---;
	@(link_name="SDL_SemTryWait") sem_try_wait :: proc(sem: Sem) -> i32																																		---;
	@(link_name="SDL_SemValue") sem_value :: proc(sem: Sem) -> u32																																		---;
	@(link_name="SDL_SemWait") sem_wait :: proc(sem: Sem) -> i32																																		---;
	@(link_name="SDL_SemWaitTimeout") sem_wait_timeout :: proc(sem: Sem, ms: u32) -> i32																																---;
	@(link_name="SDL_SetAssertionHandler") set_assertion_handler :: proc(handler: Assertion_Handler, userdata: rawptr)																											---;
	@(link_name="SDL_SetClipRect") set_clip_rect :: proc(surface: ^Surface, rect: ^Rect) -> Bool																													---;
	@(link_name="SDL_SetClipboardText") set_clipboard_text :: proc(text: cstring) -> i32																																		---;
	@(link_name="SDL_SetColorKey") set_color_key :: proc(surface: ^Surface, flag: i32, key: u32) -> i32																											---;
	@(link_name="SDL_SetCursor") set_cursor :: proc(cursor: ^Cursor)																																		---;
	@(link_name="SDL_SetError") set_error :: proc(fmt: ..cstring) -> i32																																		---;
	@(link_name="SDL_SetEventFilter") set_event_filter :: proc(filter: Event_Filter, userdata: rawptr)																													---;
	@(link_name="SDL_SetHint") set_hint :: proc(name, value: cstring) -> Bool																																---;
	@(link_name="SDL_SetHintWithPriority") set_hint_with_priority :: proc(name, value: cstring, priority: Hint_Priority) -> Bool																										---;
	@(link_name="SDL_SetMainReady") set_main_ready :: proc()																																						---;
	@(link_name="SDL_SetModState") set_mod_state :: proc(modstate: Keymod)																																		---;
	@(link_name="SDL_SetPaletteColors") set_palette_colors :: proc(palette: ^Palette, colors: ^Color, firstcolor, ncolors: i32) -> i32																						---;
	@(link_name="SDL_SetPixelFormatPalette") set_pixel_format_palette :: proc(format: ^Pixel_Format, palette: ^Palette) -> i32																										---;
	@(link_name="SDL_SetRelativeMouseMode") set_relative_mouse_mode :: proc(enabled: Bool) -> i32																																	---;
	@(link_name="SDL_SetRenderDrawBlendMode") set_render_draw_blend_mode :: proc(renderer: ^Renderer, blend_mode: Blend_Mode) -> i32																										---;
	@(link_name="SDL_SetRenderDrawColor") set_render_draw_color :: proc(renderer: ^Renderer, r, g, b, a: u8) -> i32																												---;
	@(link_name="SDL_SetRenderTarget") set_render_target :: proc(renderer: ^Renderer, texture: ^Texture) -> i32																											---;
	@(link_name="SDL_SetSurfaceAlphaMod") set_surface_alpha_mod :: proc(surface: ^Surface, alpha: u8) -> i32																													---;
	@(link_name="SDL_SetSurfaceBlendMode") set_surface_blend_mode :: proc(surface: ^Surface, blend_mode: Blend_Mode) -> i32																										---;
	@(link_name="SDL_SetSurfaceColorMod") set_surface_color_mod :: proc(surface: ^Surface, r, g, b: u8) -> i32																													---;
	@(link_name="SDL_SetSurfacePalette") set_surface_palette :: proc(surface: ^Surface, palette: ^Palette) -> i32																											---;
	@(link_name="SDL_SetSurfaceRLE") set_surface_rle :: proc(surface: ^Surface, flag: i32) -> i32																													---;
	@(link_name="SDL_SetTextInputRect") set_text_input_rect :: proc(rect: ^Rect)																																			---;
	@(link_name="SDL_SetTextureAlphaMod") set_texture_alpha_mod :: proc(texture: ^Texture, alpha: u8) -> i32																													---;
	@(link_name="SDL_SetTextureBlendMode") set_texture_blend_mode :: proc(texture: ^Texture, blend_mode: Blend_Mode) -> i32																										---;
	@(link_name="SDL_SetTextureColorMod") set_texture_color_mod :: proc(texture: ^Texture, r, g, b: u8) -> i32																													---;
	@(link_name="SDL_SetThreadPriority") set_thread_priority :: proc(priority: Thread_Priority) -> i32																														---;
	@(link_name="SDL_SetWindowBordered") set_window_bordered :: proc(window: ^Window, bordered: Bool)																														---;
	@(link_name="SDL_SetWindowBrightness") set_window_brightness :: proc(window: ^Window, brightness: f32) -> i32																												---;
	@(link_name="SDL_SetWindowData") set_window_data :: proc(window: ^Window, name: cstring, userdata: rawptr) -> rawptr																									---;
	@(link_name="SDL_SetWindowDisplayMode") set_window_display_mode :: proc(window: ^Window, mode: ^Display_Mode) -> i32																											---;
	@(link_name="SDL_SetWindowFullscreen") set_window_fullscreen :: proc(window: ^Window, flags: u32) -> i32																														---;
	@(link_name="SDL_SetWindowGammaRamp") set_window_gamma_ramp :: proc(window: ^Window, r, g, b: ^u16) -> i32																													---;
	@(link_name="SDL_SetWindowGrab") set_window_grab :: proc(window: ^Window, grabbed: Bool)																															---;
	@(link_name="SDL_SetWindowHitTest") set_window_hit_test :: proc(window: ^Window, callback: Hit_Test, callback_data: rawptr) -> i32																						---;
	@(link_name="SDL_SetWindowIcon") set_window_icon :: proc(window: ^Window, icon: ^Surface)																														---;
	@(link_name="SDL_SetWindowInputFocus") set_window_input_focus :: proc(window: ^Window) -> i32																																	---;
	@(link_name="SDL_SetWindowMaximumSize") set_window_maximum_size :: proc(window: ^Window, w, h: i32)																																---;
	@(link_name="SDL_SetWindowMinimumSize") set_window_minimum_size :: proc(window: ^Window, w, h: i32)																																---;
	@(link_name="SDL_SetWindowModalFor") set_window_modal_for :: proc(window: ^Window, parent_window: ^Window) -> i32																											---;
	@(link_name="SDL_SetWindowOpacity") set_window_opacity :: proc(window: ^Window, opacity: f32) -> i32																													---;
	@(link_name="SDL_SetWindowPosition") set_window_position :: proc(window: ^Window, x, y: i32)																																---;
	@(link_name="SDL_SetWindowResizable") set_window_resizable :: proc(window: ^Window, resizable: Bool)																														---;
	@(link_name="SDL_SetWindowShape") set_window_shape :: proc(window: ^Window, shape: ^Surface, shape_mode: Window_Shape_Mode) -> i32																					---;
	@(link_name="SDL_SetWindowSize") set_window_size :: proc(window: ^Window, w, h: i32)																																---;
	@(link_name="SDL_SetWindowTitle") set_window_title :: proc(window: ^Window, title: cstring)																															---;
	@(link_name="SDL_SetWindowsMessageHook") set_windows_message_hook :: proc(callback: Windows_Message_Hook, userdata: rawptr)																										---;
	@(link_name="SDL_ShowCursor") show_cursor :: proc(toggle: i32) -> i32																																		---;
	@(link_name="SDL_ShowMessageBox") show_message_box :: proc(message_box_data: ^Message_Box_Data, button_id: ^i32) -> i32																							---;
	@(link_name="SDL_ShowSimpleMessageBox") show_simple_message_box :: proc(flags: u32, title, message: cstring, window: ^Window) -> i32																								---;
	@(link_name="SDL_ShowWindow") show_window :: proc(window: ^Window)																																		---;
	@(link_name="SDL_SoftStretch") soft_stretch :: proc(src: ^Surface, srcrect: ^Rect, dst: ^Surface, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_StartTextInput") start_text_input :: proc()																																						---;
	@(link_name="SDL_StopTextInput") stop_text_input :: proc()																																						---;
	@(link_name="SDL_TLSCreate") tls_create :: proc() -> Tls_Id																																				---;
	@(link_name="SDL_TLSGet") tls_get :: proc(id: Tls_Id) -> rawptr																																	---;
	@(link_name="SDL_TLSSet") tls_set :: proc(id: Tls_Id, value: rawptr, destructor: proc(data: rawptr)) -> i32																						---;
	@(link_name="SDL_ThreadID") thread_id :: proc() -> Thread_Id																																			---;
	@(link_name="SDL_TryLockMutex") try_lock_mutex :: proc(mutex: ^Mutex) -> i32																																	---;
	@(link_name="SDL_UnionRect") union_rect :: proc(a, b, result: ^Rect)																																	---;
	@(link_name="SDL_UnloadObject") unload_object :: proc(handle: rawptr)																																			---;
	@(link_name="SDL_UnlockAudio") unlock_audio :: proc()																																						---;
	@(link_name="SDL_UnlockAudioDevice") unlock_audio_device :: proc(dev: Audio_Device_Id)																																	---;
	@(link_name="SDL_UnlockMutex") unlock_mutex :: proc(mutex: ^Mutex) -> i32																																	---;
	@(link_name="SDL_UnlockSurface") unlock_surface :: proc(surface: ^Surface)																																		---;
	@(link_name="SDL_UnlockTexture") unlock_texture :: proc(texture: ^Texture)																																		---;
	@(link_name="SDL_UnregisterApp") unregister_app :: proc()																																						---;
	@(link_name="SDL_UpdateTexture") update_texture :: proc(texture: ^Texture, rect: ^Rect, pixels: rawptr, pitch: i32) -> i32																								---;
	@(link_name="SDL_UpdateWindowSurface") update_window_surface :: proc(window: ^Window) -> i32																																	---;
	@(link_name="SDL_UpdateWindowSurfaceRects") update_window_surface_rects :: proc(window: ^Window, rects: ^Rect, num_rects: i32) -> i32																									---;
	@(link_name="SDL_UpdateYUVTexture") update_yuv_texture :: proc(texture: ^Texture, rect: ^Rect, y_plane: ^u8, y_pitch: i32, u_plane: ^u8, u_pitch: i32, v_plane: ^u8, v_pitch: i32) -> i32								---;
	@(link_name="SDL_UpperBlit") upper_blit :: proc(src: ^Surface, srcrect: ^Rect, dst: ^Surface, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_UpperBlitScaled") upper_blit_scaled :: proc(src: ^Surface, srcrect: ^Rect, dst: ^Surface, dstrect: ^Rect) -> i32																					---;
	@(link_name="SDL_VideoInit") video_init :: proc(driver_name: cstring) -> i32																																---;
	@(link_name="SDL_VideoQuit") video_quit :: proc()																																						---;
	@(link_name="SDL_WaitEvent") wait_event :: proc(event: ^Event) -> i32																																	---;
	@(link_name="SDL_WaitEventTimeout") wait_event_timeout :: proc(event: ^Event, timeout: i32) -> i32																														---;
	@(link_name="SDL_WaitThread") wait_thread :: proc(thread: ^Thread, status: ^i32)																															---;
	@(link_name="SDL_WarpMouseGlobal") warp_mouse_global :: proc(x, y: i32) -> i32																																		---;
	@(link_name="SDL_WarpMouseInWindow") warp_mouse_in_window :: proc(window: ^Window, x, y: i32)																																---;
	@(link_name="SDL_WasInit") was_init :: proc(flags: u32) -> u32																																		---;
	@(link_name="SDL_WriteBE16") write_be16 :: proc(dst: ^Rw_Ops, value: u16) -> u64																														---;
	@(link_name="SDL_WriteBE32") write_be32 :: proc(dst: ^Rw_Ops, value: u32) -> u64																														---;
	@(link_name="SDL_WriteBE64") write_be64 :: proc(dst: ^Rw_Ops, value: u64) -> u64																														---;
	@(link_name="SDL_WriteLE16") write_le16 :: proc(dst: ^Rw_Ops, value: u16) -> u64																														---;
	@(link_name="SDL_WriteLE32") write_le32 :: proc(dst: ^Rw_Ops, value: u32) -> u64																														---;
	@(link_name="SDL_WriteLE64") write_le64 :: proc(dst: ^Rw_Ops, value: u64) -> u64																														---;
	@(link_name="SDL_WriteU8") write_u8 :: proc(dst: ^Rw_Ops, value: u8) -> u64																															---;
}

Init_Flags :: enum u32 {
	Timer = 0x00000001,
	Audio = 0x00000010,
	Video = 0x00000020,
	Joystick = 0x00000200,
	Haptic = 0x00001000,
	GameController = 0x00002000,
	Events = 0x00004000,
	NoParachute = 0x00100000,
	Everything = Timer | Audio | Video | Events | Joystick | Haptic | GameController
}

Window_Flags :: enum u32 {
	Fullscreen = 0x00000001,
	Open_GL = 0x00000002,
	Shown = 0x00000004,
	Hidden = 0x00000008,
	Borderless = 0x00000010,
	Resizable = 0x00000020,
	Minimized = 0x00000040,
	Maximized = 0x00000080,
	Input_Grabbed = 0x00000100,
	Input_Focus = 0x00000200,
	Mouse_Focus = 0x00000400,
	Fullscreen_Desktop = Fullscreen | 0x00001000,
	Foreign = 0x00000800,
	Allow_High_DPI = 0x00002000,
	Mouse_Capture = 0x00004000,
	Always_On_Top = 0x00008000,
	Skip_Taskbar = 0x00010000,
	Utility = 0x00020000,
	Tooltip = 0x00040000,
	Popup_Menu = 0x00080000,
	Vulkan = 0x00100000
}

Window_Pos :: enum i32 {
	Undefined = 0x1FFF0000,
	Centered = 0x2FFF0000
}

Renderer_Flags :: enum u32 {
	Software = 0x00000001,
	Accelerated = 0x00000002,
	Present_VSync = 0x00000004,
	Target_Texture = 0x00000008
}

Texture_Access :: enum i32 {
    Static = 0,
    Streaming,
    Target
}

Blend_Mode :: enum i32 {
	None = 0x00000000,
	Blend = 0x00000001,
	Add = 0x00000002,
	Mod = 0x00000004
}

Error_Code :: enum i32 {
	No_Mem,
	FRead,
	FWrite,
	FSeek,
	Unsupported,
	Last_Error
}

Joystick_Power_Level :: enum i32 {
	Unknown = -1,
	Empty,
	Low,
	Medium,
	Full,
	Wired,
	Max
}

Hint_Priority :: enum i32 {
	Default,
	Normal,
	Override
}

Thread_Priority :: enum i32 {
	Low,
	Normal,
	High
}

Assert_State :: enum i32 {
	Retry,
	Break,
	Abort,
	Ignore,
	Always_Ignore
}

Event_Action :: enum i32 {
	Add_Event,
	Peek_Event,
	Get_Event
}

Hit_Test_Result :: enum i32 {
	Normal,
	Draggable,
	Resize_Top_Left,
	Resize_Top,
	Resize_Top_Right,
	Resize_Right,
	Resize_Bottom_Right,
	Resize_Bottom,
	Resize_Bottom_Left,
	Resize_Left
}

Bool :: enum i32 {
	False,
	True
}

Window_Shape_Modes :: enum i32 {
	Default,
	Binarize_Alpha,
	Reverse_Binarize_Alpha,
	Color_Key
}

Keymod :: enum i32 {
	None = 0x0000,
	LShift = 0x0001,
	RShift = 0x0002,
	LCtrl = 0x0040,
	RCtrl = 0x0080,
	LAlt = 0x0100,
	RAlt = 0x0200,
	LGui = 0x0400,
	RGui = 0x0800,
	Num = 0x1000,
	Caps = 0x2000,
	Mode = 0x4000,
	Reserved = 0x8000
}

Renderer_Flip :: enum i32 {
	None = 0x00000000,
	Horizontal = 0x00000001,
	Vertical = 0x00000002
}

GL_Attr :: enum i32 {
	Red_Size,
	Green_Size,
	Blue_Size,
	Alpha_Size,
	Buffer_Size,
	Doublebuffer,
	Depth_Size,
	Stencil_Size,
	Accum_Red_Size,
	Accum_Green_Size,
	Accum_Blue_Size,
	Accum_Alpha_Size,
	Stereo,
	Multisamplebuffers,
	Multisample_Samples,
	Accelerated_Visual,
	Retained_Backing,
	Context_Major_Version,
	Context_Minor_Version,
	Context_EGL,
	Context_Flags,
	Context_Profile_Mask,
	Share_With_Current_Context,
	Framebuffer_SRGB_Capable,
	Context_Release_Behavior
}

GL_Context_Flag :: enum i32 {
	Debug              = 0x0001,
	Forward_Compatible = 0x0002,
	Robust_Access      = 0x0004,
	Reset_Isolation    = 0x0008
}

GL_Context_Profile :: enum i32 {
	Core           = 0x0001,
	Compatibility  = 0x0002,
	ES             = 0x0004
}

Message_Box_Color_Type :: enum i32 {
	Background,
	Text,
	Button_Border,
	Button_Background,
	Button_Selected,
	Max
}

Audio_Status :: enum i32 {
	Stopped = 0,
	Playing,
	Paused
}

Power_State :: enum i32 {
	Unknown,
	On_Battery,
	No_Battery,
	Charging,
	Charged
}

Log_Category :: enum i32 {
    Application,
    Error,
    Assert,
    System,
    Audio,
    Video,
    Render,
    Input,
    Test,

    Custom = 19
}

Log_Priority :: enum i32 {
	Verbose = 1,
	Debug,
	Info,
	Warn,
	Error,
	Critical,
	Num_Log_Priorities
}

// Input stuff


Game_Controller_Button :: enum i32 {
	Invalid = -1,
	A,
	B,
	X,
	Y,
	Back,
	Guide,
	Start,
	Left_Stick,
	Right_Stick,
	Left_Shoulder,
	Right_Shoulder,
	DPad_Up,
	DPad_Down,
	DPad_Left,
	DPad_Right,
	Max
}

Game_Controller_Axis :: enum i32 {
	Invalid = -1,
	LeftX,
	LeftY,
	RightX,
	RightY,
	Trigger_Left,
	Trigger_Right,
	Max
}

Game_Controller_Bind_Type :: enum i32 {
	None = 0,
	Button,
	Axis,
	Hat
}

System_Cursor :: enum i32 {
	Arrow,
	IBeam,
	Wait,
	Crosshair,
	Wait_Arrow,
	Size_NWSE,
	Size_NESW,
	Size_WE,
	Size_NS,
	Size_All,
	No,
	Hand,
	Num_System_Cursors
}


Scancode :: enum i32 {
	Unknown = 0,

	A = 4,
	B = 5,
	C = 6,
	D = 7,
	E = 8,
	F = 9,
	G = 10,
	H = 11,
	I = 12,
	J = 13,
	K = 14,
	L = 15,
	M = 16,
	N = 17,
	O = 18,
	P = 19,
	Q = 20,
	R = 21,
	S = 22,
	T = 23,
	U = 24,
	V = 25,
	W = 26,
	X = 27,
	Y = 28,
	Z = 29,

	// Number row
	Nr1 = 30,
	Nr2 = 31,
	Nr3 = 32,
	Nr4 = 33,
	Nr5 = 34,
	Nr6 = 35,
	Nr7 = 36,
	Nr8 = 37,
	Nr9 = 38,
	Nr0 = 39,

	Return = 40,
	Escape = 41,
	Backspace = 42,
	Tab = 43,
	Space = 44,

	Minus = 45,
	Equals = 46,
	Leftbracket = 47,
	Rightbracket = 48,
	Backslash = 49,
	Nonushash = 50, // ???
	Semicolon = 51,
	Apostrophe = 52,
	Grave = 53,
	Comma = 54,
	Period = 55,
	Slash = 56,

	Caps_Lock = 57,

	F1 = 58,
	F2 = 59,
	F3 = 60,
	F4 = 61,
	F5 = 62,
	F6 = 63,
	F7 = 64,
	F8 = 65,
	F9 = 66,
	F10 = 67,
	F11 = 68,
	F12 = 69,

	Print_Screen = 70,
	Scroll_Lock = 71,
	Pause = 72,
	Insert = 73,
	Home = 74,
	Page_Up = 75,
	Delete = 76,
	End = 77,
	Page_Down = 78,
	Right = 79,
	Left = 80,
	Down = 81,
	Up = 82,

	Num_Lock_Clear = 83,
	Kp_Divide = 84,
	Kp_Multiply = 85,
	Kp_Minus = 86,
	Kp_Plus = 87,
	Kp_Enter = 88,
	Kp_1 = 89,
	Kp_2 = 90,
	Kp_3 = 91,
	Kp_4 = 92,
	Kp_5 = 93,
	Kp_6 = 94,
	Kp_7 = 95,
	Kp_8 = 96,
	Kp_9 = 97,
	Kp_0 = 98,
	Kp_Period = 99,

	Non_US_Backslash = 100,
	Application = 101,
	Power = 102,
	Kp_Equals = 103,
	F13 = 104,
	F14 = 105,
	F15 = 106,
	F16 = 107,
	F17 = 108,
	F18 = 109,
	F19 = 110,
	F20 = 111,
	F21 = 112,
	F22 = 113,
	F23 = 114,
	F24 = 115,
	Execute = 116,
	Help = 117,
	Menu = 118,
	Select = 119,
	Stop = 120,
	Again = 121,
	Undo = 122,
	Cut = 123,
	Copy = 124,
	Paste = 125,
	Find = 126,
	Mute = 127,
	Volume_Up = 128,
	Volume_Down = 129,
	Kp_Comma = 133,
	Kp_Equals_AS400 = 134,

	International1 = 135,
	International2 = 136,
	International3 = 137,
	International4 = 138,
	International5 = 139,
	International6 = 140,
	International7 = 141,
	International8 = 142,
	International9 = 143,
	Lang1 = 144,
	Lang2 = 145,
	Lang3 = 146,
	Lang4 = 147,
	Lang5 = 148,
	Lang6 = 149,
	Lang7 = 150,
	Lang8 = 151,
	Lang9 = 152,

	Alt_Erase = 153,
	Sys_Req = 154,
	Cancel = 155,
	Clear = 156,
	Prior = 157,
	Return2 = 158,
	Separator = 159,
	Out = 160,
	Oper = 161,
	Clear_Again = 162,
	Cr_Sel = 163,
	Ex_Sel = 164,

	Kp_00 = 176,
	Kp_000 = 177,
	Thousands_Separator = 178,
	Decimal_Separator = 179,
	Currency_Unit = 180,
	Currency_Sub_Unit = 181,
	Kp_Left_Paren = 182,
	Kp_Right_Paren = 183,
	Kp_Left_Brace = 184,
	Kp_Right_Brace = 185,
	Kp_Tab = 186,
	Kp_Backspace = 187,
	Kp_A = 188,
	Kp_B = 189,
	Kp_C = 190,
	Kp_D = 191,
	Kp_E = 192,
	Kp_F = 193,
	Kp_Xor = 194,
	Kp_Power = 195,
	Kp_Percent = 196,
	Kp_Less = 197,
	Kp_Greater = 198,
	Kp_Ampersand = 199,
	Kp_Dbl_Ampersand = 200,
	Kp_Vertical_Bar = 201,
	Kp_Dbl_Vertical_Bar = 202,
	Kp_Colon = 203,
	Kp_Hash = 204,
	Kp_Space = 205,
	Kp_At = 206,
	Kp_Exclam = 207,
	Kp_Mem_Store = 208,
	Kp_Mem_Recall = 209,
	Kp_Mem_Clear = 210,
	Kp_Mem_Add = 211,
	Kp_Mem_Subtract = 212,
	Kp_Mem_Multiply = 213,
	Kp_Mem_Divide = 214,
	Kp_Plus_Minus = 215,
	Kp_Clear = 216,
	Kp_Clear_Entry = 217,
	Kp_Binary = 218,
	Kp_Octal = 219,
	Kp_Decimal = 220,
	Kp_Hexadecimal = 221,

	LCtrl = 224,
	LShift = 225,
	LAlt = 226,
	LGui = 227,
	RCtrl = 228,
	RShift = 229,
	RAlt = 230,
	RGui = 231,

	Mode = 257,

	Audio_Next = 258,
	Audio_Prev = 259,
	Audio_Stop = 260,
	Audio_Play = 261,
	Audio_Mute = 262,
	Media_Select = 263,
	WWW = 264,
	Mail = 265,
	Calculator = 266,
	Computer = 267,
	Ac_Search = 268,
	Ac_Home = 269,
	Ac_Back = 270,
	Ac_Forward = 271,
	Ac_Stop = 272,
	Ac_Refresh = 273,
	Ac_Bookmarks = 274,

	Brightness_Down = 275,
	Brightness_Up = 276,
	Display_Switch = 277,
	Kb_Dillum_Toggle = 278,
	Kb_Dillum_Down = 279,
	Kb_Dillum_Up = 280,
	Eject = 281,
	Sleep = 282,

	App1 = 283,
	App2 = 284,

	Num_Scancodes = 512
}

SDLK_UNKNOWN :: 0;

SDLK_RETURN :: '\r';
SDLK_ESCAPE :: '\033';
SDLK_BACKSPACE :: '\b';
SDLK_TAB :: '\t';
SDLK_SPACE :: ' ';
SDLK_EXCLAIM :: '!';
SDLK_QUOTEDBL :: '"';
SDLK_HASH :: '#';
SDLK_PERCENT :: '%';
SDLK_DOLLAR :: '$';
SDLK_AMPERSAND :: '&';
SDLK_QUOTE :: '\'';
SDLK_LEFTPAREN :: '(';
SDLK_RIGHTPAREN :: ')';
SDLK_ASTERISK :: '*';
SDLK_PLUS :: '+';
SDLK_COMMA :: ',';
SDLK_MINUS :: '-';
SDLK_PERIOD :: '.';
SDLK_SLASH :: '/';
SDLK_0 :: '0';
SDLK_1 :: '1';
SDLK_2 :: '2';
SDLK_3 :: '3';
SDLK_4 :: '4';
SDLK_5 :: '5';
SDLK_6 :: '6';
SDLK_7 :: '7';
SDLK_8 :: '8';
SDLK_9 :: '9';
SDLK_COLON :: ':';
SDLK_SEMICOLON :: ';';
SDLK_LESS :: '<';
SDLK_EQUALS :: '=';
SDLK_GREATER :: '>';
SDLK_QUESTION :: '?';
SDLK_AT :: '@';

SDLK_LEFTBRACKET :: '[';
SDLK_BACKSLASH :: '\\';
SDLK_RIGHTBRACKET :: ']';
SDLK_CARET :: '^';
SDLK_UNDERSCORE :: '_';
SDLK_BACKQUOTE :: '`';
SDLK_a :: 'a';
SDLK_b :: 'b';
SDLK_c :: 'c';
SDLK_d :: 'd';
SDLK_e :: 'e';
SDLK_f :: 'f';
SDLK_g :: 'g';
SDLK_h :: 'h';
SDLK_i :: 'i';
SDLK_j :: 'j';
SDLK_k :: 'k';
SDLK_l :: 'l';
SDLK_m :: 'm';
SDLK_n :: 'n';
SDLK_o :: 'o';
SDLK_p :: 'p';
SDLK_q :: 'q';
SDLK_r :: 'r';
SDLK_s :: 's';
SDLK_t :: 't';
SDLK_u :: 'u';
SDLK_v :: 'v';
SDLK_w :: 'w';
SDLK_x :: 'x';
SDLK_y :: 'y';
SDLK_z :: 'z';

SDLK_CAPSLOCK :: Scancode.Caps_Lock | SDLK_SCANCODE_MASK;

SDLK_F1 :: Scancode.F1 | SDLK_SCANCODE_MASK;
SDLK_F2 :: Scancode.F2 | SDLK_SCANCODE_MASK;
SDLK_F3 :: Scancode.F3 | SDLK_SCANCODE_MASK;
SDLK_F4 :: Scancode.F4 | SDLK_SCANCODE_MASK;
SDLK_F5 :: Scancode.F5 | SDLK_SCANCODE_MASK;
SDLK_F6 :: Scancode.F6 | SDLK_SCANCODE_MASK;
SDLK_F7 :: Scancode.F7 | SDLK_SCANCODE_MASK;
SDLK_F8 :: Scancode.F8 | SDLK_SCANCODE_MASK;
SDLK_F9 :: Scancode.F9 | SDLK_SCANCODE_MASK;
SDLK_F10 :: Scancode.F10 | SDLK_SCANCODE_MASK;
SDLK_F11 :: Scancode.F11 | SDLK_SCANCODE_MASK;
SDLK_F12 :: Scancode.F12 | SDLK_SCANCODE_MASK;

SDLK_PRINTSCREEN :: Scancode.Print_Screen | SDLK_SCANCODE_MASK;
SDLK_SCROLLLOCK :: Scancode.Scroll_Lock | SDLK_SCANCODE_MASK;
SDLK_PAUSE :: Scancode.Pause | SDLK_SCANCODE_MASK;
SDLK_INSERT :: Scancode.Insert | SDLK_SCANCODE_MASK;
SDLK_HOME :: Scancode.Home | SDLK_SCANCODE_MASK;
SDLK_PAGEUP :: Scancode.Page_Up | SDLK_SCANCODE_MASK;
SDLK_DELETE :: '\177';
SDLK_END :: Scancode.End | SDLK_SCANCODE_MASK;
SDLK_PAGEDOWN :: Scancode.Page_Down | SDLK_SCANCODE_MASK;
SDLK_RIGHT :: Scancode.Right | SDLK_SCANCODE_MASK;
SDLK_LEFT :: Scancode.Left | SDLK_SCANCODE_MASK;
SDLK_DOWN :: Scancode.Down | SDLK_SCANCODE_MASK;
SDLK_UP :: Scancode.Up | SDLK_SCANCODE_MASK;

SDLK_NUMLOCKCLEAR :: Scancode.Num_Lock_Clear | SDLK_SCANCODE_MASK;
SDLK_KP_DIVIDE :: Scancode.Kp_Divide | SDLK_SCANCODE_MASK;
SDLK_KP_MULTIPLY :: Scancode.Kp_Multiply | SDLK_SCANCODE_MASK;
SDLK_KP_MINUS :: Scancode.Kp_Minus | SDLK_SCANCODE_MASK;
SDLK_KP_PLUS :: Scancode.Kp_Plus | SDLK_SCANCODE_MASK;
SDLK_KP_ENTER :: Scancode.Kp_Enter | SDLK_SCANCODE_MASK;
SDLK_KP_1 :: Scancode.Kp_1 | SDLK_SCANCODE_MASK;
SDLK_KP_2 :: Scancode.Kp_2 | SDLK_SCANCODE_MASK;
SDLK_KP_3 :: Scancode.Kp_3 | SDLK_SCANCODE_MASK;
SDLK_KP_4 :: Scancode.Kp_4 | SDLK_SCANCODE_MASK;
SDLK_KP_5 :: Scancode.Kp_5 | SDLK_SCANCODE_MASK;
SDLK_KP_6 :: Scancode.Kp_6 | SDLK_SCANCODE_MASK;
SDLK_KP_7 :: Scancode.Kp_7 | SDLK_SCANCODE_MASK;
SDLK_KP_8 :: Scancode.Kp_8 | SDLK_SCANCODE_MASK;
SDLK_KP_9 :: Scancode.Kp_9 | SDLK_SCANCODE_MASK;
SDLK_KP_0 :: Scancode.Kp_0 | SDLK_SCANCODE_MASK;
SDLK_KP_PERIOD :: Scancode.Kp_Period | SDLK_SCANCODE_MASK;

SDLK_APPLICATION :: Scancode.Application | SDLK_SCANCODE_MASK;
SDLK_POWER :: Scancode.Power | SDLK_SCANCODE_MASK;
SDLK_KP_EQUALS :: Scancode.Kp_Equals | SDLK_SCANCODE_MASK;
SDLK_F13 :: Scancode.F13 | SDLK_SCANCODE_MASK;
SDLK_F14 :: Scancode.F14 | SDLK_SCANCODE_MASK;
SDLK_F15 :: Scancode.F15 | SDLK_SCANCODE_MASK;
SDLK_F16 :: Scancode.F16 | SDLK_SCANCODE_MASK;
SDLK_F17 :: Scancode.F17 | SDLK_SCANCODE_MASK;
SDLK_F18 :: Scancode.F18 | SDLK_SCANCODE_MASK;
SDLK_F19 :: Scancode.F19 | SDLK_SCANCODE_MASK;
SDLK_F20 :: Scancode.F20 | SDLK_SCANCODE_MASK;
SDLK_F21 :: Scancode.F21 | SDLK_SCANCODE_MASK;
SDLK_F22 :: Scancode.F22 | SDLK_SCANCODE_MASK;
SDLK_F23 :: Scancode.F23 | SDLK_SCANCODE_MASK;
SDLK_F24 :: Scancode.F24 | SDLK_SCANCODE_MASK;
SDLK_EXECUTE :: Scancode.Execute | SDLK_SCANCODE_MASK;
SDLK_HELP :: Scancode.Help | SDLK_SCANCODE_MASK;
SDLK_MENU :: Scancode.Menu | SDLK_SCANCODE_MASK;
SDLK_SELECT :: Scancode.Select | SDLK_SCANCODE_MASK;
SDLK_STOP :: Scancode.Stop | SDLK_SCANCODE_MASK;
SDLK_AGAIN :: Scancode.Again | SDLK_SCANCODE_MASK;
SDLK_UNDO :: Scancode.Undo | SDLK_SCANCODE_MASK;
SDLK_CUT :: Scancode.Cut | SDLK_SCANCODE_MASK;
SDLK_COPY :: Scancode.Copy | SDLK_SCANCODE_MASK;
SDLK_PASTE :: Scancode.Paste | SDLK_SCANCODE_MASK;
SDLK_FIND :: Scancode.Find | SDLK_SCANCODE_MASK;
SDLK_MUTE :: Scancode.Mute | SDLK_SCANCODE_MASK;
SDLK_VOLUMEUP :: Scancode.Volume_Up | SDLK_SCANCODE_MASK;
SDLK_VOLUMEDOWN :: Scancode.Volume_Down | SDLK_SCANCODE_MASK;
SDLK_KP_COMMA :: Scancode.Kp_Comma | SDLK_SCANCODE_MASK;
SDLK_KP_EQUALSAS400 :: Scancode.Kp_Equals_AS400 | SDLK_SCANCODE_MASK;

SDLK_ALTERASE :: Scancode.Alt_Erase | SDLK_SCANCODE_MASK;
SDLK_SYSREQ :: Scancode.Sys_Req | SDLK_SCANCODE_MASK;
SDLK_CANCEL :: Scancode.Cancel | SDLK_SCANCODE_MASK;
SDLK_CLEAR :: Scancode.Clear | SDLK_SCANCODE_MASK;
SDLK_PRIOR :: Scancode.Prior | SDLK_SCANCODE_MASK;
SDLK_RETURN2 :: Scancode.Return2 | SDLK_SCANCODE_MASK;
SDLK_SEPARATOR :: Scancode.Separator | SDLK_SCANCODE_MASK;
SDLK_OUT :: Scancode.Out | SDLK_SCANCODE_MASK;
SDLK_OPER :: Scancode.Oper | SDLK_SCANCODE_MASK;
SDLK_CLEARAGAIN :: Scancode.Clear_Again | SDLK_SCANCODE_MASK;
SDLK_CRSEL :: Scancode.Cr_Sel | SDLK_SCANCODE_MASK;
SDLK_EXSEL :: Scancode.Ex_Sel | SDLK_SCANCODE_MASK;

SDLK_KP_00 :: Scancode.Kp_00 | SDLK_SCANCODE_MASK;
SDLK_KP_000 :: Scancode.Kp_000 | SDLK_SCANCODE_MASK;
SDLK_THOUSANDSSEPARATOR :: Scancode.Thousands_Separator | SDLK_SCANCODE_MASK;
SDLK_DECIMALSEPARATOR :: Scancode.Decimal_Separator | SDLK_SCANCODE_MASK;
SDLK_CURRENCYUNIT :: Scancode.Currency_Unit | SDLK_SCANCODE_MASK;
SDLK_CURRENCYSUBUNIT :: Scancode.Currency_Sub_Unit | SDLK_SCANCODE_MASK;
SDLK_KP_LEFTPAREN :: Scancode.Kp_Left_Paren | SDLK_SCANCODE_MASK;
SDLK_KP_RIGHTPAREN :: Scancode.Kp_Right_Paren | SDLK_SCANCODE_MASK;
SDLK_KP_LEFTBRACE :: Scancode.Kp_Left_Brace | SDLK_SCANCODE_MASK;
SDLK_KP_RIGHTBRACE :: Scancode.Kp_Right_Brace | SDLK_SCANCODE_MASK;
SDLK_KP_TAB :: Scancode.Kp_Tab | SDLK_SCANCODE_MASK;
SDLK_KP_BACKSPACE :: Scancode.Kp_Backspace | SDLK_SCANCODE_MASK;
SDLK_KP_A :: Scancode.Kp_A | SDLK_SCANCODE_MASK;
SDLK_KP_B :: Scancode.Kp_B | SDLK_SCANCODE_MASK;
SDLK_KP_C :: Scancode.Kp_C | SDLK_SCANCODE_MASK;
SDLK_KP_D :: Scancode.Kp_D | SDLK_SCANCODE_MASK;
SDLK_KP_E :: Scancode.Kp_E | SDLK_SCANCODE_MASK;
SDLK_KP_F :: Scancode.Kp_F | SDLK_SCANCODE_MASK;
SDLK_KP_XOR :: Scancode.Kp_Xor | SDLK_SCANCODE_MASK;
SDLK_KP_POWER :: Scancode.Kp_Power | SDLK_SCANCODE_MASK;
SDLK_KP_PERCENT :: Scancode.Kp_Percent | SDLK_SCANCODE_MASK;
SDLK_KP_LESS :: Scancode.Kp_Less | SDLK_SCANCODE_MASK;
SDLK_KP_GREATER :: Scancode.Kp_Greater | SDLK_SCANCODE_MASK;
SDLK_KP_AMPERSAND :: Scancode.Kp_Ampersand | SDLK_SCANCODE_MASK;
SDLK_KP_DBLAMPERSAND :: Scancode.Kp_Dbl_Ampersand | SDLK_SCANCODE_MASK;
SDLK_KP_VERTICALBAR :: Scancode.Kp_Vertical_Bar | SDLK_SCANCODE_MASK;
SDLK_KP_DBLVERTICALBAR :: Scancode.Kp_Dbl_Vertical_Bar | SDLK_SCANCODE_MASK;
SDLK_KP_COLON :: Scancode.Kp_Colon | SDLK_SCANCODE_MASK;
SDLK_KP_HASH :: Scancode.Kp_Hash | SDLK_SCANCODE_MASK;
SDLK_KP_SPACE :: Scancode.Kp_Space | SDLK_SCANCODE_MASK;
SDLK_KP_AT :: Scancode.Kp_At | SDLK_SCANCODE_MASK;
SDLK_KP_EXCLAM :: Scancode.Kp_Exclam | SDLK_SCANCODE_MASK;
SDLK_KP_MEMSTORE :: Scancode.Kp_Mem_Store | SDLK_SCANCODE_MASK;
SDLK_KP_MEMRECALL :: Scancode.Kp_Mem_Recall | SDLK_SCANCODE_MASK;
SDLK_KP_MEMCLEAR :: Scancode.Kp_Mem_Clear | SDLK_SCANCODE_MASK;
SDLK_KP_MEMADD :: Scancode.Kp_Mem_Add | SDLK_SCANCODE_MASK;
SDLK_KP_MEMSUBTRACT :: Scancode.Kp_Mem_Subtract | SDLK_SCANCODE_MASK;
SDLK_KP_MEMMULTIPLY :: Scancode.Kp_Mem_Multiply | SDLK_SCANCODE_MASK;
SDLK_KP_MEMDIVIDE :: Scancode.Kp_Mem_Divide | SDLK_SCANCODE_MASK;
SDLK_KP_PLUSMINUS :: Scancode.Kp_Plus_Minus | SDLK_SCANCODE_MASK;
SDLK_KP_CLEAR :: Scancode.Kp_Clear | SDLK_SCANCODE_MASK;
SDLK_KP_CLEARENTRY :: Scancode.Kp_Clear_Entry | SDLK_SCANCODE_MASK;
SDLK_KP_BINARY :: Scancode.Kp_Binary | SDLK_SCANCODE_MASK;
SDLK_KP_OCTAL :: Scancode.Kp_Octal | SDLK_SCANCODE_MASK;
SDLK_KP_DECIMAL :: Scancode.Kp_Decimal | SDLK_SCANCODE_MASK;
SDLK_KP_HEXADECIMAL :: Scancode.Kp_Hexadecimal | SDLK_SCANCODE_MASK;

SDLK_LCTRL :: Scancode.LCtrl | SDLK_SCANCODE_MASK;
SDLK_LSHIFT :: Scancode.LShift | SDLK_SCANCODE_MASK;
SDLK_LALT :: Scancode.LAlt | SDLK_SCANCODE_MASK;
SDLK_LGUI :: Scancode.LGui | SDLK_SCANCODE_MASK;
SDLK_RCTRL :: Scancode.RCtrl | SDLK_SCANCODE_MASK;
SDLK_RSHIFT :: Scancode.RShift | SDLK_SCANCODE_MASK;
SDLK_RALT :: Scancode.RAlt | SDLK_SCANCODE_MASK;
SDLK_RGUI :: Scancode.RGui | SDLK_SCANCODE_MASK;

SDLK_MODE :: Scancode.Mode | SDLK_SCANCODE_MASK;

SDLK_AUDIONEXT :: Scancode.Audio_Next | SDLK_SCANCODE_MASK;
SDLK_AUDIOPREV :: Scancode.Audio_Prev | SDLK_SCANCODE_MASK;
SDLK_AUDIOSTOP :: Scancode.Audio_Stop | SDLK_SCANCODE_MASK;
SDLK_AUDIOPLAY :: Scancode.Audio_Play | SDLK_SCANCODE_MASK;
SDLK_AUDIOMUTE :: Scancode.Audio_Mute | SDLK_SCANCODE_MASK;
SDLK_MEDIASELECT :: Scancode.Media_Select | SDLK_SCANCODE_MASK;
SDLK_WWW :: Scancode.WWW | SDLK_SCANCODE_MASK;
SDLK_MAIL :: Scancode.Mail | SDLK_SCANCODE_MASK;
SDLK_CALCULATOR :: Scancode.Calculator | SDLK_SCANCODE_MASK;
SDLK_COMPUTER :: Scancode.Computer | SDLK_SCANCODE_MASK;
SDLK_AC_SEARCH :: Scancode.Ac_Search | SDLK_SCANCODE_MASK;
SDLK_AC_HOME :: Scancode.Ac_Home | SDLK_SCANCODE_MASK;
SDLK_AC_BACK :: Scancode.Ac_Back | SDLK_SCANCODE_MASK;
SDLK_AC_FORWARD :: Scancode.Ac_Forward | SDLK_SCANCODE_MASK;
SDLK_AC_STOP :: Scancode.Ac_Stop | SDLK_SCANCODE_MASK;
SDLK_AC_REFRESH :: Scancode.Ac_Refresh | SDLK_SCANCODE_MASK;
SDLK_AC_BOOKMARKS :: Scancode.Ac_Bookmarks | SDLK_SCANCODE_MASK;

SDLK_BRIGHTNESSDOWN :: Scancode.Brightness_Down | SDLK_SCANCODE_MASK;
SDLK_BRIGHTNESSUP :: Scancode.Brightness_Up | SDLK_SCANCODE_MASK;
SDLK_DISPLAYSWITCH :: Scancode.Display_Switch | SDLK_SCANCODE_MASK;
SDLK_KBDILLUMTOGGLE :: Scancode.Kb_Dillum_Toggle | SDLK_SCANCODE_MASK;
SDLK_KBDILLUMDOWN :: Scancode.Kb_Dillum_Down | SDLK_SCANCODE_MASK;
SDLK_KBDILLUMUP :: Scancode.Kb_Dillum_Up | SDLK_SCANCODE_MASK;
SDLK_EJECT :: Scancode.Eject | SDLK_SCANCODE_MASK;
SDLK_SLEEP :: Scancode.Sleep | SDLK_SCANCODE_MASK;

SDLK_SCANCODE_MASK :: Scancode(1<<30);

Mousecode :: enum i32 {
	Left   = 1 << 0,
	Middle = 1 << 1,
	Right  = 1 << 2,
	X1 	   = 1 << 3,
	X2 	   = 1 << 4
}


Hat :: enum i32 {
	Centered = 0x00,
	Up = 0x01,
	Right = 0x02,
	Down = 0x04,
	Left = 0x08,
	Right_Up = Right | Up,
	Right_Down = Right | Down,
	Left_Up = Left | Up,
	Left_Down = Left | Down
}

Event_Type :: enum u32 {
	First_Event = 0,

	Quit = 0x100,

	App_Terminating = 257,
	App_Low_Memory = 258,
	App_Will_Enter_Background = 259,
	App_Did_Enter_Background = 260,
	App_Will_Enter_Foreground = 261,
	App_Did_Enter_Foreground = 262,

	Window_Event = 0x200,
	Sys_Wm_Event = 513,

	Key_Down = 0x300,
	Key_Up = 769,
	Text_Editing = 770,
	Text_Input = 771,
	Key_Map_Changed = 772,

	Mouse_Motion = 0x400,
	Mouse_Button_Down = 1025,
	Mouse_Button_Up = 1026,
	Mouse_Wheel = 1027,

	Joy_Axis_Motion = 0x600,
	Joy_Ball_Motion = 1537,
	Joy_Hat_Motion = 1538,
	Joy_Button_Down = 1539,
	Joy_Button_Up = 1540,
	Joy_Device_Added = 1541,
	Joy_Device_Removed = 1542,

	Controller_Axis_Motion = 0x650,
	Controller_Button_Down = 1617,
	Controller_Button_Up = 1618,
	Controller_Device_Added = 1619,
	Controller_Device_Removed = 1620,
	Controller_Device_Remapped = 1621,

	Finger_Down = 0x700,
	Finger_Up = 1793,
	Finger_Motion = 1794,

	Dollar_Gesture = 0x800,
	Dollar_Record = 2049,
	Multigesture = 2050,

	Clipboard_Update = 0x900,

	Drop_File = 0x1000,
	Drop_Text = 4097,
	Drop_Begin = 4098,
	Drop_Complete = 4099,

	Audio_Device_Added = 0x1100,
	Audio_Device_Removed = 4353,

	Render_Targets_Reset = 0x2000,
	Render_Device_Reset = 8193,

	User_Event = 0x8000,

	Last_Event = 0xFFFF
}

Window_Event_ID :: enum u8 {
    None = 0,
    Shown,
    Hidden,
    Exposed,
	Moved,
    Resized,
    Size_Changed,
    Minimized,
    Maximized,
    Restored,
    Enter,
    Leave,
    Focus_Gained,
    Focus_Lost,
    Close,
    Take_Focus,
    Hit_Test
}

GL_Context :: rawptr;

Blit_Map :: struct {};
Window :: struct {};
Renderer :: struct {};
Texture :: struct {};
Cond :: struct {};
Mutex :: struct {};
Sem :: struct {};
Thread :: struct {};
Haptic :: struct {};
Joystick :: struct {};
Game_Controller :: struct {};
Cursor :: struct {};
IDirect3D_Device9 :: struct {};
Rw_Ops :: struct {};

// Unsure of these
Sys_Wm_Info :: struct {};
Sys_Wm_Msg :: struct {};

Joystick_Id :: i32;
Timer_Id :: i32;
Spin_Lock :: i32;
Tls_Id :: u32;
Audio_Device_Id :: u32;
Audio_Device :: u32;
Audio_Format :: u16;
Keycode :: i32;
Thread_Id :: u64;
Touch_Id :: i64;
Gesture_Id :: i64;
Finger_Id :: i64;

Hint_Callback :: proc "c" (interval: u32, param: rawptr) -> u32;
Event_Filter :: proc "c" (userdata: rawptr, param: ^Event) -> i32;
Timer_Callback :: proc "c" (interval: u32, param: rawptr) -> u32;
Audio_Callback :: proc "c" (userdata: rawptr, stream: ^u8, len: i32);
Assertion_Handler :: proc "c" (data: ^Assert_Data, userdata: rawptr) -> Assert_State;
Audio_Filter :: proc "c" (cvt: ^Audio_Cvt, format: Audio_Format);
Thread_Function :: proc "c" (data: rawptr) -> i32;
Hit_Test :: proc "c" (window: ^Window, area: ^Point, data: rawptr) -> Hit_Test_Result;
Windows_Message_Hook :: proc "c" (userdata: rawptr, hwnd: rawptr, message: u32, wparam: u64, lparam: i64);
Log_Output_Function :: proc "c" (userdata: rawptr, category: Log_Category, priority: Log_Priority, message: cstring);

// Thanks gingerBill for this one!
Game_Controller_Button_Bind :: struct {
	bind_type: Game_Controller_Bind_Type,
	value: struct #raw_union {
		button: i32,
		axis:   i32,
		using hat_mask: struct {
			hat, mask: i32,
		},
	},
}

Message_Box_Data :: struct {
	flags: u32,
	window: ^Window,
	title: cstring,
	message: cstring,

	num_buttons: i32,
	buttons: ^Message_Box_Button_Data,

	color_scheme: ^Message_Box_Color_Scheme,
}

Message_Box_Button_Data :: struct {
	flags: u32,
	button_id: i32,
	text: cstring,
}

Message_Box_Color_Scheme :: struct {
	colors: [Message_Box_Color_Type.Max]Message_Box_Color,
}

Message_Box_Color :: struct {
	r, g, b: u8,
}

Assert_Data :: struct {
	always_ignore: i32,
	trigger_count: u32,
	condition: cstring,
	filename: cstring,
	linenum: i32,
	function: cstring,
	next: ^Assert_Data,
}

Window_Shape_Params :: struct #raw_union {
	binarization_cutoff: u8,
	color_key: Color,
}

Window_Shape_Mode :: struct {
	mode: Window_Shape_Modes,
	parameters: Window_Shape_Params,
}

Point :: struct {
	x: i32,
	y: i32,
}

Renderer_Info :: struct {
	name: cstring,
	flags: u32,
	num_texture_formats: u32,
	texture_formats: [16]u32,
	max_texture_width: i32,
	max_texture_height: i32,
}

Version :: struct {
	major: u8,
	minor: u8,
	patch: u8,
}

Display_Mode :: struct {
	format: u32,
	w: i32,
	h: i32,
	refresh_rate: i32,
	driver_data: rawptr,
}

Finger :: struct {
	id: Finger_Id,
	x: f32,
	y: f32,
	pressure: f32,
}

Audio_Spec :: struct {
	freq: i32,
	format: Audio_Format,
	channels: u8,
	silence: u8,
	samples: u16,
	padding: u16,
	size: u32,
	callback: Audio_Callback,
	userdata: rawptr,
}

Joystick_Guid :: struct {
	data: [16]u8,
}

Audio_Cvt :: struct {
	needed: i32,
	src_format: Audio_Format,
	dst_format: Audio_Format,
	rate_incr: i64,
	buf: ^u8,
	len: i32,
	len_cvt: i32,
	len_mult: i32,
	len_ratio: i64,
	filters: [10]Audio_Filter,
	filter_index: i32,
}

Surface :: struct {
	flags: u32,
	format: ^Pixel_Format,
	w, h: i32,
	pitch: i32,
	pixels: rawptr,

	userdata: rawptr,

	locked: i32,
	lock_data: rawptr,

	clip_rect: Rect,
	blip_map: ^Blit_Map,

	refcount: i32,
}

Color :: struct {
	r: u8,
	g: u8,
	b: u8,
	a: u8,
}

Palette :: struct {
	num_colors: i32,
	colors: ^Color,
	version: u32,
	ref_count: i32,
}

Pixel_Type :: enum u32 {
	UNKNOWN,
	INDEX1,
	INDEX4,
	INDEX8,
	PACKED8,
	PACKED16,
	PACKED32,
	ARRAYU8,
	ARRAYU16,
	ARRAYU32,
	ARRAYF16,
	ARRAYF32,
}

Bitmap_Order :: enum u32 {
	NONE,
	_4321,
	_1234,
}

Packed_Order :: enum u32 {
	NONE,
	XRGB,
	RGBX,
	ARGB,
	RGBA,
	XBGR,
	BGRX,
	ABGR,
	BGRA,
}

Array_Order :: enum {
	NONE,
	RGB,
	RGBA,
	ARGB,
	BGR,
	BGRA,
	ABGR,
}

Packed_Layout :: enum u32 {
	NONE,
	_332,
	_4444,
	_1555,
	_5551,
	_565,
	_8888,
	_2101010,
	_1010102,
}

pixel_format_enum_to_u32 :: proc(e: Pixel_Format_Enum) -> u32 {
	_pack_fourcc :: #force_inline proc (a, b, c, d: u8) -> u32 {
		return (u32(a) << 0) | (u32(b) << 8) | (u32(c) << 16) | (u32(d) << 24);
	}
	_pack_pixelformat :: #force_inline proc(auto_cast type, order, layout, bits, bytes: u32) -> u32 {
		return ((1 << 28) | (u32(type) << 24) | (order << 20) | (layout << 16) | (bits << 8) | (bytes << 0));
	}
	switch e {
	case .INDEX1LSB:    return _pack_pixelformat(Pixel_Type.INDEX1,   Bitmap_Order._4321, Packed_Layout.NONE,     1,  0);
	case .INDEX1MSB:    return _pack_pixelformat(Pixel_Type.INDEX1,   Bitmap_Order._1234, Packed_Layout.NONE,     1,  0);
	case .INDEX4LSB:    return _pack_pixelformat(Pixel_Type.INDEX4,   Bitmap_Order._4321, Packed_Layout.NONE,     4,  0);
	case .INDEX4MSB:    return _pack_pixelformat(Pixel_Type.INDEX4,   Bitmap_Order._1234, Packed_Layout.NONE,     4,  0);
	case .INDEX8:       return _pack_pixelformat(Pixel_Type.INDEX8,   Packed_Order.NONE,  Packed_Layout.NONE,     8,  1);
	case .RGB332:       return _pack_pixelformat(Pixel_Type.PACKED8,  Packed_Order.XRGB,  Packed_Layout._332,     8,  1);
	case .RGB444:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XRGB,  Packed_Layout._4444,    12, 2);
	case .BGR444:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XBGR,  Packed_Layout._4444,    12, 2);
	case .RGB555:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XRGB,  Packed_Layout._1555,    15, 2);
	case .BGR555:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XBGR,  Packed_Layout._1555,    15, 2);
	case .ARGB4444:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.ARGB,  Packed_Layout._4444,    16, 2);
	case .RGBA4444:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.RGBA,  Packed_Layout._4444,    16, 2);
	case .ABGR4444:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.ABGR,  Packed_Layout._4444,    16, 2);
	case .BGRA4444:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.BGRA,  Packed_Layout._4444,    16, 2);
	case .ARGB1555:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.ARGB,  Packed_Layout._1555,    16, 2);
	case .RGBA5551:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.RGBA,  Packed_Layout._5551,    16, 2);
	case .ABGR1555:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.ABGR,  Packed_Layout._1555,    16, 2);
	case .BGRA5551:     return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.BGRA,  Packed_Layout._5551,    16, 2);
	case .RGB565:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XRGB,  Packed_Layout._565,     16, 2);
	case .BGR565:       return _pack_pixelformat(Pixel_Type.PACKED16, Packed_Order.XBGR,  Packed_Layout._565,     16, 2);
	case .RGB24:        return _pack_pixelformat(Pixel_Type.ARRAYU8,  Array_Order.RGB,    Packed_Layout.NONE,     24, 3);
	case .BGR24:        return _pack_pixelformat(Pixel_Type.ARRAYU8,  Array_Order.BGR,    Packed_Layout.NONE,     24, 3);
	case .RGB888:       return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.XRGB,  Packed_Layout._8888,    24, 4);
	case .RGBX8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.RGBX,  Packed_Layout._8888,    24, 4);
	case .BGR888:       return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.XBGR,  Packed_Layout._8888,    24, 4);
	case .BGRX8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.BGRX,  Packed_Layout._8888,    24, 4);
	case .ARGB8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.ARGB,  Packed_Layout._8888,    32, 4);
	case .RGBA8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.RGBA,  Packed_Layout._8888,    32, 4);
	case .ABGR8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.ABGR,  Packed_Layout._8888,    32, 4);
	case .BGRA8888:     return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.BGRA,  Packed_Layout._8888,    32, 4);
	case .ARGB2101010:  return _pack_pixelformat(Pixel_Type.PACKED32, Packed_Order.ARGB,  Packed_Layout._2101010, 32, 4);
// NOTE(oskar): these duplicates cases above.
//	case .YV12:         return _pack_fourcc('Y', 'V', '1', '2');
//	case .IYUV:         return _pack_fourcc('I', 'Y', 'U', 'V');
//	case .YUY2:         return _pack_fourcc('Y', 'U', 'Y', '2');
	case .UYVY:         return _pack_fourcc('U', 'Y', 'V', 'Y');
	case .YVYU:         return _pack_fourcc('Y', 'V', 'Y', 'U');
	case .NV12:         return _pack_fourcc('N', 'V', '1', '2');
	case .NV21:         return _pack_fourcc('N', 'V', '2', '1');
	case .EXTERNAL_OES: return _pack_fourcc('O', 'E', 'S', ' ');
	case .UNKNOWN:
	}
	return 0;
}

Pixel_Format_Enum :: enum {
    UNKNOWN,
    INDEX1LSB,
    INDEX1MSB,
    INDEX4LSB,
    INDEX4MSB,
    INDEX8,
    RGB332,
    RGB444,
    BGR444,
    RGB555,
    BGR555,
    ARGB4444,
    RGBA4444,
    ABGR4444,
    BGRA4444,
    ARGB1555,
    RGBA5551,
    ABGR1555,
    BGRA5551,
    RGB565,
    BGR565,
    RGB24,
    BGR24,
    RGB888,
    RGBX8888,
    BGR888,
    BGRX8888,
    ARGB8888,
    RGBA8888,
    ABGR8888,
    BGRA8888,
    ARGB2101010,
    RGBA32 = ABGR8888,
    ARGB32 = BGRA8888,
    BGRA32 = ARGB8888,
    ABGR32 = RGBA8888,
    YV12,
    IYUV,
    YUY2,
    UYVY,
    YVYU,
    NV12,
    NV21,
    EXTERNAL_OES,
}

Pixel_Format :: struct {
	format: u32,
	palette: ^Palette,
	bits_per_pixel: u8,
	bytes_per_pixel: u8,
	padding: [2]u8,
	r_mask: u32,
	g_mask: u32,
	b_mask: u32,
	a_mask: u32,
	r_loss: u8,
	g_loss: u8,
	b_loss: u8,
	a_loss: u8,
	r_shift: u8,
	g_shift: u8,
	b_shift: u8,
	a_shift: u8,
	ref_count: i32,
	next: ^Pixel_Format,
}

Rect :: struct {
	x, y: i32,
	w, h: i32,
}

Atomic :: struct {
	value: i32,
}

Keysym :: struct {
	scancode: Scancode,
	sym: i32,
	mod: u16,
	unused: u32,
}

Haptic_Effect :: struct #raw_union {
	haptic_type: u16,
	constant: Haptic_Constant,
	periodic: Haptic_Periodic,
	condition: Haptic_Condition,
	ramp: Haptic_Ramp,
	left_right: Haptic_Left_Right,
	custom: Haptic_Custom,
}

Haptic_Constant :: struct {
	haptic_type: u16,
	direction: Haptic_Direction,

	length: u32,
	delay: u16,

	button: u16,
	interval: u16,

	level: i16,

	attack_length: u16,
	attack_level: u16,
	fade_length: u16,
	fade_level: u16,
}

Haptic_Periodic :: struct {
	haptic_type: u16,
	direction: Haptic_Direction,

	length: u32,
	delay: u16,

	button: u16,
	interval: u16,

	period: u16,
	magnitude: i16,
	offset: i16,
	phase: u16,

	attack_length: u16,
	attack_level: u16,
	fade_length: u16,
	fade_level: u16,
}

Haptic_Direction :: struct {
	haptic_type: u8,
	dir: [3]i32,
}

Haptic_Condition :: struct {
	haptic_type: u16,
	direction: Haptic_Direction,

	length: u32,
	delay: u16,

	button: u16,
	interval: u16,

	right_sat: [3]u16,
	left_sat: [3]u16,
	right_coeff: [3]i16,
	left_coeff: [3]i16,
	dead_band: [3]u16,
	center: [3]i16,
}

Haptic_Ramp :: struct {
	haptic_type: u16,
	direction: Haptic_Direction,

	length: u32,
	delay: u16,

	button: u16,
	interval: u16,

	start: i16,
	end: i16,

	attack_length: u16,
	attack_level: u16,
	fade_length: u16,
	fade_level: u16,
}

Haptic_Left_Right :: struct {
	haptic_type: u16,

	length: u32,

	large_magnitude: u16,
	small_magnitude: u16,
}

Haptic_Custom :: struct {
	haptic_type: u16,
	direction: Haptic_Direction,

	length: u32,
	delay: u16,

	button: u16,
	interval: u16,

	channels: u8,
	period: u16,
	samples: u16,
	data: ^u16,

	attack_length: u16,
	attack_level: u16,
	fade_length: u16,
	fade_level: u16,
}

Event :: struct #raw_union {
	type: Event_Type,
	common: Common_Event,
	window: Window_Event,
	key: Keyboard_Event,
	edit: Text_Editing_Event,
	text: Text_Input_Event,
	motion: Mouse_Motion_Event,
	button: Mouse_Button_Event,
	wheel: Mouse_Wheel_Event,
	jaxis: Joy_Axis_Event,
	jball: Joy_Ball_Event,
	jhat: Joy_Hat_Event,
	jbutton: Joy_Button_Event,
	jdevice: Joy_Device_Event,
	caxis: Controller_Axis_Event,
	cbutton: Controller_Button_Event,
	cdevice: Controller_Device_Event,
	adevice: Audio_Device_Event,
	quit: Quit_Event,
	user: User_Event,
	syswm: Sys_Wm_Event,
	tfinger: Touch_Finger_Event,
	mgesture: Multi_Gesture_Event,
	dgesture: Dollar_Gesture_Event,
	drop: Drop_Event,

	padding: [56]u8,
}

Common_Event :: struct {
	type: Event_Type,
	timestamp: u32,
}

Window_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	event: Window_Event_ID,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	data1: i32,
	data2: i32,
}

Keyboard_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	state: u8,
	repeat: u8,
	padding2: u8,
	padding3: u8,
	keysym: Keysym,
}

TEXT_EDITING_EVENT_TEXT_SIZE :: 32;
Text_Editing_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	text: [TEXT_EDITING_EVENT_TEXT_SIZE]u8,
	start: i32,
	length: i32,
}


TEXT_INPUT_EVENT_TEXT_SIZE :: 32;
Text_Input_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	text: [TEXT_INPUT_EVENT_TEXT_SIZE]u8,
}

Mouse_Motion_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	which: u32,
	state: u32,
	x: i32,
	y: i32,
	xrel: i32,
	yrel: i32,
}

Mouse_Button_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	which: u32,
	button: u8,
	state: u8,
	clicks: u8,
	padding1: u8,
	x: i32,
	y: i32,
}

Mouse_Wheel_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	which: u32,
	x: i32,
	y: i32,
	direction: u32,
}

Joy_Axis_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	axis: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	value: i16,
	padding4: u16,
}

Joy_Ball_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	ball: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	xrel: i16,
	yrel: i16,
}

Joy_Hat_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	hat: u8,
	value: u8,
	padding1: u8,
	padding2: u8,
}

Joy_Button_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	button: u8,
	state: u8,
	padding1: u8,
	padding2: u8,
}

Joy_Device_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
}

Controller_Axis_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	axis: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
	value: i16,
	padding4: u16,
}

Controller_Button_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
	button: u8,
	state: u8,
	padding1: u8,
	padding2: u8,
}

Controller_Device_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: i32,
}

Audio_Device_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	which: u32,
	iscapture: u8,
	padding1: u8,
	padding2: u8,
	padding3: u8,
}

Touch_Finger_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	touch_id: i64,
	finger_id: i64,
	x: f32,
	y: f32,
	dx: f32,
	dy: f32,
	pressure: f32,
}

Multi_Gesture_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	touch_id: i64,
	d_theta: f32,
	d_dist: f32,
	x: f32,
	y: f32,
	num_fingers: u16,
	padding: u16,
}

Dollar_Gesture_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	touch_id: i64,
	gesture_id: i64,
	num_fingers: u32,
	error: f32,
	x: f32,
	y: f32,
}

Drop_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	file: cstring,
	window_id: u32,
}

Quit_Event :: struct {
	type: Event_Type,
	timestamp: u32,
}

OS_Event :: struct {
	type: Event_Type,
	timestamp: u32,
}

User_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	window_id: u32,
	code: i32,
	data1: ^rawptr,
	data2: ^rawptr,
}

Sys_Wm_Event :: struct {
	type: Event_Type,
	timestamp: u32,
	msg: ^Sys_Wm_Msg,
}
