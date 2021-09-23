# Now part of official Odin vendor collection! https://github.com/odin-lang/Odin/tree/master/vendor/microui

As a result of being included in the official vendor collection, this repo will no longer be maintained. Any issues or PRs is expected on the official vendor library from now on.

Old README follows below.

---

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
* This library assumes you are using the latest nightly build or GitHub master of the Odin compiler. Since Odin is still under development this means this library might break in the future. Please create an issue or PR if that happens. Last verified against: odin version dev-2021-07:481fc8a5
* The library expects the user to provide input and handle the resultant
  drawing commands, it does not do any drawing itself.

## License
This library is free software; you can redistribute it and/or modify it
under the terms of the MIT license. See [LICENSE](LICENSE) for details.

