# Base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    PDF_MEMORY_LIMIT=500MB

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    libleptonica-dev \
    poppler-utils \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama
RUN curl -L https://ollama.com/download/ollama-linux-amd64 -o /usr/local/bin/ollama \
    && chmod +x /usr/local/bin/ollama

WORKDIR /app

# Copy requirements first
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir \
    pytesseract \
    flask \
    gunicorn \
    pdf2image \
    Pillow

# Copy application code
COPY . .

# Create startup script
RUN echo '#!/bin/bash\n\
ollama serve &\n\
OLLAMA_PID=$!\n\
\n\
# Wait for Ollama to start\n\
echo "Waiting for Ollama to start..."\n\
until curl -s http://localhost:11434/api/version >/dev/null; do\n\
    sleep 1\n\
done\n\
echo "Ollama is ready!"\n\
\n\
# Start Gunicorn with memory limits\n\
exec gunicorn --timeout 300 \\\n\
    --workers 2 \\\n\
    --worker-class gthread \\\n\
    --threads 4 \\\n\
    --worker-tmp-dir /dev/shm \\\n\
    --bind 0.0.0.0:$PORT \\\n\
    app:app' > /app/start.sh \
    && chmod +x /app/start.sh

# Expose port (use ARG for flexibility)
ARG PORT=8000
ENV PORT=$PORT
EXPOSE $PORT

CMD ["/app/start.sh"]
