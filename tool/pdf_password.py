#-----------------------------------------
# PDFにパスワードを設定する
# 使い方
# 1. PyPDF2をインストールする
#    pip install PyPDF2
# 2. 入力ファイルと出力ファイルのパスを指定する
#    input_pdf_path = "input.pdf"
#    output_pdf_path = "protected.pdf"
# 3. このスクリプトを実行する
#    python pdf_password.py
#-----------------------------------------

from PyPDF2 import PdfReader, PdfWriter

# 入力ファイルと出力ファイルのパス
input_pdf_path = "input.pdf"
output_pdf_path = "protected.pdf"

# 既存のPDFを読み込む
reader = PdfReader(input_pdf_path)
writer = PdfWriter()

# すべてのページを追加
for page in reader.pages:
    writer.add_page(page)

# パスワードを設定（ユーザーには閲覧のみ許可）
writer.encrypt(user_password="user123", owner_password="owner123", use_128bit=True)

# 保護されたPDFを保存
with open(output_pdf_path, "wb") as f:
    writer.write(f)

print("コピーガード付きのPDFを作成しました。")
