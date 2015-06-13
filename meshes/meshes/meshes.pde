// Sample code for starting the meshes project

import processing.opengl.*;

float time = 0;  // keep track of passing of time (for automatic rotation)
boolean rotate_flag = true;       // automatic rotation of model?
boolean smooth_flat_flag = true;
int color_flag = 1;
boolean set = false;
Polyhedral polyhedral;

// initialize stuff
void setup() {
  size(400, 400, OPENGL);  // must use OPENGL here !!!
  noStroke();     // do not draw the edges of polygons
}

// Draw the scene
void draw() {
  
  resetMatrix();  // set the transformation matrix to the identity (important!)

  background(0);  // clear the screen to black
  
  // set up for perspective projection
  perspective (PI * 0.333, 1.0, 0.01, 1000.0);
  
  // place the camera in the scene (just like gluLookAt())
  camera (0.0, 0.0, 5.0, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0);
  
  scale (1.0, -1.0, 1.0);  // change to right-handed coordinate system
  
  // create an ambient light source
  ambientLight(102, 102, 102);
  
  // create two directional light sources
  lightSpecular(204, 204, 204);
  directionalLight(102, 102, 102, -0.7, -0.7, -1);
  directionalLight(152, 152, 152, 0, 0, -1);
  
  pushMatrix();

  if(color_flag == 1)  {
    fill(50, 50, 200);            // set polygon color to blue
  }
  else if(color_flag == 2)  {
    fill(255,255,255);
  }
  ambient (200, 200, 200);
  specular(0, 0, 0);
  shininess(1.0);
  
  rotate (time, 1.0, 0.0, 0.0);

  if(set)  {
    // THIS IS WHERE YOU SHOULD DRAW THE MESH
    for(int i = 0; i < polyhedral.faceCount; i++)  {
      if(color_flag == 3)  {
        fill(random(255), random(255), random(255));
      } 
      if(smooth_flat_flag == true)  {
        beginShape();
        normal(polyhedral.faceNorms[i].vecX, polyhedral.faceNorms[i].vecY, polyhedral.faceNorms[i].vecZ);
        vertex(polyhedral.vertices[polyhedral.faces[i].v1].v[0], polyhedral.vertices[polyhedral.faces[i].v1].v[1], polyhedral.vertices[polyhedral.faces[i].v1].v[2]);
        vertex(polyhedral.vertices[polyhedral.faces[i].v2].v[0], polyhedral.vertices[polyhedral.faces[i].v2].v[1], polyhedral.vertices[polyhedral.faces[i].v2].v[2]);
        vertex(polyhedral.vertices[polyhedral.faces[i].v3].v[0], polyhedral.vertices[polyhedral.faces[i].v3].v[1], polyhedral.vertices[polyhedral.faces[i].v3].v[2]);
        endShape(CLOSE);
      }
      else if (smooth_flat_flag == false)  {
        beginShape();
        normal(polyhedral.vertNorms[polyhedral.faces[i].v1].vecX, polyhedral.vertNorms[polyhedral.faces[i].v1].vecY, polyhedral.vertNorms[polyhedral.faces[i].v1].vecZ);
        vertex(polyhedral.vertices[polyhedral.faces[i].v1].v[0], polyhedral.vertices[polyhedral.faces[i].v1].v[1], polyhedral.vertices[polyhedral.faces[i].v1].v[2]);
        normal(polyhedral.vertNorms[polyhedral.faces[i].v2].vecX, polyhedral.vertNorms[polyhedral.faces[i].v2].vecY, polyhedral.vertNorms[polyhedral.faces[i].v2].vecZ);
        vertex(polyhedral.vertices[polyhedral.faces[i].v2].v[0], polyhedral.vertices[polyhedral.faces[i].v2].v[1], polyhedral.vertices[polyhedral.faces[i].v2].v[2]);
        normal(polyhedral.vertNorms[polyhedral.faces[i].v3].vecX, polyhedral.vertNorms[polyhedral.faces[i].v3].vecY, polyhedral.vertNorms[polyhedral.faces[i].v3].vecZ);
        vertex(polyhedral.vertices[polyhedral.faces[i].v3].v[0], polyhedral.vertices[polyhedral.faces[i].v3].v[1], polyhedral.vertices[polyhedral.faces[i].v3].v[2]);
        endShape(CLOSE);
      }
    }
  }
  else  {
    beginShape();
    normal (0.0, 0.0, 1.0);
    vertex (-1.0, -1.0, 0.0);
    vertex ( 1.0, -1.0, 0.0);
    vertex ( 1.0,  1.0, 0.0);
    vertex (-1.0,  1.0, 0.0);
    endShape(CLOSE);
  }
  
  popMatrix();
 
  // maybe step forward in time (for object rotation)
  if (rotate_flag)
    time += 0.02;
}

// handle keyboard input
void keyPressed() {
  if (key == '1') {
    read_mesh ("tetra.ply");
    set = true;
  }
  else if (key == '2') {
    read_mesh ("octa.ply");
    set = true;
  }
  else if (key == '3') {
    read_mesh ("icos.ply");
    set = true;
  }
  else if (key == '4') {
    read_mesh ("star.ply");
    set = true;
  }
  else if (key == '5') {
    read_mesh ("torus.ply");
    set = true;
  }
  else if (key == '6') {
    create_sphere();                     // create a sphere
  }
  else if (key == ' ') {
    rotate_flag = !rotate_flag;          // rotate the model?
  }
  else if (key == 'n' || key == 'N') {
    smooth_flat_flag = !smooth_flat_flag;
  }
  else if (key == 'w' || key == 'W') {
    color_flag = 2;
  }
  else if (key == 'r' || key == 'R') {
    color_flag = 3;
  }
  else if (key == 'q' || key == 'Q') {
    exit();                               // quit the program
  }

}

// Read polygon mesh from .ply file
//
// You should modify this routine to store all of the mesh data
// into a mesh data structure instead of printing it to the screen.
void read_mesh (String filename)
{
  int i;
  String[] words;
  
  String lines[] = loadStrings(filename);
  
  words = split (lines[0], " ");
  int num_vertices = int(words[1]);
//  println ("number of vertices = " + num_vertices);
  
  words = split (lines[1], " ");
  int num_faces = int(words[1]);
//  println ("number of faces = " + num_faces);
  
  // read in the vertices
  Vertex[] verts = new Vertex[num_vertices];
  for (i = 0; i < num_vertices; i++) {
    words = split (lines[i+2], " ");
    float x = float(words[0]);
    float y = float(words[1]);
    float z = float(words[2]);
    verts[i] = new Vertex(x,y,z);
//    println ("vertex = " + x + " " + y + " " + z);
  }
  
  // read in the faces
  Face[] faces = new Face[num_faces];
  for (i = 0; i < num_faces; i++) {
    
    int j = i + num_vertices + 2;
    words = split (lines[j], " ");
    
    int nverts = int(words[0]);
    if (nverts != 3) {
      println ("error: this face is not a triangle.");
      exit();
    }
    
    int index1 = int(words[1]);
    int index2 = int(words[2]);
    int index3 = int(words[3]);
    
    faces[i] = new Face(index1, index2, index3);
    faces[i].centroid = null;
    
//    println ("face = " + index1 + " " + index2 + " " + index3);
  }
  
  polyhedral = new Polyhedral(num_vertices, num_faces, verts, faces);
  
//  for(int j = 0; j < num_vertices; j++)  {
//    println(polyhedral.vertices[j].v[0] + "\t" + polyhedral.vertices[j].v[1] + "\t"+ polyhedral.vertices[j].v[2]);
//  }
//  for(int k = 0; k < num_faces; k++)  {
//    println(polyhedral.faces[k][0] + "\t" + polyhedral.faces[k][1] + "\t"+ polyhedral.faces[k][2]);
//  }
}

Polyhedral dual()  {
  return null;
}

class Polyhedral   {
  int vertCount, faceCount;
  
  Vertex[] vertices;
  Face[] faces;
  
  Vector[] vertNorms, faceNorms;
    
  Polyhedral()  {
    //manually set information
  }
  
  Polyhedral(int v, int f, Vertex[] vs, Face[] fs)  {
    vertCount = v;
    faceCount = f;
    vertices = vs;
    faces = fs;
    
    faceNorms = new Vector[faceCount];
    vertNorms = new Vector[vertCount];
    
    Vector[] tempNorms = new Vector[vertCount];
    int[] share = new int[vertCount];
    for(int i = 0; i < vertCount; i++)  {
      tempNorms[i] = new Vector(0, 0, 0);
    }
    
    for(int i = 0; i < faceCount; i++)  {
      Vector U = vertices[faces[i].v2].minus(vertices[faces[i].v1]);
      Vector V = vertices[faces[i].v3].minus(vertices[faces[i].v1]);
      Vector Normal = V.cross(U).normalize();
      faceNorms[i] = Normal;
      
      tempNorms[faces[i].v1] = tempNorms[faces[i].v1].plus(Normal);
      tempNorms[faces[i].v2] = tempNorms[faces[i].v2].plus(Normal);
      tempNorms[faces[i].v3] = tempNorms[faces[i].v3].plus(Normal);
      share[faces[i].v1] += 1; 
      share[faces[i].v2] += 1; 
      share[faces[i].v3] += 1; 
    }  
    
    for(int i = 0; i < vertCount; i++)  {
      vertNorms[i] = tempNorms[i].divide(share[i]);
    }
  }
} 
  
class Vertex {
  float[] v;
  
  Vertex()  {
    v = new float[3];
  }
  
  Vertex(float x, float y, float z) {
    v = new float[3];
    v[0] = x;
    v[1] = y;
    v[2] = z;
  }
  
  Vector plus(Vertex add){
    return new Vector(v[0]+add.v[0], v[1]+add.v[1], v[2]+add.v[2]);
  }
  
  Vector minus(Vertex sub){
    return new Vector(v[0]-sub.v[0], v[1]-sub.v[1], v[2]-sub.v[2]);
  }
}

class Vector{
  float vecX, vecY, vecZ;
  
  Vector(float x, float y, float z){
    vecX = x;
    vecY = y;
    vecZ = z;
  }
  
  float mag(){
    return sqrt(this.dot(this));
  }
  
  Vector scale(float s){
    return new Vector(s * vecX, s * vecY, s * vecZ);
  }
  
  Vector divide(float s){
    return new Vector(vecX/s, vecY/s, vecZ/s);
  }
  
  Vector plus(Vector v){
    return new Vector(vecX + v.vecX, vecY + v.vecY, vecZ + v.vecZ);
  }
  
  Vector minus(Vector v){
    return new Vector(vecX - v.vecX, vecY - v.vecY, vecZ - v.vecZ);
  }
  
  float dot(Vector v){
    return (vecX * v.vecX) + (vecY * v.vecX) + (vecZ * v.vecZ);
  }
  
  Vector cross(Vector v){
    return new Vector(vecY * v.vecZ - v.vecY * vecZ, vecZ * v.vecX - v.vecZ * vecX, vecX * v.vecY - v.vecX * vecY);
  }
  
  Vector normalize(){
    return this.divide(this.mag());
  }
}


class Face {
  int v1, v2, v3;
  Vertex centroid;
  
  Face(int vertex1, int vertex2, int vertex3)  {
    v1 = vertex1;
    v2 = vertex2;
    v3 = vertex3;
  }
}
  
void create_sphere() {}

