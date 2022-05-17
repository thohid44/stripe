import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      "pk_test_51KzEChIruxQwsDO6xe45YIoQBhHRIf8cHxLFT8SoeBf6GEFUAD2YQoppqEZg9IgI1WOlcJtDh6QwyrcKZ9nQ1AEO00OUUTfGdz";
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void initState() {
    super.initState();
  }

  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () async {
              await makePayment();
            },
            child: Container(
              height: 50,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Center(
                child: Text("Pay"),
              ),
            ),
          )
        ],
      )),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentInteNt('20', 'USD');
      // if payment is success
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              applePay: true,
              googlePay: true,
              merchantCountryCode: 'US',
              merchantDisplayName: 'Thohid'));

      displayPaymentShee();
    } catch (e) {
      print('exception is' + e.toString());
    }
  }

  displayPaymentShee() async {
    try {
      Stripe.instance.presentPaymentSheet(
          parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ));

      // setState(() {
      //   paymentIntentData = null;
      // });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Paid Successfully")));
    } on StripeException catch (e) {
      print(e.toString());
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Cancelled"),
              ));
    }
  }

  createPaymentInteNt(var amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            'Authorization':
                'sk_test_51KzEChIruxQwsDO6Zqpu8B7ikzAf1usPtNXkBWhuXNm6ztXzPtz4hHHcMFOxnYLNDd7HvXaEDXGaqlfxRI22VZFt00rafJ4KPu',
            'Content-Type': 'application/x-www-form-urlencoded',
          });
      return jsonDecode(response.body.toString());
    } catch (e) {
      print('exception' + e.toString());
    }
  }

  calculateAmount(amount) {
    final price = amount * 100;
    return price.toString();
  }
}
