import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

float vertex[] = new float[4096];
int runningVertex = 0;

int connections[] = new int[4096];
int runningConnections = 0;

int colours[] = new int[4096];

int viewWidth = 0;
int viewHeight = 0;

boolean vertexShow = false;
boolean naniteShow = true;
boolean faceShow = true;
boolean depthFade = false;

float cameraZ = 5;
float scale = 300;


public class TriData {
  float x1 = 0;
  float y1 = 0;
  float z1 = 0;

  float x2 = 0;
  float y2 = 0;
  float z2 = 0;

  float x3 = 0;
  float y3 = 0;
  float z3 = 0;

  float faceDepth = 0;

  float colourR = 0;
  float colourG = 0;
  float colourB = 0;

  TriData(float x1, float y1, float z1, float x2, float y2, float z2, float x3, float y3, float z3, float faceDepth, float colourR, float colourG, float colourB) {
    this.x1 = x1;
    this.y1 = y1;
    this.z1 = z1;

    this.x2 = x2;
    this.y2 = y2;
    this.z2 = z2;

    this.x3 = x3;
    this.y3 = y3;
    this.z3 = z3;

    this.faceDepth = faceDepth;

    this.colourR = colourR;
    this.colourG = colourG;
    this.colourB = colourB;
  };
}



void setup() {
  size(1024, 1024);
  viewWidth = width;
  viewHeight = height;

  noStroke();
  fill(200);
  noSmooth();
  String spaceRegex = "\\s+";
  String vertexRegex = "/";
  String[] lines = loadStrings("goodMonkey.obj");
  for (int i = 0; i < lines.length; i++) {

    String[] brokenLine = lines[i].split(spaceRegex);
    if (brokenLine[0].equals("v")) {
      vertex[runningVertex] = Float.parseFloat(brokenLine[1]);
      vertex[runningVertex+1] = Float.parseFloat(brokenLine[2]);
      vertex[runningVertex+2] = Float.parseFloat(brokenLine[3]);
      runningVertex += 3;
    }
    if (brokenLine[0].equals("f")) {
      colours[runningConnections] = parseInt(Math.round(Math.random() * 255));
      colours[runningConnections+1] = parseInt(Math.round(Math.random() * 255));
      colours[runningConnections+2] = parseInt(Math.round(Math.random() * 255));

      for (int a = 1; a < 4; a++) {
        String[] splitVertex = brokenLine[a].split(vertexRegex);
        connections[runningConnections] = parseInt(splitVertex[0])-1;
        runningConnections++;
      }
    }
  }
}

void keyReleased() {
  if (key == 'v') {
    vertexShow = !vertexShow;
  }
  if (key == 'n') {
    naniteShow = !naniteShow;
  }
  if (key == 'f') {
    faceShow = !faceShow;
  }
  if (key == 's') {
    depthFade = !depthFade;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      cameraZ -= 0.1;
    } else if (keyCode == DOWN) {
      cameraZ += 0.1;
    }
  }
}

void draw() {
  TriData triangleData[] = new TriData[4096];
  int runningTriangles = 0;

  /*
  This is the draw call, In the draw call we want to first calculate where we should draw each triangle.
   from this stage we will recive the depth of the center of the triangle. We use this value for simple shading and to sort the triangle draw calls by distance from camera.
   This is done by adding
   */

  background(0);
  //TODO: Reimpliment vertex rendering to work with projection system
  //if (vertexShow) {
  //  fill(120);
  //  for (int i=0; i < runningVertex - 1; i+=3) {
  //    ellipse(vertex[i]*(viewWidth/2)+(viewWidth/2), vertex[i+1]*(viewHeight/2)+(viewHeight/2), 4, 4);
  //  }
  //}
  if (faceShow) {
    for (int i=0; i < runningConnections; i+=3) {

      float x1 = vertex[connections[i] * 3];
      float y1 = vertex[connections[i] * 3 + 1];
      float z1 = vertex[connections[i] * 3 + 2] + cameraZ;

      float x2 = vertex[connections[i + 1] * 3];
      float y2 = vertex[connections[i + 1] * 3 + 1];
      float z2 = vertex[connections[i + 1] * 3 + 2] + cameraZ;

      float x3 = vertex[connections[i + 2] * 3];
      float y3 = vertex[connections[i + 2] * 3 + 1];
      float z3 = vertex[connections[i + 2] * 3 + 2] + cameraZ;

      float faceDepth = z1 + z2 + z3;

      float colourR = 0;
      float colourG = 0;
      float colourB = 0;

      if (naniteShow) {
        colourR = colours[i];
        colourG = colours[i+1];
        colourB = colours[i+2];
      } else {
        if (depthFade) {
          colourR = 255 * ((((faceDepth-cameraZ*3) / 3) + 1) / 2);
          colourG = 255 * ((((faceDepth-cameraZ*3) / 3) + 1) / 2);
          colourB = 255 * ((((faceDepth-cameraZ*3) / 3) + 1) / 2);
        } else {
          colourR = 230;
          colourG = 230;
          colourB = 230;
        }
      }

      triangleData[runningTriangles] = new TriData(x1, y1, z1, x2, y2, z2, x3, y3, z3, faceDepth, colourR, colourG, colourB);
      runningTriangles++;
    }

    Arrays.sort(
      triangleData,
      0,
      runningTriangles,
      Comparator.comparingDouble((TriData tri) -> tri.faceDepth).reversed());

    for (int i = 0; i < runningTriangles; i++) {
      fill(triangleData[i].colourR, triangleData[i].colourG, triangleData[i].colourB);
      triangle(
        triangleData[i].x1 / triangleData[i].z1 * scale + viewWidth / 2,
        triangleData[i].y1 / triangleData[i].z1 * scale + viewHeight / 2,

        triangleData[i].x2 / triangleData[i].z2 * scale + viewWidth / 2,
        triangleData[i].y2 / triangleData[i].z2 * scale + viewHeight / 2,

        triangleData[i].x3 / triangleData[i].z3 * scale + viewWidth / 2,
        triangleData[i].y3 / triangleData[i].z3 * scale + viewHeight / 2
        );
    }
  }
}
