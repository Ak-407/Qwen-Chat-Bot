# Use a Python base image
FROM python:3.9-slim

# Install necessary dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    curl \
    git

# Install Ollama
RUN curl -fsSL https://ollama.com/install.sh | bash

# Ensure the installation of Ollama is available
RUN echo 'export PATH=$PATH:/root/.ollama' >> ~/.bashrc

# Install Python dependencies
RUN pip install --upgrade pip
RUN pip install pytesseract flask gunicorn

# Set up the working directory
WORKDIR /app
COPY . /app

# Expose the port the app will run on
EXPOSE 5000

# Start the application with Gunicorn
CMD ["gunicorn", "app:app", "--bind", "0.0.0.0:5000"]
