class FaceLandmarkPlayer {
  private ArrayList<FaceLandmarks> landmarksArray;
  
  public FaceLandmarkPlayer(String savedLandmarksPath) {
    landmarksArray = new ArrayList<FaceLandmarks>();
    JSONArray jsonLandmarks = loadJSONArray(savedLandmarksPath);
    for (int i = 0; i < jsonLandmarks.size(); i++) {
      JSONObject landmarksObject = jsonLandmarks.getJSONObject(i);
      float timestamp = landmarksObject.getFloat("timestamp");
      Map<Integer, PVector> landmarks = new HashMap<Integer, PVector>();
      for (int j = 0; j < 68; j++) {
        JSONArray pointsObject = landmarksObject.getJSONArray("" + j);
        if (pointsObject != null) {
          int[] points = pointsObject.getIntArray();
          landmarks.put(j, new PVector(points[0], points[1]));
        }
        
      }
      
      landmarksArray.add(new FaceLandmarks(timestamp, landmarks));
    }
  }
  
  public FaceLandmarks getLandmarksAtTime(float timestamp) {
    float modTimestamp = timestamp % landmarksArray.get(landmarksArray.size() - 1).timestamp;
    for (int i = 0; i < landmarksArray.size() - 1; i++) {
      if (landmarksArray.get(i + 1).timestamp > modTimestamp) {
        println(i);
        return landmarksArray.get(i);
      }
    }
    return landmarksArray.get(landmarksArray.size() - 1);
  }
}
