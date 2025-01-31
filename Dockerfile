FROM python:3.9-slim

# Create a non-root user
RUN useradd -m myuser

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

# Copy requirements and install Python dependencies
COPY --chown=myuser:myuser requirements.txt .
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
COPY --chown=myuser:myuser . .

# Switch to non-root user
USER myuser

# Expose port
EXPOSE 5000

# Run the application
CMD ollama pull qwen2.5:0.5b && ollama serve & gunicorn --bind 0.0.0.0:$PORT app:app
