'''
Typical addon boilerplate code
'''

bl_info = {
    "name": "Hello World Cython Addon",
    "description": "This is a descriptive description",
    "author": "author-san",
    "version": (2, 0, 0),
    "blender": (2, 92, 0),
    "wiki_url": "",
    "category": "Mesh",
    "location": "view 3d > Properties > HelloWorld"}

import bpy
from bpy.utils import register_class, unregister_class

from . import game_of_life

class Object_OT_helloworld(bpy.types.Operator):
    # reference:
    # https://docs.blender.org/api/current/bpy.types.Operator.html

    bl_idname = 'object.helloworld'
    bl_label = 'Hello Wold'
    bl_description = 'does an ultra-advanced computation of Game Of Life'

    #big enough that would run slow in pure python
    GAME_OF_LIFE_WIDTH_HEIGHT = [500, 500]

    _timer = None

    @classmethod
    def poll(self, context):
        return context.object and context.object.type == 'MESH'

    def invoke(self, context, event):
        # typical addon modal boilerplate
        wm = context.window_manager
        self._timer = wm.event_timer_add(1/60, window=context.window)
        wm.modal_handler_add(self)
        
        # use mesh vertices to visualize ultra-advanced computation
        self.object = context.object
        import bmesh
        bm = bmesh.new()
        w, h = self.GAME_OF_LIFE_WIDTH_HEIGHT
        
        for i in range(w * h):
            bm.verts.new((0, 0, 0)) # verts location will be updated later
        
        bm.to_mesh(self.object.data)
        del bm # save memory

        # create game of life class that uses advanced lowlevel computation
        self.game = game_of_life.GameOfLife(w, h)

        return {'RUNNING_MODAL'}

    def modal(self, context, event):
        if event.type == 'TIMER':
            # runs 60 times per second, hopefully
            self.game.run_timestep()
            self.object.data.vertices.foreach_set('co', self.game.vertex_data)
            self.object.data.update()
            context.area.tag_redraw()

        if event.type == 'ESC':
            print('stopping game of life')
            return {'FINISHED'}
        else:
            return {'PASS_THROUGH'}


class Object_PT_helloworld(bpy.types.Panel):
    # reference:
    # https://docs.blender.org/api/current/bpy.types.Panel.html

    bl_idname = 'OBJECT_PT_helloworld'
    bl_label = 'Hello World'
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_category = 'HelloWorld'
    
    @classmethod
    def poll(self, context):
        return True

    def draw(self, context):
        layout = self.layout
        layout.label(text='This is a button:')
        layout.operator('object.helloworld', text='Run Advanced Computation')


classes = [Object_OT_helloworld, Object_PT_helloworld]

def register():
    for cls in classes:
        register_class(cls)

def unregister():
    for cls in classes:
        unregister_class(cls)
