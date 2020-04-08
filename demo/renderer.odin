package microui_demo

import sdl "./odin-sdl2"
import mu  "../"

import "core:mem"
import "core:log"

window:        ^sdl.Window;
renderer:      ^sdl.Renderer;
atlas_texture: ^sdl.Texture;

width:  i32 = 800;
height: i32 = 600;

@(private="file")
logger: log.Logger = log.create_console_logger(ident = "renderer");

r_test :: proc() {
	WHITE   :: mu.Color{255,255,255,255};
	BLACK   :: mu.Color{0,0,0,255};
	MAGENTA :: mu.Color{255,0,255,255};

	context.logger = logger;

	r_clear(MAGENTA);
	r_set_clip_rect({0,0,160,height});
	r_draw_rect({100,100,100,100}, BLACK);
	r_draw_rect({100+2,100+2,100-4,100-4}, WHITE);
	r_draw_icon(.EXPANDED, {100,100,100,100}, BLACK);
	r_draw_text("Hellope", {0,0}, WHITE);
}

r_init :: proc() -> (ok: bool) {
	context.logger = logger;

	window = sdl.create_window(title = "microui-odin", x = cast(i32) sdl.Window_Pos.Undefined, y = cast(i32) sdl.Window_Pos.Undefined, w = width, h = height, flags = .Shown | .Resizable);
	if window == nil {
		log.error("create_window(): ", sdl.get_error());
		return false;
	}

	log.info("================================================================================");
	log.info("Querying available render drivers");

	if n := sdl.get_num_render_drivers(); n <= 0 {
		log.error("No render drivers available");
		return false;
	} else do for i in 0..<n {
		info: sdl.Renderer_Info = ---;
		if err := sdl.get_render_driver_info(i, &info); err == 0 {
			log.infof("[%d]: %v", i, info);
		} else {
			log.warn("get_render_driver_info(): ", sdl.get_error());
		}
	}

	log.info("--------------------------------------------------------------------------------");

	sdl.set_hint("SDL_RENDER_SCALE_QUALITY", "nearest");

	renderer = sdl.create_renderer(window, -1, .Accelerated /* |.Present_VSync */);
	if renderer == nil {
		log.error("create_renderer(): ", sdl.get_error());
		return false;
	}

	info: sdl.Renderer_Info;
	if err := sdl.get_renderer_info(renderer, &info); err == 0 do log.info("Selected renderer: ", info);
	else do log.warn("get_renderer_info(): ", sdl.get_error());

	log.info("================================================================================");

	// Atlas image data contains only alpha values, need to expand this to RGBA8
	// (solution from https://github.com/floooh/sokol-samples/blob/master/sapp/sgl-microui-sapp.c)
	rgba8_pixels := mem.make([]u32, ATLAS_WIDTH * ATLAS_HEIGHT);
	defer delete(rgba8_pixels);
	for y in 0..<ATLAS_HEIGHT {
		#no_bounds_check for x in 0..<ATLAS_WIDTH {
			index := y*ATLAS_WIDTH + x;
			rgba8_pixels[index] = 0x00FFFFFF | (u32(atlas_alpha[index]) << 24);
		}
	}

	atlas_texture = sdl.create_texture(renderer, sdl.pixel_format_enum_to_u32(.RGBA32), i32(sdl.Texture_Access.Target), ATLAS_WIDTH, ATLAS_HEIGHT);
	assert(atlas_texture != nil);
	sdl.set_texture_blend_mode(atlas_texture, .Blend);
	if err := sdl.update_texture(atlas_texture, nil, &rgba8_pixels[0], 4*ATLAS_WIDTH); err != 0 {
		log.error("sdl.update_texture(): ", sdl.get_error());
		return false;
	}

	return true;
}

r_set_clip_rect :: proc(using rect: mu.Rect) {
	rect := transmute(sdl.Rect) rect;
	sdl.render_set_clip_rect(renderer, &rect);
}

r_draw_icon :: proc(id: mu.Icon, rect: mu.Rect, color: mu.Color) {
	src := atlas[int(id)];
	x := rect.x + (rect.w - src.w) / 2;
	y := rect.y + (rect.h - src.h) / 2;
	atlas_quad({x, y, src.w, src.h}, src, color);
}

r_draw_rect :: proc(rect: mu.Rect, using color: mu.Color) {
	atlas_quad(rect, atlas[ATLAS_WHITE], color);

	// NOTE(oskar): alternative implementation since SDL2 supports filled rects.
	// rect := transmute(sdl.Rect) rect;
	// sdl.set_render_draw_color(renderer, r, g, b, a);
	// sdl.render_fill_rect(renderer, &rect);
}

r_draw_text :: proc(text: string, pos: mu.Vec2, color: mu.Color) {
	dst := mu.Rect{ pos.x, pos.y, 0, 0 };
	for ch in text {
		if ch&0xc0 == 0x80 do continue;
		chr := min(int(ch), 127);
		src := atlas[ATLAS_FONT + chr];
		dst.w = src.w;
		dst.h = src.h;
		atlas_quad(dst, src, color);
		dst.x += dst.w;
	}
}

r_get_text_width :: proc(text: string) -> (res: i32) {
	for ch in text {
		if ch&0xc0 == 0x80 do continue;
		chr := min(int(ch), 127);
		res += atlas[ATLAS_FONT + chr].w;
	}
	return;
}

r_get_text_height :: proc() -> i32 {
	return 18;
}

r_clear :: proc(using color: mu.Color) {
	sdl.set_render_draw_color(renderer, r, g, b, a);
	sdl.render_clear(renderer);
}

r_present :: proc() {
	sdl.render_present(renderer);
}

@(private="file")
atlas_quad :: proc(dst, src: mu.Rect, using color: mu.Color) {
	src := transmute(sdl.Rect) src;
	dst := transmute(sdl.Rect) dst;
	sdl.set_texture_color_mod(atlas_texture, r, g, b);
	sdl.render_copy(renderer, atlas_texture, &src, &dst);
}
