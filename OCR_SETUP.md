# OCR Receipt Scanning Setup Guide

This guide explains how to set up and use the OCR (Optical Character Recognition) functionality for scanning receipts and automatically adding items to your inventory.

## Features

- **Camera Integration**: Take photos of receipts directly from the app
- **Gallery Selection**: Choose existing receipt images from your device
- **Automatic Text Extraction**: Extract item names, quantities, and prices from receipts
- **Item Selection**: Choose which extracted items to add to your inventory
- **Automatic Inventory Addition**: Add selected items directly to your inventory

## Backend Setup

### 1. Install Python Dependencies

Navigate to the `backEnd` directory and install the required packages:

```bash
cd backEnd
pip install -r requirements.txt
```

### 2. Start the Backend Server

```bash
cd backEnd
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Test OCR Functionality

Run the test script to verify OCR is working:

```bash
cd backEnd
python test_ocr.py
```

## Flutter App Setup

### 1. Install Dependencies

The following dependencies have been added to `pubspec.yaml`:

- `camera: ^0.10.5+9` - For camera functionality
- `permission_handler: ^11.3.1` - For handling permissions

Run the following command to install dependencies:

```bash
flutter pub get
```

### 2. Android Permissions

The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:

- `android.permission.CAMERA` - Camera access
- `android.permission.READ_EXTERNAL_STORAGE` - Read storage access
- `android.permission.WRITE_EXTERNAL_STORAGE` - Write storage access
- `android.permission.INTERNET` - Internet access

## How to Use

### 1. Access OCR Functionality

1. Open the LILI app
2. Navigate to the Inventory section
3. Tap "Add New Item"
4. Look for the camera icon in the top-right corner
5. Tap the camera icon to start receipt scanning

### 2. Choose Image Source

When you tap the camera icon, you'll see two options:

- **Camera**: Take a new photo of your receipt
- **Gallery**: Select an existing receipt image from your device

### 3. Process Receipt

1. Select your preferred image source
2. Take or select a clear image of your receipt
3. The app will automatically process the image using OCR
4. Wait for the processing to complete

### 4. Select Items

1. Review the extracted items from your receipt
2. Check the boxes next to items you want to add to your inventory
3. Tap "Add Selected" to proceed

### 5. Confirm Items

1. For each selected item, you'll see a confirmation dialog
2. Review the item details (name, quantity, price)
3. Choose "Add" to add the item or "Skip" to skip it
4. The first item will automatically pre-fill the form fields

## OCR API Configuration

The OCR functionality uses the Asprise OCR API. In the current setup:

- **Test Mode**: Uses the 'TEST' API key for development
- **Production**: Replace 'TEST' with your actual Asprise API key

### To get your own API key:

1. Visit [Asprise OCR API](https://ocr.asprise.com/)
2. Sign up for an account
3. Get your API key
4. Replace 'TEST' in `backEnd/app/routes/ocr_routes.py` with your actual key

## Troubleshooting

### Common Issues

1. **OCR Service Unavailable**
   - Ensure the backend server is running
   - Check your internet connection
   - Verify the API key is correct

2. **No Items Found**
   - Try with a clearer, better-lit image
   - Ensure the receipt text is clearly visible
   - Try different angles or lighting

3. **Permission Denied**
   - Grant camera and storage permissions when prompted
   - Check app settings if permissions were denied

4. **Backend Connection Issues**
   - Verify the backend URL in `lib/services/ocr_service.dart`
   - Ensure the backend server is running on the correct port
   - Check firewall settings

### Testing

To test the OCR functionality:

1. Start the backend server
2. Run the Flutter app
3. Use the test script: `python backEnd/test_ocr.py`
4. Try scanning a clear receipt image

## File Structure

```
lib/
├── services/
│   └── ocr_service.dart          # OCR service for API calls
├── pages/
│   ├── receipt_scan_dialog.dart  # Camera/gallery selection dialog
│   ├── extracted_items_dialog.dart # Item selection dialog
│   └── add_new_iteminventory_page.dart # Updated with OCR integration

backEnd/
├── app/
│   ├── routes/
│   │   └── ocr_routes.py         # OCR API endpoints
│   └── main.py                   # Updated with OCR routes
├── requirements.txt              # Python dependencies
└── test_ocr.py                   # Test script
```

## API Endpoints

- `POST /ocr/test` - Test OCR service connection
- `POST /ocr/receipt` - Process receipt image and extract text

## Security Notes

- The current implementation uses the test API key
- For production, use your own API key
- Consider implementing rate limiting
- Add proper error handling and validation
- Consider adding image compression for better performance

## Future Enhancements

- Add support for multiple receipt formats
- Implement offline OCR processing
- Add receipt image quality validation
- Implement batch processing for multiple receipts
- Add receipt storage and history
- Implement automatic category detection 