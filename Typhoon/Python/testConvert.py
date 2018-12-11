import sys

triangles = [];
result = "";
triangles.append([(100,200,800),(200,124,754),(125,100,199),(255,255,255)]);
triangles.append([(100,100,800),(80,150,200),(200,200,1),(255,255,255)]);

for tri in triangles:
    temp = 0;
    temp = (tri[0][0] | (tri[0][1] << 10) | (tri[0][2] << 20)) & 0xFFFFFFFFF
    temp = temp |  (((tri[1][0] | (tri[1][1] << 10) | (tri[1][2] << 20)) & 0xFFFFFFFFF) << 36)
    temp = temp |  (((tri[2][0] | (tri[2][1] << 10) | (tri[2][2] << 20)) & 0xFFFFFFFFF) << 72)
    temp = temp |  (((tri[3][0] | (tri[3][1] << 8) | (tri[3][2] << 16)) & 0xFFFFFF) << 108)
    print(hex(temp));
    print(hex(((temp >> 72)&0xFFFFFFFFF)>>20))
    print(((temp >> 72)&0xFFFFFFFFF)>>20)