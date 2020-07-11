int dimensions = 2;
int cubeLength = 400;
int numDrones = 40;
float droneRadius = 10;
float interactionRadius = 100;

Drone[] drones;
NTree nTree;

void setup() {
  size(800, 800);
  
  print(-1 % 10);
  nTree = new NTree(dimensions, cubeLength / 2);
  
  drones = new Drone[numDrones];
  for (int i = 0; i < drones.length; i++) {
    float[] pos = new float[dimensions];
    float[] vel = new float[dimensions];
    float[] acc = new float[dimensions];
    
    for (int j = 0; j < dimensions; j++) {
      pos[j] = random(cubeLength) - cubeLength / 2;
      vel[j] = random(1) - 0.5;
      acc[j] = 0;
    }
    
    drones[i] = new Drone(pos, vel, acc, droneRadius);
  }
}

void draw() {
  background(0);
  
  translate(width / 2, height / 2);
  
  nTree.clear();
  for (int i = 0; i < drones.length; i++) {
    nTree.insert(drones[i]);
  }
  //nTree.show();
  
  for (int i = 0; i < drones.length; i++) {
    drones[i].update();
  }
  
  for (int i = 0; i < drones.length; i++) {
    drones[i].display();
  }
}
