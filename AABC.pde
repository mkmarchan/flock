// N-dimensional axis-aligned bounding cube with half length and center
class AABC {
  public float[] center;
  public float halfLength;
  
  // Create an AABC, centered on center, side length of 2 * halfLength
  // with dimensions matching center.length
  public AABC(float[] center, float halfLength) {
    this.center = center;
    this.halfLength = halfLength;
  }
  
  // Determines if point p is contained within this AABC.
  // Throws an error if p and center dimensions are mismatched
  public boolean containsPoint(float[] p) {
    if (p.length != center.length) {
      throw new RuntimeException("Mismatched dimensions");
    }
    
    for (int i = 0; i < center.length; i++) {
      if (p[i] < center[i] - halfLength || p[i] >= center[i] + halfLength) {
        return false;
      }
    }
    return true;
  }
  
  // Determines this and other overlap
  // Throws an error if the AABC dimensions are mismatched
  public boolean intersects(AABC other) {
    if (center.length != other.center.length){
      throw new RuntimeException("Mismatched dimensions");
    }
    
    for (int i = 0; i < center.length; i++) {
      if (other.center[i] - other.halfLength >= center[i] + halfLength
          || other.center[i] + other.halfLength < center[i] - halfLength)
          return false;
    }
    return true;
  }
}
