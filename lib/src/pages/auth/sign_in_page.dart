import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gopizza/src/network/api.dart';
import 'package:gopizza/src/pages/auth/sign_up_page.dart';
import 'package:gopizza/src/pages/components/custom_text_field.dart';
import 'package:gopizza/src/pages/home/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base/base_app.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  var email;
  var password;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.red,
        body: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              children: [
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 40),
                        children: [
                          TextSpan(
                            text: "UTF",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "Pizza",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
                // Formulário login
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Campo de e-mail
                        CustomTextField(
                          icon: Icons.email,
                          label: 'E-mail',
                          validator: (value) {
                            String emailValue = value.toString();
                            bool emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(emailValue);
                            if (!emailValid) {
                              return 'Campo inválido.';
                            }
                            email = emailValue;
                            return null;
                          },
                        ),
                        // Campo de senha
                        CustomTextField(
                          icon: Icons.lock,
                          label: 'Senha',
                          isSecret: true,
                          validator: (value) {
                            if (value!.length < 6) {
                              return 'Campo inválido.';
                            }
                            password = value.toString();
                            return null;
                          },
                        ),
                        // Botão entrar
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _login();
                              }
                            },
                            child: Text(
                              _isLoading ? 'Processando...' : 'Entrar',
                              style: const TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        // Esqueceu a senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Esqueceu a senha?",
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        // Divisor
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.withAlpha(90),
                                  thickness: 2,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text("Ou"),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.withAlpha(90),
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Botão criar conta
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(width: 2, color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  18,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (c) {
                                    return SignUpScreen();
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Criar conta",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _login() async {
    setState(() {
      _isLoading = true;
    });
    var data = {'email': email, 'password': password};

    var res = await Network().authData(data, '/login');
    var body = json.decode(res.body);
    if (body['success'] == true) {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      localStorage.setString('token', json.encode(body['token']));
      localStorage.setString('user', json.encode(body['user']));
      Navigator.push(
        context,
        new MaterialPageRoute(builder: (context) => BaseScreen()),
      );
    } else {
      print(body);
    }

    setState(() {
      _isLoading = false;
    });
  }
}
