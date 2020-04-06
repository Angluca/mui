include renderer

var
  logbuf: string
  logbuf_updated = false
  bg = [90.Real, 95, 100]

type PContext = ptr Context
proc wlog(text: cstring) =
  if logbuf.len > 2048: logbuf = ""
  if logbuf.len>0: logbuf.add '\n'
  logbuf.add text
  logbuf_updated = true


proc test_window(ctx: PContext) =
  var
    win: ptr Container
    buf: string
  if mu.begin_window(ctx, "demo win", mu.rect(40,40,300,450))!=0:
    win = get_current_container(ctx)
    win.rect.w = mu.max(win.rect.w, 240)
    win.rect.h = mu.max(win.rect.h, 300)

    if mu.header(ctx, "win info")!=0:
      win = get_current_container(ctx)
      var v {.global.} = [54.cint, -1]
      mu.layout_row(ctx, 2,v[0].addr, 0)
      mu.label(ctx, "position:")
      buf = $win.rect.x & "," & $win.rect.y; mu.label(ctx, buf)
      mu.label(ctx, "size:")
      buf = $win.rect.w & "," & $win.rect.h; mu.label(ctx, buf)

    if mu.header_ex(ctx, "test buttons", OPT_EXPANDED)!=0:
      var v {.global.} = [86.cint, -110, -1]
      mu.layout_row(ctx, 3, v[0].addr, 0)
      mu.label(ctx, "test btn1:")
      if mu.button(ctx, "btn1:")!=0: wlog("pres btn1")
      if mu.button(ctx, "btn2:")!=0: wlog("pres btn2")
      mu.label(ctx, "test btn2:")
      if mu.button(ctx, "btn3:")!=0: wlog("pres btn3")
      if mu.button(ctx, "popup:")!=0: mu.open_popup(ctx, "test popup")
      if mu.begin_popup(ctx, "test popup")!=0:
        discard mu.button(ctx, "hello")
        discard mu.button(ctx, "world")
        mu.end_popup(ctx)

    if mu.header_ex(ctx, "tree and text", OPT_EXPANDED)!=0:
      var v {.global.} = [140.cint, -1]
      mu.layout_row(ctx, 2, v[0].addr, 0)
      mu.layout_begin_column(ctx)
      if mu.begin_treenode(ctx, "test 1")!=0:
        if mu.begin_treenode(ctx, "test 1a")!=0:
          mu.label(ctx, "hello")
          mu.label(ctx, "tree!")
          mu.end_treenode(ctx)
        if mu.begin_treenode(ctx, "test 1b")!=0:
          if mu.button(ctx, "tbtn1:")!=0: wlog("pres tbtn1")
          if mu.button(ctx, "tbtn2:")!=0: wlog("pres tbtn2")
          mu.end_treenode(ctx)
        mu.end_treenode(ctx)

      if mu.begin_treenode(ctx, "test 2")!=0:
        var v {.global.} = [54.cint, 54]
        mu.layout_row(ctx, 2, v[0].addr, 0)
        if mu.button(ctx, "tbtn3:")!=0: wlog("pres tbtn3")
        if mu.button(ctx, "tbtn4:")!=0: wlog("pres tbtn4")
        if mu.button(ctx, "tbtn5:")!=0: wlog("pres tbtn5")
        if mu.button(ctx, "tbtn6:")!=0: wlog("pres tbtn6")
        mu.end_treenode(ctx)

      if mu.begin_treenode(ctx, "test 3")!=0:
        var chks {.global.} = [1.cint, 0, 1]
        discard mu.checkbox(ctx, "chkbox1", chks[0].addr)
        discard mu.checkbox(ctx, "chkbox1", chks[1].addr)
        discard mu.checkbox(ctx, "chkbox1", chks[2].addr)
        mu.end_treenode(ctx)
      mu.layout_end_column(ctx)

      mu.layout_begin_column(ctx)
      var v2 {.global.} = [-1.cint]
      mu.layout_row(ctx, 1, v2[0].addr, 0)
      mu.text(ctx, "Lorem ipsum dolor sit amet, consectetur adipiscing \nelit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus \nipsum, eu varius magna felis a nulla.")
      mu.layout_end_column(ctx)

    if mu.header_ex(ctx, "bg color", OPT_EXPANDED)!=0:
      var v {.global.} = [-78.cint, -1]
      mu.layout_row(ctx, 2, v[0].addr, 74)

      mu.layout_begin_column(ctx)
      var v2 {.global.} = [46.cint, -1]
      mu.layout_row(ctx, 2, v2[0].addr, 0)
      mu.label(ctx, "red:"); discard mu.slider(ctx, bg[0].addr, 0.Real, 255.Real)
      mu.label(ctx, "green:"); discard mu.slider(ctx, bg[1].addr, 0.Real, 255.Real)
      mu.label(ctx, "blue:"); discard mu.slider(ctx, bg[2].addr, 0.Real, 255.Real)
      mu.layout_end_column(ctx)

      var r = mu.layout_next(ctx)
      mu.draw_rect(ctx, r, mu.color(bg[0].cint, bg[1].cint, bg[2].cint, 255.cint))
      var buf = $bg[0].int & "," & $bg[1].int & "," & $bg[2].int
      mu.draw_control_text(ctx, buf[0].addr, r, COLOR_TEXT, OPT_ALIGNCENTER)
    mu.end_window(ctx)

proc log_window(ctx: PContext) =
  if mu.begin_window(ctx, "log win", mu.rect(350, 40, 300, 200))!=0:
    var v {.global.} = [-1.cint]
    mu.layout_row(ctx, 1, v[0].addr, -25)
    mu.begin_panel(ctx, "log output")
    var panel = mu.get_current_container(ctx)
    mu.layout_row(ctx, 1, v[0].addr, -1)
    mu.text(ctx, logbuf)
    mu.end_panel(ctx)
    if logbuf_updated:
      panel.scroll.y = panel.content_size.y
      logbuf_updated = false

    var
      buf {.global.}: array[128, char]
      bsub = false
      v2 {.global.} = [-70.cint, -1]
    mu.layout_row(ctx, 2, v2[0].addr, 0)
    if (mu.textbox(ctx, buf.unsafeAddr, buf.high) and RES_SUBMIT) != 0:
      mu.set_focus(ctx, ctx.last_id)
      bsub = true
    if mu.button(ctx, "submit") != 0: bsub = true
    if bsub:
      wlog(buf.unsafeAddr)
      buf[0] = '\0'

    mu.end_window(ctx)

proc uint8_slider(ctx: PContext, val: ptr cuchar, low:int, high:int): int  =
  var tmp {.global.}: Real
  mu.push_id(ctx, val.unsafeAddr, sizeof(val).cint)
  tmp = val[].Real
  result = mu.slider_ex(ctx, tmp.addr, low.Real, high.Real, 0.Real, "%.0f", OPT_ALIGNCENTER)
  val[] = tmp.cuchar
  mu.pop_id(ctx)

proc style_window(ctx: PContext) =
  var colors {.global.} = [ "text:", "border:", "windowbg:", "titlebg:", "titletext:", "panelbg:", "button:", "buttonhover:", "buttonfocus:", "base:", "basehover:", "basefocus:", "scrollbase:", "scrollthumb:" ]
  if mu.begin_window(ctx, "style editor", mu.rect(350, 250, 300, 240))!=0:
    var
      sw = (mu.get_current_container(ctx).body.w.float * 0.14).cint
      v = [80.cint, sw, sw, sw, sw, -1]
    mu.layout_row(ctx, 6, v[0].addr, 0)
    for i, v in colors:
      mu.label(ctx, v)
      discard uint8_slider(ctx, ctx.style.colors[i].r.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].g.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].b.addr, 0, 255)
      discard uint8_slider(ctx, ctx.style.colors[i].a.addr, 0, 255)
      mu.draw_rect(ctx, mu.layout_next(ctx), ctx.style.colors[i])
    mu.end_window(ctx)


proc process_frame(ctx: PContext) =
  mu.begin(ctx)
  style_window(ctx)
  log_window(ctx)
  test_window(ctx)
  mu.end(ctx)

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
  mu.init(ctx)
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
      of MOUSEMOTION: mu.input_mousemove(ctx, e.motion.x, e.motion.y)
      of MOUSEWHEEL: mu.input_scroll(ctx, 0, e.wheel.y * -30)
      of TEXTINPUT: mu.input_text(ctx, e.text.text.unsafeAddr)
      of MOUSEBUTTONDOWN, MOUSEBUTTONUP:
        if button_map.hasKey(e.button.button and 0xff):
          b = button_map[e.button.button and 0xff].cint
        if (b!=0) and (e.kind == MOUSEBUTTONDOWN):
          mu.input_mousedown(ctx, e.button.x, e.button.y, b)
        if (b!=0) and (e.kind == MOUSEBUTTONUP):
          mu.input_mouseup(ctx, e.button.x, e.button.y, b)
      of KEYDOWN, KEYUP:
        if key_map.hasKey(e.key.keysym.sym and 0xff):
          b = key_map[e.key.keysym.sym and 0xff].cint
        if (b!=0) and (e.kind == KEYDOWN):
          mu.input_keydown(ctx, b)
        if (b!=0) and (e.kind == KEYUP):
          mu.input_keyup(ctx, b)
      else: discard

    process_frame(ctx)

    r_clear(mu.color(bg[0].cint, bg[1].cint, bg[2].cint, 255.cint))
    var cmd: ptr mu.Command = nil
    while mu.next_command(ctx, cmd.addr) != 0:
      case cmd.typec:
      of COMMAND_TEXT: r_draw_text(cmd.text.str[0].addr, cmd.text.pos, cmd.text.color)
      of COMMAND_RECT: r_draw_rect(cmd.rect.rect, cmd.rect.color)
      of COMMAND_ICON: r_draw_icon(cmd.icon.id, cmd.icon.rect, cmd.icon.color)
      of COMMAND_CLIP: r_set_clip_rect(cmd.clip.rect)
      else: discard

    r_present()
  sdl.quit()
main()
