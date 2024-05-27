# HelloWorld-Addon-blender
an example of how to use cython for a blender addon

# Compilation
more info https://cython.readthedocs.io/en/latest/src/userguide/source_files_and_compilation.html

to compile the module you must install the same python version as as blender uses (3.11 in case of blender 4.1)
commands:
`python -m pip install Cython`
`cythonize -i game_of_life.pyx`
