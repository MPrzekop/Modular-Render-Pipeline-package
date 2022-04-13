# Modular-Render-Pipeline-package

<p align="center">
  <img src="https://github.com/MPrzekop/Custom-Modular-Render-Pipeline/blob/repo_images/RepoImages/Header.png" width="500" title="Header image">
 
Work in progress modular render pipeline system. 

Trying to create render pipeline that allows user to mix and match stages of rendering *eg. no need for forward/deferred path, just remove module that handles that feature.*

As of now my focus on deferred rendering path.

Implemented features:
- modular rendering path
- populating gBuffer with color, MADS, normals and position
- principled bsdf deferred shading 
- custom lights - realtime area light
- shadowcasting for spot and directional lights
- basic forward opaque/transparent render (no lighting data yet)   
- basic SSR
- Amplify Shader Editor templates for populating gBuffers and rendering them to screen
