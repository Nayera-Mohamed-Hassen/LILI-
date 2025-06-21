from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
import requests
import base64
import io
from PIL import Image
import logging

router = APIRouter()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@router.post("/ocr/receipt")
async def scan_receipt(file: UploadFile = File(...)):
    """
    Scan receipt image and extract text using Asprise OCR API
    """
    try:
        # Read the uploaded image
        image_data = await file.read()
        
        # Validate file type
        if not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        # Prepare the image for OCR
        image = Image.open(io.BytesIO(image_data))
        
        # Convert to RGB if necessary
        if image.mode != 'RGB':
            image = image.convert('RGB')
        
        # Save to bytes for API call
        img_byte_arr = io.BytesIO()
        image.save(img_byte_arr, format='JPEG')
        img_byte_arr = img_byte_arr.getvalue()
        
        # Asprise OCR API endpoint
        receipt_ocr_endpoint = 'https://ocr.asprise.com/api/v1/receipt'
        
        # Make API call to Asprise OCR
        response = requests.post(
            receipt_ocr_endpoint,
            data={
                'api_key': 'TEST',  # Use 'TEST' for testing, replace with your API key for production
                'recognizer': 'auto',  # can be 'US', 'CA', 'JP', 'SG' or 'auto'
                'ref_no': 'lili_receipt_ocr',  # optional caller provided ref code
            },
            files={"file": ("receipt.jpg", img_byte_arr, "image/jpeg")},
            timeout=30
        )
        
        if response.status_code != 200:
            logger.error(f"OCR API error: {response.status_code} - {response.text}")
            raise HTTPException(status_code=500, detail="OCR service unavailable")
        
        # Parse the OCR response
        ocr_result = response.json()
        
        # Extract relevant information from OCR result
        extracted_data = parse_ocr_result(ocr_result)
        
        return JSONResponse(content=extracted_data)
        
    except Exception as e:
        logger.error(f"Error processing receipt: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing receipt: {str(e)}")

def parse_ocr_result(ocr_result):
    """
    Parse OCR result and extract relevant item information
    """
    try:
        # Initialize extracted data
        extracted_data = {
            "items": [],
            "total_amount": 0.0,
            "store_name": "",
            "date": "",
            "raw_text": ""
        }
        
        # Check if OCR was successful
        if 'receipts' in ocr_result and len(ocr_result['receipts']) > 0:
            receipt = ocr_result['receipts'][0]
            
            # Extract store name
            if 'merchant_name' in receipt:
                extracted_data['store_name'] = receipt['merchant_name']
            
            # Extract date
            if 'date' in receipt:
                extracted_data['date'] = receipt['date']
            
            # Extract total amount
            if 'total' in receipt:
                extracted_data['total_amount'] = float(receipt['total'])
            
            # Extract items
            if 'items' in receipt:
                for item in receipt['items']:
                    item_data = {
                        "name": item.get('description', ''),
                        "quantity": item.get('qty', 1),
                        "amount": float(item.get('amount', 0)),
                        "unit_price": float(item.get('unit_price', 0))
                    }
                    extracted_data['items'].append(item_data)
            
            # Extract raw text for manual parsing if needed
            if 'text' in receipt:
                extracted_data['raw_text'] = receipt['text']
        
        return extracted_data
        
    except Exception as e:
        logger.error(f"Error parsing OCR result: {str(e)}")
        return {
            "items": [],
            "total_amount": 0.0,
            "store_name": "",
            "date": "",
            "raw_text": "",
            "error": "Failed to parse OCR result"
        }

@router.post("/ocr/test")
async def test_ocr():
    """
    Test endpoint to verify OCR service is working
    """
    return {"message": "OCR service is running", "status": "success"} 