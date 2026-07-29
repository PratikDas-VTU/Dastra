import sys
import os
import argparse
import fitz  # PyMuPDF

def compress_pdf(input_path, output_path, level):
    try:
        # Open document
        doc = fitz.open(input_path)
        
        # Configure save options based on level
        # Levels: low, medium, high, max
        
        # Base kwargs for fitz.save
        save_kwargs = {
            "garbage": 4, # 4 = clean up unused objects, merge duplicates, delete unused streams
            "clean": True, # sanitize syntax
            "deflate": True, # compress uncompressed streams
        }
        
        if level == "low":
            # Just do lossless garbage collection and deflation, light image optimization
            doc.rewrite_images(dpi_target=150, quality=75)
            
        elif level == "medium":
            # Downsample large images
            save_kwargs["deflate_images"] = True
            save_kwargs["deflate_fonts"] = True
            doc.rewrite_images(dpi_target=100, quality=50)
            
        elif level == "high":
            # Aggressive image compression
            save_kwargs["deflate_images"] = True
            save_kwargs["deflate_fonts"] = True
            save_kwargs["garbage"] = 4
            doc.rewrite_images(dpi_target=72, quality=30)
            
        elif level == "max":
            # Maximum compression (forces grayscale)
            save_kwargs["deflate_images"] = True
            save_kwargs["deflate_fonts"] = True
            save_kwargs["garbage"] = 4
            doc.rewrite_images(dpi_target=72, quality=10, set_to_gray=True)
            
        # Ensure directory exists
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        
        print("Progress: 50")
        
        # Save compressed
        doc.save(output_path, **save_kwargs)
        doc.close()
        
        print("Progress: 100")
        print(f"Success: Saved to {output_path}")
        
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="PDF Compressor Engine for Dastra")
    parser.add_argument("input", help="Input PDF file path")
    parser.add_argument("output", help="Output PDF file path")
    parser.add_argument("--level", choices=["low", "medium", "high", "max"], default="medium", help="Compression level")
    
    args = parser.parse_args()
    
    print("Progress: 10")
    compress_pdf(args.input, args.output, args.level)

if __name__ == "__main__":
    main()
