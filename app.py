# from flask import Flask, render_template, request, jsonify
# import pytesseract
# from PIL import Image, ImageOps, ImageFilter
# from pdf2image import convert_from_bytes
# import os
# import re
# import subprocess
# from io import BytesIO

# app = Flask(__name__)

# # Update Tesseract path if necessary
# pytesseract.pytesseract.tesseract_cmd = '/opt/homebrew/bin/tesseract'

# def preprocess_image(img):
#     """Preprocess image by converting to grayscale, enhancing contrast, and sharpening."""
#     try:
#         img = img.convert("L")  # Grayscale
#         img = ImageOps.autocontrast(img)  # Enhance contrast
#         img = img.filter(ImageFilter.SHARPEN)  # Sharpen
#         return img
#     except Exception as e:
#         app.logger.error(f"Image preprocessing error: {str(e)}")
#         raise

# def clean_ocr_text(text):
#     """Clean OCR output by removing unwanted characters."""
#     text = re.sub(r'[^\w\s.,!?@#&$*()\-+=]+', '', text)
#     text = re.sub(r'\s+', ' ', text).strip()
#     return text

# def get_model_response(user_input):
#     """Get AI model summary from Ollama models."""
#     command = ["ollama", "run", "qwen2.5:0.5b", "summarize this text: " + user_input]
    
#     try:
#         result = subprocess.run(
#             command,
#             input=user_input,
#             capture_output=True,
#             text=True,
#             timeout=300
#         )
        
#         if result.returncode != 0:
#             app.logger.error(f"Model error: {result.stderr}")
#             return "AI summary unavailable at the moment"
        
#         return result.stdout.strip()
#     except subprocess.TimeoutExpired:
#         return "Request timed out. Please try again."
#     except Exception as e:
#         app.logger.error(f"Model error: {str(e)}")
#         return "Error generating summary"

# @app.route('/')
# def index():
#     return render_template('index.html')

# @app.route('/ocr', methods=['POST'])
# def ocr():
#     if 'file' not in request.files:
#         return jsonify({'error': 'No file uploaded'}), 400
    
#     file = request.files['file']
#     if file.filename == '':
#         return jsonify({'error': 'No file selected'}), 400
    
#     try:
#         custom_config = r'--oem 3 --psm 6 -c tessedit_char_whitelist=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,!?@#$%&*()-_+= '
        
#         if file.filename.lower().endswith('.pdf'):
#             # Handle PDF files
#             pdf_bytes = file.read()
#             images = convert_from_bytes(pdf_bytes)
#             all_text = []
            
#             for img in images:
#                 processed_img = preprocess_image(img)
#                 raw_text = pytesseract.image_to_string(processed_img, config=custom_config, lang='eng')
#                 all_text.append(clean_ocr_text(raw_text))
            
#             cleaned_text = '\n'.join(all_text)
#             print(cleaned_text)
#         else:
#             # Handle image files
#             img_bytes = file.read()
#             img = Image.open(BytesIO(img_bytes))
#             processed_img = preprocess_image(img)
#             raw_text = pytesseract.image_to_string(processed_img, config=custom_config, lang='eng')
#             cleaned_text = clean_ocr_text(raw_text)
#             print(cleaned_text)
        
#         if not cleaned_text:
#             return jsonify({'error': 'No text could be extracted from the image'}), 400
        
#         # Get AI summary
#         prompt = f"Please provide a brief 4-line summary of the following text:\n{cleaned_text}"
#         ai_summary = get_model_response(prompt)
#         print(ai_summary)
        
#         return jsonify({
#             'text': cleaned_text,
#             'summary': ai_summary
#         })
        
#     except Exception as e:
#         app.logger.error(f"OCR Processing Error: {str(e)}")
#         return jsonify({'error': f'Error processing file: {str(e)}'}), 500

# @app.route('/chat', methods=['POST'])
# def chat():
#     try:
#         data = request.get_json()
#         if not data or 'message' not in data:
#             return jsonify({"error": "No message provided"}), 400
        
#         user_input = data['message']
#         model_response = get_model_response(user_input)
        
#         return jsonify({"response": model_response})
    
#     except Exception as e:
#         app.logger.error(f"Chat Error: {str(e)}")
#         return jsonify({"error": str(e)}), 500

# if __name__ == '__main__':
#     app.run(debug=True)


import ollama
response = ollama. chat(model="deepseek-rl", messages=[
"role": "user"
"content": "Tell me 5 cyber security good practices",
3,
print(response ["message"] ["content "])
