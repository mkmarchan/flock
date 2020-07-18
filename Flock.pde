import java.util.*;

int dimensions = 2;
int cubeLength = 800;
int numDrones = 150;
int updatesPerFrame = 10;
float droneRadius = 1;


boolean mouseDown = false;
boolean showLines = true;
float interactionRadius = 55;
float repulsionRadius = 40;
float maxForce = 0.01;
float minSpeed = 0.0;
float alignment = 0.1;
float cohesion = 0.5;
float separation = 4;
float gravity = 1;
float forceSmoothing = 0;

Drone[] drones;
NTree nTree;

void setup() {
  size(800, 800);
  
  nTree = new NTree(dimensions, cubeLength / 2);
  
  drones = new Drone[numDrones];
  for (int i = 0; i < drones.length; i++) {
    float[] pos = new float[dimensions];
    float[] vel = new float[dimensions];
    float[] acc = new float[dimensions];
    
    if (i == 0) {
      pos[0] = -75;
      pos[1] = 0;
      vel[0] = 0.5;
    } else if (i == 1){
      pos[0] = 75;
      pos[1] = 0;
      vel[0] = -0.5;
    } else {
      for (int j = 0; j < dimensions; j++) {
        pos[j] = random(cubeLength / 2) - cubeLength / 4;
        vel[j] = random(0.2) - 0.1;
        acc[j] = 0;
      }
    }
   
    drones[i] = new Drone(pos, vel, acc, droneRadius);
  }
}

void draw() {
  background(0);
  translate(width / 2, height / 2);
  
  fill(255);
  
  for (int j = 0; j < updatesPerFrame; j++) {
    
    nTree.clear();
    for (int i = 0; i < drones.length; i++) {
      nTree.insert(drones[i]);
    }
    //nTree.show();
  
    for (int i = 0; i < drones.length; i++) {
      drones[i].calculateSteeringForce();
    }
    
    for (int i = 0; i < drones.length; i++) {
      drones[i].update();
    }
  }
  
  for (int i = 0; i < drones.length; i++) {
    drones[i].display();
  }
  //println(frameRate);
  saveFrame();
}

void mousePressed() {
  mouseDown = true;
}

void mouseReleased() {
  mouseDown = false;
}
