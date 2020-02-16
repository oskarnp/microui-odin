package microui_demo

import gl  "./odin-gl"
import sdl "./odin-sdl2"
import mu  "../"

window: ^sdl.Window;
width: i32  = 800;
height: i32 = 600;

r_init :: proc() {
  /* init SDL window */
  window = sdl.create_window(
  nil, cast(i32)sdl.Window_Pos.Undefined, cast(i32)sdl.Window_Pos.Undefined,
  width, height, sdl.Window_Flags.Open_GL);
  sdl.gl_create_context(window);

  /* init gl */
  gl.Enable(gl.BLEND);
  gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  gl.Disable(gl.CULL_FACE);
  gl.Disable(gl.DEPTH_TEST);
  gl.Enable(gl.SCISSOR_TEST);
  gl.Enable(gl.TEXTURE_2D);
  // gl.EnableClientState(gl.VERTEX_ARRAY);
  // gl.EnableClientState(gl.TEXTURE_COORD_ARRAY);
  // gl.EnableClientState(gl.COLOR_ARRAY);

  /* init texture */
  id: u32;
  gl.GenTextures(1, &id);
  gl.BindTexture(gl.TEXTURE_2D, id);
  gl.TexImage2D(gl.TEXTURE_2D, 0, gl.ALPHA, ATLAS_WIDTH, ATLAS_HEIGHT, 0, gl.ALPHA, gl.UNSIGNED_BYTE, &atlas_texture);
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
  gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
  assert(gl.GetError() == 0);
}

r_clear :: proc(clr: mu.Color) {
	// TODO(oskar)
}

r_get_text_width :: proc(text: string) -> i32 {
	// TODO(oskar)
	return 0;
}

r_get_text_height :: proc() -> i32 {
	// TODO(oskar)
	return 0;
}


/*
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>
#include <assert.h>
#include "renderer.h"
#include "atlas.inl"

#define BUFFER_SIZE 16384

static GLfloat   tex_buf[BUFFER_SIZE *  8];
static GLfloat  vert_buf[BUFFER_SIZE *  8];
static GLubyte color_buf[BUFFER_SIZE * 16];
static GLuint  index_buf[BUFFER_SIZE *  6];

static int buf_idx;

static SDL_Window *window;


*/


flush :: proc() {
	// TODO(oskar)
/*
  if (buf_idx == 0) { return; }

  glViewport(0, 0, width, height);
  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  glOrtho(0.0f, width, height, 0.0f, -1.0f, +1.0f);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix();
  glLoadIdentity();

  glTexCoordPointer(2, GL_FLOAT, 0, tex_buf);
  glVertexPointer(2, GL_FLOAT, 0, vert_buf);
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, color_buf);
  glDrawElements(GL_TRIANGLES, buf_idx * 6, GL_UNSIGNED_INT, index_buf);

  glMatrixMode(GL_MODELVIEW);
  glPopMatrix();
  glMatrixMode(GL_PROJECTION);
  glPopMatrix();

  buf_idx = 0;
*/
}


/*
static void push_quad(mu_Rect dst, mu_Rect src, mu_Color color) {
  if (buf_idx == BUFFER_SIZE) { flush(); }

  int texvert_idx = buf_idx *  8;
  int   color_idx = buf_idx * 16;
  int element_idx = buf_idx *  4;
  int   index_idx = buf_idx *  6;
  buf_idx++;

  /* update texture buffer */
  float x = src.x / (float) ATLAS_WIDTH;
  float y = src.y / (float) ATLAS_HEIGHT;
  float w = src.w / (float) ATLAS_WIDTH;
  float h = src.h / (float) ATLAS_HEIGHT;
  tex_buf[texvert_idx + 0] = x;
  tex_buf[texvert_idx + 1] = y;
  tex_buf[texvert_idx + 2] = x + w;
  tex_buf[texvert_idx + 3] = y;
  tex_buf[texvert_idx + 4] = x;
  tex_buf[texvert_idx + 5] = y + h;
  tex_buf[texvert_idx + 6] = x + w;
  tex_buf[texvert_idx + 7] = y + h;

  /* update vertex buffer */
  vert_buf[texvert_idx + 0] = dst.x;
  vert_buf[texvert_idx + 1] = dst.y;
  vert_buf[texvert_idx + 2] = dst.x + dst.w;
  vert_buf[texvert_idx + 3] = dst.y;
  vert_buf[texvert_idx + 4] = dst.x;
  vert_buf[texvert_idx + 5] = dst.y + dst.h;
  vert_buf[texvert_idx + 6] = dst.x + dst.w;
  vert_buf[texvert_idx + 7] = dst.y + dst.h;

  /* update color buffer */
  memcpy(color_buf + color_idx +  0, &color, 4);
  memcpy(color_buf + color_idx +  4, &color, 4);
  memcpy(color_buf + color_idx +  8, &color, 4);
  memcpy(color_buf + color_idx + 12, &color, 4);

  /* update index buffer */
  index_buf[index_idx + 0] = element_idx + 0;
  index_buf[index_idx + 1] = element_idx + 1;
  index_buf[index_idx + 2] = element_idx + 2;
  index_buf[index_idx + 3] = element_idx + 2;
  index_buf[index_idx + 4] = element_idx + 3;
  index_buf[index_idx + 5] = element_idx + 1;
}


void r_draw_rect(mu_Rect rect, mu_Color color) {
  push_quad(rect, atlas[ATLAS_WHITE], color);
}


void r_draw_text(const char *text, mu_Vec2 pos, mu_Color color) {
  mu_Rect dst = { pos.x, pos.y, 0, 0 };
  for (const char *p = text; *p; p++) {
	if ((*p & 0xc0) == 0x80) { continue; }
	int chr = mu_min((unsigned char) *p, 127);
	mu_Rect src = atlas[ATLAS_FONT + chr];
	dst.w = src.w;
	dst.h = src.h;
	push_quad(dst, src, color);
	dst.x += dst.w;
  }
}


void r_draw_icon(int id, mu_Rect rect, mu_Color color) {
  mu_Rect src = atlas[id];
  int x = rect.x + (rect.w - src.w) / 2;
  int y = rect.y + (rect.h - src.h) / 2;
  push_quad(mu_rect(x, y, src.w, src.h), src, color);
}


int r_get_text_width(const char *text, int len) {
  int res = 0;
  for (const char *p = text; *p && len--; p++) {
	if ((*p & 0xc0) == 0x80) { continue; }
	int chr = mu_min((unsigned char) *p, 127);
	res += atlas[ATLAS_FONT + chr].w;
  }
  return res;
}


int r_get_text_height(void) {
  return 18;
}


void r_set_clip_rect(mu_Rect rect) {
  flush();
  glScissor(rect.x, height - (rect.y + rect.h), rect.w, rect.h);
}


void r_clear(mu_Color clr) {
  flush();
  glClearColor(clr.r / 255., clr.g / 255., clr.b / 255., clr.a / 255.);
  glClear(GL_COLOR_BUFFER_BIT);
}

*/

r_present :: proc() {
  flush();
  sdl.gl_swap_window(window);
}


