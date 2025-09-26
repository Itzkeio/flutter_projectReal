import 'package:tsel_ui/login/login.dart';
import 'package:tsel_ui/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Signup extends StatelessWidget {
  Signup({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Container(
       decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFEAF4FF),
          Color(0xFFB7DCF6),
          Color(0xFF7EBEE8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: _signin(context),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 50
        ),
        body: SafeArea(
          child:SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Register Account',
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 32
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 80,),
                _emailAddress(),
                const SizedBox(height: 20,),
                _password(),
                const SizedBox(height: 50),
                _signup(context),
              ],
            ),
          )
          )
      ),
    );
  }

  Widget _emailAddress(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email Address",
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            filled: true,
            hintText: "your-email@gmail.com",
            hintStyle: const TextStyle(
              color: Color(0xff6A6A6A),
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            fillColor: const Color(0xffF7F7F9),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
          ),
        )
      ],
    );
  }

  Widget _password(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            )
          ),
        ),
        const SizedBox(height: 16,),
        TextField(
          controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: 'Your Password',
          filled: true,
          fillColor: const Color(0xffF7F7F9) ,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(14)
            )
        ),
        )
      ],
    );
  }

  Widget _signup(BuildContext context){
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 141, 198, 63),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(14),
        ),
        minimumSize: const Size(double.infinity, 60),
        elevation: 0
      ),
      onPressed: () async{
        await AuthService().signup(
          email: _emailController.text,
          password: _passwordController.text,
          context: context
        );
      },
      child: Text("Sign Up", style: GoogleFonts.raleway(
            textStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold ,
              fontSize: 20
            ),
      ),
      ),
    );
  }

  Widget _signin(BuildContext context){
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            const TextSpan(
              text: "Already have an account ? ",
              style: TextStyle(
                color: Color(0xff6A6A6A),
                fontWeight: FontWeight.normal,
                fontSize: 16
              ),
            ),
            TextSpan(
              text: "Login",
              style: const TextStyle(
                color: Color(0xff1A1D1E),
                fontWeight: FontWeight.normal,
                fontSize: 16
              ),
              recognizer: TapGestureRecognizer()..onTap = (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder:(context) => Login() ),
                  );
              }
            )
          ]
        ),
      ),
    );
  }
}