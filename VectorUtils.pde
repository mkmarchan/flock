static float dist(float[] a, float[] b) {
  if (a.length != b.length) {
    throw new RuntimeException("Mismatched dimensions");
  }
  
  float sum = 0;
  for (int i = 0; i < a.length; i++) {
    sum += pow(a[i] - b[i], 2);
  }
  
  return sqrt(sum);
}
