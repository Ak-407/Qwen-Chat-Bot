FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    curl \
    git \
    poppler-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Create a modified version of app.py
RUN echo 'from flask import Flask, render_template, request, jsonify\n\
import pytesseract\n\
from PIL import Image, ImageOps, ImageFilter\n\
from pdf2image import convert_from_bytes\n\
import os\n\
import re\n\
from io import BytesIO\n\
\n\
app = Flask(__name__)\n\
\n\
def get_model_response(user_input):\n\
    try:\n\
        return f"No AI summary available: {user_input}"\n\
    except Exception as e:\n\
        return f"Error: {str(e)}"\n\
\n\
@app.route("/")\n\
def index():\n\
    return render_template("index.html")\n\
\n\
@app.route("/ocr", methods=["POST"])\n\
def ocr():\n\
    if "file" not in request.files:\n\
        return jsonify({"error": "No file uploaded"}), 400\n\
    \n\
    file = request.files["file"]\n\
    if file.filename == "":\n\
        return jsonify({"error": "No file selected"}), 400\n\
    \n\
    try:\n\
        if file.filename.lower().endswith(".pdf"):\n\
            pdf_bytes = file.read()\n\
            images = convert_from_bytes(pdf_bytes)\n\
            text = "\\n".join([pytesseract.image_to_string(img) for img in images])\n\
        else:\n\
            img = Image.open(BytesIO(file.read()))\n\
            text = pytesseract.image_to_string(img)\n\
        \n\
        return jsonify({\n\
            "text": text,\n\
            "summary": get_model_response(text)\n\
        })\n\
    except Exception as e:\n\
        return jsonify({"error": str(e)}), 500\n\
\n\
if __name__ == "__main__":\n\
    app.run(debug=True)' > app.py

RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir pytesseract flask gunicorn ollama pdf2image requests beautifulsoup4 SQLAlchemy Pillow

EXPOSE $PORT

CMD gunicorn --timeout 300 --bind 0.0.0.0:$PORT app:app
