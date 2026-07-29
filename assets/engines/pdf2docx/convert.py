import sys
import json
from pdf2docx import Converter

def main():
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Usage: convert.py <input.pdf> <output.docx>"}))
        sys.exit(1)

    input_pdf = sys.argv[1]
    output_docx = sys.argv[2]

    try:
        cv = Converter(input_pdf)
        cv.convert(output_docx)
        cv.close()
        print(json.dumps({"status": "success", "input": input_pdf, "output": output_docx}))
        sys.exit(0)
    except Exception as e:
        print(json.dumps({"error": str(e)}))
        sys.exit(1)

if __name__ == "__main__":
    main()
