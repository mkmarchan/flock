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
      vel[i] += acc[i];
      pos[i] = CubeWrap(pos[i] + vel[i], cubeLength);
    }
  }
  
  public void display() {
    if (vel.length != 2 && vel.length != 3) {
      throw new RuntimeException("Only 2  or 3 dimensional drones can be displayed");
    }
    float[] pos = getPosition();
    if (pos.length == 2) {
      ArrayList<float[]> reflectionPoints = getReflectionPoints(this, cubeLength);
      
      for (Drone d : getWrappedNearby(nTree)) {
        float[] nearbyPos = d.getPosition();
        float dist = WrappedDist(pos, nearbyPos, cubeLength);
        float[] minDistPoint = getMinDistPoint(d);
        
        float opacity = 255 * (1.0 - pow(dist / interactionRadius, 2));
        stroke(opacity);
        line(minDistPoint[0], minDistPoint[1], pos[0], pos[1]);
        // TODO: resolve line flicker when passing edge
        // simulate double line draw
        if (!Arrays.equals(minDistPoint, nearbyPos)) {
          line(minDistPoint[0], minDistPoint[1], pos[0], pos[1]);
        }
        
        ArrayList<float[]> nearbyReflectionPoints = getReflectionPoints(d, cubeLength);
        for (float[] nearbyReflectionPoint : getReflectionPoints(d, cubeLength)) {
          float[] closestReflectionPoint = pos;
          float minDist = Dist(pos, nearbyReflectionPoint);
          for (float[] reflectionPoint : reflectionPoints) {
            float thisDist;
            if ((thisDist = Dist(reflectionPoint, nearbyReflectionPoint)) < minDist) {
              minDist = thisDist;
              closestReflectionPoint = reflectionPoint;
            }
          }
          if (minDist < interactionRadius) {
            line(nearbyReflectionPoint[0], nearbyReflectionPoint[1], closestReflectionPoint[0], closestReflectionPoint[1]);
          }
        }
        //for (int i = 0; i < nearbyReflectionPoints.size(); i++) {
          
        //  float[] curReflectionPoint = reflectionPoints.get(i);
        //  float[] nearbyReflectionPoint = nearbyReflectionPoints.get(i);
        //  line(nearbyReflectionPoint[0], nearbyReflectionPoint[1], curReflectionPoint[0], curReflectionPoint[1]);
        //}
      }
      
      fill(255);
      stroke(255);
      circle(pos[0], pos[1], r);
      
      for (float[] reflectionPoint : reflectionPoints) {
        circle(reflectionPoint[0], reflectionPoint[1], r);
      }
    } else {
      // TODO
      translate(pos[0], pos[1], pos[2]);
    }
  }
  
  private Set<Drone> getWrappedNearby(NTree<Drone> nTree) {
    float[] pos = getPosition();
    ArrayList<Drone> candidates = new ArrayList<Drone>();
    Set<Drone> nearby = new HashSet<Drone>();
    
    candidates.addAll(nTree.queryRange(new AABC(pos, interactionRadius)));
    boolean[] dimWraps = new boolean[pos.length];
    
    for (int i = 0; i < pos.length; i++) {
      if (abs(cubeLength / 2) - abs(pos[i]) < interactionRadius) {
        dimWraps[i] = true;
      }
    }
    
    // TODO: use dimwraps to optimize this, currently adding multiple times
    // reference point reflection drawing
    for (int i = 0; i < pow(2, pos.length); i++) {
      float[] newCenter = new float[pos.length];
      for (int j = 0; j < newCenter.length; j++) {
        int mult = (i / (int) pow(2, j)) % 2 == 0 ? 1 : -1;
        newCenter[j] = pos[j] * mult;
      }
      candidates.addAll(nTree.queryRange(new AABC(newCenter, interactionRadius)));
    }
    for (Drone d : candidates) {
      if (d != this && !nearby.contains(d) && WrappedDist(pos, d.getPosition(), cubeLength) <= interactionRadius) {
        nearby.add(d);
      }
    }
    
    return nearby;
  }
  
  private float[] getMinDistPoint(Drone d) {
    float[] pos = getPosition();
    float[] dPos = d.getPosition();
    float[] minDistPoint = new float[pos.length];
    
    for (int i = 0; i < pos.length; i++) {
      float reflectionCoord = Math.signum(pos[i] - dPos[i]) * cubeLength + dPos[i];
      minDistPoint[i] = abs(reflectionCoord - pos[i]) > abs(dPos[i] - pos[i]) ? dPos[i] : reflectionCoord;
    }
    return minDistPoint;
  }
  
  private ArrayList<float[]> getReflectionPoints(Drone d, float radius) {
    float[] pos = d.getPosition();
    ArrayList<float[]> reflectionPoints = new ArrayList<float[]>();
    ArrayList<Integer> wrappedDims = new ArrayList<Integer>();
    
    for (int i = 0; i < pos.length; i++) {
      if (abs(cubeLength / 2) - abs(pos[i]) < radius) {
        wrappedDims.add(i);
      }
    }
    
    for (int i = 1; i < pow(2, wrappedDims.size()); i++) {
      float[] reflectionPoint = new float[pos.length];
      for (int j = 0; j < wrappedDims.size(); j++) {
        int mult = (i / (int) pow(2, j)) % 2 == 0 ? 0 : 1;
        reflectionPoint[wrappedDims.get(j)] = pos[wrappedDims.get(j)] - Math.signum(pos[wrappedDims.get(j)]) * cubeLength * mult;
      }
      for (int j = 0; j < pos.length; j++) {
        if (!wrappedDims.contains(j)) {
          reflectionPoint[j] = pos[j];
        }
      }
      reflectionPoints.add(reflectionPoint);
    }
    return reflectionPoints;
  }
}
