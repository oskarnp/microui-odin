# microui-odin

## Description
A tiny, portable, immediate-mode UI library written in Odin. (Ported from [rxi/microui](https://github.com/rxi/microui).)

![screenshot](https://user-images.githubusercontent.com/3920290/56437823-c3dcdb80-62d8-11e9-978a-a0739f9e16f0.png)

[**Browser Demo**](https://floooh.github.io/sokol-html5/sgl-microui-sapp.html) (rxi's microui)

## Features
* Tiny: around `1200 sloc` of Odin
* Works within a fixed-sized memory region: no additional memory is
  allocated
* Built-in controls: window, panel, button, slider, textbox, label,
  checkbox, wordwrapped text
* Easy to add custom controls
* Simple layout system

## Usage
See the [`demo-sdl2`](demo-sdl2) directory for a usage example (using SDL2).
```
cd demo-sdl2
odin run .
```

## Notes
* The library expects the user to provide input and handle the resultant
  drawing commands, it does not do any drawing itself

## License
This library is free software; you can redistribute it and/or modify it
under the terms of the MIT license. See [LICENSE](LICENSE) for details.

