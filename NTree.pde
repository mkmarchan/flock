class NTree<T extends Positional> {
  final int CAPACITY = 1;
  
  AABC boundary;
  ArrayList<T> points;
  NTree[] children;
  
  public NTree(int dimensions, float halfLength) {
    this.boundary = new AABC(new float[dimensions], halfLength);
    initialize();
  }
  
  public NTree(AABC boundary) {
    this.boundary = boundary;
    initialize();
  }
  
  private void initialize() {
    points = new ArrayList<T>();
    children = new NTree[(int)pow(2, boundary.center.length)];
  }
  
  public boolean insert(T point) {
    if (!boundary.containsPoint(point.getPosition())) {
      return false;
    }
    
    if (points.size() < CAPACITY && children[0] == null) {
      points.add(point);
      return true;
    }
    
    if (children[0] == null) {
      subdivide();
    }
    
    for (int i = 0; i < children.length; i++) {
      if (children[i].insert(point)) {
        return true;
      }
    }
    
    return false;
  }
  
  public ArrayList<T> queryRange(AABC range) {
    ArrayList<T> results = new ArrayList<T>();
    if (!boundary.intersects(range)) {
      return results;
    }
    
    for (int i = 0; i < points.size(); i++) {
      if (range.containsPoint(points.get(i).getPosition())) {
        results.add(points.get(i));
      }
    }
    
    if (children[0] == null) {
      return results;
    }
    
    for (int i = 0; i < children.length; i++) {
      results.addAll(children[i].queryRange(range));
    }
    
    return results;
  }
  
  public void clear() {
    points.clear();
    for (int i = 0; i < children.length; i++) {
      children[i] = null;
    }
  }
  
  private void subdivide() {
    for (int i = 0; i < pow(2, boundary.center.length); i++) {
      float[] newCenter = new float[boundary.center.length];
      for (int j = 0; j < newCenter.length; j++) {
        int mult = (i / (int) pow(2, j)) % 2 == 0 ? 1 : -1;
        newCenter[j] = boundary.center[j] + mult * boundary.halfLength / 2;
      }
      
      children[i] = new NTree(new AABC(newCenter, boundary.halfLength / 2));
    }
  }
  
  public void show() {
    if (boundary.center.length != 2 && boundary.center.length != 3) {
      throw new RuntimeException("Only 2  or 3 dimensional trees can be displayed");
    }
    
    pushMatrix();
    if (boundary.center.length == 2) {
      stroke(255);
      noFill();
      rectMode(CENTER);
      println(boundary.center[0] +", " + boundary.center[1]);
      rect(boundary.center[0], boundary.center[1], boundary.halfLength * 2, boundary.halfLength * 2);
    } else {
      translate(boundary.center[0], boundary.center[1], boundary.center[2]);
      stroke(255);
      noFill();
      box(boundary.halfLength * 2);
    }
    popMatrix();
    
    if (children[0] != null) {
      for (int i = 0; i < children.length; i++) {
        //line(boundary.center.x, boundary.center.y, boundary.center.z, children[i].boundary.center.x, children[i].boundary.center.y, children[i].boundary.center.z);
        children[i].show();
      }
    }
  }
}
