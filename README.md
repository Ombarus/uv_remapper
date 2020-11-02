# UV Remapper


## Introduction

**UV Remapper** is a small script that can take a model with two UVs and a source texture and convert the source texture to the second set of UVs.

## How to use
* With your favorite 3d software, export a model in a format compatible with Godot (I use gltf2.0) that include two sets of UVs
* Open the Godot project (currently support godot 3.2.3) and load the scene Remapper.tscn
* Replace the 3d model in the scene with your model, make sure the MeshInstance node is accessible (you might need to right-click the model and select "editable children").
* Click on the root node and point the "Mesh Instance" property to your model's MeshInstance (not the Root Spatial Node! click editable children if there's no visible MeshInstance in your scene tree)
* Load the texture to remap in "Original Texture"
* Set the desired size of the output texture in "New Texture Size" (bigger texture will be MUCH slower)
* Run the scene and wait a while (like a few minutes...)
* The result should show on the screen and will be saved in your user:// folder as PNG


## Support

You can ask for help on:

* [The Contact Form on my website](https://www.ombarus.com/)
* [Ombarus Discord Server](https://discord.gg/8vUQuqh)
* Social networks:
  [Twitter](https://twitter.com/ombarus1/),
  [YouTube](https://www.youtube.com/channel/UCscoqrVcMbZwv5jIpKVYpDg),
  [Instagram](https://www.instagram.com/ombarus1/).

## Credits

[Ombarus Dev](https://www.ombarus.com/):
  
## License

The MIT License (MIT)

Copyright (c) 2020 Ombarus Dev

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.