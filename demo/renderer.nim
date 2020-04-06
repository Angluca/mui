include atlas
import sdl2 as sdl
import opengl

const
  BUFFER_SIZE = 16384
  WIDTH = 800
  HEIGHT = 600
var
  tex_buf : array[BUFFER_SIZE * 8, GL_Float]
  vert_buf: array[BUFFER_SIZE * 8, GL_Float]
  color_buf: array[BUFFER_SIZE * 16, GLubyte]
  index_buf: array[BUFFER_SIZE * 6, GLuint]
  window: WindowPtr = nil
  buf_idx = 0.int

proc r_init =
  window = createWindow(nil, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH, HEIGHT, SDL_WINDOW_OPENGL)
  loadExtensions()
  discard glCreateContext(window)
  glEnable(GL_BLEND)
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glDisable(GL_CULL_FACE)
  glDisable(GL_DEPTH_TEST)
  glEnable(GL_SCISSOR_TEST)
  glEnable(GL_TEXTURE_2D)
  glEnableClientState(GL_VERTEX_ARRAY)
  glEnableClientState(GL_TEXTURE_COORD_ARRAY)
  glEnableClientState(GL_COLOR_ARRAY)

  var id: GLuint
  glGenTextures(1, id.addr)
  glBindTexture(GL_TEXTURE_2D, id)
  glTexImage2D(GL_TEXTURE_2D, 0.GLint, GL_ALPHA.GLint, ATLAS_WIDTH, ATLAS_HEIGHT, 0.GLint, GL_ALPHA, GL_UNSIGNED_BYTE, atlas_texture.unsafeAddr)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
  assert glGetError().int == 0

proc flush =
  if buf_idx == 0: return
  glViewport(0, 0, WIDTH, HEIGHT)
  glMatrixMode(GL_PROJECTION)
  glPushMatrix()
  glLoadIdentity()
  glOrtho(0.0f, WIDTH, HEIGHT, 0.0f, -1.0f, +1.0f)
  glMatrixMode(GL_MODELVIEW)
  glPushMatrix()
  glLoadIdentity()

  glTexCoordPointer(2, cGL_FLOAT, 0, tex_buf.unsafeAddr)
  glVertexPointer(2, cGL_FLOAT, 0, vert_buf.unsafeAddr)
  glColorPointer(4, GL_UNSIGNED_BYTE, 0, color_buf.unsafeAddr)
  glDrawElements(GL_TRIANGLES, (buf_idx * 6).GLsizei, GL_UNSIGNED_INT, index_buf.unsafeAddr)

  glMatrixMode(GL_MODELVIEW)
  glPopMatrix()
  glMatrixMode(GL_PROJECTION)
  glPopMatrix()
  buf_idx = 0

proc push_quad(dst, src: mu.Rect; color: mu.Color) =
  if buf_idx == BUFFER_SIZE: flush()
  var
    texvert_idx = buf_idx * 8
    color_idx = buf_idx * 16
    element_idx = buf_idx * 4
    index_idx = buf_idx * 6
    x = src.x.float/ATLAS_WIDTH.float
    y = src.y.float/ATLAS_WIDTH.float
    w = src.w.float/ATLAS_WIDTH.float
    h = src.h.float/ATLAS_WIDTH.float

  inc(buf_idx) #buf_idx += 1
  tex_buf[texvert_idx+0] = x
  tex_buf[texvert_idx+1] = y
  tex_buf[texvert_idx+2] = x+w
  tex_buf[texvert_idx+3] = y
  tex_buf[texvert_idx+4] = x
  tex_buf[texvert_idx+5] = y+h
  tex_buf[texvert_idx+6] = x+w
  tex_buf[texvert_idx+7] = y+h

  vert_buf[texvert_idx+0] = dst.x.GLfloat
  vert_buf[texvert_idx+1] = dst.y.GLfloat
  vert_buf[texvert_idx+2] = (dst.x + dst.w).GLfloat
  vert_buf[texvert_idx+3] = dst.y.GLfloat
  vert_buf[texvert_idx+4] = dst.x.GLfloat
  vert_buf[texvert_idx+5] = (dst.y + dst.h).GLfloat
  vert_buf[texvert_idx+6] = (dst.x + dst.w).GLfloat
  vert_buf[texvert_idx+7] = (dst.y + dst.h).GLfloat

  template cbcpy(idx: int) =
    copyMem(color_buf[idx].addr, color.r.unsafeAddr, 4)
  cbcpy(color_idx)
  cbcpy(color_idx+4)
  cbcpy(color_idx+8)
  cbcpy(color_idx+12)

  index_buf[index_idx+0] = (element_idx+0).GLuint
  index_buf[index_idx+1] = (element_idx+1).GLuint
  index_buf[index_idx+2] = (element_idx+2).GLuint
  index_buf[index_idx+3] = (element_idx+2).GLuint
  index_buf[index_idx+4] = (element_idx+3).GLuint
  index_buf[index_idx+5] = (element_idx+1).GLuint

proc r_draw_rect(rect: mu.Rect, color: mu.Color) =
  push_quad(rect, atlas[ATLAS_WHITE], color)

proc r_draw_text(p: cstring, pos:mu.Vec2, color: mu.Color) =
  var
    dst = mu.rect(pos.x, pos.y, 0, 0)
    chr: int
    src: mu.Rect
  for i,v in p:
    if (v.uint8 and 0xc0) == 0x80: continue
    chr = mu.min(v.uint8, 127).int + ATLAS_FONT
    if atlas.hasKey(chr):
      src = atlas[chr]
      dst.w = src.w
      dst.h = src.h
      push_quad(dst, src, color)
      dst.x += dst.w

proc r_draw_icon(id:int, rect:mu.Rect, color:mu.Color) =
  if atlas.hasKey(id):
    var
      src = atlas[id]
      x = rect.x + ((rect.w-src.w)/2).cint
      y = rect.y + ((rect.h-src.h)/2).cint
    push_quad(mu.rect(x,y,src.w,src.h), src, color)

proc r_get_text_width(p: cstring, len:int): cint =
  var
    chr: int
  for i in 0..<len:
    if (p[i].uint8 and 0xc0) == 0x80: continue
    chr = mu.min(p[i].uint8, 127).int + ATLAS_FONT
    if atlas.hasKey(chr):
      result += atlas[chr].w

proc r_get_text_height:cint = 18

proc r_set_clip_rect(rect:mu.Rect) =
  flush()
  glScissor(rect.x, HEIGHT - (rect.y + rect.h), rect.w, rect.h)

proc r_clear(clr: mu.Color) =
  flush()
  glClearColor(clr.r.float/255.0, clr.g.float/255.0, clr.b.float/255.0, clr.a.float/255.0)
  glClear(GL_COLOR_BUFFER_BIT)

proc r_present =
  flush()
  glSwapWindow(window)
