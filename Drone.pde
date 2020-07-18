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
    Add(vel, acc);
    if (Magnitude(vel) < minSpeed) {
      SetMag(vel, minSpeed);
    }
    for (int i = 0; i < pos.length; i++) {
      pos[i] = CubeWrap(pos[i] + vel[i], cubeLength);
    }
    
  }
  
  public void calculateSteeringForce() {
    float[] pos = getPosition();
    float[] avgVel = new float[pos.length];
    float[] avgPos = new float[pos.length];
    float[] displacementPos = new float[pos.length];
    float[] newAcc = new float[pos.length];
    
    int numTooClose = 0;
    Set<Drone> nearby = getWrappedNearby(nTree);
    for (Drone d : nearby) {
      float dist = WrappedDist(pos, d.getPosition(), cubeLength);
      float[] minDistPoint = getMinDistPoint(d);
      
      Add(avgVel, Mult(Arrays.copyOf(d.vel, d.vel.length), (interactionRadius - dist) / interactionRadius));
      Add(avgPos, minDistPoint);
      
      if (dist <= repulsionRadius) {
        numTooClose++;
        Add(displacementPos, minDistPoint); 
      }
    }
    
    // Include this drones velocity in the average
    Add(avgVel, vel);
    
    if (nearby.size() > 0) {
      
      // Get the average velocity of all drones near this one
      // +1 since this drone's velocity is included
      Mult(avgVel, 1.0 / (nearby.size() + 1));
      
      // Add the alignment force
      Subtract(avgVel, vel);
      if (Magnitude(avgVel) > maxForce) {
        SetMag(avgVel, maxForce);
      }
      Add(newAcc, Mult(avgVel, alignment));
      
      // Get the average position of all drones near this one
      Mult(avgPos, 1.0 / nearby.size());
      
      // Add the cohesion force
      Subtract(avgPos, pos);
      float cohesionMagnitude = inverseDistMap(Magnitude(avgPos), interactionRadius, cohesion * maxForce, 0, 2); 
      SetMag(avgPos, cohesionMagnitude);
      Add(newAcc, avgPos);
      
      if (numTooClose > 0) {
        Mult(displacementPos, 1.0 / numTooClose);
        Subtract(displacementPos, pos);
        Mult(displacementPos, -1);
        float separationMagnitude = inverseDistMap(Magnitude(displacementPos), repulsionRadius, separation * maxForce, 0, 2);
        SetMag(displacementPos, separationMagnitude);
        Add(newAcc, displacementPos);
      }
    }
    
    if (mouseDown) {
      float gravityDist = WrappedDist(pos, new float[pos.length], cubeLength);
      float[] gravityDir = Subtract(new float[pos.length], pos);
      float gravityMagnitude = inverseDistMap(gravityDist, cubeLength, gravity * maxForce, 0, 2);
      SetMag(gravityDir, gravityMagnitude);
      Add(newAcc, gravityDir);
    }
    
    Add(Mult(acc, forceSmoothing), Mult(newAcc, 1 - forceSmoothing));
  }
  
  private float inverseDistMap(float dist, float maxDist, float maxOut, float minOut, float power) {
    float distDiff = (maxDist - dist) / maxDist;
    float maxTerm = 1.0 / pow(2, power);
    return (1.0 / pow(distDiff + 1, power) - maxTerm) / (1 - maxTerm) * (maxOut - minOut) + minOut;
  }
  
  public void display() {
    if (vel.length != 2 && vel.length != 3) {
      throw new RuntimeException("Only 2  or 3 dimensional drones can be displayed");
    }
    float[] pos = getPosition();
    if (pos.length == 2) {
      ArrayList<float[]> reflectionPoints = getReflectionPoints(this, cubeLength);
      if (showLines) {
        for (Drone d : getWrappedNearby(nTree)) {
          float[] nearbyPos = d.getPosition();
          float dist = WrappedDist(pos, nearbyPos, cubeLength);
          float[] minDistPoint = getMinDistPoint(d);
          
          float opacity = 255 * (1.0 - pow(dist / interactionRadius, 2));
          stroke(255, opacity);
          line(minDistPoint[0], minDistPoint[1], pos[0], pos[1]);
          // TODO: resolve line flicker when passing edge
          // possibly has to do with NTree not giving all possible neighbors properly
          
          // simulate double line draw
          if (!Arrays.equals(minDistPoint, nearbyPos)) {
            //line(minDistPoint[0], minDistPoint[1], pos[0], pos[1]);
          }
          
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
            if (minDist <= interactionRadius) {
              line(nearbyReflectionPoint[0], nearbyReflectionPoint[1], closestReflectionPoint[0], closestReflectionPoint[1]);
            }
          }
        }
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
      if (abs(cubeLength / 2) - abs(pos[i]) <= interactionRadius) {
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
      if (abs(cubeLength / 2) - abs(pos[i]) <= radius) {
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
