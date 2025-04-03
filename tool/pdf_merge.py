#-----------------------------------------
# PDFファイルを結合する
# 使い方
# 1. pypdfをインストールする
#    pip install pypdf
# 2. 結合したいPDFファイルと出力先を指定する
#    pdf_files = ["test.pdf", "test.pdf", "test.pdf", "test.pdf"]
#    output_pdf = "merged.pdf"
# 3. このスクリプトを実行する
#    python pdf_merge.py
#-----------------------------------------

from pypdf import PdfWriter

def merge_pdfs(input_files, output_file):
    pdf_writer = PdfWriter()

    for pdf in input_files:
        pdf_writer.append(pdf)

    with open(output_file, "wb") as out:
        pdf_writer.write(out)

    print(f"PDF merge completed: {output_file}")

pdf_files = ["test.pdf", "test.pdf", "test.pdf", "test.pdf"]
output_pdf = "merged.pdf"
merge_pdfs(pdf_files, output_pdf)

