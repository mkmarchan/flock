static float NonNegMod(float a, float b) {
  return ((a % b) + b) % b;
}

static float CubeWrap(float a, float cubeLength) {
  return NonNegMod(a + cubeLength / 2, cubeLength) - cubeLength / 2;
}

static float WrappedDist(float[] a, float[] b, float cubeLength) {
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

static float Dist(float[] a, float[] b) {
  float sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i] - b[i], 2);
  }
  return sqrt(sum);
}

static float[] Add(float[] a, float[] b) {
  if (a.length != b.length) {
    throw new RuntimeException("Mismatched dimensions");
  }
  for (int i = 0; i < a.length; i++) {
    a[i] += b[i];
  }
  
  return a;
}

static float[] Subtract(float[] a, float[] b) {
  if (a.length != b.length) {
    throw new RuntimeException("Mismatched dimensions");
  }
  for (int i = 0; i < a.length; i++) {
    a[i] -= b[i];
  }
  
  return a;
}

static float[] Normalize(float[] a) {
  float magnitude = Magnitude(a);
  for (int i = 0; i < a.length; i++) {
    a[i] = a[i] / magnitude;
  }
  
  return a;
}

static float Magnitude(float[] a) {
  float sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i], 2);
  }
  
  return sqrt(sum);
}

static float[] Mult(float[] a, float scalar) {
  for (int i = 0; i < a.length; i++) {
    a[i] *= scalar;
  }
  return a;
}

static float[] SetMag(float[] a, float scalar) {
  return Mult(Normalize(a), scalar);
}
