##
## * Copyright (c) 2020 rxi
## * Modified by Angluca
## * This library is free software; you can redistribute it and/or modify it
## * under the terms of the MIT license. See `microui.c` for details.
##

from strutils import replace
{.pragma: mui, header: "src/microui.h"}
const muiDir = currentSourcePath().replace("\\", "/")[0..^8]
{.compile: "src/microui.c", passC: "-I" & muiDir.}

template Stack* (T:typedesc, n:int): untyped=
  tuple[idx:int, items:array[n, T]]
const
  VERSION* = "2.01"
  COMMANDLIST_SIZE* = (256 * 1024)
  ROOTLIST_SIZE* = 32
  CONTAINERSTACK_SIZE* = 32
  CLIPSTACK_SIZE* = 32
  IDSTACK_SIZE* = 32
  LAYOUTSTACK_SIZE* = 16
  CONTAINERPOOL_SIZE* = 48
  TREENODEPOOL_SIZE* = 48
  MAX_WIDTHS* = 16

type
  mcint = cint
  mcfloat = cfloat
  mcstring = cstring
const
  REAL_FMT* = "%.3g"
  SLIDER_FMT* = "%.2f"
  MAX_FMT* = 127

template min*(a, b: untyped): untyped =
  (if (a) < (b): (a) else: (b))

template max*(a, b: untyped): untyped =
  (if (a) > (b): (a) else: (b))

template clamp*(x, a, b: untyped): untyped =
  min(b, max(a, x))

const
  CLIP_PART* = 1
  CLIP_ALL* = 2

const
  COMMAND_JUMP* = 1
  COMMAND_CLIP* = 2
  COMMAND_RECT* = 3
  COMMAND_TEXT* = 4
  COMMAND_ICON* = 5
  COMMAND_MAX* = 6

const
  COLOR_TEXT* = 0
  COLOR_BORDER* = 1
  COLOR_WINDOWBG* = 2
  COLOR_TITLEBG* = 3
  COLOR_TITLETEXT* = 4
  COLOR_PANELBG* = 5
  COLOR_BUTTON* = 6
  COLOR_BUTTONHOVER* = 7
  COLOR_BUTTONFOCUS* = 8
  COLOR_BASE* = 9
  COLOR_BASEHOVER* = 10
  COLOR_BASEFOCUS* = 11
  COLOR_SCROLLBASE* = 12
  COLOR_SCROLLTHUMB* = 13
  COLOR_MAX* = 14

const
  ICON_CLOSE* = 1
  ICON_CHECK* = 2
  ICON_COLLAPSED* = 3
  ICON_EXPANDED* = 4
  ICON_MAX* = 5

const
  RES_ACTIVE* = (1 shl 0)
  RES_SUBMIT* = (1 shl 1)
  RES_CHANGE* = (1 shl 2)

const
  OPT_ALIGNCENTER* = (1 shl 0)
  OPT_ALIGNRIGHT* = (1 shl 1)
  OPT_NOINTERACT* = (1 shl 2)
  OPT_NOFRAME* = (1 shl 3)
  OPT_NORESIZE* = (1 shl 4)
  OPT_NOSCROLL* = (1 shl 5)
  OPT_NOCLOSE* = (1 shl 6)
  OPT_NOTITLE* = (1 shl 7)
  OPT_HOLDFOCUS* = (1 shl 8)
  OPT_AUTOSIZE* = (1 shl 9)
  OPT_POPUP* = (1 shl 10)
  OPT_CLOSED* = (1 shl 11)
  OPT_EXPANDED* = (1 shl 12)

const
  MOUSE_LEFT* = (1 shl 0)
  MOUSE_RIGHT* = (1 shl 1)
  MOUSE_MIDDLE* = (1 shl 2)

const
  KEY_SHIFT* = (1 shl 0)
  KEY_CTRL* = (1 shl 1)
  KEY_ALT* = (1 shl 2)
  KEY_BACKSPACE* = (1 shl 3)
  KEY_RETURN* = (1 shl 4)

{.push warnings: off.}

type
  Id* = mcint
  Real* = mcfloat
  Font* = pointer
  Vec2* {.importc: "mu_Vec2", mui, bycopy.} = object
    x* {.importc: "x".}: mcint
    y* {.importc: "y".}: mcint

  Rect* {.importc: "mu_Rect", mui, bycopy.} = object
    x* {.importc: "x".}: mcint
    y* {.importc: "y".}: mcint
    w* {.importc: "w".}: mcint
    h* {.importc: "h".}: mcint

  Color* {.importc: "mu_Color", mui, bycopy.} = object
    r* {.importc: "r".}: uint8
    g* {.importc: "g".}: uint8
    b* {.importc: "b".}: uint8
    a* {.importc: "a".}: uint8

  PoolItem* {.importc: "mu_PoolItem", mui, bycopy.} = object
    id* {.importc: "id".}: Id
    last_update* {.importc: "last_update".}: mcint

  BaseCommand* {.importc: "mu_BaseCommand", mui, bycopy.} = object
    `type`* {.importc: "type".}: mcint
    size* {.importc: "size".}: mcint

  JumpCommand* {.importc: "mu_JumpCommand", mui, bycopy.} = object
    base* {.importc: "base".}: BaseCommand
    dst* {.importc: "dst".}: pointer

  ClipCommand* {.importc: "mu_ClipCommand", mui, bycopy.} = object
    base* {.importc: "base".}: BaseCommand
    rect* {.importc: "rect".}: Rect

  RectCommand* {.importc: "mu_RectCommand", mui, bycopy.} = object
    base* {.importc: "base".}: BaseCommand
    rect* {.importc: "rect".}: Rect
    color* {.importc: "color".}: Color

  TextCommand* {.importc: "mu_TextCommand", mui, bycopy.} = object
    base* {.importc: "base".}: BaseCommand
    font* {.importc: "font".}: Font
    pos* {.importc: "pos".}: Vec2
    color* {.importc: "color".}: Color
    str* {.importc: "str".}: array[1, char]

  IconCommand* {.importc: "mu_IconCommand", mui, bycopy.} = object
    base* {.importc: "base".}: BaseCommand
    rect* {.importc: "rect".}: Rect
    id* {.importc: "id".}: mcint
    color* {.importc: "color".}: Color

  Command* {.importc: "mu_Command", mui, bycopy, union.} = object
    `type`* {.importc: "type".}: mcint
    base* {.importc: "base".}: BaseCommand
    jump* {.importc: "jump".}: JumpCommand
    clip* {.importc: "clip".}: ClipCommand
    rect* {.importc: "rect".}: RectCommand
    text* {.importc: "text".}: TextCommand
    icon* {.importc: "icon".}: IconCommand

  Layout* {.importc: "mu_Layout", mui, bycopy.} = object
    body* {.importc: "body".}: Rect
    next* {.importc: "next".}: Rect
    position* {.importc: "position".}: Vec2
    size* {.importc: "size".}: Vec2
    max* {.importc: "max".}: Vec2
    widths* {.importc: "widths".}: array[MAX_WIDTHS, mcint]
    items* {.importc: "items".}: mcint
    item_index* {.importc: "item_index".}: mcint
    next_row* {.importc: "next_row".}: mcint
    next_type* {.importc: "next_type".}: mcint
    indent* {.importc: "indent".}: mcint

  Container* {.importc: "mu_Container", mui, bycopy.} = object
    head* {.importc: "head".}: ptr Command
    tail* {.importc: "tail".}: ptr Command
    rect* {.importc: "rect".}: Rect
    body* {.importc: "body".}: Rect
    content_size* {.importc: "content_size".}: Vec2
    scroll* {.importc: "scroll".}: Vec2
    zindex* {.importc: "zindex".}: mcint
    open* {.importc: "open".}: mcint

  Style* {.importc: "mu_Style", mui, bycopy.} = object
    font* {.importc: "font".}: Font
    size* {.importc: "size".}: Vec2
    padding* {.importc: "padding".}: mcint
    spacing* {.importc: "spacing".}: mcint
    indent* {.importc: "indent".}: mcint
    title_height* {.importc: "title_height".}: mcint
    scrollbar_size* {.importc: "scrollbar_size".}: mcint
    thumb_size* {.importc: "thumb_size".}: mcint
    colors* {.importc: "colors".}: array[COLOR_MAX, Color]

  Context* {.importc: "mu_Context", mui, bycopy.} = object
    text_width* {.importc: "text_width".}: proc (font: Font; str: mcstring; len: mcint): mcint {.cdecl.} ##  callbacks
    text_height* {.importc: "text_height".}: proc (font: Font): mcint {.cdecl.}
    draw_frame* {.importc: "draw_frame".}: proc (ctx: ptr Context; rect: Rect; colorid: mcint) {.cdecl.} ##  core state
    ustyle* {.importc: "_style".}: Style
    style* {.importc: "style".}: ptr Style
    hover* {.importc: "hover".}: Id
    focus* {.importc: "focus".}: Id
    last_id* {.importc: "last_id".}: Id
    last_rect* {.importc: "last_rect".}: Rect
    last_zindex* {.importc: "last_zindex".}: mcint
    updated_focus* {.importc: "updated_focus".}: mcint
    frame* {.importc: "frame".}: mcint
    hover_root* {.importc: "hover_root".}: ptr Container
    next_hover_root* {.importc: "next_hover_root".}: ptr Container
    scroll_target* {.importc: "scroll_target".}: ptr Container
    number_edit_buf* {.importc: "number_edit_buf".}: array[MAX_FMT, char]
    number_edit* {.importc: "number_edit".}: Id
    command_list* {.importc: "command_list".}: Stack(char, COMMANDLIST_SIZE)
    root_list* {.importc: "root_list".}: Stack(ptr Container, ROOTLIST_SIZE)
    container_stack* {.importc: "container_stack".}: Stack(ptr Container, CONTAINERPOOL_SIZE)
    clip_stack* {.importc: "clip_stack".}: Stack(Rect, CLIPSTACK_SIZE)
    id_stack* {.importc: "id_stack".}: Stack(Id, IDSTACK_SIZE)
    layout_stack* {.importc: "layout_stack".}: Stack(Layout, LAYOUTSTACK_SIZE) ##  retained state pools
    container_pool* {.importc: "container_pool".}: array[CONTAINERPOOL_SIZE, PoolItem]
    containers* {.importc: "containers".}: array[CONTAINERPOOL_SIZE, Container]
    treenode_pool* {.importc: "treenode_pool".}: array[TREENODEPOOL_SIZE, PoolItem] ##  input state
    mouse_pos* {.importc: "mouse_pos".}: Vec2
    last_mouse_pos* {.importc: "last_mouse_pos".}: Vec2
    mouse_delta* {.importc: "mouse_delta".}: Vec2
    scroll_delta* {.importc: "scroll_delta".}: Vec2
    mouse_down* {.importc: "mouse_down".}: mcint
    mouse_pressed* {.importc: "mouse_pressed".}: mcint
    key_down* {.importc: "key_down".}: mcint
    key_pressed* {.importc: "key_pressed".}: mcint
    input_text* {.importc: "input_text".}: array[32, char]

{.pop.}

#proc vec2*(x: mcint; y: mcint): Vec2 {.cdecl, importc: "mu_vec2", mui.}
#proc rect*(x: mcint; y: mcint; w: mcint; h: mcint): Rect {.cdecl, importc: "mu_rect", mui.}
#proc color*(r: mcint; g: mcint; b: mcint; a: mcint): Color {.cdecl, importc: "mu_color", mui.}
func vec2*(x: mcint; y: mcint): Vec2 = Vec2(x:x, y:y)
func rect*(x: mcint; y: mcint; w: mcint; h: mcint): Rect = Rect(x:x,y:y,w:w,h:h)
func color*(r: mcint; g: mcint; b: mcint; a: mcint): Color = Color(r:r.uint8,g:g.uint8,b:b.uint8,a:a.uint8)

proc init*(ctx: ptr Context) {.cdecl, importc: "mu_init", mui.}
proc begin*(ctx: ptr Context) {.cdecl, importc: "mu_begin", mui.}
proc `end`*(ctx: ptr Context) {.cdecl, importc: "mu_end", mui.}
proc set_focus*(ctx: ptr Context; id: Id) {.cdecl, importc: "mu_set_focus", mui.}
proc get_id*(ctx: ptr Context; data: pointer; size: mcint): Id {.cdecl, importc: "mu_get_id", mui.}
proc push_id*(ctx: ptr Context; data: pointer; size: mcint) {.cdecl, importc: "mu_push_id", mui.}
proc pop_id*(ctx: ptr Context) {.cdecl, importc: "mu_pop_id", mui.}
proc push_clip_rect*(ctx: ptr Context; rect: Rect) {.cdecl, importc: "mu_push_clip_rect", mui.}
proc pop_clip_rect*(ctx: ptr Context) {.cdecl, importc: "mu_pop_clip_rect", mui.}
proc get_clip_rect*(ctx: ptr Context): Rect {.cdecl, importc: "mu_get_clip_rect", mui.}
proc check_clip*(ctx: ptr Context; r: Rect): mcint {.cdecl, importc: "mu_check_clip", mui.}
proc get_current_container*(ctx: ptr Context): ptr Container {.cdecl, importc: "mu_get_current_container", mui.}
proc get_container*(ctx: ptr Context; name: mcstring): ptr Container {.cdecl, importc: "mu_get_container", mui.}
proc bring_to_front*(ctx: ptr Context; cnt: ptr Container) {.cdecl, importc: "mu_bring_to_front", mui.}
proc pool_init*(ctx: ptr Context; items: ptr PoolItem; len: mcint; id: Id): mcint {.cdecl, importc: "mu_pool_init", mui.}
proc pool_get*(ctx: ptr Context; items: ptr PoolItem; len: mcint; id: Id): mcint {.cdecl, importc: "mu_pool_get", mui.}
proc pool_update*(ctx: ptr Context; items: ptr PoolItem; idx: mcint) {.cdecl, importc: "mu_pool_update", mui.}
proc input_mousemove*(ctx: ptr Context; x: mcint; y: mcint) {.cdecl, importc: "mu_input_mousemove", mui.}
proc input_mousedown*(ctx: ptr Context; x: mcint; y: mcint; btn: mcint) {.cdecl, importc: "mu_input_mousedown", mui.}
proc input_mouseup*(ctx: ptr Context; x: mcint; y: mcint; btn: mcint) {.cdecl, importc: "mu_input_mouseup", mui.}
proc input_scroll*(ctx: ptr Context; x: mcint; y: mcint) {.cdecl, importc: "mu_input_scroll", mui.}
proc input_keydown*(ctx: ptr Context; key: mcint) {.cdecl, importc: "mu_input_keydown", mui.}
proc input_keyup*(ctx: ptr Context; key: mcint) {.cdecl, importc: "mu_input_keyup", mui.}
proc input_text*(ctx: ptr Context; text: mcstring) {.cdecl, importc: "mu_input_text", mui.}
proc push_command*(ctx: ptr Context; typec: mcint; size: mcint): ptr Command {.cdecl, importc: "mu_push_command", mui.}
proc next_command*(ctx: ptr Context; cmd: ptr ptr Command): mcint {.cdecl, importc: "mu_next_command", mui.}
proc set_clip*(ctx: ptr Context; rect: Rect) {.cdecl, importc: "mu_set_clip", mui.}
proc draw_rect*(ctx: ptr Context; rect: Rect; color: Color) {.cdecl, importc: "mu_draw_rect", mui.}
proc draw_box*(ctx: ptr Context; rect: Rect; color: Color) {.cdecl, importc: "mu_draw_box", mui.}
proc draw_text*(ctx: ptr Context; font: Font; str: mcstring; len: mcint; pos: Vec2; color: Color) {.cdecl, importc: "mu_draw_text", mui.}
proc draw_icon*(ctx: ptr Context; id: mcint; rect: Rect; color: Color) {.cdecl, importc: "mu_draw_icon", mui.}

proc layout_row*(ctx: ptr Context; items: mcint; widths: ptr cint; height: mcint) {.cdecl, importc: "mu_layout_row", mui.}

proc layout_width*(ctx: ptr Context; width: mcint) {.cdecl, importc: "mu_layout_width", mui.}
proc layout_height*(ctx: ptr Context; height: mcint) {.cdecl, importc: "mu_layout_height", mui.}
proc layout_begin_column*(ctx: ptr Context) {.cdecl, importc: "mu_layout_begin_column", mui.}
proc layout_end_column*(ctx: ptr Context) {.cdecl, importc: "mu_layout_end_column", mui.}
proc layout_set_next*(ctx: ptr Context; r: Rect; relative: mcint) {.cdecl, importc: "mu_layout_set_next", mui.}
proc layout_next*(ctx: ptr Context): Rect {.cdecl, importc: "mu_layout_next", mui.}
proc draw_control_frame*(ctx: ptr Context; id: Id; rect: Rect; colorid: mcint; opt: mcint) {.cdecl, importc: "mu_draw_control_frame", mui.}
proc draw_control_text*(ctx: ptr Context; str: mcstring; rect: Rect; colorid: mcint; opt: mcint) {.cdecl, importc: "mu_draw_control_text", mui.}
proc mouse_over*(ctx: ptr Context; rect: Rect): mcint {.cdecl, importc: "mu_mouse_over", mui.}
proc update_control*(ctx: ptr Context; id: Id; rect: Rect; opt: mcint) {.cdecl, importc: "mu_update_control", mui.}

template button*(ctx, label: untyped): untyped =
  button_ex(ctx, label, 0, OPT_ALIGNCENTER)

template textbox*(ctx, buf, bufsz: untyped): untyped =
  textbox_ex(ctx, buf, bufsz, 0)

template slider*(ctx, value, lo, hi: untyped): untyped =
  slider_ex(ctx, value, lo, hi, 0, SLIDER_FMT, OPT_ALIGNCENTER)

template number*(ctx, value, step: untyped): untyped =
  number_ex(ctx, value, step, SLIDER_FMT, OPT_ALIGNCENTER)

template header*(ctx, label: untyped): untyped =
  header_ex(ctx, label, 0)

template begin_treenode*(ctx, label: untyped): untyped =
  begin_treenode_ex(ctx, label, 0)

template begin_window*(ctx, title, rect: untyped): untyped =
  begin_window_ex(ctx, title, rect, 0)

template begin_panel*(ctx, name: untyped): untyped =
  begin_panel_ex(ctx, name, 0)

proc text*(ctx: ptr Context; text: mcstring) {.cdecl, importc: "mu_text", mui.}
proc label*(ctx: ptr Context; text: mcstring) {.cdecl, importc: "mu_label", mui.}
proc button_ex*(ctx: ptr Context; label: mcstring; icon: mcint; opt: mcint): mcint {.cdecl, importc: "mu_button_ex", mui.}
proc checkbox*(ctx: ptr Context; label: mcstring; state: ptr cint): mcint {.cdecl, importc: "mu_checkbox", mui.}
proc textbox_raw*(ctx: ptr Context; buf: mcstring; bufsz: mcint; id: Id; r: Rect; opt: mcint): mcint {.cdecl, importc: "mu_textbox_raw", mui.}
proc textbox_ex*(ctx: ptr Context; buf: mcstring; bufsz: mcint; opt: mcint): mcint {.cdecl, importc: "mu_textbox_ex", mui.}
proc slider_ex*(ctx: ptr Context; value: ptr Real; low: Real; high: Real; step: Real; fmt: mcstring; opt: mcint): mcint {.cdecl, importc: "mu_slider_ex", mui.}
proc number_ex*(ctx: ptr Context; value: ptr Real; step: Real; fmt: mcstring; opt: mcint): mcint {.cdecl, importc: "mu_number_ex", mui.}
proc header_ex*(ctx: ptr Context; label: mcstring; opt: mcint): mcint {.cdecl, importc: "mu_header_ex", mui.}
proc begin_treenode_ex*(ctx: ptr Context; label: mcstring; opt: mcint): mcint {.cdecl, importc: "mu_begin_treenode_ex", mui.}
proc end_treenode*(ctx: ptr Context) {.cdecl, importc: "mu_end_treenode", mui.}
proc begin_window_ex*(ctx: ptr Context; title: mcstring; rect: Rect; opt: mcint): mcint {.cdecl, importc: "mu_begin_window_ex", mui.}
proc end_window*(ctx: ptr Context) {.cdecl, importc: "mu_end_window", mui.}
proc open_popup*(ctx: ptr Context; name: mcstring) {.cdecl, importc: "mu_open_popup", mui.}
proc begin_popup*(ctx: ptr Context; name: mcstring): mcint {.cdecl, importc: "mu_begin_popup", mui.}
proc end_popup*(ctx: ptr Context) {.cdecl, importc: "mu_end_popup", mui.}
proc begin_panel_ex*(ctx: ptr Context; name: mcstring; opt: mcint) {.cdecl, importc: "mu_begin_panel_ex", mui.}
proc end_panel*(ctx: ptr Context) {.cdecl, importc: "mu_end_panel", mui.}

#converts
converter tomci*(n: SomeInteger|enum): mcint = n.cint
converter tomcstr*(s: var string|array|seq[byte]):
  mcstring = cast[mcstring](s[0].addr)
converter toAddr*(a: var array|seq[cint]): ptr mcint = a[0].addr
#converter toAddr*[I;T](a: var array[I,T]|seq[T]): ptr T = a[0].addr

type
  PVec2* = ptr Vec2
  PRect* = ptr Rect
  PColor* = ptr Color
  PPoolItem* = ptr PoolItem
  PBaseCommand* = ptr BaseCommand
  PJumpCommand* = ptr JumpCommand
  PClipCommand* = ptr ClipCommand
  PRectCommand* = ptr RectCommand
  PTextCommand* = ptr TextCommand
  PIconCommand* = ptr IconCommand
  PCommand* = ptr Command
  PLayout* = ptr Layout
  PContainer* = ptr Container
  PStyle* = ptr Style
  PContext* = ptr Context

