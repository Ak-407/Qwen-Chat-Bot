from flask import Flask, render_template, request, jsonify
import pytesseract
from PIL import Image, ImageOps, ImageFilter
from pdf2image import convert_from_bytes
import os
import re
import subprocess
import time
from io import BytesIO

app = Flask(__name__)

def preprocess_image(img):
    """Preprocess image with memory-efficient operations."""
    try:
        # Convert to small size if too large
        max_size = 2000
        if img.size[0] > max_size or img.size[1] > max_size:
            ratio = max_size / max(img.size)
            img = img.resize((int(img.size[0] * ratio), int(img.size[1] * ratio)))
        
        img = img.convert("L")  # Grayscale
        img = ImageOps.autocontrast(img)
        img = img.filter(ImageFilter.SHARPEN)
        return img
    except Exception as e:
        app.logger.error(f"Image preprocessing error: {str(e)}")
        raise

def get_model_response(user_input, max_retries=3):
    """Get AI model response with retry logic."""
    for attempt in range(max_retries):
        try:
            command = ["ollama", "run", "qwen2.5:0.5b", "summarize this text: " + user_input]
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                timeout=60  # Reduced timeout
            )
            
            if result.returncode == 0:
                return result.stdout.strip()
            
            app.logger.error(f"Ollama error (attempt {attempt + 1}): {result.stderr}")
            time.sleep(2)  # Wait before retry
            
        except subprocess.TimeoutExpired:
            app.logger.error(f"Timeout (attempt {attempt + 1})")
            if attempt == max_retries - 1:
                return "Request timed out. Please try again."
            time.sleep(2)
        except Exception as e:
            app.logger.error(f"Model error (attempt {attempt + 1}): {str(e)}")
            if attempt == max_retries - 1:
                return f"Error generating summary: {str(e)}"
            time.sleep(2)
    
    return "Unable to generate summary after multiple attempts"

@app.route('/ocr', methods=['POST'])
def ocr():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    try:
        if file.filename.lower().endswith('.pdf'):
            pdf_bytes = file.read()
            # Memory-optimized PDF conversion
            images = convert_from_bytes(
                pdf_bytes,
                dpi=200,  # Lower DPI
                thread_count=2,  # Limit threads
                memory_limit=int(os.getenv('PDF_MEMORY_LIMIT', 500)) * 1024 * 1024  # Convert MB to bytes
            )
            
            all_text = []
            for img in images:
                processed_img = preprocess_image(img)
                text = pytesseract.image_to_string(processed_img)
                all_text.append(text)
                # Explicitly clear memory
                processed_img.close()
                img.close()
            
            cleaned_text = '\n'.join(all_text)
        else:
            img_bytes = file.read()
            img = Image.open(BytesIO(img_bytes))
            processed_img = preprocess_image(img)
            cleaned_text = pytesseract.image_to_string(processed_img)
            processed_img.close()
            img.close()
        
        if not cleaned_text.strip():
            return jsonify({'error': 'No text could be extracted from the image'}), 400
        
        # Get AI summary
        ai_summary = get_model_response(cleaned_text)
        
        return jsonify({
            'text': cleaned_text,
            'summary': ai_summary
        })
        
    except Exception as e:
        app.logger.error(f"OCR Processing Error: {str(e)}")
        return jsonify({'error': f'Error processing file: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True)
