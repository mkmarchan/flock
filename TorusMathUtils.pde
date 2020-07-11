static float NonNegMod(float a, float b) {
  return ((a % b) + b) % b;
}

static float CubeWrap(float a, float cubeLength) {
  return NonNegMod(a + cubeLength / 2, cubeLength) - cubeLength / 2;
}

static float Dist(float[] a, float[] b, float cubeLength) {
  if (a.length != b.length) {
    throw new RuntimeException("Mismatched dimensions");
  }
  
  float sum = 0;
  for (int i = 0; i < a.length; i++) {
    float absDimDiff = abs(a[i] - b[i]);
    float wrapDimDiff = min(absDimDiff, cubeLength - absDimDiff);
    sum += pow(wrapDimDiff, 2);
    
  }
  return sqrt(sum);
}
