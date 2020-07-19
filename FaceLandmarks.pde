class FaceLandmarks {
  static final int recordingWidth = 1080;
  static final int recordingHeight = 720;
  float timestamp;
  Map<Integer, PVector> landmarks;
  
  public FaceLandmarks(float timestamp, Map<Integer, PVector> landmarks) {
    this.timestamp = timestamp;
    this.landmarks = landmarks;
  }
  
  public void display() {
    for (PVector landmark : landmarks.values()) {
      fill(255);
      stroke(255);
      // TODO: aspect ratio screwed up here
      circle(landmark.x / (float) recordingWidth * cubeLength - cubeLength / 2, landmark.y / (float) recordingHeight * cubeLength - cubeLength / 2, 10);
    }
  }
  
}
