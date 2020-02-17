/*
** Copyright (c) 2019 rxi
** Copyright (c) 2020 oskarnp
**
** Permission is hereby granted, free of charge, to any person obtaining a copy
** of this software and associated documentation files (the "Software"), to
** deal in the Software without restriction, including without limitation the
** rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
** sell copies of the Software, and to permit persons to whom the Software is
** furnished to do so, subject to the following conditions:
**
** The above copyright notice and this permission notice shall be included in
** all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
** IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
** FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
** AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
** LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
** FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
** IN THE SOFTWARE.
*/

package microui

import "core:fmt"
import "core:runtime"
import "core:mem"
import "core:sort"
import "core:builtin"
import "core:strings"

MU_VERSION :: "1.02";

MU_COMMANDLIST_SIZE     :: (1024 * 256);
MU_ROOTLIST_SIZE        :: 32;
MU_CONTAINERSTACK_SIZE  :: 32;
MU_CLIPSTACK_SIZE       :: 32;
MU_IDSTACK_SIZE         :: 32;
MU_LAYOUTSTACK_SIZE     :: 16;
MU_MAX_WIDTHS           :: 16;
MU_REAL                 :: f32;
MU_REAL_FMT             :: "%.3g";
MU_SLIDER_FMT           :: "%.2f";
MU_MAX_FMT              :: 127;

Stack :: struct(T: typeid, N: int) {
	idx:   int,
	items: [N] T,
}

// TODO(oskar): remove this, just use the builtins directly
mu_min   :: builtin.min;
mu_max   :: builtin.max;
mu_clamp :: builtin.clamp;

Clip :: enum {
	NONE,
	PART,
	ALL
}

Command_Type :: enum i32 {
	JUMP = 1,
	CLIP,
	RECT,
	TEXT,
	ICON,
	MAX
}

Color_Type :: enum {
	TEXT,
	BORDER,
	WINDOWBG,
	TITLEBG,
	TITLETEXT,
	PANELBG,
	BUTTON,
	BUTTONHOVER = BUTTON+1,
	BUTTONFOCUS = BUTTON+2,
	BASE,
	BASEHOVER = BASE+1,
	BASEFOCUS = BASE+2,
	SCROLLBASE,
	SCROLLTHUMB
}

Icon :: enum i32 {
	CLOSE = 1,
	CHECK,
	COLLAPSED,
	EXPANDED,
	MAX
}

Res :: enum {
	ACTIVE,
	SUBMIT,
	CHANGE,
}
Res_Bits :: bit_set[Res];

Opt :: enum {
	ALIGNCENTER,
	ALIGNRIGHT,
	NOINTERACT,
	NOFRAME,
	NORESIZE,
	NOSCROLL,
	NOCLOSE,
	NOTITLE,
	HOLDFOCUS,
	AUTOSIZE,
	POPUP,
	CLOSED
}
Opt_Bits :: bit_set[Opt];

Mouse :: enum {
	LEFT,
	RIGHT,
	MIDDLE,
}
Mouse_Bits :: bit_set[Mouse];

Key :: enum {
	SHIFT,
	CTRL,
	ALT,
	BACKSPACE,
	RETURN,
}
Key_Bits :: bit_set[Key];

Layout_Type :: enum { NONE = 0, RELATIVE = 1, ABSOLUTE = 2 }

Id    :: distinct u32;
Real  :: MU_REAL;
Font  :: distinct rawptr;

Vec2  :: struct { x, y: i32 }
Rect  :: struct { x, y, w, h: i32 }
Color :: struct { r, g, b, a: u8 }

Base_Command :: struct { type: Command_Type, size: int }
Jump_Command :: struct { using base: Base_Command, dst: rawptr }
Clip_Command :: struct { using base: Base_Command, rect: Rect }
Rect_Command :: struct { using base: Base_Command, rect: Rect, color: Color }
Text_Command :: struct { using base: Base_Command, font: Font, pos: Vec2, color: Color, str: [1]u8, }
Icon_Command :: struct { using base: Base_Command, rect: Rect, id: Icon, color: Color }

Command :: struct #raw_union {
	type: Command_Type,
	base: Base_Command,
	jump: Jump_Command,
	clip: Clip_Command,
	rect: Rect_Command,
	text: Text_Command,
	icon: Icon_Command,
}

Layout :: struct {
	body, next:                 Rect,
	position, size, max:        Vec2,
	widths:                     [MU_MAX_WIDTHS] i32,
	items, row_index, next_row: i32,
	next_type:                  Layout_Type,
	indent:                     i32,
}

Container :: struct {
	head, tail:   ^Command,
	rect, body:   Rect,
	content_size: Vec2,
	scroll:       Vec2,
	inited:       b32,
	zindex:       i32,
	open:         b32,
}

Style :: struct {
	font:           Font,
	size:           Vec2,
	padding:        i32,
	spacing:        i32,
	indent:         i32,
	title_height:   i32,
	scrollbar_size: i32,
	thumb_size:     i32,
	colors:         [Color_Type] Color,
}

Context :: struct {
	/* callbacks */
	text_width:                          proc(font: Font, str: string) -> i32,
	text_height:                         proc(font: Font) -> i32,
	draw_frame:                          proc(ctx: ^Context, rect: Rect, colorid: Color_Type),
	/* core state */
	_style:                              Style,
	style:                               ^Style,
	hover:                               Id,
	focus:                               Id,
	last_id:                             Id,
	last_rect:                           Rect,
	last_zindex:                         i32,
	updated_focus:                       b32,
	hover_root:                          ^Container,
	last_hover_root:                     ^Container,
	scroll_target:                       ^Container,
	number_buf:                          [MU_MAX_FMT] u8,
	number_editing:                      Id,
	/* stacks */
	command_list:                        Stack(u8, MU_COMMANDLIST_SIZE),
	root_list:                           Stack(^Container, MU_ROOTLIST_SIZE),
	container_stack:                     Stack(^Container, MU_CONTAINERSTACK_SIZE),
	clip_stack:                          Stack(Rect, MU_CLIPSTACK_SIZE),
	id_stack:                            Stack(Id, MU_IDSTACK_SIZE),
	layout_stack:                        Stack(Layout, MU_LAYOUTSTACK_SIZE),
	/* input state */
	mouse_pos, last_mouse_pos:           Vec2,
	mouse_delta, scroll_delta:           Vec2,
	mouse_down_bits, mouse_pressed_bits: Mouse_Bits,
	key_down_bits, key_pressed_bits:     Key_Bits,
	text_store:                          [32] u8,
	text_input:                          strings.Builder, // uses `text_store` as backing store with nil_allocator.
}

expect :: builtin.assert;

push :: proc(stk: ^$T/Stack($V,$N), val: V) {
	expect(stk.idx < len(stk.items));
	stk.items[stk.idx] = val;
	stk.idx += 1;
}

pop :: proc(stk: ^$T/Stack($V,$N)) {
	expect(stk.idx > 0);
	stk.idx -= 1;
}

@static unclipped_rect := Rect{0, 0, 0x1000000, 0x1000000};

@static default_style := Style{
	font = nil,
	size = { 68, 10 },
	padding = 6, spacing = 4, indent = 24,
	title_height = 26, scrollbar_size = 12, thumb_size = 8,
	colors = {
		.TEXT        = {230, 230, 230, 255},
		.BORDER      = {25,  25,  25,  255},
		.WINDOWBG    = {50,  50,  50,  255},
		.TITLEBG     = {25,  25,  25,  255},
		.TITLETEXT   = {240, 240, 240, 255},
		.PANELBG     = {0,   0,   0,   0  },
		.BUTTON      = {75,  75,  75,  255},
		.BUTTONHOVER = {95,  95,  95,  255},
		.BUTTONFOCUS = {115, 115, 115, 255},
		.BASE        = {30,  30,  30,  255},
		.BASEHOVER   = {35,  35,  35,  255},
		.BASEFOCUS   = {40,  40,  40,  255},
		.SCROLLBASE  = {43,  43,  43,  255},
		.SCROLLTHUMB = {30,  30,  30,  255},
	}
};

init :: proc(ctx: ^Context) {
	ctx^ = {}; // zero memory
	ctx.text_width = text_width;
	ctx.text_height = text_height;
	ctx.draw_frame = draw_frame;
	ctx._style = default_style;
	ctx.style = &ctx._style;
	ctx.text_input = strings.builder_from_slice(ctx.text_store[:]);
}

get_clip_rect :: proc(ctx: ^Context) -> Rect {
	expect(ctx.clip_stack.idx > 0);
	return ctx.clip_stack.items[ctx.clip_stack.idx - 1];
}

draw_rect :: proc(ctx: ^Context, rect: Rect, color: Color) {
	cmd: ^Command;
	rect := clip_rect(rect, get_clip_rect(ctx));
	if rect.w > 0 && rect.h > 0 {
		cmd = push_command(ctx, .RECT, size_of(Rect_Command));
		cmd.rect.rect = rect;
		cmd.rect.color = color;
	}
}

begin :: proc(ctx: ^Context) {
	ctx.command_list.idx = 0;
	ctx.root_list.idx    = 0;
	ctx.scroll_target    = nil;
	ctx.last_hover_root  = ctx.hover_root;
	ctx.hover_root       = nil;
	ctx.mouse_delta.x    = ctx.mouse_pos.x - ctx.last_mouse_pos.x;
	ctx.mouse_delta.y    = ctx.mouse_pos.y - ctx.last_mouse_pos.y;
}

end :: proc(ctx: ^Context) {
	/* check stacks */
	expect(ctx.container_stack.idx == 0);
	expect(ctx.clip_stack.idx      == 0);
	expect(ctx.id_stack.idx        == 0);
	expect(ctx.layout_stack.idx    == 0);

	/* handle scroll input */
	if ctx.scroll_target != nil {
		ctx.scroll_target.scroll.x += ctx.scroll_delta.x;
		ctx.scroll_target.scroll.y += ctx.scroll_delta.y;
	}

	/* unset focus if focus id was not touched this frame */
	if !ctx.updated_focus do ctx.focus = 0;
	ctx.updated_focus = false;

	/* bring hover root to front if mouse was pressed */
	if card(ctx.mouse_pressed_bits) == 0 && ctx.hover_root != nil &&
	   ctx.hover_root.zindex < ctx.last_zindex do bring_to_front(ctx, ctx.hover_root);

	/* reset input state */
	ctx.key_pressed_bits = {}; // clear
	strings.reset_builder(&ctx.text_input);
	ctx.mouse_pressed_bits = {}; // clear
	ctx.scroll_delta = Vec2{0, 0};
	ctx.last_mouse_pos = ctx.mouse_pos;

	/* sort root containers by zindex */
	n := ctx.root_list.idx;
	sort.quick_sort_proc(ctx.root_list.items[:], proc(a, b: ^Container) -> int {
		return int(a.zindex) - int(b.zindex);
	});

	/* set root container jump commands */
	for i := 0; i < n; i += 1 {
		cnt := ctx.root_list.items[i];
		/* if this is the first container then make the first command jump to it.
		** otherwise set the previous container's tail to jump to this one */
		if i == 0 {
			cmd := cast(^Command) &ctx.command_list.items[0];
			cmd.jump.dst = rawptr(uintptr(cnt.head) + size_of(Jump_Command));
		} else {
			prev := ctx.root_list.items[i - 1];
			prev.tail.jump.dst = rawptr(uintptr(cnt.head) + size_of(Jump_Command));
		}
		/* make the last container's tail jump to the end of command list */
		if i == n - 1 {
			cnt.tail.jump.dst = rawptr(&ctx.command_list.items[ctx.command_list.idx]);
		}
	}
}

set_focus :: proc(ctx: ^Context, id: Id) {
	ctx.focus = id;
	ctx.updated_focus = true;
}

/* 32bit fnv-1a hash */
HASH_INITIAL :: 2166136261;

hash :: proc(hash: ^Id, data: rawptr, size: int) {
	size := size;
	p := cast(^u8) data;
	for ; size > 0; size -= 1 {
		hash^ = cast(Id) (u32(hash^) ~ u32(p^)) * 16777619;
		p = mem.ptr_offset(p, 1);
	}
}

get_id :: proc(ctx: ^Context, data: rawptr, size: int) -> Id {
	idx := ctx.id_stack.idx;
	res := (idx > 0) ? ctx.id_stack.items[idx - 1] : HASH_INITIAL;
	hash(&res, data, size);
	ctx.last_id = res;
	return res;
}

push_id :: proc(ctx: ^Context, data: rawptr, size: int) {
	push(&ctx.id_stack, get_id(ctx, data, size));
}

pop_id :: proc(ctx: ^Context) {
	pop(&ctx.id_stack);
}

push_clip_rect :: proc(ctx: ^Context, rect: Rect) {
	last := get_clip_rect(ctx);
	push(&ctx.clip_stack, clip_rect(rect, last));
}

pop_clip_rect :: proc(ctx: ^Context) {
	pop(&ctx.clip_stack);
}

check_clip :: proc(ctx: ^Context, r: Rect) -> Clip {
	cr := get_clip_rect(ctx);
	if r.x > cr.x + cr.w || r.x + r.w < cr.x ||
	   r.y > cr.y + cr.h || r.y + r.h < cr.y do return .ALL;
	if r.x >= cr.x && r.x + r.w <= cr.x + cr.w &&
	   r.y >= cr.y && r.y + r.h <= cr.y + cr.h do return .NONE;
	return .PART;
}

push_layout :: proc(ctx: ^Context, body: Rect, scroll: Vec2) {
	layout: Layout;
	layout.body = Rect{body.x - scroll.x, body.y - scroll.y, body.w, body.h};
	layout.max = Vec2{-0x1000000, -0x1000000};
	push(&ctx.layout_stack, layout);
	layout_row(ctx, 1, []i32{0}, 0);
}

@private get_layout :: proc(ctx: ^Context) -> ^Layout {
	return &ctx.layout_stack.items[ctx.layout_stack.idx - 1];
}

@private push_container :: proc(ctx: ^Context, cnt: ^Container) {
	cnt := cnt;
	push(&ctx.container_stack, cnt);
	push_id(ctx, &cnt, size_of(^Container));
}

@private pop_container :: proc(ctx: ^Context) {
	cnt := get_container(ctx);
	layout := get_layout(ctx);
	cnt.content_size.x = layout.max.x - layout.body.x;
	cnt.content_size.y = layout.max.y - layout.body.y;
	/* pop container, layout and id */
	pop(&ctx.container_stack);
	pop(&ctx.layout_stack);
	pop_id(ctx);
}

get_container :: proc(ctx: ^Context) -> ^Container {
	expect(ctx.container_stack.idx > 0);
	return ctx.container_stack.items[ctx.container_stack.idx - 1];
}

init_window :: proc(ctx: ^Context, cnt: ^Container, opt: Opt_Bits) {
	cnt^ = {}; // zero memory
	cnt.inited = true;
	cnt.open = .CLOSED not_in opt;
	cnt.rect = Rect{100, 100, 300, 300};
	bring_to_front(ctx, cnt);
}

bring_to_front :: proc(ctx: ^Context, cnt: ^Container) {
	ctx.last_zindex += 1;
	cnt.zindex = ctx.last_zindex;
}

/*============================================================================
** input handlers
**============================================================================*/

input_mousemove :: proc(ctx: ^Context, x, y: i32) {
	ctx.mouse_pos = Vec2{x, y};
}

input_mousedown :: proc(ctx: ^Context, x, y: i32, btn: Mouse) {
	input_mousemove(ctx, x, y);
	incl(&ctx.mouse_down_bits, btn);
	incl(&ctx.mouse_pressed_bits, btn);
}

input_mouseup :: proc(ctx: ^Context, x, y: i32, btn: Mouse) {
	input_mousemove(ctx, x, y);
	excl(&ctx.mouse_down_bits, btn);
}

input_scroll :: proc(ctx: ^Context, x, y: i32) {
	ctx.scroll_delta.x += x;
	ctx.scroll_delta.y += y;
}

input_keydown :: proc(ctx: ^Context, key: Key) {
	incl(&ctx.key_pressed_bits, key);
	incl(&ctx.key_down_bits, key);
}

input_keyup :: proc(ctx: ^Context, key: Key) {
	excl(&ctx.key_down_bits, key);
}

input_text :: proc(ctx: ^Context, text: string) {
	strings.write_string(&ctx.text_input, text);
}

/*
/*============================================================================
** commandlist
**============================================================================*/
*/

push_command :: proc(ctx: ^Context, type: Command_Type, size: int) -> ^Command {
	cmd := transmute(^Command) &ctx.command_list.items[ctx.command_list.idx];
	expect(ctx.command_list.idx + size < MU_COMMANDLIST_SIZE);
	cmd.base.type = type;
	cmd.base.size = size;
	ctx.command_list.idx += size;
	return cmd;
}

// TODO(oskar): get rid of double pointer here and use multiple returns instead (more idiomatic)
next_command :: proc(ctx: ^Context, pcmd: ^^Command) -> bool {
	cmd := pcmd^;
	defer pcmd^ = cmd;
	if cmd != nil {
		cmd = cast(^Command) uintptr(int(uintptr(cmd)) + cmd.base.size);
	} else {
		first_command :: inline proc(ctx: ^Context) -> ^Command { return cast(^Command) &ctx.command_list.items[0]; }
		cmd = first_command(ctx);
	}
	invalid_command :: inline proc(ctx: ^Context) -> ^Command { return cast(^Command) &ctx.command_list.items[ctx.command_list.idx]; }
	for cmd != invalid_command(ctx) {
		if cmd.type != .JUMP do return true;
		cmd = cast(^Command) cmd.jump.dst;
	}
	return false;
}

@private push_jump :: proc(ctx: ^Context, dst: ^Command) -> ^Command {
	cmd := push_command(ctx, .JUMP, size_of(Jump_Command));
	cmd.jump.dst = dst;
	return cmd;
}

set_clip :: proc(ctx: ^Context, rect: Rect) {
	cmd := push_command(ctx, .CLIP, size_of(Clip_Command));
	cmd.clip.rect = rect;
}

draw_box :: proc(ctx: ^Context, rect: Rect, color: Color) {
	draw_rect(ctx, Rect{rect.x+1,        rect.y,          rect.w-2, 1     }, color);
	draw_rect(ctx, Rect{rect.x+1,        rect.y+rect.h-1, rect.w-2, 1     }, color);
	draw_rect(ctx, Rect{rect.x,          rect.y,          1,        rect.h}, color);
	draw_rect(ctx, Rect{rect.x+rect.w-1, rect.y,          1,        rect.h}, color);
}

draw_text :: proc(ctx: ^Context, font: Font, str: string, pos: Vec2, color: Color) {
	rect := Rect{pos.x, pos.y, ctx.text_width(font, str), ctx.text_height(font)};
	clipped := check_clip(ctx, rect);
	if clipped == .ALL  do return;
	if clipped == .PART do set_clip(ctx, get_clip_rect(ctx));
	/* add command */
	raw_str := transmute(mem.Raw_String) str;
	cmd := push_command(ctx, .TEXT, size_of(Text_Command) + raw_str.len);
	runtime.mem_copy(&cmd.text.str[0], raw_str.data, raw_str.len);
	cmd.text.str[raw_str.len] = 0;
	cmd.text.pos = pos;
	cmd.text.color = color;
	cmd.text.font = font;
	/* reset clipping if it was set */
	if clipped != .NONE do set_clip(ctx, unclipped_rect);
}

draw_icon :: proc(ctx: ^Context, id: Icon, rect: Rect, color: Color) {
	/* do clip command if the rect isn't fully contained within the cliprect */
	clipped := check_clip(ctx, rect);
	if clipped == .ALL do return;
	if clipped == .PART do set_clip(ctx, get_clip_rect(ctx));
	/* do icon command */
	cmd := push_command(ctx, .ICON, size_of(Icon_Command));
	cmd.icon.id = id;
	cmd.icon.rect = rect;
	cmd.icon.color = color;
	/* reset clipping if it was set */
	if clipped != .NONE do set_clip(ctx, unclipped_rect);
}

/*============================================================================
** layout
**============================================================================*/

layout_begin_column :: proc(ctx: ^Context) {
	push_layout(ctx, layout_next(ctx), Vec2{0, 0});
}

layout_end_column :: proc(ctx: ^Context) {
	b := get_layout(ctx);
	pop(&ctx.layout_stack);
	/* inherit position/next_row/max from child layout if they are greater */
	a := get_layout(ctx);
	a.position.x = max(a.position.x, b.position.x + b.body.x - a.body.x);
	a.next_row = max(a.next_row, b.next_row + b.body.y - a.body.y);
	a.max.x = max(a.max.x, b.max.x);
	a.max.y = max(a.max.y, b.max.y);
}

layout_row :: proc(ctx: ^Context, items: i32, widths: []i32, height: i32) {
	layout := get_layout(ctx);
	if len(widths) > 0 {
		// NOTE(oskar): This was `items` instead of `len(widths)` in original. Seems
		// like length of slice is what we actually want here? Do we even need to
		// pass `items` at all?
		n := len(widths);
		expect(n <= MU_MAX_WIDTHS);
		runtime.mem_copy(&layout.widths, &widths[0], n * size_of(widths[0]));
	}
	layout.items = items;
	layout.position = Vec2{layout.indent, layout.next_row};
	layout.size.y = height;
	layout.row_index = 0;
}

layout_width :: proc(ctx: ^Context, width: i32) {
	get_layout(ctx).size.x = width;
}

layout_height :: proc(ctx: ^Context, height: i32) {
	get_layout(ctx).size.y = height;
}

layout_set_next :: proc(ctx: ^Context, r: Rect, relative: bool) {
	layout := get_layout(ctx);
	layout.next = r;
	layout.next_type = relative ? .RELATIVE : .ABSOLUTE;
}

layout_next :: proc(ctx: ^Context) -> (res: Rect) {
	layout := get_layout(ctx);
	style := ctx.style;
	defer ctx.last_rect = res;

	if layout.next_type != .NONE {
		/* handle rect set by `layout_set_next` */
		type := layout.next_type;
		layout.next_type = .NONE;
		res = layout.next;
		if type == .ABSOLUTE do return;
	} else {
		/* handle next row */
		if layout.row_index == layout.items {
			layout_row(ctx, layout.items, []i32{}, layout.size.y);
		}

		/* position */
		res.x = layout.position.x;
		res.y = layout.position.y;

		/* size */
		res.w = layout.items > -1 ? layout.widths[layout.row_index] : layout.size.x;
		res.h = layout.size.y;
		if res.w == 0 do res.w = style.size.x + style.padding * 2;
		if res.h == 0 do res.h = style.size.y + style.padding * 2;
		if res.w <  0 do res.w += layout.body.w - res.x + 1;
		if res.h <  0 do res.h += layout.body.h - res.y + 1;

		layout.row_index += 1;
	}

	/* update position */
	layout.position.x += res.w + style.spacing;
	layout.next_row = max(layout.next_row, res.y + res.h + style.spacing);

	/* apply body offset */
	res.x += layout.body.x;
	res.y += layout.body.y;

	/* update max position */
	layout.max.x = max(layout.max.x, res.x + res.w);
	layout.max.y = max(layout.max.y, res.y + res.h);
	return;
}

/*============================================================================
** controls
**============================================================================*/

@private in_hover_root :: proc(ctx: ^Context) -> bool {
	i := ctx.container_stack.idx;
	for ; i > 0; i -= 1 {
		if ctx.container_stack.items[i] == ctx.last_hover_root do return true;
		/* only root containers have their `head` field set; stop searching if we've
		** reached the current root container */
		if ctx.container_stack.items[i].head != nil do break;
	}
	return false;
}

draw_control_frame :: proc(ctx: ^Context, id: Id, rect: Rect, colorid: Color_Type, opt: Opt_Bits) {
	expect(colorid == .BUTTON || colorid == .BASE);
	if .NOFRAME in opt do return;
	colorid := Color_Type(int(colorid) + int((ctx.focus == id) ? 2 : (ctx.hover == id) ? 1 : 0));
	ctx.draw_frame(ctx, rect, colorid);
}

draw_control_text :: proc(ctx: ^Context, str: string, rect: Rect, colorid: Color_Type, opt: Opt_Bits) {
	pos: Vec2;
	font := ctx.style.font;
	tw := ctx.text_width(font, str);
	push_clip_rect(ctx, rect);
	pos.y = rect.y + (rect.h - ctx.text_height(font)) / 2;
	if .ALIGNCENTER in opt {
		pos.x = rect.x + (rect.w - tw) / 2;
	} else if .ALIGNRIGHT in opt {
		pos.x = rect.x + rect.w - tw - ctx.style.padding;
	} else {
		pos.x = rect.x + ctx.style.padding;
	}
	draw_text(ctx, font, str, pos, ctx.style.colors[colorid]);
	pop_clip_rect(ctx);
}

mouse_over :: proc(ctx: ^Context, rect: Rect) -> bool {
	return rect_overlaps_vec2(rect, ctx.mouse_pos) &&
           rect_overlaps_vec2(get_clip_rect(ctx), ctx.mouse_pos) &&
           in_hover_root(ctx);
}

update_control :: proc(ctx: ^Context, id: Id, rect: Rect, opt: Opt_Bits) {
	mouseover := mouse_over(ctx, rect);

	if ctx.focus == id do ctx.updated_focus = true;
	if .NOINTERACT in opt do return;
	if mouseover && card(ctx.mouse_down_bits) == 0 do ctx.hover = id;

	if ctx.focus == id {
		if card(ctx.mouse_pressed_bits) != 0 && !mouseover do set_focus(ctx, 0);
		if card(ctx.mouse_down_bits) == 0 && .HOLDFOCUS not_in opt do set_focus(ctx, 0);
	}

	if ctx.hover == id {
		if !mouseover {
			ctx.hover = 0;
		} else if card(ctx.mouse_pressed_bits) != 0 {
			set_focus(ctx, id);
		}
	}
}

/*

void mu_text(mu_Context *ctx, const char *text) {
  const char *start, *end, *p = text;
  int width = -1;
  mu_Font font = ctx->style->font;
  mu_Color color = ctx->style->colors[MU_COLOR_TEXT];
  mu_layout_begin_column(ctx);
  mu_layout_row(ctx, 1, &width, ctx->text_height(font));
  do {
	mu_Rect r = mu_layout_next(ctx);
	int w = 0;
	start = end = p;
	do {
	  const char* word = p;
	  while (*p && *p != ' ' && *p != '\n') { p++; }
	  w += ctx->text_width(font, word, p - word);
	  if (w > r.w && end != start) { break; }
	  w += ctx->text_width(font, p, 1);
	  end = p++;
	} while (*end && *end != '\n');
	mu_draw_text(ctx, font, start, end - start, mu_vec2(r.x, r.y), color);
	p = end + 1;
  } while (*end);
  mu_layout_end_column(ctx);
}


void mu_label(mu_Context *ctx, const char *text) {
  mu_draw_control_text(ctx, text, mu_layout_next(ctx), MU_COLOR_TEXT, 0);
}


int mu_button_ex(mu_Context *ctx, const char *label, int icon, int opt) {
  int res = 0;
  mu_Id id = label ? mu_get_id(ctx, label, strlen(label))
	: mu_get_id(ctx, &icon, sizeof(icon));
  mu_Rect r = mu_layout_next(ctx);
  mu_update_control(ctx, id, r, opt);
  /* handle click */
  if (ctx->mouse_pressed == MU_MOUSE_LEFT && ctx->focus == id) {
	res |= MU_RES_SUBMIT;
  }
  /* draw */
  mu_draw_control_frame(ctx, id, r, MU_COLOR_BUTTON, opt);
  if (label) { mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, opt); }
  if (icon) { mu_draw_icon(ctx, icon, r, ctx->style->colors[MU_COLOR_TEXT]); }
  return res;
}


int mu_button(mu_Context *ctx, const char *label) {
  return mu_button_ex(ctx, label, 0, MU_OPT_ALIGNCENTER);
}


int mu_checkbox(mu_Context *ctx, int *state, const char *label) {
  int res = 0;
  mu_Id id = mu_get_id(ctx, &state, sizeof(state));
  mu_Rect r = mu_layout_next(ctx);
  mu_Rect box = mu_rect(r.x, r.y, r.h, r.h);
  mu_update_control(ctx, id, r, 0);
  /* handle click */
  if (ctx->mouse_pressed == MU_MOUSE_LEFT && ctx->focus == id) {
	res |= MU_RES_CHANGE;
	*state = !*state;
  }
  /* draw */
  mu_draw_control_frame(ctx, id, box, MU_COLOR_BASE, 0);
  if (*state) {
	mu_draw_icon(ctx, MU_ICON_CHECK, box, ctx->style->colors[MU_COLOR_TEXT]);
  }
  r = mu_rect(r.x + box.w, r.y, r.w - box.w, r.h);
  mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, 0);
  return res;
}


int mu_textbox_raw(mu_Context *ctx, char *buf, int bufsz, mu_Id id, mu_Rect r,
  int opt)
{
  int res = 0;
  mu_update_control(ctx, id, r, opt | MU_OPT_HOLDFOCUS);

  if (ctx->focus == id) {
	/* handle text input */
	int len = strlen(buf);
	int n = mu_min(bufsz - len - 1, (int) strlen(ctx->text_input));
	if (n > 0) {
	  memcpy(buf + len, ctx->text_input, n);
	  len += n;
	  buf[len] = '\0';
	  res |= MU_RES_CHANGE;
	}
	/* handle backspace */
	if (ctx->key_pressed & MU_KEY_BACKSPACE && len > 0) {
	  /* skip utf-8 continuation bytes */
	  while ((buf[--len] & 0xc0) == 0x80 && len > 0);
	  buf[len] = '\0';
	  res |= MU_RES_CHANGE;
	}
	/* handle return */
	if (ctx->key_pressed & MU_KEY_RETURN) {
	  mu_set_focus(ctx, 0);
	  res |= MU_RES_SUBMIT;
	}
  }

  /* draw */
  mu_draw_control_frame(ctx, id, r, MU_COLOR_BASE, opt);
  if (ctx->focus == id) {
	mu_Color color = ctx->style->colors[MU_COLOR_TEXT];
	mu_Font font = ctx->style->font;
	int textw = ctx->text_width(font, buf, -1);
	int texth = ctx->text_height(font);
	int ofx = r.w - ctx->style->padding - textw - 1;
	int textx = r.x + mu_min(ofx, ctx->style->padding);
	int texty = r.y + (r.h - texth) / 2;
	mu_push_clip_rect(ctx, r);
	mu_draw_text(ctx, font, buf, -1, mu_vec2(textx, texty), color);
	mu_draw_rect(ctx, mu_rect(textx + textw, texty, 1, texth), color);
	mu_pop_clip_rect(ctx);
  } else {
	mu_draw_control_text(ctx, buf, r, MU_COLOR_TEXT, opt);
  }

  return res;
}


static int number_textbox(mu_Context *ctx, mu_Real *value, mu_Rect r, mu_Id id) {
  if (ctx->mouse_pressed == MU_MOUSE_LEFT &&
	  ctx->key_down & MU_KEY_SHIFT &&
	  ctx->hover == id)
  {
	ctx->number_editing = id;
	sprintf(ctx->number_buf, MU_REAL_FMT, *value);
  }
  if (ctx->number_editing == id) {
	int res = mu_textbox_raw(
	  ctx, ctx->number_buf, sizeof(ctx->number_buf), id, r, 0);
	if (res & MU_RES_SUBMIT || ctx->focus != id) {
	  *value = strtod(ctx->number_buf, NULL);
	  ctx->number_editing = 0;
	} else {
	  return 1;
	}
  }
  return 0;
}


int mu_textbox_ex(mu_Context *ctx, char *buf, int bufsz, int opt) {
  mu_Id id = mu_get_id(ctx, &buf, sizeof(buf));
  mu_Rect r = mu_layout_next(ctx);
  return mu_textbox_raw(ctx, buf, bufsz, id, r, opt);
}


int mu_textbox(mu_Context *ctx, char *buf, int bufsz) {
  return mu_textbox_ex(ctx, buf, bufsz, 0);
}


int mu_slider_ex(mu_Context *ctx, mu_Real *value, mu_Real low, mu_Real high,
  mu_Real step, const char *fmt, int opt)
{
  char buf[MU_MAX_FMT + 1];
  mu_Rect thumb;
  int w, res = 0;
  mu_Real normalized, last = *value, v = last;
  mu_Id id = mu_get_id(ctx, &value, sizeof(value));
  mu_Rect base = mu_layout_next(ctx);

  /* handle text input mode */
  if (number_textbox(ctx, &v, base, id)) { return res; }

  /* handle normal mode */
  mu_update_control(ctx, id, base, opt);

  /* handle input */
  if (ctx->focus == id && ctx->mouse_down == MU_MOUSE_LEFT) {
	v = low + ((mu_Real) (ctx->mouse_pos.x - base.x) / base.w) * (high - low);
	if (step) { v = ((long) ((v + step/2) / step)) * step; }
  }
  /* clamp and store value, update res */
  *value = v = mu_clamp(v, low, high);
  if (last != v) { res |= MU_RES_CHANGE; }

  /* draw base */
  mu_draw_control_frame(ctx, id, base, MU_COLOR_BASE, opt);
  /* draw thumb */
  w = ctx->style->thumb_size;
  normalized = (v - low) / (high - low);
  thumb = mu_rect(base.x + normalized * (base.w - w), base.y, w, base.h);
  mu_draw_control_frame(ctx, id, thumb, MU_COLOR_BUTTON, opt);
  /* draw text  */
  sprintf(buf, fmt, v);
  mu_draw_control_text(ctx, buf, base, MU_COLOR_TEXT, opt);

  return res;
}


int mu_slider(mu_Context *ctx, mu_Real *value, mu_Real low, mu_Real high) {
  return mu_slider_ex(ctx, value, low, high, 0, MU_SLIDER_FMT, MU_OPT_ALIGNCENTER);
}


int mu_number_ex(mu_Context *ctx, mu_Real *value, mu_Real step,
  const char *fmt,int opt)
{
  char buf[MU_MAX_FMT + 1];
  int res = 0;
  mu_Id id = mu_get_id(ctx, &value, sizeof(value));
  mu_Rect base = mu_layout_next(ctx);
  mu_Real last = *value;

  /* handle text input mode */
  if (number_textbox(ctx, value, base, id)) { return res; }

  /* handle normal mode */
  mu_update_control(ctx, id, base, opt);

  /* handle input */
  if (ctx->focus == id && ctx->mouse_down == MU_MOUSE_LEFT) {
	*value += ctx->mouse_delta.x * step;
  }
  /* set flag if value changed */
  if (*value != last) { res |= MU_RES_CHANGE; }

  /* draw base */
  mu_draw_control_frame(ctx, id, base, MU_COLOR_BASE, opt);
  /* draw text  */
  sprintf(buf, fmt, *value);
  mu_draw_control_text(ctx, buf, base, MU_COLOR_TEXT, opt);

  return res;
}


int mu_number(mu_Context *ctx, mu_Real *value, mu_Real step) {
  return mu_number_ex(ctx, value, step, MU_SLIDER_FMT, MU_OPT_ALIGNCENTER);
}


static int header(mu_Context *ctx, int *state, const char *label,
  int istreenode)
{
  mu_Rect r;
  mu_Id id;
  int width = -1;
  mu_layout_row(ctx, 1, &width, 0);
  r = mu_layout_next(ctx);
  id = mu_get_id(ctx, &state, sizeof(state));
  mu_update_control(ctx, id, r, 0);
  /* handle click */
  if (ctx->mouse_pressed == MU_MOUSE_LEFT && ctx->focus == id) {
	*state = !(*state);
  }
  /* draw */
  if (istreenode) {
	if (ctx->hover == id) { ctx->draw_frame(ctx, r, MU_COLOR_BUTTONHOVER); }
  } else {
	mu_draw_control_frame(ctx, id, r, MU_COLOR_BUTTON, 0);
  }
  mu_draw_icon(
	ctx, *state ? MU_ICON_EXPANDED : MU_ICON_COLLAPSED,
	mu_rect(r.x, r.y, r.h, r.h), ctx->style->colors[MU_COLOR_TEXT]);
  r.x += r.h - ctx->style->padding;
  r.w -= r.h - ctx->style->padding;
  mu_draw_control_text(ctx, label, r, MU_COLOR_TEXT, 0);
  return *state ? MU_RES_ACTIVE : 0;
}


int mu_header(mu_Context *ctx, int *state, const char *label) {
  return header(ctx, state, label, 0);
}


int mu_begin_treenode(mu_Context *ctx, int *state, const char *label) {
  int res = header(ctx, state, label, 1);
  if (res & MU_RES_ACTIVE) {
	get_layout(ctx)->indent += ctx->style->indent;
	mu_push_id(ctx, &state, sizeof(void*));
  }
  return res;
}


void mu_end_treenode(mu_Context *ctx) {
  get_layout(ctx)->indent -= ctx->style->indent;
  mu_pop_id(ctx);
}


#define scrollbar(ctx, cnt, b, cs, x, y, w, h)                              \
  do {                                                                      \
	/* only add scrollbar if content size is larger than body */            \
	int maxscroll = cs.y - b->h;                                            \
																			\
	if (maxscroll > 0 && b->h > 0) {                                        \
	  mu_Rect base, thumb;                                                  \
	  mu_Id id = mu_get_id(ctx, "!scrollbar" #y, 11);                       \
																			\
	  /* get sizing / positioning */                                        \
	  base = *b;                                                            \
	  base.x = b->x + b->w;                                                 \
	  base.w = ctx->style->scrollbar_size;                                  \
																			\
	  /* handle input */                                                    \
	  mu_update_control(ctx, id, base, 0);                                  \
	  if (ctx->focus == id && ctx->mouse_down == MU_MOUSE_LEFT) {           \
		cnt->scroll.y += ctx->mouse_delta.y * cs.y / base.h;                \
	  }                                                                     \
	  /* clamp scroll to limits */                                          \
	  cnt->scroll.y = mu_clamp(cnt->scroll.y, 0, maxscroll);                \
																			\
	  /* draw base and thumb */                                             \
	  ctx->draw_frame(ctx, base, MU_COLOR_SCROLLBASE);                      \
	  thumb = base;                                                         \
	  thumb.h = mu_max(ctx->style->thumb_size, base.h * b->h / cs.y);       \
	  thumb.y += cnt->scroll.y * (base.h - thumb.h) / maxscroll;            \
	  ctx->draw_frame(ctx, thumb, MU_COLOR_SCROLLTHUMB);                    \
																			\
	  /* set this as the scroll_target (will get scrolled on mousewheel) */ \
	  /* if the mouse is over it */                                         \
	  if (mu_mouse_over(ctx, *b)) { ctx->scroll_target = cnt; }             \
	} else {                                                                \
	  cnt->scroll.y = 0;                                                    \
	}                                                                       \
  } while (0)


static void scrollbars(mu_Context *ctx, mu_Container *cnt, mu_Rect *body) {
  int sz = ctx->style->scrollbar_size;
  mu_Vec2 cs = cnt->content_size;
  cs.x += ctx->style->padding * 2;
  cs.y += ctx->style->padding * 2;
  mu_push_clip_rect(ctx, *body);
  /* resize body to make room for scrollbars */
  if (cs.y > cnt->body.h) { body->w -= sz; }
  if (cs.x > cnt->body.w) { body->h -= sz; }
  /* to create a horizontal or vertical scrollbar almost-identical code is
  ** used; only the references to `x|y` `w|h` need to be switched */
  scrollbar(ctx, cnt, body, cs, x, y, w, h);
  scrollbar(ctx, cnt, body, cs, y, x, h, w);
  mu_pop_clip_rect(ctx);
}


static void push_container_body(
  mu_Context *ctx, mu_Container *cnt, mu_Rect body, int opt
) {
  if (~opt & MU_OPT_NOSCROLL) { scrollbars(ctx, cnt, &body); }
  push_layout(ctx, expand_rect(body, -ctx->style->padding), cnt->scroll);
  cnt->body = body;
}


static void begin_root_container(mu_Context *ctx, mu_Container *cnt) {
  push_container(ctx, cnt);

  /* push container to roots list and push head command */
  push(ctx->root_list, cnt);
  cnt->head = push_jump(ctx, NULL);

  /* set as hover root if the mouse is overlapping this container and it has a
  ** higher zindex than the current hover root */
  if (rect_overlaps_vec2(cnt->rect, ctx->mouse_pos) &&
	  (!ctx->hover_root || cnt->zindex > ctx->hover_root->zindex))
  {
	ctx->hover_root = cnt;
  }
  /* clipping is reset here in case a root-container is made within
  ** another root-containers's begin/end block; this prevents the inner
  ** root-container being clipped to the outer */
  push(ctx->clip_stack, unclipped_rect);
}


static void end_root_container(mu_Context *ctx) {
  /* push tail 'goto' jump command and set head 'skip' command. the final steps
  ** on initing these are done in mu_end() */
  mu_Container *cnt = mu_get_container(ctx);
  cnt->tail = push_jump(ctx, NULL);
  cnt->head->jump.dst = ctx->command_list.items + ctx->command_list.idx;
  /* pop base clip rect and container */
  mu_pop_clip_rect(ctx);
  pop_container(ctx);
}


int mu_begin_window_ex(mu_Context *ctx, mu_Container *cnt, const char *title,
  int opt)
{
  mu_Rect rect, body, titlerect;

  if (!cnt->inited) { mu_init_window(ctx, cnt, opt); }
  if (!cnt->open) { return 0; }

  begin_root_container(ctx, cnt);
  rect = cnt->rect;
  body = rect;

  /* draw frame */
  if (~opt & MU_OPT_NOFRAME) {
	ctx->draw_frame(ctx, rect, MU_COLOR_WINDOWBG);
  }

  /* do title bar */
  titlerect = rect;
  titlerect.h = ctx->style->title_height;
  if (~opt & MU_OPT_NOTITLE) {
	ctx->draw_frame(ctx, titlerect, MU_COLOR_TITLEBG);

	/* do title text */
	if (~opt & MU_OPT_NOTITLE) {
	  mu_Id id = mu_get_id(ctx, "!title", 6);
	  mu_update_control(ctx, id, titlerect, opt);
	  mu_draw_control_text(ctx, title, titlerect, MU_COLOR_TITLETEXT, opt);
	  if (id == ctx->focus && ctx->mouse_down == MU_MOUSE_LEFT) {
		cnt->rect.x += ctx->mouse_delta.x;
		cnt->rect.y += ctx->mouse_delta.y;
	  }
	  body.y += titlerect.h;
	  body.h -= titlerect.h;
	}

	/* do `close` button */
	if (~opt & MU_OPT_NOCLOSE) {
	  mu_Id id = mu_get_id(ctx, "!close", 6);
	  mu_Rect r = mu_rect(
		titlerect.x + titlerect.w - titlerect.h,
		titlerect.y, titlerect.h, titlerect.h);
	  titlerect.w -= r.w;
	  mu_draw_icon(ctx, MU_ICON_CLOSE, r, ctx->style->colors[MU_COLOR_TITLETEXT]);
	  mu_update_control(ctx, id, r, opt);
	  if (ctx->mouse_pressed == MU_MOUSE_LEFT && id == ctx->focus) {
		cnt->open = 0;
	  }
	}
  }

  push_container_body(ctx, cnt, body, opt);

  /* do `resize` handle */
  if (~opt & MU_OPT_NORESIZE) {
	int sz = ctx->style->title_height;
	mu_Id id = mu_get_id(ctx, "!resize", 7);
	mu_Rect r = mu_rect(rect.x + rect.w - sz, rect.y + rect.h - sz, sz, sz);
	mu_update_control(ctx, id, r, opt);
	if (id == ctx->focus && ctx->mouse_down == MU_MOUSE_LEFT) {
	  cnt->rect.w = mu_max(96, cnt->rect.w + ctx->mouse_delta.x);
	  cnt->rect.h = mu_max(64, cnt->rect.h + ctx->mouse_delta.y);
	}
  }

  /* resize to content size */
  if (opt & MU_OPT_AUTOSIZE) {
	mu_Rect r = get_layout(ctx)->body;
	cnt->rect.w = cnt->content_size.x + (cnt->rect.w - r.w);
	cnt->rect.h = cnt->content_size.y + (cnt->rect.h - r.h);
  }

  /* close if this is a popup window and elsewhere was clicked */
  if (opt & MU_OPT_POPUP && ctx->mouse_pressed && ctx->last_hover_root != cnt) {
	cnt->open = 0;
  }

  mu_push_clip_rect(ctx, cnt->body);
  return MU_RES_ACTIVE;
}


int mu_begin_window(mu_Context *ctx, mu_Container *cnt, const char *title) {
  return mu_begin_window_ex(ctx, cnt, title, 0);
}


void mu_end_window(mu_Context *ctx) {
  mu_pop_clip_rect(ctx);
  end_root_container(ctx);
}


void mu_open_popup(mu_Context *ctx, mu_Container *cnt) {
  /* set as hover root so popup isn't closed in begin_window_ex()  */
  ctx->last_hover_root = ctx->hover_root = cnt;
  /* init container if not inited */
  if (!cnt->inited) { mu_init_window(ctx, cnt, 0); }
  /* position at mouse cursor, open and bring-to-front */
  cnt->rect = mu_rect(ctx->mouse_pos.x, ctx->mouse_pos.y, 0, 0);
  cnt->open = 1;
  mu_bring_to_front(ctx, cnt);
}


int mu_begin_popup(mu_Context *ctx, mu_Container *cnt) {
  int opt = MU_OPT_POPUP | MU_OPT_AUTOSIZE | MU_OPT_NORESIZE |
			MU_OPT_NOSCROLL | MU_OPT_NOTITLE | MU_OPT_CLOSED;
  return mu_begin_window_ex(ctx, cnt, "", opt);
}


void mu_end_popup(mu_Context *ctx) {
  mu_end_window(ctx);
}


void mu_begin_panel_ex(mu_Context *ctx, mu_Container *cnt, int opt) {
  cnt->rect = mu_layout_next(ctx);
  if (~opt & MU_OPT_NOFRAME) {
	ctx->draw_frame(ctx, cnt->rect, MU_COLOR_PANELBG);
  }
  push_container(ctx, cnt);
  push_container_body(ctx, cnt, cnt->rect, opt);
  mu_push_clip_rect(ctx, cnt->body);
}


void mu_begin_panel(mu_Context *ctx, mu_Container *cnt) {
  mu_begin_panel_ex(ctx, cnt, 0);
}


void mu_end_panel(mu_Context *ctx) {
  mu_pop_clip_rect(ctx);
  pop_container(ctx);
}

*/

@private expand_rect :: proc(rect: Rect, n: i32) -> Rect {
	return Rect{rect.x - n, rect.y - n, rect.w + n * 2, rect.h + n * 2};
}

@private clip_rect :: proc(r1, r2: Rect) -> Rect {
	x1 := max(r1.x, r2.x);
	y1 := max(r1.y, r2.y);
	x2 := min(r1.x + r1.w, r2.x + r2.w);
	y2 := min(r1.y + r1.h, r2.y + r2.h);
	if x2 < x1 do x2 = x1;
	if y2 < y1 do y2 = y1;
	return Rect{x1, y1, x2 - x1, y2 - y1};
}

@private rect_overlaps_vec2 :: proc(r: Rect, p: Vec2) -> bool {
	return p.x >= r.x && p.x < r.x + r.w && p.y >= r.y && p.y < r.y + r.h;
}

@private text_width :: proc(font: Font, str: string) -> i32 {
	return i32(len(str) * 8);
}

@private text_height :: proc(font: Font) -> i32 {
	return 16;
}

@private draw_frame :: proc(ctx: ^Context, rect: Rect, colorid: Color_Type) {
	draw_rect(ctx, rect, ctx.style.colors[colorid]);
	if colorid == .SCROLLBASE || colorid == .SCROLLTHUMB || colorid == .TITLEBG do return;
	/* draw border */
	if ctx.style.colors[.BORDER].a != 0 {
		draw_box(ctx, expand_rect(rect, 1), ctx.style.colors[.BORDER]);
	}
}
