# cython: language_level=3
from cpython cimport array
from libc.stdint cimport uint64_t as u64
from cpython.bytearray cimport PyByteArray_AS_STRING
cimport cython


# very good yet simple random number generator
# https://en.wikipedia.org/wiki/Xorshift
cpdef inline u64 xorshift(u64 i) noexcept nogil:
    i = i ^ (i << 13)
    i = i ^ (i >> 7)
    i = i ^ (i << 17)
    return i

cdef class GameOfLife:
    cdef readonly bytearray data
    cdef readonly bytearray data_pingpong # pingpong buffer technique
    cdef readonly array.array vertex_data

    cdef readonly int w, h

    def __init__(self, int w, int h, u64 seed=123456):
        cdef int _
        self.data = bytearray(w * h)
        self.data_pingpong = bytearray(w * h)
        self.vertex_data = array.array('f', (0 for _ in range(w * h * 3)))
        self.w = w
        self.h = h

        cdef int i
        for i in range(w * h):
            seed = xorshift(seed) # next random step
            self.data[i] = seed & 0x1

    cdef inline char read_cell(self, int x, int y):
        # cast data to a raw pointer view for faster access
        cdef char* data = PyByteArray_AS_STRING(self.data)
        x = x % self.w # wraparound addressing
        y = y % self.h 
        return data[x + y * self.w]
    
    cdef inline void write_next_cell(self, char val, int x, int y):
        # cast data to a raw pointer view for faster access
        cdef char*  data = PyByteArray_AS_STRING(self.data_pingpong)
        x = x % self.w # wraparound addressing
        y = y % self.h 
        data[x + y * self.w] = val

    @cython.cdivision(True)
    def run_timestep(self):
        # rules of the game: https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life

        cdef int x, y, offset_x, offset_y, i
        cdef int cell_sum = 0
        cdef int alive = 0

        cdef float* vertex_data = self.vertex_data.data.as_floats
        
        for y in range(self.h):
            for x in range(self.w):
                cell_sum = 0
                for offset_x in range(-1, 2):
                    for offset_y in range(-1, 2):
                        cell_sum += self.read_cell(x + offset_x, y + offset_y)

                alive = self.read_cell(x, y)
                cell_sum -= alive

                if cell_sum < 2:
                    alive = 0
                elif cell_sum > 3:
                    alive = 0
                elif cell_sum == 3:
                    alive = 1

                self.write_next_cell(alive, x, y,)

                # move vertex far away and pretend it disappeared if not alive
                vertex_data[(x + y*self.w)*3] = <float>x / <float>self.w if alive else 99999.0
                vertex_data[(x + y*self.w)*3 + 1] = <float>y / <float>self.h
                vertex_data[(x + y*self.w)*3 + 2] = 0

        
        self.data_pingpong, self.data = self.data, self.data_pingpong



        


    
