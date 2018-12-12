import sys

triangles = [];
mats = [];
result = "";
#triangles.append([(100,200,800),(200,124,754),(125,100,199),(255,255,255)]);
#triangles.append([(100,100,800),(80,150,200),(200,200,1),(255,255,255)]);


vertices = [];
with open("rasterTest.obj", 'r') as f:
    currentMat = "";
    for line in f:
        splitLine = line.split(' ');
        if splitLine[0] == 'usemtl':
            currentMat = splitLine[1]
        if splitLine[0] == 'v':
            vertices.append((int(float(splitLine[1])),int(float(splitLine[2])), int(float(splitLine[3]))));
        if splitLine[0] == 'f':
            
            triangles.append((vertices[int(splitLine[1].split('/')[0])-1],vertices[int(splitLine[2].split('/')[0])-1], vertices[int(splitLine[3].split('/')[0])-1]));
            mats.append(currentMat);

with open("worldGeo.mif", 'w') as f:
    f.write("DEPTH = 1024;\n")
    f.write("WIDTH = 144;\n")
    f.write("ADDRESS_RADIX = HEX;\n")
    f.write("DATA_RADIX = HEX;\n")
    f.write("CONTENT\n");
    f.write("BEGIN\n");

    address = 0;

    for tri in triangles:
        temp = 0;
        temp = (tri[0][0] | (tri[0][1] << 10) | (tri[0][2] << 20)) & 0xFFFFFFFFF
        temp = temp |  (((tri[1][0] | (tri[1][1] << 10) | (tri[1][2] << 20)) & 0xFFFFFFFFF) << 36)
        temp = temp |  (((tri[2][0] | (tri[2][1] << 10) | (tri[2][2] << 20)) & 0xFFFFFFFFF) << 72)
        #temp = temp |  (((tri[3][0] | (tri[3][1] << 8) | (tri[3][2] << 16)) & 0xFFFFFF) << 108)
        f.write("{0:0X}".format(address) + ":  " + "{0:0{1}X}".format(temp,36) + ";\n");

        area = (tri[2][0] - tri[0][0])*(tri[1][1]-tri[0][1]) - (tri[2][1]-tri[0][1])*(tri[1][0]-tri[0][0]);
        f.write("-- ^ tri = " + str(tri[0]) + str(tri[1]) + str(tri[2]) + "\n")
        f.write("-- ^ area = " + str(area) + "\n")
        f.write("-- ^ mat - " + mats[address] + "\n")
        address += 1;
    f.write("END;\n");


#for tri in triangles:
    #temp = 0;
    #temp = (tri[0][0] | (tri[0][1] << 10) | (tri[0][2] << 20)) & 0xFFFFFFFFF
    #temp = temp |  (((tri[1][0] | (tri[1][1] << 10) | (tri[1][2] << 20)) & 0xFFFFFFFFF) << 36)
    #emp = temp |  (((tri[2][0] | (tri[2][1] << 10) | (tri[2][2] << 20)) & 0xFFFFFFFFF) << 72)
    #temp = temp |  (((tri[3][0] | (tri[3][1] << 8) | (tri[3][2] << 16)) & 0xFFFFFF) << 108)
    #print(hex(temp));
    #print(hex(((temp >> 72)&0xFFFFFFFFF)>>20))
    #print(((temp >> 72)&0xFFFFFFFFF)>>20)