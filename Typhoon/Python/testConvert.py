import sys

triangles = [];
mats = [];
result = "";
triangles.append([(0,0,0),(0,0,0),(0,0,0),(0,0,0)]);
#triangles.append([(100,100,800),(80,150,200),(200,200,1),(255,255,255)]);


vertices = [];
normals = [];
with open("rasterTest.obj", 'r') as f:
    currentMat = "";
    for line in f:
        splitLine = line.split(' ');
        if splitLine[0] == 'usemtl':
            currentMat = splitLine[1]
        if splitLine[0] == 'v':
            vertices.append((int(float(splitLine[1])),int(float(splitLine[2])), int(float(splitLine[3]))));
        if splitLine[0] == 'vn':
            normals.append((int(float(splitLine[1])*127.0+127.0),int(float(splitLine[2])*127.0+127.0), int(float(splitLine[3])*127.0+127.0)));
        if splitLine[0] == 'f':
            
            v0 = int(splitLine[1].split('/')[0])-1
            v1 = int(splitLine[2].split('/')[0])-1
            v2 = int(splitLine[3].split('/')[0])-1
            n0 = int(splitLine[1].split('/')[2])-1
            n1 = int(splitLine[2].split('/')[2])-1
            n2 = int(splitLine[3].split('/')[2])-1
            #print(str(len(normals)) + ", " + str(v0));
            n0 = normals[n0]
            n1 = normals[n1]
            
            n2 = normals[n2]
            n_avg = ((n0[0] + n1[0] + n2[0])/3,(n0[1] + n1[1] + n2[1])/3,(n0[2] + n1[2] + n2[2])/3)

            triangles.append((vertices[v0],
                                vertices[v1],
                                vertices[v2],
                                n_avg));
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
        temp = temp |  (((tri[3][0] | (tri[3][1] << 8) | (tri[3][2] << 16)) & 0xFFFFFF) << 108)
        f.write("{0:0X}".format(address) + ":  " + "{0:0{1}X}".format(temp,36) + ";\n");

        area = (tri[2][0] - tri[0][0])*(tri[1][1]-tri[0][1]) - (tri[2][1]-tri[0][1])*(tri[1][0]-tri[0][0]);
        f.write("-- ^ tri = " + str(tri[0]) + str(tri[1]) + str(tri[2]) + "\n")
        f.write("-- ^ norms = " + str(tri[3]) + "\n")
        f.write("-- ^ area = " + str(area) + "\n")
        #f.write("-- ^ mat - " + mats[address] + "\n")
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