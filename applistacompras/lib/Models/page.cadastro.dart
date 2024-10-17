import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final String nome;
  final String senha;

  const User({
    required this.nome,
    required this.senha,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        nome: json["nome"],
        senha: json["senha"],
      );

  Map<String, dynamic> toJson() => {
        "nome": nome,
        "senha": senha,
      };
}

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _errorMessage;

  // Função para realizar o cadastro via API
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword) {
      try {
        // Criar instância do User
        User newUser = User(nome: name, senha: password);

        // Enviar os dados para a API
        final url =
            Uri.parse('http://localhost:8080/ListadeCompra/cadastrarUsuario');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newUser.toJson()),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cadastro realizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _clearFields();
        } else {
          setState(() {
            _errorMessage =
                'Erro ao realizar cadastro. Código: ${response.statusCode}';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Erro de conexão com a API: $e';
        });
      }
    } else {
      setState(() {
        _errorMessage =
            'Verifique se todos os campos estão preenchidos corretamente.';
      });
    }
  }

  // Função para limpar os campos
  void _clearFields() {
    _nameController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text('Cadastro'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Campo de texto para o nome
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    prefixIcon: const Icon(Icons.person, color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de texto para a senha
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

              // Campo de texto para confirmar a senha
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Confirmar Senha',
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

              // Botão de cadastrar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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
        ),
      ),
    );
  }
}
