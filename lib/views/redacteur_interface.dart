import 'package:flutter/material.dart';

import '../modele/redacteur.dart';
import '../services/database_manager.dart';

class RedacteurInterface extends StatefulWidget {
  const RedacteurInterface({super.key});

  @override
  State<RedacteurInterface> createState() => _RedacteurInterfaceState();
}

class _RedacteurInterfaceState extends State<RedacteurInterface> {
  final DatabaseManager _databaseManager = DatabaseManager();

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  List<Redacteur> _redacteurs = [];

  @override
  void initState() {
    super.initState();
    _chargerRedacteurs();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _chargerRedacteurs() async {
    final List<Redacteur> liste = await _databaseManager.getAllRedacteurs();
    setState(() {
      _redacteurs = liste;
    });
  }

  Future<void> _ajouterRedacteur() async {
    final String nom = _nomController.text.trim();
    final String prenom = _prenomController.text.trim();
    final String email = _emailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    final Redacteur nouveauRedacteur = Redacteur.sansId(
      nom: nom,
      prenom: prenom,
      email: email,
    );

    await _databaseManager.insertRedacteur(nouveauRedacteur);

    _nomController.clear();
    _prenomController.clear();
    _emailController.clear();

    await _chargerRedacteurs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rédacteur ajouté.')),
      );
    }
  }

  Future<void> _modifierRedacteur(Redacteur redacteur) async {
    final TextEditingController nomModifie =
        TextEditingController(text: redacteur.nom);
    final TextEditingController prenomModifie =
        TextEditingController(text: redacteur.prenom);
    final TextEditingController emailModifie =
        TextEditingController(text: redacteur.email);

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Modifier Rédacteur'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomModifie,
                decoration: const InputDecoration(labelText: 'Nouveau Nom'),
              ),
              TextField(
                controller: prenomModifie,
                decoration: const InputDecoration(labelText: 'Nouveau Prénom'),
              ),
              TextField(
                controller: emailModifie,
                decoration: const InputDecoration(labelText: 'Nouvel Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                final Redacteur redacteurModifie = Redacteur(
                  id: redacteur.id,
                  nom: nomModifie.text.trim(),
                  prenom: prenomModifie.text.trim(),
                  email: emailModifie.text.trim(),
                );
                await _databaseManager.updateRedacteur(redacteurModifie);
                await _chargerRedacteurs();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _supprimerRedacteur(int id) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: const Text('Voulez-vous vraiment supprimer ce rédacteur ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                await _databaseManager.deleteRedacteur(id);
                await _chargerRedacteurs();
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des rédacteurs'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _ajouterRedacteur,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un Rédacteur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _redacteurs.length,
                itemBuilder: (BuildContext context, int index) {
                  final Redacteur redacteur = _redacteurs[index];
                  return Card(
                    child: ListTile(
                      title: Text('${redacteur.nom} ${redacteur.prenom}'),
                      subtitle: Text(redacteur.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _modifierRedacteur(redacteur),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _supprimerRedacteur(redacteur.id!),
                          ),
                        ],
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