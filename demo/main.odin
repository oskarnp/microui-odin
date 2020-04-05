package microui_demo

import sdl "./odin-sdl2"
import mu  "../"

import "core:fmt"
import "core:log"

@static bg: [3]u8 = { 90, 95, 100 };

main :: proc() {
	context.logger = log.create_console_logger(ident = "demo");

	/* init SDL and renderer */
	if err := sdl.init(.Video); err != 0 {
		log.error("init(): ", sdl.get_error());
		return;
	}
	if ok := r_init(); !ok {
		return;
	}

	/* init microui */
	ctx := new(mu.Context);
	defer free(ctx);
	mu.init(ctx);

	text_width  :: inline proc(font: mu.Font, text: string) -> i32 do return r_get_text_width(text);
	text_height :: inline proc(font: mu.Font) -> i32 do return r_get_text_height();
	ctx.text_width = text_width;
	ctx.text_height = text_height;

	main_loop: for {
		/* handle SDL events */
		e: sdl.Event = ---;
		for sdl.poll_event(&e) != 0 {
			#partial switch e.type {
			case .Quit: break main_loop;
			case .Mouse_Motion: mu.input_mousemove(ctx, e.motion.x, e.motion.y);
			case .Mouse_Wheel: mu.input_scroll(ctx, 0, e.wheel.y * -30);
			case .Text_Input: mu.input_text(ctx, string(cstring(&e.text.text[0])));

			case .Mouse_Button_Down, .Mouse_Button_Up:
				button_map :: inline proc(button: u8) -> (res: mu.Mouse, ok: bool) {
					ok = true;
					switch button {
						case 1: res = .LEFT;
						case 2: res = .MIDDLE;
						case 3: res = .RIGHT;
						case: ok = false;
					}
					return;
				}
				if btn, ok := button_map(e.button.button); ok {
					switch {
					case e.type == .Mouse_Button_Down: mu.input_mousedown(ctx, e.button.x, e.button.y, btn);
					case e.type == .Mouse_Button_Up:   mu.input_mouseup(ctx, e.button.x, e.button.y, btn);
					}
				}

			case .Key_Down, .Key_Up:
				if e.type == .Key_Up && e.key.keysym.sym == sdl.SDLK_ESCAPE {
					quit_event: sdl.Event;
					quit_event.type = .Quit;
					sdl.push_event(&quit_event);
				}

				key_map :: inline proc(x: i32) -> (res: mu.Key, ok: bool) {
					ok = true;
					switch x {
						case cast(i32)sdl.SDLK_LSHIFT:    res = .SHIFT;
						case cast(i32)sdl.SDLK_RSHIFT:    res = .SHIFT;
						case cast(i32)sdl.SDLK_LCTRL:     res = .CTRL;
						case cast(i32)sdl.SDLK_RCTRL:     res = .CTRL;
						case cast(i32)sdl.SDLK_LALT:      res = .ALT;
						case cast(i32)sdl.SDLK_RALT:      res = .ALT;
						case cast(i32)sdl.SDLK_RETURN:    res = .RETURN;
						case cast(i32)sdl.SDLK_BACKSPACE: res = .BACKSPACE;
						case: ok = false;
					}
					return;
				}
				if key, ok := key_map(e.key.keysym.sym); ok {
					switch {
					case e.type == .Key_Down: mu.input_keydown(ctx, key);
					case e.type == .Key_Up:   mu.input_keyup(ctx, key);
					}
				}
			}
		}

		/* process frame */
		process_frame(ctx);

		/* render */
		r_clear(mu.Color{bg[0], bg[1], bg[2], 255});
		cmd: ^mu.Command;
		for mu.next_command(ctx, &cmd) {
			switch cmd.type {
			case .TEXT: r_draw_text(cmd.text.str, cmd.text.pos, cmd.text.color);
			case .RECT: r_draw_rect(cmd.rect.rect, cmd.rect.color);
			case .ICON: r_draw_icon(cmd.icon.id, cmd.icon.rect, cmd.icon.color);
			case .CLIP: r_set_clip_rect(cmd.clip.rect);
			case .JUMP: unreachable(); /* handled internally by next_command() */
			}
		}

		//r_test();

		r_present();
	} // main_loop

	sdl.quit();
}

process_frame :: proc(ctx: ^mu.Context) {
	mu.begin(ctx);
	test_window(ctx);
	//log_window(ctx);
	//style_window(ctx);
	mu.end(ctx);
}

write_log :: proc(text: string) {
	// TODO(oskar)
}

test_window :: proc(ctx: ^mu.Context) {
	@static window: mu.Container;

	// NOTE(oskar): mu.button() returns Res_Bits and not bool (should fix this)
	button :: inline proc(ctx: ^mu.Context, label: string) -> bool do return mu.button(ctx, label) == {.SUBMIT};

	/* init window manually so we can set its position and size */
	if !window.inited {
		mu.init_window(ctx, &window);
		window.rect = mu.Rect{40, 40, 300, 450};
	}

	/* limit window to minimum size */
	window.rect.w = max(window.rect.w, 240);
	window.rect.h = max(window.rect.h, 300);

	/* do window */
	if mu.begin_window(ctx, &window, "Demo Window") {
		/* window info */
		@static show_info := false;
		if mu.header(ctx, &show_info, "Window Info") != {} {
			mu.layout_row(ctx, 2, []i32{ 54, -1 }, 0);
			mu.label(ctx, "Position:");
			mu.label(ctx, fmt.tprintf("%d, %d", window.rect.x, window.rect.y));
			mu.label(ctx, "Size:");
			mu.label(ctx, fmt.tprintf("%d, %d", window.rect.w, window.rect.h));
		}

		/* labels + buttons */
		@static show_buttons := true;
		if mu.header(ctx, &show_buttons, "Test Buttons") != {} {
			mu.layout_row(ctx, 3, []i32{ 86, -110, -1 }, 0);
			mu.label(ctx, "Test buttons 1:");
			if button(ctx, "Button 1") do write_log("Pressed button 1");
			if button(ctx, "Button 2") do write_log("Pressed button 2");
			mu.label(ctx, "Test buttons 2:");
			if button(ctx, "Button 3") do write_log("Pressed button 3");
			if button(ctx, "Button 4") do write_log("Pressed button 4");
		}

		/* tree */
		@static show_tree := true;
		if mu.header(ctx, &show_tree, "Tree and Text") != {} {
			mu.layout_row(ctx, 2, []i32{ 140, -1 }, 0);
			mu.layout_begin_column(ctx);
			@static states: [8]bool;
			if mu.begin_treenode(ctx, &states[0], "Test 1") != {} {
				if mu.begin_treenode(ctx, &states[1], "Test 1a") != {} {
					mu.label(ctx, "Hello");
					mu.label(ctx, "world");
					mu.end_treenode(ctx);
				}
				if mu.begin_treenode(ctx, &states[2], "Test 1b") != {} {
					if button(ctx, "Button 1") do write_log("Pressed button 1");
					if button(ctx, "Button 2") do write_log("Pressed button 2");
					mu.end_treenode(ctx);
				}
				mu.end_treenode(ctx);
			}
			if mu.begin_treenode(ctx, &states[3], "Test 2") != {} {
				mu.layout_row(ctx, 2, []i32{ 54, 54 }, 0);
				if button(ctx, "Button 3") do write_log("Pressed button 3");
				if button(ctx, "Button 4") do write_log("Pressed button 4");
				if button(ctx, "Button 5") do write_log("Pressed button 5");
				if button(ctx, "Button 6") do write_log("Pressed button 6");
				mu.end_treenode(ctx);
			}
			if mu.begin_treenode(ctx, &states[4], "Test 3") != {} {
				@static checks := [3]bool{ true, false, true };
				mu.checkbox(ctx, &checks[0], "Checkbox 1");
				mu.checkbox(ctx, &checks[1], "Checkbox 2");
				mu.checkbox(ctx, &checks[2], "Checkbox 3");
				mu.end_treenode(ctx);
			}
			mu.layout_end_column(ctx);

			mu.layout_begin_column(ctx);
			mu.layout_row(ctx, 1, []i32{ -1 }, 0);
			mu.text(ctx, "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus ipsum, eu varius magna felis a nulla.");
			mu.layout_end_column(ctx);
		}

		/* background color sliders */
		@static show_sliders := true;
		if mu.header(ctx, &show_sliders, "Background Color") != {} {
			mu.layout_row(ctx, 2, []i32{ -78, -1 }, 74);
			/* sliders */
			mu.layout_begin_column(ctx);
			mu.layout_row(ctx, 2, []i32{ 46, -1 }, 0);
			// TODO(oskar)
			// mu.label(ctx, "Red:");   mu.slider(ctx, &bg[0], 0, 255);
			// mu.label(ctx, "Green:"); mu.slider(ctx, &bg[1], 0, 255);
			// mu.label(ctx, "Blue:");  mu.slider(ctx, &bg[2], 0, 255);
			mu.layout_end_column(ctx);
			/* color preview */
			r := mu.layout_next(ctx);
			mu.draw_rect(ctx, r, mu.Color{bg[0], bg[1], bg[2], 255});
			mu.draw_control_text(ctx, fmt.tprintf("#%02X%02X%02X", bg[0], bg[1], bg[2]), r, .TEXT, {.ALIGNCENTER});
		}

		mu.end_window(ctx);
	}
}

/*
static void log_window(mu_Context *ctx) {
  static mu_Container window;

  /* init window manually so we can set its position and size */
  if (!window.inited) {
	mu_init_window(ctx, &window, 0);
	window.rect = mu_rect(350, 40, 300, 200);
  }

  if (mu_begin_window(ctx, &window, "Log Window")) {

	/* output text panel */
	static mu_Container panel;
	mu_layout_row(ctx, 1, (int[]) { -1 }, -28);
	mu_begin_panel(ctx, &panel);
	mu_layout_row(ctx, 1, (int[]) { -1 }, -1);
	mu_text(ctx, logbuf);
	mu_end_panel(ctx);
	if (logbuf_updated) {
	  panel.scroll.y = panel.content_size.y;
	  logbuf_updated = 0;
	}

	/* input textbox + submit button */
	static char buf[128];
	int submitted = 0;
	mu_layout_row(ctx, 2, (int[]) { -70, -1 }, 0);
	if (mu_textbox(ctx, buf, sizeof(buf)) & MU_RES_SUBMIT) {
	  mu_set_focus(ctx, ctx->last_id);
	  submitted = 1;
	}
	if (mu_button(ctx, "Submit")) { submitted = 1; }
	if (submitted) {
	  write_log(buf);
	  buf[0] = '\0';
	}

	mu_end_window(ctx);
  }
}


static int uint8_slider(mu_Context *ctx, unsigned char *value, int low, int high) {
  static float tmp;
  mu_push_id(ctx, &value, sizeof(value));
  tmp = *value;
  int res = mu_slider_ex(ctx, &tmp, low, high, 0, "%.0f", MU_OPT_ALIGNCENTER);
  *value = tmp;
  mu_pop_id(ctx);
  return res;
}


static void style_window(mu_Context *ctx) {
  static mu_Container window;

  /* init window manually so we can set its position and size */
  if (!window.inited) {
	mu_init_window(ctx, &window, 0);
	window.rect = mu_rect(350, 250, 300, 240);
  }

  static struct { const char *label; int idx; } colors[] = {
	{ "text:",         MU_COLOR_TEXT        },
	{ "border:",       MU_COLOR_BORDER      },
	{ "windowbg:",     MU_COLOR_WINDOWBG    },
	{ "titlebg:",      MU_COLOR_TITLEBG     },
	{ "titletext:",    MU_COLOR_TITLETEXT   },
	{ "panelbg:",      MU_COLOR_PANELBG     },
	{ "button:",       MU_COLOR_BUTTON      },
	{ "buttonhover:",  MU_COLOR_BUTTONHOVER },
	{ "buttonfocus:",  MU_COLOR_BUTTONFOCUS },
	{ "base:",         MU_COLOR_BASE        },
	{ "basehover:",    MU_COLOR_BASEHOVER   },
	{ "basefocus:",    MU_COLOR_BASEFOCUS   },
	{ "scrollbase:",   MU_COLOR_SCROLLBASE  },
	{ "scrollthumb:",  MU_COLOR_SCROLLTHUMB },
	{ NULL }
  };

  if (mu_begin_window(ctx, &window, "Style Editor")) {
	int sw = mu_get_container(ctx)->body.w * 0.14;
	mu_layout_row(ctx, 6, (int[]) { 80, sw, sw, sw, sw, -1 }, 0);
	for (int i = 0; colors[i].label; i++) {
	  mu_label(ctx, colors[i].label);
	  uint8_slider(ctx, &ctx->style->colors[i].r, 0, 255);
	  uint8_slider(ctx, &ctx->style->colors[i].g, 0, 255);
	  uint8_slider(ctx, &ctx->style->colors[i].b, 0, 255);
	  uint8_slider(ctx, &ctx->style->colors[i].a, 0, 255);
	  mu_draw_rect(ctx, mu_layout_next(ctx), ctx->style->colors[i]);
	}
	mu_end_window(ctx);
  }
}
*/
