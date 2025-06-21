#!/usr/bin/env python3
"""
Test script for OCR functionality
"""

import requests
import json
from PIL import Image
import io

def test_ocr_endpoint():
    """Test the OCR endpoint with a sample image"""
    
    # Test the OCR endpoint
    url = "http://localhost:8000/ocr/test"
    
    try:
        response = requests.post(url)
        print(f"Test endpoint response: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error testing OCR endpoint: {e}")

def test_ocr_with_sample_image():
    """Test OCR with a sample image (you'll need to provide an image file)"""
    
    # Create a simple test image
    img = Image.new('RGB', (100, 100), color='white')
    img_byte_arr = io.BytesIO()
    img.save(img_byte_arr, format='JPEG')
    img_byte_arr = img_byte_arr.getvalue()
    
    url = "http://localhost:8000/ocr/receipt"
    
    try:
        files = {"file": ("test.jpg", img_byte_arr, "image/jpeg")}
        response = requests.post(url, files=files)
        print(f"OCR endpoint response: {response.status_code}")
        print(f"Response: {response.json()}")
    except Exception as e:
        print(f"Error testing OCR with image: {e}")

if __name__ == "__main__":
    print("Testing OCR functionality...")
    test_ocr_endpoint()
    print("\n" + "="*50 + "\n")
    test_ocr_with_sample_image() 