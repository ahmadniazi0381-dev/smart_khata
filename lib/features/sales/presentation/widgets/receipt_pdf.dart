import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/qty.dart';
import '../../data/sale_repository.dart';

class ReceiptPdfHelper {
  ReceiptPdfHelper._();

  static Future<Uint8List> generate(SaleWithDetails details) async {
    final pdf = pw.Document();

    final shopName = details.settings?.shopName ?? 'Smart Khata';
    final shopPhone = details.settings?.phone;
    final shopAddress = details.settings?.address;
    final footer =
        details.settings?.receiptFooter ?? 'Thank you for your business!';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Center(
                child: pw.Text(
                  shopName,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              if (shopPhone != null && shopPhone.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    shopPhone,
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ),
              ],
              if (shopAddress != null && shopAddress.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(
                    shopAddress,
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Invoice:',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    details.sale.invoiceNo,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    AppDateUtils.formatDateTime(details.sale.saleDate),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (details.customer != null) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(
                      details.customer!.name,
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              if (details.sale.status == 'cancelled') ...[
                pw.SizedBox(height: 4),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  alignment: pw.Alignment.center,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.8),
                  ),
                  child: pw.Text(
                    '*** CANCELLED ***',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              // Items header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Item',
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Qty',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Rate',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text('Total',
                        textAlign: pw.TextAlign.right,
                        style: pw.TextStyle(
                            fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              ...details.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(item.productNameSnapshot,
                            style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          Qty.format(item.qtyMilli, item.unitSnapshot),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          Money.format(item.unitPricePaisa),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 7.5),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          Money.format(item.lineTotalPaisa),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 3),
              // Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(Money.format(details.sale.subtotalPaisa),
                      style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (details.sale.discountPaisa > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:',
                        style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('- ${Money.format(details.sale.discountPaisa)}',
                        style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total:',
                      style: pw.TextStyle(
                          fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    Money.format(details.sale.totalPaisa),
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Paid (${details.payment?.method ?? 'Cash'}):',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    Money.format(details.sale.paidPaisa),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (details.sale.duePaisa > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Due / Udhaar:',
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      Money.format(details.sale.duePaisa),
                      style: pw.TextStyle(
                          fontSize: 9, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.8, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  footer,
                  style: const pw.TextStyle(fontSize: 7.5),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<void> printReceipt(SaleWithDetails details) async {
    await Printing.layoutPdf(
      onLayout: (format) => generate(details),
      name: 'receipt_${details.sale.invoiceNo}',
    );
  }

  static Future<void> shareReceipt(SaleWithDetails details) async {
    final pdfBytes = await generate(details);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'receipt_${details.sale.invoiceNo}.pdf',
    );
  }
}
