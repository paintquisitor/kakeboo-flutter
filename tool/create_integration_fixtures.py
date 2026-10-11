"""Synthetic integration inputs; never reads a user's documents."""
from pathlib import Path
from datetime import date
import json
import zipfile
from PIL import Image, ImageDraw, ImageFont
from reportlab.pdfgen import canvas
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

root = Path(__file__).resolve().parents[1] / 'test' / 'fixtures'
root.mkdir(parents=True, exist_ok=True)
font_path = '/System/Library/Fonts/Supplemental/Arial.ttf'
pdfmetrics.registerFont(TTFont('Fixture', font_path))
receipt = Image.new('RGB', (1000, 1100), 'white')
draw = ImageDraw.Draw(receipt)
font = ImageFont.truetype(font_path, 42)
lines = ['SKLEP TESTOWY', 'DANE SYNTETYCZNE', '2026-09-28 12:30', 'PARAGON FISKALNY', 'Chleb          12,50', 'Mleko           7,50', 'SUMA PLN       20,00', 'KARTA          20,00']
for i, line in enumerate(lines):
    draw.text((70, 65 + i * 115), line, fill='black', font=font)
receipt.save(root / 'receipt.png')

pdf = canvas.Canvas(str(root / 'statement.pdf'), pagesize=(595, 842), invariant=1)
pdf.setTitle('Synthetic bank statement - integration fixture')
# Amount is intentionally emitted before the left column in the PDF stream.
# Readers must recover page geometry instead of relying on drawing order.
operations = [
    ('2026-09-28', 'PŁATNOŚĆ KARTĄ', '-20,00 PLN', 'SKLEP TESTOWY'),
    ('2026-09-27', 'PRZELEW', '-1 250,00 PLN', 'Czynsz testowy'),
    ('2026-09-26', 'OSZCZĘDZANIE', '-5,00 PLN', 'Automatyczne oszczędzanie'),
    ('2026-09-25', 'UZNANIE', '+3 000,00 PLN', 'Wpływ testowy'),
]
expected = []
for page in range(2):
    pdf.setFont('Fixture', 11)
    pdf.drawString(36, 804, 'WYCIĄG TESTOWY - wyłącznie dane syntetyczne')
    for index in range(2):
        day, kind, amount, title = operations[page * 2 + index]
        y = 750 - index * 290
        pdf.drawRightString(558, y, amount)
        pdf.drawString(36, y, 'Data operacji ' + kind)
        pdf.drawString(36, y - 24, day)
        pdf.drawString(36, y - 48, 'Data księgowania ' + day)
        pdf.drawString(36, y - 72, 'Tytuł: ' + title)
        expected += ['Data operacji ' + kind + ' ' + amount, day,
                     'Data księgowania ' + day, 'Tytuł: ' + title]
    pdf.showPage()
pdf.save()
(root / 'statement_expected.json').write_text(json.dumps(expected, ensure_ascii=False, indent=2) + '\n')
name = '00000000-0000-4000-8000-000000000001.img'
epoch = (date(2026, 9, 28) - date(1970, 1, 1)).days
backup = dict(format=1, createdAt=1790596800000, tables={
    'monthly_plans': [dict(month='2026-09', savingsGrosz=20000, resolutions='Cel testowy')],
    'custom_categories': [dict(id=41, name='Test', nameKey='test', icon='WALLET')],
    'planned_items': [dict(id=12, month='2026-09', type='EXPENSE', title='Czynsz testowy', amountGrosz=125000, dateEpochDay=epoch, recurrence='MONTHLY', recurrenceAnchorMonth='2026-09', icon='HOME')],
    'custom_subcategories': [dict(id=42, categoryId=41, name='Zakupy testowe', nameKey='zakupy testowe')],
    'entries': [dict(id=101, amountGrosz=2000, type='EXPENSE', dateEpochDay=epoch, note='SKLEP TESTOWY', subcategory=None, plannedItemId=None, receiptName=name, customSubcategoryId=42), dict(id=102, amountGrosz=125000, type='EXPENSE', dateEpochDay=epoch, note='Czynsz testowy', subcategory=None, plannedItemId=12, receiptName=None, customSubcategoryId=None)],
    'monthly_reflections': [dict(month='2026-09', successes='Test', improvements='', nextMonth='')],
}, profileSettings=dict(bookName='Księga testowa', startTab=0, reminderEnabled=False, reminderHour=20, reminderMinute=0))
with zipfile.ZipFile(root / 'legacy_v1.zip', 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('kakebo.json', json.dumps(backup, ensure_ascii=False))
    z.writestr('receipts/' + name, (root / 'receipt.png').read_bytes())
