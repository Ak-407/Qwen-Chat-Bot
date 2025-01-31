# Use a Python base image
FROM python:3.9-slim

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    curl \
    git \
    poppler-utils && apt-get clean

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Ensure the installation of Ollama is available
ENV PATH=$PATH:/root/.ollama

# Set up the working directory
WORKDIR /app

# Copy the requirements.txt and install dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r /app/requirements.txt
RUN pip install pytesseract flask gunicorn ollama pytesseract pdf2image requests beautifulsoup4 SQLAlchemy Pillow 

# Copy the application code
COPY . /app

# Run Ollama with the desired model (qwen2.5:0.5b)
CMD ollama pull qwen2.5:0.5b & gunicorn app:app --bind 0.0.0.0:5000
