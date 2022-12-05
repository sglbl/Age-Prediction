import os
import json
import numpy as np
import tensorflow as tf
from PIL import Image
#from inference_model import InferenceModel
 
from azureml.contrib.services.aml_request import rawhttp
from azureml.contrib.services.aml_response import AMLResponse
 

class InferenceModel():
    def __init__(self, model_path):
        self.model = tf.keras.models.load_model(model_path)
 
    def _preprocess_image(self, image_bytes):
        image = Image.open(image_bytes)        
        image = image.resize((48,48)).convert('L')
        image_np = (255 - np.array(image.getdata())) / 255.0
 
        return image_np.reshape(-1,48,48,1)
 
    def predict(self, image_bytes):
        image_data = self._preprocess_image(image_bytes)
        prediction = self.model.predict(image_data)
 
        return np.argmax(prediction, axis=1)


def init():
    global model
    model_path = os.path.join(os.getenv("AZUREML_MODEL_DIR"), "age_model_a.h5")
    print(model_path)
    model = InferenceModel(model_path)
 
@rawhttp
def run(request):
    if request.method != 'POST':
        return AMLResponse(f"Unsupported verb: {request.method}", 400)
 
    image_data = request.files['image']
    preds = model.predict(image_data)
    
    return AMLResponse(json.dumps({"preds": preds.tolist()}), 200)