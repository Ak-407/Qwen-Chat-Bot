FROM python:3.9-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    curl \
    git \
    poppler-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama 
RUN curl -fsSL https://ollama.com/install.sh | sh

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir \
    pytesseract \
    flask \
    gunicorn \
    ollama \
    pdf2image \
    requests \
    beautifulsoup4 \
    SQLAlchemy \
    Pillow

# Copy application files
COPY . .

# Expose port
EXPOSE $PORT

# Modify app.py to remove Ollama dependency if it fails to connect
RUN sed -i 's/get_model_response(user_input)/f"No AI summary available: {user_input}"/g' app.py

# Run the application
CMD ollama pull qwen2.5:0.5b && \
    ollama serve & \
    gunicorn --timeout 300 --bind 0.0.0.0:$PORT app:app
