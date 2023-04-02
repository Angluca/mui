# ![microui](https://user-images.githubusercontent.com/3920290/75171571-be83c500-5723-11ea-8a50-504cc2ae1109.png)
A *tiny*, portable, immediate-mode UI library written in ANSI C

Copy [**rxi/microui**](https://github.com/rxi/microui)  
Use it with nim language :)
## Features
* Tiny: around `1100 sloc` of ANSI C
* Works within a fixed-sized memory region: no additional memory is allocated
* Built-in controls: window, scrollable panel, button, slider, textbox, label,
  checkbox, wordwrapped text
* Works with any rendering system that can draw rectangles and text
* Designed to allow the user to easily add custom controls
* Simple layout system

### Installation
```sh
nimble install # or nimble install mui
nimble test
```

## Example
![example](https://user-images.githubusercontent.com/3920290/75187058-2b598800-5741-11ea-9358-38caf59f8791.png)
```nim
#if ctx.begin_window("My Window", mu.Rect(x:10, y:10, w:140, h:86))!=0:
if ctx.begin_window("My Window", mu.rect(10, 10, 140, 86))!=0:
  ctx.layout_row(2, [60, -1], 0);

  ctx.label("First:");
  if button(ctx, "Button1")!=0: # c call func
    echo "Button1 pressed"

  ctx.label("Second:");
  if ctx.button("Button2")!=0: # OOP call func
    ctx.open_popup("My Popup")

  if ctx.begin_popup("My Popup")!=0:
    ctx.label("Hello world!")
    ctx.end_popup()

  ctx.end_window()
```

## Screenshot
![screenshot](https://user-images.githubusercontent.com/3920290/75188642-63ae9580-5744-11ea-9eee-d753ff5c0aa7.png)

[**Browser Demo**](https://floooh.github.io/sokol-html5/sgl-microui-sapp.html)

## Usage
* See the [`demo`](demo) directory for a usage example

## Notes
The library expects the user to provide input and handle the resultant drawing
commands, it does not do any drawing itself.

## Contributing
The library is designed to be lightweight, providing a foundation to which you
can easily add custom controls and UI elements; pull requests adding additional
features will likely not be merged. Bug reports are welcome.

## License
This library is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See [LICENSE](LICENSE) for details.

