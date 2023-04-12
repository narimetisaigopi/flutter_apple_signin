import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apple_signin/home_screen.dart';
import 'package:social_login_buttons/social_login_buttons.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AppleSigninScreen extends StatefulWidget {
  const AppleSigninScreen({super.key});

  @override
  State<AppleSigninScreen> createState() => _AppleSigninScreenState();
}

class _AppleSigninScreenState extends State<AppleSigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[10],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SocialLoginButton(
              buttonType: SocialLoginButtonType.apple,
              onPressed: () {
                appleSign();
              },
            )
          ],
        ),
      ),
    );
  }

  void appleSign() async {
    AuthorizationResult authorizationResult =
        await TheAppleSignIn.performRequests([
      const AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (authorizationResult.status) {
      case AuthorizationStatus.authorized:
        print("authorized");
        try {
          AppleIdCredential? appleCredentials = authorizationResult.credential;
          OAuthProvider oAuthProvider = OAuthProvider("apple.com");
          OAuthCredential oAuthCredential = oAuthProvider.credential(
              idToken: String.fromCharCodes(appleCredentials!.identityToken!),
              accessToken:
                  String.fromCharCodes(appleCredentials.authorizationCode!));
          print(appleCredentials.email);
          print(appleCredentials.fullName);
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(oAuthCredential);
          if (userCredential.user != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (builder) => HomeScreen()));
          }
        } catch (e) {
          print("apple auth failed $e");
        }

        break;
      case AuthorizationStatus.error:
        print("error" + authorizationResult.error.toString());
        break;
      case AuthorizationStatus.cancelled:
        print("cancelled");
        break;
      default:
        print("none of the above: default");
        break;
    }
  }
}
