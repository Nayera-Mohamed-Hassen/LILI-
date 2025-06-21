#!/usr/bin/env python3
"""
Demo script for OCR functionality
This script demonstrates how the OCR system works with sample data
"""

import json
import requests
from PIL import Image, ImageDraw, ImageFont
import io

def create_sample_receipt():
    """Create a sample receipt image for testing"""
    
    # Create a white background
    img = Image.new('RGB', (400, 600), color='white')
    draw = ImageDraw.Draw(img)
    
    # Try to use a default font, fallback to default if not available
    try:
        font = ImageFont.truetype("arial.ttf", 16)
    except:
        font = ImageFont.load_default()
    
    # Sample receipt text
    receipt_text = [
        "GROCERY STORE",
        "123 Main Street",
        "City, State 12345",
        "",
        "Date: 2024-01-15",
        "Time: 14:30:25",
        "",
        "Items:",
        "1. Milk 2L - $3.99",
        "2. Bread - $2.49",
        "3. Eggs (12) - $4.99",
        "4. Bananas 1kg - $1.99",
        "5. Yogurt - $2.99",
        "",
        "Subtotal: $16.45",
        "Tax: $1.32",
        "Total: $17.77",
        "",
        "Thank you for shopping!",
        "Please come again!"
    ]
    
    # Draw text on image
    y_position = 20
    for line in receipt_text:
        draw.text((20, y_position), line, fill='black', font=font)
        y_position += 25
    
    return img

def demo_ocr_processing():
    """Demonstrate OCR processing with sample receipt"""
    
    print("=== OCR Receipt Scanning Demo ===")
    print()
    
    # Create sample receipt
    print("1. Creating sample receipt image...")
    receipt_img = create_sample_receipt()
    
    # Save to bytes
    img_byte_arr = io.BytesIO()
    receipt_img.save(img_byte_arr, format='JPEG')
    img_byte_arr = img_byte_arr.getvalue()
    
    print("2. Sample receipt created successfully!")
    print("   - Store: GROCERY STORE")
    print("   - Items: Milk, Bread, Eggs, Bananas, Yogurt")
    print("   - Total: $17.77")
    print()
    
    # Test OCR endpoint
    print("3. Testing OCR endpoint...")
    url = "http://localhost:8000/ocr/receipt"
    
    try:
        files = {"file": ("sample_receipt.jpg", img_byte_arr, "image/jpeg")}
        response = requests.post(url, files=files, timeout=30)
        
        if response.status_code == 200:
            result = response.json()
            print("   ✓ OCR processing successful!")
            print()
            
            # Display extracted information
            print("4. Extracted Information:")
            print(f"   Store: {result.get('store_name', 'Not detected')}")
            print(f"   Date: {result.get('date', 'Not detected')}")
            print(f"   Total Amount: ${result.get('total_amount', 0):.2f}")
            print()
            
            # Display extracted items
            items = result.get('items', [])
            if items:
                print("   Extracted Items:")
                for i, item in enumerate(items, 1):
                    print(f"   {i}. {item.get('name', 'Unknown')}")
                    print(f"      Quantity: {item.get('quantity', 1)}")
                    print(f"      Price: ${item.get('amount', 0):.2f}")
                    print()
            else:
                print("   No items extracted from receipt")
                print()
                
        else:
            print(f"   ✗ OCR processing failed: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("   ✗ Cannot connect to OCR service")
        print("   Make sure the backend server is running on localhost:8000")
    except Exception as e:
        print(f"   ✗ Error: {e}")
    
    print("5. Demo completed!")
    print()
    print("To use this in your Flutter app:")
    print("1. Start the backend server: python -m uvicorn app.main:app --reload")
    print("2. Run the Flutter app")
    print("3. Navigate to Add New Item in Inventory")
    print("4. Tap the camera icon to scan receipts")

def demo_api_response():
    """Show what the API response structure looks like"""
    
    print("=== API Response Structure ===")
    print()
    
    sample_response = {
        "items": [
            {
                "name": "Milk 2L",
                "quantity": 1,
                "amount": 3.99,
                "unit_price": 3.99
            },
            {
                "name": "Bread",
                "quantity": 1,
                "amount": 2.49,
                "unit_price": 2.49
            },
            {
                "name": "Eggs (12)",
                "quantity": 1,
                "amount": 4.99,
                "unit_price": 4.99
            }
        ],
        "total_amount": 17.77,
        "store_name": "GROCERY STORE",
        "date": "2024-01-15",
        "raw_text": "GROCERY STORE\n123 Main Street\n..."
    }
    
    print("Sample API Response:")
    print(json.dumps(sample_response, indent=2))
    print()
    
    print("This response is automatically parsed by the Flutter app")
    print("and displayed in the item selection dialog.")

if __name__ == "__main__":
    print("LILI OCR Receipt Scanning Demo")
    print("=" * 40)
    print()
    
    demo_ocr_processing()
    print()
    demo_api_response() 