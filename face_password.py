import hashlib
import sys
import cv2

def generate_image_password(face_image_path):

    face_img = cv2.imread(face_image_path, cv2.IMREAD_GRAYSCALE)
    if face_img is None:
        print("Error: Unable to load the face.")
        sys.exit(1)

    hash_ = face_img.flatten()
    face_image_hash = hashlib.sha256(hash_.tobytes()).hexdigest()

    return face_image_hash

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 face_password.py <path_to_image>")
        sys.exit(1)

    image_path = sys.argv[1]
    image_password = generate_image_password(image_path)
    print(image_password) 
