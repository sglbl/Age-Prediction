import os
import json
import numpy as np
import tensorflow as tf
import cv2 as cv
from PIL import Image
#from inference_model import InferenceModel
 
from azureml.contrib.services.aml_request import rawhttp
from azureml.contrib.services.aml_response import AMLResponse
 

class InferenceModel():
    def __init__(self, model_path):
        self.model = tf.keras.models.load_model(model_path)
 
    def face_border_detector(self, image):
        face_cascade = cv.CascadeClassifier('haarcascade_frontalface_default.xml')
        gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        biggest_face = (0,0,0,0)
        for i, (x, y, w, h) in enumerate(faces):
            if (biggest_face[2] - biggest_face[0]) < (w - x):
                biggest_face = (x, y, w, h)
                
        x,y,w,h = biggest_face
        cv.rectangle(image, (x, y), (x + w, y + h), (255, 0, 0), 2)
        return biggest_face
 
 
    def _preprocess_image(self, image_bytes):
        image = Image.open(image_bytes)        
        image = image.resize((48,48)).convert('L')
        # image.show()
        image_np = (255 - np.array(image.getdata())) / 255.0
 
        return image_np.reshape(-1,48,48,1)
 
    def predict(self, image_bytes):
        image_data = self._preprocess_image(image_bytes)
        prediction = self.model.predict(image_data)
        
        face_borders = self.face_border_detector(cv.imread(image_bytes))
        # print("Prediction: ", prediction)
        # print("Face borders: ", face_borders)
        return [prediction, face_borders]


def init():
    global model
    model_name = "age_model_a.h5"
    model_path = os.path.join(os.getenv("AZUREML_MODEL_DIR"), model_name)
    model = InferenceModel(model_path)

@rawhttp
def run(request):
    if request.method != 'POST':
        return AMLResponse(f"Unsupported verb: {request.method}", 400)
 
    image_data = request.files['image']
    preds = model.predict(image_data)
    
    return AMLResponse(json.dumps({"preds": preds.tolist()}), 200)
    
# if __name__ == "__main__":
#     global model
#     # model_path = os.path.join(os.getcwd(), "/age_model_a.h5")
#     model_path = "age_model_a.h5"
#     print(model_path)
#     model = InferenceModel(model_path)
#     print("main")
#     predicted = model.predict("sglbl.jpg")
#     print(predicted)