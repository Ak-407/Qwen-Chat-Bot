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

# Copy application files first
COPY . .

# Install Python dependencies
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

# Modify get_model_response function to handle Ollama connection issues
RUN sed -i 's/def get_model_response(user_input):/def get_model_response(user_input):\n    try:/' app.py && \
    sed -i 's/        return result.stdout.strip()/        return result.stdout.strip()\n    except Exception as e:\n        print(f"Ollama error: {e}")\n        return f"No AI summary available: {user_input}"/' app.py

# Expose port
EXPOSE $PORT

# Run the application
CMD ollama pull qwen2.5:0.5b && \
    ollama serve & \
    gunicorn --timeout 300 --bind 0.0.0.0:$PORT app:app
