class Drone extends Positional {
  private float[] vel;
  private float[] acc;
  private float r;
  
  public Drone(float[] pos, float[] vel, float[] acc, float r) {
    super(pos);
    if (pos.length != vel.length || pos.length != acc.length) {
      throw new RuntimeException("Dimension mismatch");
    }
    this.vel = vel;
    this.acc = acc;
    this.r = r;
  }
  
  public void update() {
    
    float[] pos = getPosition();
    for (int i = 0; i < pos.length; i++) {
      pos[i] = ((pos[i] + vel[i] + cubeLength / 2) % cubeLength + cubeLength) % cubeLength - cubeLength / 2;
    }
  }
  
  public void display() {
    if (vel.length != 2 && vel.length != 3) {
      throw new RuntimeException("Only 2  or 3 dimensional drones can be displayed");
    }
    pushMatrix();
    float[] pos = getPosition();
    if (pos.length == 2) {
      translate(pos[0], pos[1]);
      ArrayList<Drone> nearby = nTree.queryRange(new AABC(pos, interactionRadius));
      for (Drone d : nearby) {
        float[] nearbyPos = d.getPosition();
        float dist;
        if (d == this || (dist = dist(pos, nearbyPos)) > interactionRadius) {
          continue;
        }
        
        stroke(255 * (1.0 - pow(dist / interactionRadius, 2)));
        line(nearbyPos[0], nearbyPos[1], pos[0], pos[1]);
        
      }
      
      fill(255);
      stroke(255);
      circle(pos[0], pos[1], r);
    } else {
      // TODO
      translate(pos[0], pos[1], pos[2]);
    }
    popMatrix();
  }
}
