include renderer

var
  logbuf: string
  logbuf_updated = false
  bg = [90.Real, 95, 100]

#type PContext = ptr Context
proc wlog(text: cstring) =
  if logbuf.len > 2048: logbuf = ""
  if logbuf.len>0: logbuf.add '\n'
  logbuf.add text
  logbuf_updated = true


proc test_window(ctx: PContext) =
  var
    win: ptr Container
    buf: string
  if ctx.begin_window("demo win", mu.rect(40,40,300,450))!=0:
    win = get_current_container(ctx)
    win.rect.w = mu.max(win.rect.w, 240)
    win.rect.h = mu.max(win.rect.h, 300)

    if ctx.header("win info")!=0:
      win = get_current_container(ctx)
      let v {.global.} = [54.cint, -1]
      ctx.layout_row(2,v[0].addr, 0)
      ctx.label("position:")
      buf = $win.rect.x & "," & $win.rect.y; ctx.label(buf.cstring)
      ctx.label("size:")
      buf = $win.rect.w & "," & $win.rect.h; ctx.label(buf.cstring)

    if ctx.header_ex("test buttons", OPT_EXPANDED)!=0:
      let v {.global.} = [86.cint, -110, -1]
      ctx.layout_row(3, v[0].addr, 0)
      ctx.label("test btn1:")
      if ctx.button("btn1:")!=0: wlog("pres btn1")
      if ctx.button("btn2:")!=0: wlog("pres btn2")
      ctx.label("test btn2:")
      if ctx.button("btn3:")!=0: wlog("pres btn3")
      if ctx.button("popup:")!=0: ctx.open_popup("test popup")
      if ctx.begin_popup("test popup")!=0:
        discard ctx.button("hello")
        discard ctx.button("world")
        ctx.end_popup()

    if ctx.header_ex("tree and text", OPT_EXPANDED)!=0:
      let v {.global.} = [140.cint, -1]
      ctx.layout_row(2, v[0].addr, 0)
      ctx.layout_begin_column()
      if ctx.begin_treenode("test 1")!=0:
        if ctx.begin_treenode("test 1a")!=0:
          ctx.label("hello")
          ctx.label("tree!")
          ctx.end_treenode()
        if ctx.begin_treenode("test 1b")!=0:
          if ctx.button("tbtn1:")!=0: wlog("pres tbtn1")
          if ctx.button("tbtn2:")!=0: wlog("pres tbtn2")
          ctx.end_treenode()
        ctx.end_treenode()

      if ctx.begin_treenode("test 2")!=0:
        let v {.global.} = [54.cint, 54]
        ctx.layout_row(2, v[0].addr, 0)
        if ctx.button("tbtn3:")!=0: wlog("pres tbtn3")
        if ctx.button("tbtn4:")!=0: wlog("pres tbtn4")
        if ctx.button("tbtn5:")!=0: wlog("pres tbtn5")
        if ctx.button("tbtn6:")!=0: wlog("pres tbtn6")
        ctx.end_treenode()

      if ctx.begin_treenode("test 3")!=0:
        let chks {.global.} = [1.cint, 0, 1]
        discard ctx.checkbox("chkbox1", chks[0].addr)
        discard ctx.checkbox("chkbox1", chks[1].addr)
        discard ctx.checkbox("chkbox1", chks[2].addr)
        ctx.end_treenode()
      ctx.layout_end_column()

      ctx.layout_begin_column()
      let v2 {.global.} = [-1.cint]
      ctx.layout_row(1, v2[0].addr, 0)
      ctx.text("Lorem ipsum dolor sit amet, consectetur adipiscing \nelit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus \nipsum, eu varius magna felis a nulla.")
      ctx.layout_end_column()

    if ctx.header_ex("bg color", OPT_EXPANDED)!=0:
      let v {.global.} = [-78.cint, -1]
      ctx.layout_row(2, v[0].addr, 74)

      ctx.layout_begin_column()
      let v2 {.global.} = [46.cint, -1]
      ctx.layout_row(2, v2[0].addr, 0)
      ctx.label("red:"); discard ctx.slider(bg[0].addr, 0.Real, 255.Real)
      ctx.label("green:"); discard ctx.slider(bg[1].addr, 0.Real, 255.Real)
      ctx.label("blue:"); discard ctx.slider(bg[2].addr, 0.Real, 255.Real)
      ctx.layout_end_column()

      var r = ctx.layout_next()
      ctx.draw_rect(r, mu.color(bg[0].cint, bg[1].cint, bg[2].cint, 255.cint))
      var buf = $bg[0].int & "," & $bg[1].int & "," & $bg[2].int
      ctx.draw_control_text(buf.cstring, r, COLOR_TEXT, OPT_ALIGNCENTER)
    ctx.end_window()

proc log_window(ctx: PContext) =
  if ctx.begin_window("log win", mu.rect(350, 40, 300, 200))!=0:
    let v {.global.} = [-1.cint]
    ctx.layout_row(1, v[0].addr, -25)
    ctx.begin_panel("log output")
    var panel = ctx.get_current_container()
    ctx.layout_row(1, v[0].addr, -1)
    ctx.text(logbuf.cstring)
    ctx.end_panel()
    if logbuf_updated:
      panel.scroll.y = panel.content_size.y
      logbuf_updated = false

    var
      buf0 {.global.}: array[128, char]
      buf: cstring = cast[cstring](buf0.addr)
      bsub = false
      v2 {.global.} = [-70.cint, -1]
    ctx.layout_row(2, v2[0].addr, 0)
    if (ctx.textbox(buf, buf0.high) and RES_SUBMIT) != 0:
      ctx.set_focus(ctx.last_id)
      bsub = true
    if ctx.button("submit") != 0: bsub = true
    if bsub:
      wlog(buf)
      zeroMem(buf, buf.len)

    ctx.end_window()

proc uint8_slider(ctx: PContext, val: ptr uint8, low:int, high:int): int  =
  var tmp {.global.}: Real
  ctx.push_id(val.addr, sizeof(val).cint)
  tmp = val[].Real
  result = ctx.slider_ex(tmp.addr, low.Real, high.Real, 0.Real, "%.0f", OPT_ALIGNCENTER)
  val[] = tmp.uint8
  ctx.pop_id()

proc style_window(ctx: PContext) =
  let colors {.global.} = [ "text:", "border:", "windowbg:", "titlebg:", "titletext:", "panelbg:", "button:", "buttonhover:", "buttonfocus:", "base:", "basehover:", "basefocus:", "scrollbase:", "scrollthumb:" ]
  if ctx.begin_window("style editor", mu.rect(350, 250, 300, 240))!=0:
    var
      sw = (ctx.get_current_container().body.w.float * 0.14).cint
      v = [80.cint, sw, sw, sw, sw, -1]
    ctx.layout_row(6, v[0].addr, 0)
    for i, v in colors:
      ctx.label(v.cstring)
      discard uint8_slider(ctx, ctx.style.colors[i].r.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].g.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].b.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].a.addr, 0, 255)
      ctx.draw_rect(ctx.layout_next(), ctx.style.colors[i])
    ctx.end_window()


proc process_frame(ctx: PContext) =
  ctx.begin()
  style_window(ctx)
  log_window(ctx)
  test_window(ctx)
  ctx.end()

const button_map = {
  BUTTON_LEFT   and 0xff : MOUSE_LEFT,
  BUTTON_RIGHT  and 0xff : MOUSE_RIGHT,
  BUTTON_MIDDLE and 0xff : MOUSE_MIDDLE,
}.totable
const key_map = {
  K_LSHIFT       and 0xff : KEY_SHIFT,
  K_RSHIFT       and 0xff : KEY_SHIFT,
  K_LCTRL        and 0xff : KEY_CTRL,
  K_RCTRL        and 0xff : KEY_CTRL,
  K_LALT         and 0xff : KEY_ALT,
  K_RALT         and 0xff : KEY_ALT,
  K_RETURN       and 0xff : KEY_RETURN,
  K_BACKSPACE    and 0xff : KEY_BACKSPACE,
}.totable

proc text_width(font: Font; text: cstring; len: cint): cint {. cdecl.} =
  var n = len
  if n == -1: n = text.len.cint
  return r_get_text_width(text, n)

proc text_height(font: Font): cint {.cdecl} =
  result = r_get_text_height()


proc main =
  sdl.init(INIT_EVERYTHING)
  r_init()

  var ctx: PContext = cast[PContext](alloc0(sizeof(mu.Context)))
  ctx.init()
  ctx.text_width = text_width
  ctx.text_height = text_height

  var
    b = 0.cint
    bRun = true
  while bRun:
    var e: sdl.Event
    while sdl.pollEvent(e):
      b = 0
      case e.kind:
      of QuitEvent: bRun = false; break
      of MOUSEMOTION: ctx.input_mousemove(e.motion.x, e.motion.y)
      of MOUSEWHEEL: ctx.input_scroll(0, e.wheel.y * -30)
      #of TEXTINPUT: ctx.input_text(cast[cstring](e.text.text.addr)) #failed, fix it pls
      of TEXTINPUT: input_text(ctx, cast[cstring](e.text.text.addr))
      of MOUSEBUTTONDOWN, MOUSEBUTTONUP:
        if button_map.hasKey(e.button.button and 0xff):
          b = button_map[e.button.button and 0xff].cint
        if (b!=0) and (e.kind == MOUSEBUTTONDOWN):
          ctx.input_mousedown(e.button.x, e.button.y, b)
        if (b!=0) and (e.kind == MOUSEBUTTONUP):
          ctx.input_mouseup(e.button.x, e.button.y, b)
      of KEYDOWN, KEYUP:
        if key_map.hasKey(e.key.keysym.sym and 0xff):
          b = key_map[e.key.keysym.sym and 0xff].cint
        if (b!=0) and (e.kind == KEYDOWN):
          ctx.input_keydown(b)
        if (b!=0) and (e.kind == KEYUP):
          ctx.input_keyup(b)
      else: discard

    process_frame(ctx)

    r_clear(mu.color(bg[0].cint, bg[1].cint, bg[2].cint, 255.cint))
    var cmd: ptr mu.Command = nil
    while ctx.next_command(cmd.addr) != 0:
      case cmd.typec:
      of COMMAND_TEXT: r_draw_text(cast[cstring](cmd.text.str[0].addr), cmd.text.pos, cmd.text.color)
      of COMMAND_RECT: r_draw_rect(cmd.rect.rect, cmd.rect.color)
      of COMMAND_ICON: r_draw_icon(cmd.icon.id, cmd.icon.rect, cmd.icon.color)
      of COMMAND_CLIP: r_set_clip_rect(cmd.clip.rect)
      else: discard

    r_present()
  sdl.quit()
main()
