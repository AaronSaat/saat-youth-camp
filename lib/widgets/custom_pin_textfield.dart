import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CustomPinTextfield extends StatelessWidget {
  const CustomPinTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: 6, // jumlah digit OTP
      obscureText: false,
      animationType: AnimationType.fade,
      keyboardType: TextInputType.number,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 50,
        fieldWidth: 40,
        activeFillColor: Colors.white,
        selectedFillColor: Colors.white,
        inactiveFillColor: Colors.white,
        activeColor: Colors.blue,
        selectedColor: Colors.blue,
        inactiveColor: Colors.grey,
      ),
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      onCompleted: (otp) {
        print('OTP entered: $otp');
        // Lakukan verifikasi OTP di sini
      },
      onChanged: (value) {},
    );
  }
}
