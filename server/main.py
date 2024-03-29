import base64
from io import BytesIO

import cv2
import numpy as np
import requests
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI()


# Allow CORS for all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ImageRequest(BaseModel):
    image_url: str


def process_image_opencv(image_url: str) -> str:
    try:
        # Fetch the image from the URL
        response = requests.get(image_url)
        response.raise_for_status()
        image_data = BytesIO(response.content)

        # Read the image using OpenCV
        image = cv2.imdecode(
            np.frombuffer(image_data.read(), np.uint8), cv2.IMREAD_COLOR
        )

        # Our image processing code with OpenCV goes here
        # For example, convert the image to grayscale
        gray_image = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

        # Encode the processed image as base64
        _, encoded_image = cv2.imencode(".png", gray_image)
        base64_image = base64.b64encode(encoded_image.tobytes()).decode("utf-8")

        return base64_image

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")


@app.post("/process_image")
def process_image(image_request: ImageRequest):
    result = process_image_opencv(image_request.image_url)
    return {"image": result}
