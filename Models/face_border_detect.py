import cv2 as cv


def face_border_detector(image):
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

# face_border_detector(cv.imread("17_0_0_20170114025941650.jpg"))

##################################################

def face_border_detector2(img):
    grayImage = cv.cvtColor(img, cv.COLOR_BGR2GRAY)
    cv.imshow("Lady gray", grayImage)

    haar_cascade = cv.CascadeClassifier("haar_cascade_face.xml")
    # rectangle detected the face
    faces_rect = haar_cascade.detectMultiScale(grayImage, scaleFactor=1.1,
        minNeighbors=5) # number of neighbors rectangle should have call face
    # When you increase minNeighbors it founds less face usually.

    # print(f"Number of faces found = {len(faces_rect)}")
    if(len(faces_rect) == 0):
        print("No face found")
    elif(len(faces_rect) == 1):
        return faces_rect
        

    for(x,y,w,h) in faces_rect:
        cv.rectangle(img, (x,y), (x+w, y+h), (0,255,0), thickness=2)

    cv.imshow("Detected faces", img)

    cv.waitKey(0)
    
# img = cv.imread("photos/kucukluk8_2.jpg")
# face_border_detector2(img)