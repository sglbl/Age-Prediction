import io
import json
import numpy as np
import tensorflow as tf
import cv2 as cv
from PIL import Image
import base64
import logging
import azure.functions as func


class InferenceModel():
    def __init__(self, model_path):
        # Load the model from the path
        self.model = tf.keras.models.load_model(model_path)
 
    #def abs(a):
     #   return 1
 
    def face_border_detector(self, image):
        # get xml from repo
        face_cascade = cv.CascadeClassifier('models/haarcascade_frontalface_default.xml')
        face_cascade2 = cv.CascadeClassifier('models/haarcascade_frontalface_alt.xml')
        face_cascade3 = cv.CascadeClassifier('models/haarcascade_frontalface_alt2.xml')
        face_cascade4 = cv.CascadeClassifier('models/haarcascade_frontalface_alt_tree.xml')

        gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        biggest_face = [0,0,0,0]
        if len(faces) == 0 or abs(faces[0][2] - faces[0][2]) < 100:
            print("No faces found in file1")
            faces = face_cascade2.detectMultiScale(gray, 1.1, 4)
            if len(faces) == 0:
                print("No faces found in file2")
                faces = face_cascade3.detectMultiScale(gray, 1.1, 4)
                print(faces)
                if len(faces) == 0:
                    print("No faces found in file3")
                    faces = face_cascade4.detectMultiScale(gray, 1.1, 4)

        for i, (x, y, w, h) in enumerate(faces):
            if abs(biggest_face[2] - biggest_face[0]) < abs(w - x):
                biggest_face = [x, y, w, h]
        print(biggest_face)        
        [x,y,w,h] = biggest_face
        cv.rectangle(image, (x, y), (x + w, y + h), (255, 0, 0), 2)
        # Show image with face border
        cv.imshow("image", image)
        cv.waitKey(0)
        
        return biggest_face


    # Decode image from base64 to pillow and opencv images
    def preprocess_image(self, image_encoded):     
        pil_image = Image.open(io.BytesIO(base64.b64decode(image_encoded)))
        pil_image_gray = pil_image.resize((48,48)).convert('L')
        # pil_image_gray.show()
        image_np = (255 - np.array(pil_image_gray.getdata())) / 255.0
        cv_image = np.array(pil_image) # converting PIL image to cv2 image
        cv_image = cv_image[:, :, ::-1].copy()  # convert from RGB to BGR

        return cv_image, image_np.reshape(-1,48,48,1)
 
 
    def predict(self, req_body):
        opencv_image, image_data = self.preprocess_image(req_body)
        prediction = self.model.predict(image_data)
        # print(prediction.tolist()[0][0], "Predict list")
        print("Prediction is: ", prediction)
        predicted_age = int(prediction.tolist()[0][0])
        face_borders_and_age = self.face_border_detector( opencv_image )
        face_borders_and_age.append(predicted_age)
        return face_borders_and_age

    def encoder(self, image_src):
        # with open(image_src, "rb") as image_file:
        with open(image_src, "rb") as image_file:
            encoded_string = base64.b64encode(image_file.read())
        return encoded_string

def int32_to_int(obj):
    if isinstance(obj, np.integer):
        return int(obj)    
     
   
if __name__ == "__main__":
    global model
    model_path = "models/age_model_a"
    model = InferenceModel(model_path)
    
    # #open image from encoded string in json file
    # with open('outputfile.json') as json_file:
    #     json_ob = json.load(json_file)  # read outputfile as json
    # encoded_photo = json_ob["image"]
    
    # open image from local path and encode it
    image_path = "models/ex_images/gray.jpg"
    # image_path = "datasets/UTK_Images/part3/4_1_0_20170116215618294.jpg"
    # image_path = "C:/Users/sglbl/Downloads/Bill_Gates_-_Nov._8_2019.jpg"
    encoded_photo = model.encoder(image_path)
    
    
    preds = model.predict(encoded_photo)
    dumped_preds = json.dumps({"preds": preds}, default=int32_to_int)
    print("Dumped preds: ", dumped_preds)   
    