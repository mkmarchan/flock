# Created by Sergio Canu: https://pysource.com/2019/03/12/face-landmarks-detection-opencv-with-python/
# Modified by Mick Marchan

import cv2
import numpy as np
import dlib
import keyboard
import time
import json

excludedPoints = list(range(0, 17)) + list(range(48, 60))
cap = cv2.VideoCapture(0)
recording = False

detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")

saved_landmarks = list()

while True:
    if keyboard.is_pressed('r'):
        if recording:
            print("recording stopped")
            with open('data.json', 'w') as f:
                json.dump(saved_landmarks, f)
            saved_landmarks = list()
        else:
            print("recording started")
        recording = not recording

    _, frame = cap.read()
    gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

    if recording:
        cur_time = time.process_time()
        if not len(saved_landmarks):
            recording_start = time.process_time()
        saved_landmark = dict()
        saved_landmark['timestamp'] = cur_time - recording_start

    faces = detector(gray)
    for face in faces:
        x1 = face.left()
        y1 = face.top()
        x2 = face.right()
        y2 = face.bottom()
        #cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 3)

        landmarks = predictor(gray, face)

        for n in range(0, 68):
            if n in excludedPoints:
                continue
            x = landmarks.part(n).x
            y = landmarks.part(n).y
            cv2.circle(frame, (x, y), 4, (255, 0, 0), -1)
            if recording:
                saved_landmark[n] = (x, y)

    if recording:
        saved_landmarks.append(saved_landmark)
    cv2.imshow("Frame", frame)

    key = cv2.waitKey(1)
    if key == 27:
        break
