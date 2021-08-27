package microui_demo

import "sdl"
import mu  "../"

import "core:fmt"
import "core:log"
import "core:time"
import "core:reflect"
import "core:strings"

bg: [3]u8 = { 90, 95, 100 };
frame_stats: Frame_Stats;

logbuf: strings.Builder;
logbuf_updated: bool;

Frame_Stats :: struct {
	samples:      [100] time.Duration,
	sample_index: int,
	sample_sum:   time.Duration,
	mspf, fps:    f64,
	last_update:  time.Time,
}

init_frame_stats :: proc(using _: ^Frame_Stats) {
	now := time.now();
	last_update = now;
}

update_frame_stats :: proc(using _: ^Frame_Stats) {
	now := time.now();
	dt := time.diff(last_update, now);
	last_update = now;

	sample_sum -= samples[sample_index];
	samples[sample_index] = dt;
	sample_sum += dt;
	sample_index = (sample_index + 1) % len(samples);

	fps = len(samples) / time.duration_seconds(sample_sum);
	mspf = 1000.0 * time.duration_seconds(sample_sum) / len(samples);
}

main :: proc() {
	context.logger = log.create_console_logger(ident = "demo");

	logbuf = strings.make_builder();

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

	text_width  :: #force_inline proc(font: mu.Font, text: string) -> i32 do return r_get_text_width(text);
	text_height :: #force_inline proc(font: mu.Font) -> i32 do return r_get_text_height();
	ctx.text_width = text_width;
	ctx.text_height = text_height;

	init_frame_stats(&frame_stats);
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
				button_map :: #force_inline proc(button: u8) -> (res: mu.Mouse, ok: bool) {
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

				key_map :: #force_inline proc(x: i32) -> (res: mu.Key, ok: bool) {
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

		update_frame_stats(&frame_stats);
	} // main_loop

	sdl.quit();
}

process_frame :: proc(ctx: ^mu.Context) {
	mu.begin(ctx);
	test_window(ctx);
	log_window(ctx);
	style_window(ctx);
	mu.end(ctx);
}

test_window :: proc(ctx: ^mu.Context) {
	@static opts: mu.Opt_Bits;

	// NOTE(oskar): mu.button() returns Res_Bits and not bool (should fix this)
	button :: #force_inline proc(ctx: ^mu.Context, label: string) -> bool do return mu.button(ctx, label) == {.SUBMIT};

	/* do window */
	if mu.begin_window(ctx, "Demo Window", {40,40,300,450}, opts) {
		if mu.header(ctx, "Frame Stats") != {} {
			mu.layout_row(ctx, 1, []i32{-1}, 0);
			mu.text(ctx, fmt.tprintf("FPS %v MSPF %v", frame_stats.fps, frame_stats.mspf));
		}

		if mu.header(ctx, "Window Options") != {} {
			win := mu.get_current_container(ctx);
			mu.layout_row(ctx, 3, []i32{120, 120, 120}, 0);
			for opt in mu.Opt {
				state: bool = opt in opts;
				if mu.checkbox(ctx, fmt.tprintf("%v", opt), &state) != {} {
					if state {
						opts |= {opt};
					}
					else {
						opts &~= {opt};
					}
				}
			}
		}

		/* window info */
		if mu.header(ctx, "Window Info") != {} {
			win := mu.get_current_container(ctx);
			mu.layout_row(ctx, 2, []i32{ 54, -1 }, 0);
			mu.label(ctx, "Position:");
			mu.label(ctx, fmt.tprintf("%d, %d", win.rect.x, win.rect.y));
			mu.label(ctx, "Size:");
			mu.label(ctx, fmt.tprintf("%d, %d", win.rect.w, win.rect.h));
		}

		/* labels + buttons */
		if mu.header(ctx, "Test Buttons", {.EXPANDED}) != {} {
			mu.layout_row(ctx, 3, []i32{ 86, -110, -1 }, 0);
			mu.label(ctx, "Test buttons 1:");
			if button(ctx, "Button 1") do write_log("Pressed button 1");
			if button(ctx, "Button 2") do write_log("Pressed button 2");
			mu.label(ctx, "Test buttons 2:");
			if button(ctx, "Button 3") do write_log("Pressed button 3");
			if button(ctx, "Button 4") do write_log("Pressed button 4");
		}

		/* tree */
		if mu.header(ctx, "Tree and Text", {.EXPANDED}) != {} {
			mu.layout_row(ctx, 2, []i32{ 140, -1 }, 0);
			mu.layout_begin_column(ctx);
			if mu.begin_treenode(ctx, "Test 1") != {} {
				if mu.begin_treenode(ctx, "Test 1a") != {} {
					mu.label(ctx, "Hello");
					mu.label(ctx, "world");
					mu.end_treenode(ctx);
				}
				if mu.begin_treenode(ctx, "Test 1b") != {} {
					if button(ctx, "Button 1") do write_log("Pressed button 1");
					if button(ctx, "Button 2") do write_log("Pressed button 2");
					mu.end_treenode(ctx);
				}
				mu.end_treenode(ctx);
			}
			if mu.begin_treenode(ctx, "Test 2") != {} {
				mu.layout_row(ctx, 2, []i32{ 54, 54 }, 0);
				if button(ctx, "Button 3") do write_log("Pressed button 3");
				if button(ctx, "Button 4") do write_log("Pressed button 4");
				if button(ctx, "Button 5") do write_log("Pressed button 5");
				if button(ctx, "Button 6") do write_log("Pressed button 6");
				mu.end_treenode(ctx);
			}
			if mu.begin_treenode(ctx, "Test 3") != {} {
				@static checks := [3]bool{ true, false, true };
				mu.checkbox(ctx, "Checkbox 1", &checks[0]);
				mu.checkbox(ctx, "Checkbox 2", &checks[1]);
				mu.checkbox(ctx, "Checkbox 3", &checks[2]);
				mu.end_treenode(ctx);
			}
			mu.layout_end_column(ctx);

			mu.layout_begin_column(ctx);
			mu.layout_row(ctx, 1, []i32{ -1 }, 0);
			mu.text(ctx, "Lorem ipsum\n dolor sit amet, consectetur adipiscing elit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus ipsum, eu varius magna felis a nulla.");
			mu.layout_end_column(ctx);
		}

		/* background color sliders */
		if mu.header(ctx, "Background Color", {.EXPANDED}) != {} {
			mu.layout_row(ctx, 2, []i32{ -78, -1 }, 74);
			/* sliders */
			mu.layout_begin_column(ctx);
			mu.layout_row(ctx, 2, []i32{ 46, -1 }, 0);
			mu.label(ctx, "Red:");   uint8_slider(ctx, &bg[0], 0, 255);
			mu.label(ctx, "Green:"); uint8_slider(ctx, &bg[1], 0, 255);
			mu.label(ctx, "Blue:");  uint8_slider(ctx, &bg[2], 0, 255);
			mu.layout_end_column(ctx);
			/* color preview */
			r := mu.layout_next(ctx);
			mu.draw_rect(ctx, r, mu.Color{bg[0], bg[1], bg[2], 255});
			mu.draw_control_text(ctx, fmt.tprintf("#%02X%02X%02X", bg[0], bg[1], bg[2]), r, .TEXT, {.ALIGNCENTER});
		}

		mu.end_window(ctx);
	}
}

@private uint8_slider :: proc(ctx: ^mu.Context, value: ^u8, low, high: int) -> (res: mu.Res_Bits) {
	using mu;
	@static tmp: Real;
	push_id(ctx, uintptr(value));
	tmp = Real(value^);
	res = slider(ctx, &tmp, Real(low), Real(high), 0, "%.0f", {.ALIGNCENTER});
	value^ = u8(tmp);
	pop_id(ctx);
	return;
}


@private write_log :: proc(text: string) {
	strings.write_string(&logbuf, text);
	strings.write_string(&logbuf, "\n");
	logbuf_updated = true;
}

@private log_window :: proc(ctx: ^mu.Context) {
	using mu;

	if begin_window(ctx, "Log Window", Rect{350,40,300,200}) {
		/* output text panel */
		layout_row(ctx, 1, { -1 }, -28);
		begin_panel(ctx, "Log Output");
		panel := get_current_container(ctx);
		layout_row(ctx, 1, { -1 }, -1);
		text(ctx, strings.to_string(logbuf));
		end_panel(ctx);
		if logbuf_updated {
			panel.scroll.y = panel.content_size.y;
			logbuf_updated = false;
		}

		/* input textbox + submit button */
		@static textlen: int;
		@static textbuf: [128] byte;
		submitted := false;
		layout_row(ctx, 2, { -70, -1 }, 0);
		if .SUBMIT in textbox(ctx, textbuf[:], &textlen) {
			set_focus(ctx, ctx.last_id);
			submitted = true;
		}
		if button(ctx, "Submit") != {} do submitted = true;
		if submitted {
			textstr := string(textbuf[:textlen]);
			write_log(textstr);
			textlen = 0;
		}

		end_window(ctx);
	}
}

@private style_window :: proc(ctx: ^mu.Context) {
	using mu;

	if begin_window(ctx, "Style Editor", Rect{350,250,300,240}) {
		sw := i32(Real(get_current_container(ctx).body.w) * 0.14);
		layout_row(ctx, 6, { 80, sw, sw, sw, sw, -1 }, 0);
		for c in Color_Type {
			label(ctx, fmt.tprintf("%s:", reflect.enum_string(c)));
			uint8_slider(ctx, &ctx.style.colors[c].r, 0, 255);
			uint8_slider(ctx, &ctx.style.colors[c].g, 0, 255);
			uint8_slider(ctx, &ctx.style.colors[c].b, 0, 255);
			uint8_slider(ctx, &ctx.style.colors[c].a, 0, 255);
			draw_rect(ctx, layout_next(ctx), ctx.style.colors[c]);
		}
		end_window(ctx);
	}
}
