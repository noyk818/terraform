from reportlab.pdfgen import canvas

# 正常なPDFを作成
output_path = "test.pdf"
c = canvas.Canvas(output_path)
c.drawString(100, 750, "This is a test PDF.")
c.save()

# 一部だけ読み込んで壊れたPDFを作成
with open(output_path, "rb") as f:
    data = f.read()

# 途中で切って壊れたPDFにする
broken_data = data[:int(len(data) / 2)]

with open("broken.pdf", "wb") as f:
    f.write(broken_data)
