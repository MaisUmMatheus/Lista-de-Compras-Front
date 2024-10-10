import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Classe Compras já existente
class Compras {
  final int Id;
  final String Itens;
  final bool Comprado;
  final int UserId;

  Compras({
    required this.Id,
    required this.Itens,
    required this.Comprado,
    required this.UserId,
  });

  factory Compras.fromJson(Map<String, dynamic> json) => Compras(
        Id: json["Id"],
        Itens: json["Itens"],
        Comprado: json["Comprado"],
        UserId: json["UserId"],
      );

  Map<String, dynamic> toJson() => {
        "Id": Id,
        "Itens": Itens,
        "Comprado": Comprado,
        "UserId": UserId,
      };
}

class ShoppingListPage extends StatefulWidget {
  final int userId;
  final String? userName; // Nome do usuário (agora pode ser null)
  final String? userPassword; // Senha do usuário (agora pode ser null)

  const ShoppingListPage({
    required this.userId,
    required this.userName,
    required this.userPassword
  });

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final List<Compras> _shoppingList = [];
  TextEditingController _textController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShoppingList(); // Carrega a lista de compras do usuário ao iniciar a página
  }

  // Função para buscar a lista de compras do usuário e adicionar à lista _shoppingList
  Future<void> _fetchShoppingList() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:7057/api/ListaCompras/user/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> items = jsonDecode(response.body);

        setState(() {
          for (var item in items) {
            final compras = Compras.fromJson(item);
            _shoppingList.add(compras); // Adiciona à lista de compras
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar lista')),
        );
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Função para adicionar item localmente e na API
  Future<void> _addItem(String newItem) async {
    if (newItem.isNotEmpty) {   

      final response = await http.post(
        Uri.parse('http://localhost:7057/api/ListaCompras/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Itens': newItem,
          'Comprado': false,
          'UserId': widget.userId,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item adicionado com sucesso')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao adicionar item à API')),
        );
      }

      _textController.clear();
    }
  }

  // Função para marcar como comprado e remover da lista local
  void _markAsBought(int index) {
    setState(() {
      _shoppingList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item marcado como comprado')),
    );
  }

  // Função para deletar item da lista local
  void _deleteItem(int index) {
    setState(() {
      _shoppingList.removeAt(index);
    });
  }

  // Função para editar item localmente
  void _editItem(int index, String newName) {
    setState(() {
      _shoppingList[index] = Compras(
        Id: _shoppingList[index].Id,
        Itens: newName,
        Comprado: _shoppingList[index].Comprado,
        UserId: _shoppingList[index].UserId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lista de Compras',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Exibindo o nome, o ID e a senha do usuário no canto superior, com valores padrão se forem nulos
            Align(
              alignment: Alignment.topLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${widget.userId}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Usuário: ${widget.userName}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Senha: ${widget.userPassword}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Adicionar novo item',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    _addItem(_textController.text);
                  },
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _shoppingList.isEmpty
                      ? Center(
                          child: Text(
                            'Sua lista está vazia',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _shoppingList.length,
                          itemBuilder: (context, index) {
                            final item = _shoppingList[index];
                            TextEditingController editController =
                                TextEditingController(text: item.Itens);
                            bool isEditing = false;

                            return StatefulBuilder(
                              builder: (context, setStateInner) => Card(
                                color: Colors.green[50],
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  leading: Text(
                                    item.Id.toString(),
                                    style: TextStyle(
                                      color: Colors.green[900],
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  title: isEditing
                                      ? TextField(
                                          controller: editController,
                                          onSubmitted: (newName) {
                                            _editItem(index, newName);
                                            setStateInner(() {
                                              isEditing = false;
                                            });
                                          },
                                        )
                                      : Text(
                                          item.Itens,
                                          style: TextStyle(
                                            color: Colors.green[900],
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () {
                                          setStateInner(() {
                                            isEditing = !isEditing;
                                          });
                                        },
                                      ),
                                      // Botão para marcar como comprado e remover da lista
                                      IconButton(
                                        icon: const Icon(Icons.check,
                                            color: Colors.green),
                                        onPressed: () {
                                          _markAsBought(index);
                                        },
                                      ),
                                      // Botão para deletar item
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () {
                                          _deleteItem(index);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(_textController.text),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
