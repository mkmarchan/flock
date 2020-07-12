import java.util.*;

int dimensions = 2;
int cubeLength = 400;
int numDrones = 125;
float droneRadius = 1;


float interactionRadius = 50;
float repulsionRadius = 25;
float maxForce = 5;
float minSpeed = 0.25;
float alignment = 1;
float cohesion = 0.4;
float separation = 1;
float forceSmoothing = 0.01;

Drone[] drones;
NTree nTree;

void setup() {
  size(400, 400);
  
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
        pos[j] = random(cubeLength) - cubeLength / 2;
        vel[j] = random(2) - 1;
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
  
  for (int i = 0; i < drones.length; i++) {
    drones[i].display();
  }
  println(frameRate);
}
