include renderer
import std/strformat

var
  ctx_src: mu.Context
  ctx = ctx_src.addr # PContext
  logbuf: string
  logbuf_updated: bool
  bg: tuple[r,g,b: float32] = (90.0f, 95.0f, 100.0f)

proc test_window(ctx: mu.PContext)
proc log_window(ctx: mu.PContext)
proc style_window(ctx: mu.PContext)

proc text_width_cb(font: mu.Font, text: cstring, len: cint): cint {.cdecl.} =
  var n = len
  if n == -1: n = text.len.cint
  return r_get_text_width(text, n)

proc text_height_cb(font: mu.Font): cint {.cdecl.} =
  r_get_text_height()

proc wlog(text: cstring) =
  if logbuf.len > 2048: logbuf.setLen(0)
  if logbuf.len > 0: logbuf.add('\n')
  logbuf.add(text)
  logbuf_updated = true

proc init {.cdecl.} =
  sg.setup(sg.Desc(
    context: sglue.context(),
    logger: sg.Logger(fn: slog.fn),
  ))
  sgl.setup(sgl.Desc(
    logger: sgl.Logger(fn: slog.fn),
  ))

  r_init()
  mu.init(ctx)
  ctx.text_width = text_width_cb
  ctx.text_height = text_height_cb

proc `[]=`(arr: var openArray[cint] ; key: sapp.Keycode; val: SomeNumber) =
  arr[key.cint] = val.cint
var key_map: array[512, cint]
key_map[sapp.keyCodeLeftShift] = mu.KEY_SHIFT
key_map[sapp.keyCodeRightShift] = mu.KEY_SHIFT
key_map[sapp.keyCodeLeftControl] = mu.KEY_CTRL
key_map[sapp.keyCodeRightControl] = mu.KEY_CTRL
key_map[sapp.keyCodeLeftAlt] = mu.KEY_ALT
key_map[sapp.keyCodeRightAlt] = mu.KEY_ALT
key_map[sapp.keyCodeEnter] = mu.KEY_RETURN
key_map[sapp.keyCodeBackspace] = mu.KEY_BACKSPACE

proc event(ev: ptr Event) {.cdecl.} =
  case ev.`type`:
  of eventtypeMouseDown:
    input_mousedown(ctx, ev.mouseX.cint, ev.mouseY.cint, (1 shl ev.mouseButton).cint)
  of eventtypeMouseUp:
    input_mouseup(ctx, ev.mouseX.cint, ev.mouseY.cint, (1 shl ev.mouseButton).cint)
  of eventtypeMouseMove:
    input_mousemove(ctx, ev.mouseX.cint, ev.mouseY.cint)
  of eventtypeMouseScroll:
    input_scroll(ctx, 0,  ev.scrollY.cint)
  of eventtypeKeydown:
    input_keydown(ctx, key_map[ev.keyCode and 511])
  of eventtypeKeyup:
    input_keyup(ctx, key_map[ev.keyCode and 511])
  of eventtypeChar:
    if ev.charCode != 127:
      input_text(ctx, [ev.charCode.byte and 255, 0])
  else: discard

proc frame {.cdecl.} =
  mu.begin(ctx)
  test_window(ctx)
  log_window(ctx)
  style_window(ctx)
  mu.end(ctx)

  r_begin(sapp.width(), sapp.height())
  var cmd: mu.PCommand
  while ctx.next_command(cmd.addr)!=0:
    case cmd.type:
    of COMMAND_TEXT: r_draw_text(cmd.text.str, cmd.text.pos, cmd.text.color)
    of COMMAND_RECT: r_draw_rect(cmd.rect.rect, cmd.rect.color)
    of COMMAND_ICON: r_draw_icon(cmd.icon.id, cmd.icon.rect, cmd.icon.color)
    of COMMAND_CLIP: r_set_clip_rect(cmd.clip.rect)
    else: discard
  r_end()

  var pa: sg.PassAction
  pa.colors[0].loadAction = loadActionClear
  pa.colors[0].clearValue = sg.Color(r: bg.r / 255.0f, g: bg.g / 255.0f, b: bg.b / 255.0f, a: 1.0f)
  beginDefaultPass(pa, sapp.width(), sapp.height())

  r_draw()
  sg.endPass()
  sg.commit()
  discard

proc cleanup {.cdecl.} =
  sgl.shutdown()
  sg.shutdown()

proc test_window(ctx: PContext) =
  var win: PContainer
  if ctx.begin_window("Demo Window", mu.rect(0,0,345,440))!=0:
    win = get_current_container(ctx)
    win.rect.w = max(win.rect.w, 240)
    win.rect.h = max(win.rect.h, 300)

    if ctx.header("Window Info")!=0:
      win = get_current_container(ctx)
      ctx.layout_row(2,[54.cint, -1], 0)
      ctx.label("Position:")
      var buf = &"{win.rect.x}, {win.rect.y}"; ctx.label(buf.cstring)
      ctx.label("Size:")
      buf = &"{win.rect.w}, {win.rect.h}"; ctx.label(buf.cstring)

    # lable + buttons
    if ctx.header_ex("Test buttons", OPT_EXPANDED)!=0:
      ctx.layout_row(3, [86.cint, -110, -1], 0)
      ctx.label("Test btn 1:")
      if ctx.button("btn1:")!=0: wlog("Press btn1")
      if ctx.button("btn2:")!=0: wlog("Press btn2")
      ctx.label("test btn2:")
      if ctx.button("btn3:")!=0: wlog("Press btn3")
      if ctx.button("popup:")!=0: ctx.open_popup("Test popup")
      if ctx.begin_popup("Test popup")!=0:
        discard ctx.button("hello")
        discard ctx.button("world")
        ctx.end_popup()

    # tree
    if ctx.header_ex("Tree and text", OPT_EXPANDED)!=0:
      ctx.layout_row(2, [140.cint, -1], 0)
      ctx.layout_begin_column()
      if ctx.begin_treenode("test 1")!=0:
        if ctx.begin_treenode("test 1a")!=0:
          ctx.label("hello")
          ctx.label("tree!")
          ctx.end_treenode()
        if ctx.begin_treenode("test 1b")!=0:
          if ctx.button("tbtn1:")!=0: wlog("Press tbtn1")
          if ctx.button("tbtn2:")!=0: wlog("Press tbtn2")
          ctx.end_treenode()
        ctx.end_treenode()

      if ctx.begin_treenode("test 2")!=0:
        ctx.layout_row(2, [54.cint, 54], 0)
        if ctx.button("tbtn3:")!=0: wlog("Press tbtn3")
        if ctx.button("tbtn4:")!=0: wlog("Press tbtn4")
        if ctx.button("tbtn5:")!=0: wlog("Press tbtn5")
        if ctx.button("tbtn6:")!=0: wlog("Press tbtn6")
        ctx.end_treenode()

      if ctx.begin_treenode("test 3")!=0:
        var chks{.global.} = [1.cint, 0, 1]
        discard ctx.checkbox("chkbox1", chks[0].addr)
        discard ctx.checkbox("chkbox1", chks[1].addr)
        discard ctx.checkbox("chkbox1", chks[2].addr)
        ctx.end_treenode()
      ctx.layout_end_column()

      ctx.layout_begin_column()
      ctx.layout_row(1, [-1.cint], 0)
      ctx.text("Lorem ipsum dolor sit amet, consectetur adipiscing "&
      "elit. Maecenas lacinia, sem eu lacinia molestie, mi risus faucibus "&
      "ipsum, eu varius magna felis a nulla.")
      ctx.layout_end_column()

    # backgroud color sliders
    if ctx.header_ex("Background color", OPT_EXPANDED)!=0:
      ctx.layout_row(2, [-78.cint, -1], 74)
      # sliders
      ctx.layout_begin_column()
      ctx.layout_row(2, [46.cint, -1], 0)
      ctx.label("Red:"); discard ctx.slider(bg.r.addr, 0, 255)
      ctx.label("Green:"); discard ctx.slider(bg.g.addr, 0, 255)
      ctx.label("Blue:"); discard ctx.slider(bg.b.addr, 0, 255)
      ctx.layout_end_column()

      # color preview
      var r = ctx.layout_next()
      ctx.draw_rect(r, mu.color(bg.r.cint, bg.g.cint, bg.b.cint, 255))
      var buf = &"#{bg.r.int:02X}{bg.g.int:02X}{bg.b.int:02X}"
      ctx.draw_control_text(buf.cstring, r, COLOR_TEXT, OPT_ALIGNCENTER)
    ctx.end_window()
  discard

proc log_window(ctx: PContext) =
  if ctx.begin_window("Log window", mu.rect(350, 0, 300, 200))!=0:
    # output text panel
    ctx.layout_row(1, [-1.cint], -25)
    ctx.begin_panel("Log output")
    var panel = ctx.get_current_container()
    ctx.layout_row(1, [-1.cint], -1)
    ctx.text(logbuf.cstring)
    ctx.end_panel()
    if logbuf_updated:
      panel.scroll.y = panel.content_size.y
      logbuf_updated = false
    # input textbox + submit button
    var
      buf {.global.}: array[128, char]
      isSubmitted = false
    ctx.layout_row(2, [-70.cint, -1], 0)
    if (ctx.textbox(buf, buf.len) and RES_SUBMIT)!=0:
      ctx.set_focus(ctx.last_id)
      isSubmitted = true
    if ctx.button("submit")!=0: isSubmitted = true
    if isSubmitted:
      wlog(buf)
      buf[0] = '\0'

    ctx.end_window()
  discard

proc uint8_slider(ctx: PContext, val: ptr uint8, low, high:cint): cint {.discardable.} =
  var tmp {.global.}: Real
  ctx.push_id(val.addr, sizeof(val))
  tmp = val[].Real
  result = ctx.slider_ex(tmp.addr, low.Real, high.Real, 0, "%.0f", OPT_ALIGNCENTER)
  val[] = tmp.uint8
  ctx.pop_id()

proc style_window(ctx: PContext) =
  let colors {.global.} = [
  (label: "text:",  idx: COLOR_TEXT),
  ("border:",       COLOR_BORDER),
  ("windowbg:",     COLOR_WINDOWBG),
  ("titlebg:",      COLOR_TITLEBG),
  ("titletext:",    COLOR_TITLETEXT),
  ("panelbg:",      COLOR_PANELBG),
  ("button:",       COLOR_BUTTON),
  ("buttonhover:",  COLOR_BUTTONHOVER),
  ("buttonfocus:",  COLOR_BUTTONFOCUS),
  ("base:",         COLOR_BASE),
  ("basehover:",    COLOR_BASEHOVER),
  ("basefocus:",    COLOR_BASEFOCUS),
  ("scrollbase:",   COLOR_SCROLLBASE),
  ("scrollthumb:",  COLOR_SCROLLTHUMB)]

  if ctx.begin_window("Style editor", mu.rect(350, 200, 300, 240))!=0:
    var sw = (ctx.get_current_container().body.w.float32 * 0.14f).cint
    ctx.layout_row(6, [80.cint, sw, sw, sw, sw, -1], 0)
    for i, val in colors:
      ctx.label(val.label.cstring)
      uint8_slider(ctx, ctx.style.colors[i].r.addr, 0, 255)
      uint8_slider(ctx, ctx.style.colors[i].g.addr, 0, 255)
      uint8_slider(ctx, ctx.style.colors[i].b.addr, 0, 255)
      uint8_slider(ctx, ctx.style.colors[i].a.addr, 0, 255)
      ctx.draw_rect(ctx.layout_next(), ctx.style.colors[i])
    ctx.end_window()
  discard

proc main =
  sapp.run(sapp.Desc(
    initCb: init,
    frameCb: frame,
    cleanupCb: cleanup,
    eventCB: event,
    width: 720,
    height: 540,
    windowTitle: "mui + sokol-nim",
    #icon: IconDesc(sokol_default: true),
    icon: IconDesc(sokol_default: false, images: [sapp.ImageDesc(width:ATLAS_WIDTH, height:ATLAS_HEIGHT, pixels: sapp.Range(addr: atlas_texture.addr, size: atlas_texture.len))]),
    logger: sapp.Logger(fn: slog.fn),
  ))

when isMainModule: main()

