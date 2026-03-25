import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class InvoiceHelper {
  static Future<void> generateAndPrintInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();

    final List items = order['items'] ?? [];
    final date = order['createdAt'] != null 
        ? (order['createdAt'] as dynamic).toDate() 
        : DateTime.now();
    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final boldFont = await PdfGoogleFonts.nunitoBold();

    final double subtotal = (order['subtotal'] ?? 0.0).toDouble();
    final double discount = (order['discount'] ?? 0.0).toDouble() + (order['pointsDiscount'] ?? 0.0).toDouble();
    final double deliveryFee = (order['deliveryFee'] ?? 0.0).toDouble();
    final double total = (order['totalAmount'] ?? 0.0).toDouble();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('PAYKARI BAZAR', style: pw.TextStyle(font: boldFont, fontSize: 22, color: PdfColors.deepPurple900)),
                        pw.Text('Your Trusted Local Partner', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey700)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 20)),
                        pw.Text('#${order['id'].toString().substring(0, 8).toUpperCase()}', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('BILL TO:', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        pw.Text(order['customerName']?.toString() ?? 'Guest', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                        pw.Text(order['customerPhone']?.toString() ?? ''),
                        pw.Container(width: 200, child: pw.Text(order['deliveryAddress']?.toString() ?? '', style: const pw.TextStyle(fontSize: 10))),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('ORDER DATE:', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        pw.Text(formattedDate, style: const pw.TextStyle(fontSize: 12)),
                        pw.SizedBox(height: 8),
                        pw.Text('PAYMENT METHOD:', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                        pw.Text(order['paymentMethod'] ?? 'COD', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                  headerStyle: pw.TextStyle(font: boldFont, color: PdfColors.white),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple900),
                  headers: ['Product Name', 'Qty', 'Price', 'Subtotal'],
                  cellAlignment: pw.Alignment.centerLeft,
                  data: items.map((item) => [
                    item['productName']?.toString() ?? 'Item',
                    '${item['quantity']}',
                    '৳${item['price']}',
                    '৳${(item['price'] * item['quantity']).toInt()}',
                  ]).toList(),
                ),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Container(
                      width: 200,
                      child: pw.Column(
                        children: [
                          _buildSummaryRow('Subtotal:', '৳${subtotal.toInt()}', font),
                          if (discount > 0) _buildSummaryRow('Total Discount:', '- ৳${discount.toInt()}', font),
                          _buildSummaryRow('Delivery Fee:', '+ ৳${deliveryFee.toInt()}', font),
                          pw.Divider(color: PdfColors.grey400),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('GRAND TOTAL:', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                              pw.Text('৳${total.toInt()}', style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColors.deepPurple900)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Center(child: pw.Text('This is a computer-generated invoice. No signature required.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500))),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text('Thank you for shopping with Paykari Bazar!', style: pw.TextStyle(font: boldFont, fontSize: 10))),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildSummaryRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10)),
        ],
      ),
    );
  }
}
