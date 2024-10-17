import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShoppingListPage extends StatefulWidget {
  final String userName; // Nome do usuário
  final String userPassword; // Senha do usuário

  const ShoppingListPage({
    Key? key,
    required this.userName,
    required this.userPassword,
  }) : super(key: key);

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _textController = TextEditingController();
  List<dynamic> _items = []; // Lista para armazenar os itens de compras

  @override
  void initState() {
    super.initState();
    _fetchItems(); // Carrega todos os itens ao iniciar a página
  }

  // Função para buscar todos os itens da API
  Future<void> _fetchItems() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/ListadeCompra/todosItens'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _items = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar itens da API')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  // Função para adicionar item à lista de compras via API
  Future<void> _addItem(String newItem) async {
    if (newItem.isNotEmpty) {
      try {
        final url =
            Uri.parse('http://localhost:8080/ListadeCompra/cadastrarItem');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(newItem),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item adicionado com sucesso')),
          );
          _fetchItems(); // Atualiza a lista após adicionar o item
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao adicionar item à API')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }

      _textController.clear(); // Limpa o campo de texto após adicionar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um item válido')),
      );
    }
  }

  // Função para excluir um item da lista de compras via API
  Future<void> _deleteItem(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/ListadeCompra/$id'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removido com sucesso')),
        );
        _fetchItems(); // Atualiza a lista após deletar o item
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao remover item da API')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibindo o nome e a senha do usuário no canto superior
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Usuário: ${widget.userName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Senha: ${widget.userPassword}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Campo de texto para adicionar novo item
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'Digite o item',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            // Botão central para adicionar item
            ElevatedButton(
              onPressed: () {
                _addItem(_textController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange, // Cor do botão
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 20), // Tamanho do botão
              ),
              child: const Text(
                'Adicionar Item',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Exibindo a lista de itens adicionados logo abaixo
            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('Nenhum item na lista'),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        // print(item);
                        // final String itemName = item['Itens'] ?? 'Item desconhecido';
                        // final int itemId = item['id'] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(item['itens']),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteItem(
                                    item['id']); // Chama a função de deletar
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
