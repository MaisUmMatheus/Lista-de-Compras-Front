import 'dart:convert';
import 'package:applistacompras/Models/page.cadastro.dart';
import 'package:applistacompras/Models/page.listaCompras.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _showRegisterButton = false;

  Future<void> _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        // Nova URL da API
        final url = Uri.parse(
            'http://localhost:8080/ListadeCompra/autenticacao/$username/$password');
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // Login realizado com sucesso, navega para a lista de compras
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login realizado com sucesso!')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ShoppingListPage(
                userName: username, // Usei o username como nome
                userPassword: password, // Senha enviada
              ),
            ),
          );
        } else {
          // Se o status code for diferente de 200, mostra erro
          setState(() {
            _errorMessage = 'Usuário ou senha incorretos';
            _showRegisterButton = true; // Exibe o botão de cadastro
          });
        }
      } catch (e) {
        // Mostra erro de comunicação com a API
        setState(() {
          _errorMessage = 'Erro ao se comunicar com a API: $e';
        });
      }
    } else {
      // Se campos estiverem vazios, exibe mensagem
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone no topo
              Icon(
                Icons.shopping_cart,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Texto de boas-vindas
              Text(
                'Bem-vindo ao Lista de Compras!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Faça login para continuar',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 40),

              // Campo de texto do usuário
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Usuário',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de texto da senha
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Mensagem de erro, se houver
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),

              // Botão de Login e, se falhar, botão de Cadastrar
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão de Login
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Botão laranja
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Botão de Cadastrar (mostra após tentativa falha)
                  if (_showRegisterButton)
                    ElevatedButton(
                      onPressed: () {
                        // Navegar para a página de cadastro
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CadastroPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Botão verde
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Cadastrar',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
