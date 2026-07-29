from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter

c = canvas.Canvas("sample_resume.pdf", pagesize=letter)
c.setFont("Helvetica-Bold", 20)
c.drawString(100, 750, "John Doe - Senior Engineer")
c.setFont("Helvetica", 12)
c.drawString(100, 720, "Experience: 10+ years in software development.")
c.drawString(100, 700, "Skills: Python, Dart, Rust, C++")
c.rect(100, 680, 400, 2, fill=1)
c.drawString(100, 650, "This is a real PDF document used for end-to-end testing of Dastra PDF to Word tool.")
c.save()
