const fs = require('fs');

if (process.argv.length != 3) return console.log("Usage: convert.js teapot.off");

let fn = process.argv[2];

//make this streaming if we're running into size issues
//though that is very very highly unlikely, lol
let data = fs.readFileSync(fn, 'utf8').split("\n");

let readLine = ()=>{
    while (data.length != 0) {
        let line = data.shift().trim();
        if (line.startsWith("#") || line == "OFF" || line == "") continue;
        return line;
    }
}

let header = readLine().split(/\s+/).map(e=>+e);
console.log(header[0] + " vertices, " + header[1] + " faces");

//read vertices
let vertices = Array(header[0]).fill(0).map(()=>readLine().split(/\s+/).map(e=>+e));

//read faces and convert to triangles
let tris = [];
for (let i=0;i<header[1];i++) {
    let face = readLine().split(/\s+/).map(e=>+e);
    
    //disregard those after the length, may be color data
    face.splice(face.shift());
    if (face.length < 3) throw "???";
    
    //fan triangulate
    for (let i=1;i<face.length-1;i++) tris.push([face[0], face[i], face[i+1]]);
}
console.log("Created " + tris.length + " triangles");

/*memory format:
21 bits x, 2's comp
21 bits y, 2's comp
21 bits z, 2's comp
1 bit always 1 except for end of data
3 words per triangle
*/
let out = Buffer.alloc(100, 1);
fs.writeFileSync(fn + ".hex", out);