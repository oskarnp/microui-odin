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
import "core:reflect"

COMMANDLIST_SIZE     :: (1024 * 256);
ROOTLIST_SIZE        :: 32;
CONTAINERSTACK_SIZE  :: 32;
CLIPSTACK_SIZE       :: 32;
IDSTACK_SIZE         :: 32;
LAYOUTSTACK_SIZE     :: 16;
MAX_WIDTHS           :: 16;
REAL                 :: f32;
REAL_FMT             :: "%.3g";
SLIDER_FMT           :: "%.2f";
MAX_FMT              :: 127;

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
	ICON
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
	NONE,
	CLOSE,
	CHECK,
	COLLAPSED,
	EXPANDED,
	RESIZE
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

Id    :: distinct u32;
Real  :: REAL;
Font  :: distinct rawptr;

Vec2  :: distinct [2] i32;
Rect  :: struct { x, y, w, h: i32 }
Color :: struct { r, g, b, a: u8 }

Base_Command :: struct { type: Command_Type, size: int }
Jump_Command :: struct { using base: Base_Command, dst: rawptr }
Clip_Command :: struct { using base: Base_Command, rect: Rect }
Rect_Command :: struct { using base: Base_Command, rect: Rect, color: Color }
Text_Command :: struct { using base: Base_Command, font: Font, pos: Vec2, color: Color, str: string /* + string data (VLA) */ }
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
	widths:                     [MAX_WIDTHS] i32,
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
	footer_height:  i32,
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
	number_buf:                          [MAX_FMT] u8,
	number_editing:                      Id,
	/* stacks */
	command_list:                        Stack(u8, COMMANDLIST_SIZE),
	root_list:                           Stack(^Container, ROOTLIST_SIZE),
	container_stack:                     Stack(^Container, CONTAINERSTACK_SIZE),
	clip_stack:                          Stack(Rect, CLIPSTACK_SIZE),
	id_stack:                            Stack(Id, IDSTACK_SIZE),
	layout_stack:                        Stack(Layout, LAYOUTSTACK_SIZE),
	/* input state */
	mouse_pos, last_mouse_pos:           Vec2,
	mouse_delta, scroll_delta:           Vec2,
	mouse_down_bits:                     Mouse_Bits,
	mouse_pressed_bits:                  Mouse_Bits,
	mouse_released_bits:                 Mouse_Bits,
	key_down_bits, key_pressed_bits:     Key_Bits,
	_text_store:                         [32] u8,
	text_input:                          strings.Builder, // uses `_text_store` as backing store with nil_allocator.
}

expect :: builtin.assert;

Stack :: struct(T: typeid, n: int) {
	idx:   int,
	items: [n] T,
}
push :: inline proc(stk: ^$T/Stack($V,$N), val: V) { expect(stk.idx < len(stk.items)); stk.items[stk.idx] = val; stk.idx += 1; }
pop  :: inline proc(stk: ^$T/Stack($V,$N))         { expect(stk.idx > 0); stk.idx -= 1; }

@static unclipped_rect := Rect{0, 0, 0x1000000, 0x1000000};

@static default_style := Style{
	font = nil,
	size = { 68, 10 },
	padding = 6, spacing = 4, indent = 24,
	title_height = 26, footer_height = 20,
	scrollbar_size = 12, thumb_size = 8,
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
	if ctx.style.colors[.BORDER].a != 0 { /* draw border */
		draw_box(ctx, expand_rect(rect, 1), ctx.style.colors[.BORDER]);
	}
}

init :: proc(ctx: ^Context) {
	ctx^ = {}; // zero memory
	ctx.text_width  = text_width;
	ctx.text_height = text_height;
	ctx.draw_frame  = draw_frame;
	ctx._style      = default_style;
	ctx.style       = &ctx._style;
	ctx.text_input  = strings.builder_from_slice(ctx._text_store[:]);
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
	if mouse_pressed(ctx) && ctx.hover_root != nil && ctx.hover_root.zindex < ctx.last_zindex {
		bring_to_front(ctx, ctx.hover_root);
	}

	/* reset input state */
	ctx.key_pressed_bits = {}; // clear
	strings.reset_builder(&ctx.text_input);
	ctx.mouse_pressed_bits = {}; // clear
	ctx.mouse_released_bits = {}; // clear
	ctx.scroll_delta = Vec2{0, 0};
	ctx.last_mouse_pos = ctx.mouse_pos;

	/* sort root containers by zindex */
	n := ctx.root_list.idx;
	sort.quick_sort_proc(ctx.root_list.items[:n], proc(a, b: ^Container) -> int {
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

@private hash :: proc(hash: ^Id, data: rawptr, size: int) {
	size := size;
	cptr := cast(^u8) data;
	for ; size > 0; size -= 1 {
		hash^ = cast(Id) (u32(hash^) ~ u32(cptr^)) * 16777619;
		cptr = mem.ptr_offset(cptr, 1);
	}
}

get_id        :: proc{get_id_string, get_id_any, get_id_bytes, get_id_rawptr};
get_id_any    :: inline proc(ctx: ^Context, val: any)                -> Id do return get_id_bytes(ctx, reflect.to_bytes(val));
get_id_string :: inline proc(ctx: ^Context, str: string)             -> Id do return get_id_bytes(ctx, transmute([]byte) str);
get_id_rawptr :: inline proc(ctx: ^Context, data: rawptr, size: int) -> Id do return get_id_bytes(ctx, mem.slice_ptr(cast(^u8)data, size));
get_id_bytes  :: proc(ctx: ^Context, bytes: []byte) -> Id {
	idx := ctx.id_stack.idx;
	res := ctx.id_stack.items[idx - 1] if idx > 0 else HASH_INITIAL;
	hash(&res, &bytes[0], len(bytes));
	ctx.last_id = res;
	return res;
}

push_id        :: proc{push_id_any, push_id_rawptr, push_id_bytes};
push_id_any    :: inline proc(ctx: ^Context, val: any)                do push(&ctx.id_stack, get_id(ctx, reflect.to_bytes(val)));
push_id_rawptr :: inline proc(ctx: ^Context, data: rawptr, size: int) do push(&ctx.id_stack, get_id(ctx, data, size));
push_id_bytes  :: inline proc(ctx: ^Context, bytes: []byte)           do push(&ctx.id_stack, get_id(ctx, bytes));

pop_id :: proc(ctx: ^Context) do pop(&ctx.id_stack);

push_clip_rect :: proc(ctx: ^Context, rect: Rect) {
	last := get_clip_rect(ctx);
	push(&ctx.clip_stack, clip_rect(rect, last));
}

pop_clip_rect :: proc(ctx: ^Context) {
	pop(&ctx.clip_stack);
}

get_clip_rect :: proc(ctx: ^Context) -> Rect {
	expect(ctx.clip_stack.idx > 0);
	return ctx.clip_stack.items[ctx.clip_stack.idx - 1];
}

check_clip :: proc(ctx: ^Context, r: Rect) -> Clip {
	cr := get_clip_rect(ctx);
	if r.x > cr.x + cr.w || r.x + r.w < cr.x ||
	   r.y > cr.y + cr.h || r.y + r.h < cr.y do return .ALL;
	if r.x >= cr.x && r.x + r.w <= cr.x + cr.w &&
	   r.y >= cr.y && r.y + r.h <= cr.y + cr.h do return .NONE;
	return .PART;
}

@private push_layout :: proc(ctx: ^Context, body: Rect, scroll: Vec2) {
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
	cntaddr := uintptr(cnt);
	push(&ctx.container_stack, cnt);
	push_id(ctx, &cntaddr, size_of(cntaddr));
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

init_window :: proc(ctx: ^Context, cnt: ^Container, opt: Opt_Bits = {}) {
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
	incl(&ctx.mouse_released_bits, btn);
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

/*============================================================================
** commandlist
**============================================================================*/

push_command :: proc(ctx: ^Context, type: Command_Type, size: int) -> ^Command {
	cmd := transmute(^Command) &ctx.command_list.items[ctx.command_list.idx];
	expect(ctx.command_list.idx + size < COMMANDLIST_SIZE);
	cmd.base.type = type;
	cmd.base.size = size;
	ctx.command_list.idx += size;
	return cmd;
}

next_command :: proc(ctx: ^Context, pcmd: ^^Command) -> bool {
	cmd := pcmd^;
	defer pcmd^ = cmd;
	if cmd != nil {
		cmd = cast(^Command) uintptr(int(uintptr(cmd)) + cmd.base.size);
	} else {
		cmd = cast(^Command) &ctx.command_list.items[0];
	}
	invalid_command :: inline proc(ctx: ^Context) -> ^Command do return cast(^Command) &ctx.command_list.items[ctx.command_list.idx];
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

draw_rect :: proc(ctx: ^Context, rect: Rect, color: Color) {
	rect := clip_rect(rect, get_clip_rect(ctx));
	if rect.w > 0 && rect.h > 0 {
		cmd := push_command(ctx, .RECT, size_of(Rect_Command));
		cmd.rect.rect = rect;
		cmd.rect.color = color;
	}
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
	text_cmd := cast(^Text_Command) push_command(ctx, .TEXT, size_of(Text_Command) + len(str));
	text_cmd.pos = pos;
	text_cmd.color = color;
	text_cmd.font = font;
	/* copy string */
	dst_raw_str := transmute(^mem.Raw_String) &text_cmd.str;
	dst_raw_str.data = cast(^byte) mem.ptr_offset(text_cmd, 1);
	dst_raw_str.len = len(str);
	runtime.mem_copy(dst_raw_str.data, (transmute(mem.Raw_String)str).data, len(str));
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

Layout_Type :: enum { NONE = 0, RELATIVE = 1, ABSOLUTE = 2 }

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
		expect(items <= MAX_WIDTHS);
		runtime.mem_copy(&layout.widths, &widths[0], int(items) * size_of(widths[0]));
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
	layout.next_type = .RELATIVE if relative else .ABSOLUTE;
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
	for i := ctx.container_stack.idx - 1; i >= 0; i -= 1 {
		if ctx.container_stack.items[i] == ctx.last_hover_root do return true;
		/* only root containers have their `head` field set; stop searching if we've
		** reached the current root container */
		if ctx.container_stack.items[i].head != nil do break;
	}
	return false;
}

draw_control_frame :: proc(ctx: ^Context, id: Id, rect: Rect, colorid: Color_Type, opt: Opt_Bits = {}) {
	if .NOFRAME in opt do return;
	expect(colorid == .BUTTON || colorid == .BASE);
	colorid := Color_Type(int(colorid) + int((ctx.focus == id) ? 2 : (ctx.hover == id) ? 1 : 0));
	ctx.draw_frame(ctx, rect, colorid);
}

draw_control_text :: proc(ctx: ^Context, str: string, rect: Rect, colorid: Color_Type, opt: Opt_Bits = {}) {
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

update_control :: proc(ctx: ^Context, id: Id, rect: Rect, opt: Opt_Bits = {}) {
	mouseover := mouse_over(ctx, rect);

	if ctx.focus == id do ctx.updated_focus = true;
	if .NOINTERACT in opt do return;
	if mouseover && !mouse_down(ctx) do ctx.hover = id;

	if ctx.focus == id {
		if mouse_pressed(ctx) && !mouseover do set_focus(ctx, 0);
		if !mouse_down(ctx) && .HOLDFOCUS not_in opt do set_focus(ctx, 0);
	}

	if ctx.hover == id {
		if !mouseover {
			ctx.hover = 0;
		} else if mouse_pressed(ctx) {
			set_focus(ctx, id);
		}
	}
}

text :: proc(ctx: ^Context, text: string) {
	text  := text;
	font  := ctx.style.font;
	color := ctx.style.colors[.TEXT];
	layout_begin_column(ctx);
	layout_row(ctx, 1, {-1}, ctx.text_height(font));
	for len(text) > 0 {
		w:     i32;
		start: int;
		end:   int = len(text);
		r := layout_next(ctx);
		for ch, i in text {
			if ch == ' ' || ch == '\n' {
				word := text[start:i];
				w += ctx.text_width(font, word);
				if w > r.w && start != 0 {
					end = start;
					break;
				}
				w += ctx.text_width(font, text[i:i+1]);
				if ch == '\n' {
					end = i+1;
					break;
				}
				start = i+1;
			}
		}
		draw_text(ctx, font, text[:end], Vec2{r.x, r.y}, color);
		text = text[end:];
	}
	layout_end_column(ctx);
}

label :: proc(ctx: ^Context, text: string) {
	draw_control_text(ctx, text, layout_next(ctx), .TEXT);
}

button_ex :: proc(ctx: ^Context, label: string, icon: Icon, opt: Opt_Bits = {}) -> (res: Res_Bits) {
	id := len(label) > 0 ? get_id(ctx, label) : get_id(ctx, icon);
	r := layout_next(ctx);
	update_control(ctx, id, r, opt);
	/* handle click */
	if .LEFT in ctx.mouse_pressed_bits && ctx.focus == id {
		res |= {.SUBMIT};
	}
	/* draw */
	draw_control_frame(ctx, id, r, .BUTTON, opt);
	if len(label) > 0 do draw_control_text(ctx, label, r, .TEXT, opt);
	if icon != .NONE do draw_icon(ctx, icon, r, ctx.style.colors[.TEXT]);
	return;
}

button :: proc(ctx: ^Context, label: string) -> Res_Bits {
	return button_ex(ctx, label, .NONE, {.ALIGNCENTER});
}

checkbox :: proc(ctx: ^Context, state: ^bool, label: string) -> (res: Res_Bits) {
	id := get_id(ctx, uintptr(state));
	r := layout_next(ctx);
	box := Rect{r.x, r.y, r.h, r.h};
	update_control(ctx, id, r, {});
	/* handle click */
	if .LEFT in ctx.mouse_released_bits && ctx.hover == id {
		res |= {.CHANGE};
		state^ = !state^;
	}
	/* draw */
	draw_control_frame(ctx, id, box, .BASE, {});
	if state^ {
		draw_icon(ctx, .CHECK, box, ctx.style.colors[.TEXT]);
	}
	r = Rect{r.x + box.w, r.y, r.w - box.w, r.h};
	draw_control_text(ctx, label, r, .TEXT);
	return;
}

/*
textbox_raw :: proc(ctx: ^Context, buf: string, id: Id, r: Rect, opt: Opt_Bits = {}) -> (res: Res_Bits) {
	update_control(ctx, id, r, opt | .HOLDFOCUS);

	if ctx.focus == id {
		/* handle text input */
		len := len(buf);
		n := min(bufsz - len - 1, strings.builder_len(ctx.text_input));
		if (n > 0) {
			memcpy(buf + len, ctx->text_input, n);
			len += n;
			buf[len] = '\0';
			res |= RES_CHANGE;
		}
		/* handle backspace */
		if .BACKSPACE in ctx.key_pressed_bits && len > 0 {
			panic("FIXME(oskar)");
			// /* skip utf-8 continuation bytes */
			// while ((buf[--len] & 0xc0) == 0x80 && len > 0);
			// buf[len] = '\0';
			// res |= RES_CHANGE;
		}
		/* handle return */
		if .RETURN in ctx.key_pressed_bits {
			set_focus(ctx, 0);
			res |= {.SUBMIT};
		}
	}

	/* draw */
	draw_control_frame(ctx, id, r, .BASE, opt);
	if ctx.focus == id {
		color := ctx.style.colors[.TEXT];
		font := ctx.style.font;
		textw := ctx.text_width(font, buf);
		texth := ctx.text_height(font);
		ofx := r.w - ctx.style.padding - textw - 1;
		textx := r.x + min(ofx, ctx.style.padding);
		texty := r.y + (r.h - texth) / 2;
		push_clip_rect(ctx, r);
		draw_text(ctx, font, buf, Vec2{textx, texty}, color);
		draw_rect(ctx, Rect{textx + textw, texty, 1, texth}, color);
		pop_clip_rect(ctx);
	} else {
		draw_control_text(ctx, buf, r, .TEXT, opt);
	}

	return;
}
*/

/*

static int number_textbox(Context *ctx, Real *value, Rect r, Id id) {
  if (ctx->mouse_pressed == MOUSE_LEFT &&
	  ctx->key_down & KEY_SHIFT &&
	  ctx->hover == id)
  {
	ctx->number_editing = id;
	sprintf(ctx->number_buf, REAL_FMT, *value);
  }
  if (ctx->number_editing == id) {
	int res = textbox_raw(
	  ctx, ctx->number_buf, sizeof(ctx->number_buf), id, r, 0);
	if (res & RES_SUBMIT || ctx->focus != id) {
	  *value = strtod(ctx->number_buf, NULL);
	  ctx->number_editing = 0;
	} else {
	  return 1;
	}
  }
  return 0;
}


int textbox_ex(Context *ctx, char *buf, int bufsz, int opt) {
  Id id = get_id(ctx, &buf, sizeof(buf));
  Rect r = layout_next(ctx);
  return textbox_raw(ctx, buf, bufsz, id, r, opt);
}


int textbox(Context *ctx, char *buf, int bufsz) {
  return textbox_ex(ctx, buf, bufsz, 0);
}


int slider_ex(Context *ctx, Real *value, Real low, Real high,
  Real step, const char *fmt, int opt)
{
  char buf[MAX_FMT + 1];
  Rect thumb;
  int w, res = 0;
  Real normalized, last = *value, v = last;
  Id id = get_id(ctx, &value, sizeof(value));
  Rect base = layout_next(ctx);

  /* handle text input mode */
  if (number_textbox(ctx, &v, base, id)) { return res; }

  /* handle normal mode */
  update_control(ctx, id, base, opt);

  /* handle input */
  if (ctx->focus == id && ctx->mouse_down == MOUSE_LEFT) {
	v = low + ((Real) (ctx->mouse_pos.x - base.x) / base.w) * (high - low);
	if (step) { v = ((long) ((v + step/2) / step)) * step; }
  }
  /* clamp and store value, update res */
  *value = v = clamp(v, low, high);
  if (last != v) { res |= RES_CHANGE; }

  /* draw base */
  draw_control_frame(ctx, id, base, COLOR_BASE, opt);
  /* draw thumb */
  w = ctx->style->thumb_size;
  normalized = (v - low) / (high - low);
  thumb = rect(base.x + normalized * (base.w - w), base.y, w, base.h);
  draw_control_frame(ctx, id, thumb, COLOR_BUTTON, opt);
  /* draw text  */
  sprintf(buf, fmt, v);
  draw_control_text(ctx, buf, base, COLOR_TEXT, opt);

  return res;
}


int slider(Context *ctx, Real *value, Real low, Real high) {
  return slider_ex(ctx, value, low, high, 0, SLIDER_FMT, OPT_ALIGNCENTER);
}


int number_ex(Context *ctx, Real *value, Real step,
  const char *fmt,int opt)
{
  char buf[MAX_FMT + 1];
  int res = 0;
  Id id = get_id(ctx, &value, sizeof(value));
  Rect base = layout_next(ctx);
  Real last = *value;

  /* handle text input mode */
  if (number_textbox(ctx, value, base, id)) { return res; }

  /* handle normal mode */
  update_control(ctx, id, base, opt);

  /* handle input */
  if (ctx->focus == id && ctx->mouse_down == MOUSE_LEFT) {
	*value += ctx->mouse_delta.x * step;
  }
  /* set flag if value changed */
  if (*value != last) { res |= RES_CHANGE; }

  /* draw base */
  draw_control_frame(ctx, id, base, COLOR_BASE, opt);
  /* draw text  */
  sprintf(buf, fmt, *value);
  draw_control_text(ctx, buf, base, COLOR_TEXT, opt);

  return res;
}


int number(Context *ctx, Real *value, Real step) {
  return number_ex(ctx, value, step, SLIDER_FMT, OPT_ALIGNCENTER);
}

*/

@private _header :: proc(ctx: ^Context, state: ^bool, label: string, istreenode: bool) -> Res_Bits {
	layout_row(ctx, 1, []i32{-1}, 0);
	r := layout_next(ctx);
	id := get_id(ctx, state);
	update_control(ctx, id, r, {});
	/* handle click */
	if .LEFT in ctx.mouse_pressed_bits && ctx.focus == id {
		state^ = !state^;
	}
	/* draw */
	if istreenode {
		if ctx.hover == id do ctx.draw_frame(ctx, r, .BUTTONHOVER);
	} else {
		draw_control_frame(ctx, id, r, .BUTTON);
	}
	draw_icon(ctx, state^ ? .EXPANDED : .COLLAPSED, Rect{r.x, r.y, r.h, r.h}, ctx.style.colors[.TEXT]);
	r.x += r.h - ctx.style.padding;
	r.w -= r.h - ctx.style.padding;
	draw_control_text(ctx, label, r, .TEXT);
	return state^ ? {.ACTIVE} : {};
}

header :: proc(ctx: ^Context, state: ^bool, label: string) -> Res_Bits {
	return _header(ctx, state, label, false);
}

begin_treenode :: proc(ctx: ^Context, state: ^bool, label: string) -> Res_Bits {
	res := _header(ctx, state, label, true);
	if .ACTIVE in res {
		get_layout(ctx).indent += ctx.style.indent;
		push_id(ctx, state);
	}
	return res;
}

end_treenode :: proc(ctx: ^Context) {
	get_layout(ctx).indent -= ctx.style.indent;
	pop_id(ctx);
}

@private scrollbar :: proc(ctx: ^Context, cnt: ^Container, _b: ^Rect, cs: Vec2, id_string: string, i: int) {
	b := cast(^struct{ pos, size: [2]i32 }) _b;
	#assert(size_of(b^) == size_of(_b^));

	/* only add scrollbar if content size is larger than body */
	maxscroll   := cs[i] - b.size[i];
	contentsize := b.size[i];
	if maxscroll > 0 && contentsize > 0 {
		id := get_id(ctx, id_string);

		/* get sizing / positioning */
		base := b^;
		base.pos[1-i] = b.pos[1-i] + b.size[1-i];
		base.size[1-i] = ctx.style.scrollbar_size;

		/* handle input */
		update_control(ctx, id, transmute(Rect) base);
		if ctx.focus == id && .LEFT in ctx.mouse_down_bits {
			cnt.scroll[i] += ctx.mouse_delta[i] * cs[i] / base.size[i];
		}
		/* clamp scroll to limits */
		cnt.scroll[i] = clamp(cnt.scroll[i], 0, maxscroll);

		/* draw base and thumb */
		ctx.draw_frame(ctx, transmute(Rect) base, .SCROLLBASE);
		thumb := base;
		thumb.size[i] = max(ctx.style.thumb_size, base.size[i] * b.size[i] / cs[i]);
		thumb.pos[i] += cnt.scroll[i] * (base.size[i] - thumb.size[i]) / maxscroll;
		ctx.draw_frame(ctx, transmute(Rect) thumb, .SCROLLTHUMB);

		/* set this as the scroll_target (will get scrolled on mousewheel) */
		/* if the mouse is over it */
		if mouse_over(ctx, transmute(Rect) b^) do ctx.scroll_target = cnt;
	} else {
		cnt.scroll[i] = 0;
	}
}

@private scrollbars :: proc(ctx: ^Context, cnt: ^Container, body: ^Rect) {
	sz := ctx.style.scrollbar_size;
	cs := cnt.content_size;
	cs.x += ctx.style.padding * 2;
	cs.y += ctx.style.padding * 2;
	push_clip_rect(ctx, body^);
	/* resize body to make room for scrollbars */
	if cs.y > cnt.body.h do body.w -= sz;
	if cs.x > cnt.body.w do body.h -= sz;
	/* to create a horizontal or vertical scrollbar almost-identical code is
	** used; only the references to `x|y` `w|h` need to be switched */
	scrollbar(ctx, cnt, body, cs, "!scrollbarv", 1); // 1 = y,h
	scrollbar(ctx, cnt, body, cs, "!scrollbarh", 0); // 0 = x,w
	pop_clip_rect(ctx);
}

@private push_container_body :: proc(ctx: ^Context, cnt: ^Container, body: Rect, opt: Opt_Bits = {}) {
	body := body;
	if .NOSCROLL not_in opt do scrollbars(ctx, cnt, &body);
	push_layout(ctx, expand_rect(body, -ctx.style.padding), cnt.scroll);
	cnt.body = body;
}

@private begin_root_container :: proc(ctx: ^Context, cnt: ^Container) {
	push_container(ctx, cnt);

	/* push container to roots list and push head command */
	push(&ctx.root_list, cnt);
	cnt.head = push_jump(ctx, nil);

	/* set as hover root if the mouse is overlapping this container and it has a
	** higher zindex than the current hover root */
	if rect_overlaps_vec2(cnt.rect, ctx.mouse_pos) && (ctx.hover_root == nil || cnt.zindex > ctx.hover_root.zindex) {
		ctx.hover_root = cnt;
	}

	/* clipping is reset here in case a root-container is made within
	** another root-containers's begin/end block; this prevents the inner
	** root-container being clipped to the outer */
	push(&ctx.clip_stack, unclipped_rect);
}

@private end_root_container :: proc(ctx: ^Context) {
	/* push tail 'goto' jump command and set head 'skip' command. the final steps
	** on initing these are done in end() */
	cnt := get_container(ctx);
	cnt.tail = push_jump(ctx, nil);
	cnt.head.jump.dst = &ctx.command_list.items[ctx.command_list.idx];
	/* pop base clip rect and container */
	pop_clip_rect(ctx);
	pop_container(ctx);
}

begin_window_ex :: proc(ctx: ^Context, cnt: ^Container, title: string, opt: Opt_Bits = {}) -> bool {
	if !cnt.inited do init_window(ctx, cnt, opt);
	if !cnt.open do return false;

	begin_root_container(ctx, cnt);
	rect := cnt.rect;
	body := rect;

	/* draw frame */
	if .NOFRAME not_in opt {
		ctx.draw_frame(ctx, rect, .WINDOWBG);
	}

	/* do title bar */
	titlerect := rect;
	titlerect.h = ctx.style.title_height;
	if .NOTITLE not_in opt {
		ctx.draw_frame(ctx, titlerect, .TITLEBG);

		/* do title text */
		if .NOTITLE not_in opt {
			id := get_id(ctx, "!title");
			update_control(ctx, id, titlerect, opt);
			draw_control_text(ctx, title, titlerect, .TITLETEXT, opt);
			if id == ctx.focus && ctx.mouse_down_bits == {.LEFT} {
				cnt.rect.x += ctx.mouse_delta.x;
				cnt.rect.y += ctx.mouse_delta.y;
			}
			body.y += titlerect.h;
			body.h -= titlerect.h;
		}

		/* do `close` button */
		if .NOCLOSE not_in opt {
			id := get_id(ctx, "!close");
			r := Rect{titlerect.x + titlerect.w - titlerect.h, titlerect.y, titlerect.h, titlerect.h};
			titlerect.w -= r.w;
			draw_icon(ctx, .CLOSE, r, ctx.style.colors[.TITLETEXT]);
			update_control(ctx, id, r, opt);
			if .LEFT in ctx.mouse_released_bits && id == ctx.hover {
				cnt.open = false;
			}
		}
	}

	/* do `resize` handle */
	if .NORESIZE not_in opt {
		sz := ctx.style.footer_height;
		id := get_id(ctx, "!resize");
		r := Rect{rect.x + rect.w - sz, rect.y + rect.h - sz, sz, sz};
		draw_icon(ctx, .RESIZE, r, ctx.style.colors[.TEXT]);
		update_control(ctx, id, r, opt);
		if id == ctx.focus && .LEFT in ctx.mouse_down_bits {
			cnt.rect.w = max(96, cnt.rect.w + ctx.mouse_delta.x);
			cnt.rect.h = max(64, cnt.rect.h + ctx.mouse_delta.y);
		}
		body.h -= sz;
	}

	push_container_body(ctx, cnt, body, opt);

	/* resize to content size */
	if .AUTOSIZE in opt {
		r := get_layout(ctx).body;
		cnt.rect.w = cnt.content_size.x + (cnt.rect.w - r.w);
		cnt.rect.h = cnt.content_size.y + (cnt.rect.h - r.h);
	}

	/* close if this is a popup window and elsewhere was clicked */
	if .POPUP in opt && mouse_pressed(ctx) && ctx.last_hover_root != cnt {
		cnt.open = false;
	}

	push_clip_rect(ctx, cnt.body);
	return true;
}

begin_window :: proc(ctx: ^Context, cnt: ^Container, title: string) -> bool {
	return begin_window_ex(ctx, cnt, title);
}

end_window :: proc(ctx: ^Context) {
	pop_clip_rect(ctx);
	end_root_container(ctx);
}

open_popup :: proc(ctx: ^Context, cnt: ^Container) {
	/* set as hover root so popup isn't closed in begin_window_ex()  */
	ctx.last_hover_root = cnt;
	ctx.hover_root = cnt;
	/* init container if not inited */
	if !cnt.inited do init_window(ctx, cnt);
	/* position at mouse cursor, open and bring-to-front */
	cnt.rect = Rect{ctx.mouse_pos.x, ctx.mouse_pos.y, 0, 0};
	cnt.open = true;
	bring_to_front(ctx, cnt);
}

begin_popup :: proc(ctx: ^Context, cnt: ^Container) -> bool {
	opt := Opt_Bits{.POPUP, .AUTOSIZE, .NORESIZE, .NOSCROLL, .NOTITLE, .CLOSED};
	return begin_window_ex(ctx, cnt, "", opt);
}

end_popup :: proc(ctx: ^Context) {
	end_window(ctx);
}

begin_panel_ex :: proc(ctx: ^Context, cnt: ^Container, opt: Opt_Bits = {}) {
	cnt.rect = layout_next(ctx);
	if .NOFRAME not_in opt do ctx.draw_frame(ctx, cnt.rect, .PANELBG);
	push_container(ctx, cnt);
	push_container_body(ctx, cnt, cnt.rect, opt);
	push_clip_rect(ctx, cnt.body);
}

begin_panel :: proc(ctx: ^Context, cnt: ^Container) {
	begin_panel_ex(ctx, cnt);
}

end_panel :: proc(ctx: ^Context) {
	pop_clip_rect(ctx);
	pop_container(ctx);
}

@private mouse_released :: inline proc(ctx: ^Context) -> bool do return card(ctx.mouse_released_bits) != 0;
@private mouse_pressed  :: inline proc(ctx: ^Context) -> bool do return card(ctx.mouse_pressed_bits) != 0;
@private mouse_down     :: inline proc(ctx: ^Context) -> bool do return card(ctx.mouse_down_bits) != 0;
