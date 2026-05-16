# Scanner Sample

This sample is a focused barcode scanning app.

- Uses the camera preview as the live view
- Press `Enter` to capture and scan
- Press `Backspace` to exit the page
- Shows the decoded barcode result in a minimal scanner UI

## Notes

- If no barcode is found, the page shows a non-error empty result state

## WebP Decode

- The scanner decodes camera WebP captures with a pure JavaScript implementation before calling `BarcodeDetector.detect(...)`
- It uses a pure JavaScript WebP decoder so barcode scanning can still work on runtime versions that do not provide `Blob` or `ImageData`
- The vendored decoder lives in `samples/scanner/lib/vendor/webpjs`

## Credits

- The vendored `webpjs` files come from the upstream `webpjs` package, which packages the library created by Dominik Homberger
- Thanks to Dominik Homberger and the `webpjs` project for making a pure JavaScript WebP decoder available for compatibility-focused runtimes
