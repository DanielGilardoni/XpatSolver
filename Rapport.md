# Rapport XPatSolver

<!-- Table des matières -->
- [Rapport XPatSolver](#rapport-xpatsolver)
  - [Identifiants](#identifiants)
  - [Fonctionnalités](#fonctionnalités)
  - [Compilation et exécution](#compilation-et-exécution)
    - [Compilation](#compilation)
    - [Execution](#execution)
  - [Découpage modulaire](#découpage-modulaire)
    - [Game](#game)
    - [XPatSolver](#xpatsolver)
      - [treat\_game](#treat_game)
    - [XPatRandom](#xpatrandom)
    - [Search](#search)
  - [Organisation du travail](#organisation-du-travail)
  - [Misc](#misc)


## Identifiants
---
| Nom       |  Prénom | Identifiant | Numéro d'étudiant |  
| ----------|---------|-------------|-------------------|
| Abignoli  | Léopold |  @abignoli  |      22004535     |  
| Gilardoni | Daniel  |  @gilardon  |      22008366     |

## Fonctionnalités
---
   <!-- Donnez une description précise des fonctionnalités implémentées
   par votre rendu:  
   - sujet minimal
   - extensions éventuelles
   - éventuellement parties non réalisées ou encore non fonctionnelles. -->


## Compilation et exécution
---
<!--
Expliquer comment:
- Compiler le projet (normalement via dune)  
- Executer le projet (en donnant les options acceptées par votre programme).  
Pour ce projet, aucune bibliothèques externes n'est autorisé a priori.
-->
### Compilation
Pour compiler le projet, vous pouvez executer la commande suivante:
```bash
dune build
```
Vous pouvez également utiliser le `Makefile`:
```bash
make
```
<br/><br/>
### Execution
Pour lancer le projet, vous pouvez executer le fichier `run`. Il faudra alors lui passer plusieurs paramètres. Voici un exemple de la page d'aide:
```bash
XpatSolver <game>.<number> : search solution for Xpat2 game <number>
  -check <filename>:    Validate a solution file
  -search <filename>:   Search a solution and write it to a solution file
  -help  Display this list of options
  --help  Display this list of options
```
Voici un exemple pour chercher une solution et l'écrire dans le fichier `test.sol` si elle existe:
```bash
./run FreeCell.123456 -search test.sol
```
Enfin, un deuxième exemple pour vérifier si un fichier solution est correcte:
```bash
./run FreeCell.123 -check tests/I/fc123.sol
```

## Découpage modulaire
---
<!--
- Description de chaque module (.ml) de votre projet
- Précisez le rôle/nécessité de chaque module ajouté au dépôt initial.
- -->

Pour notre projet, nous avons eu besoin de créer plusieurs modules. Notamment un module **Game.ml** et **Search.ml**.

### Game
---

### XPatSolver
---
Le module `XPatSolver` est le module avec la fonction **main**. C'est celui qui parse les arguments puis qui lance une **recherche** de solutions ou une **vérification** d'un fichier solution de **Solitaire**. Dans ce module, nous avons uniquement modifié la fonction **treat_game**.

#### treat_game
Cette fonction nous permet d'effectuer une **recherche** de solutions ou de **vérifier** un fichier solution.

Le début de la fonction n'a pas changé. Elle calcule la **permutation** des cartes selon la **graine** puis l'affiche à l'écran. A l'aide de cette permutation, on va alors créer un objet **GameStruct** avec la fonction **Game.initGame** (voir [Game](#game))

<br/><br/>
Voici ensuite les différentes étapes de l'algorithme:

**I) On effectue une recherche exhaustive ou non_exhaustive**
- On ouvre le fichier dans lequel on va écrire la solution (**file**)
- On appelle la fonction **exhaustive** ou **non_exhaustive** (Voir [Search](#search))
- Si il n'y a pas de solution:
    - **Exhaustive**: on affiche **INSOLUBLE** et code erreur 2
    - **Non exhaustive**: il faut remplacer **INSOLUBLE** par **ECHEC** et exit 1
- Si il y a une solution, on écrit les mouvements dans le fichier **file** (*write_moves*) et on affiche **SUCCES**

**II) On vérifie si un fichier solution est correcte**
- On ouvre le fichier (**file**)
- On lit une ligne du fichier file avec **read_aux** (renvoie **None** si on arrive au bout du fichier)
- On appelle la fonction **treat_game_aux** qui permet d'executer tous les coups du fichier file.
  - On lit le prochain coup (**read_aux**)
  - Si on est au bout du fichier
    - On normalise la partie
    - Si la partie est gagné (**is_won**), on affiche **SUCCES**
    - Sinon, la partie est perdu et le fichier n'est pas une solution. On affiche **ECHEC**.
  - Sinon, on prend la prochaine ligne
    - On récupère la carte et l'endroit où on veut la placer.
    - On normalise la partie
    - On vérifie si le mouvement donné par le fichier est autorisé
    - Si Le mouvement est *interdit*, on affiche **ECHEC**
    - Sinon, si le mouvement est *autorisé*
      - On retire la carte et on la place sur sa nouvelle location
      - On appelle recursivement treat_game pour effectuer le prochain coup 

### XPatRandom
---
Le module `XPatRandom` contient la fonction **shuffle** qui va nous permettre de générer une permutation de carte pour une certaine graine (**seed**). Pour écrire cette fonction, nous avons suivi toutes les instructions données au début du fichier. Voici donc, une petite description de notre code:

### Search
---
Le module `Search` contient toutes les fonctions pour effectuer une recherche de solutions. Il nous permet d'effectuer une recherche **exhaustive** et **non-exhaustive** parmis tous les jeux de Solitaire compatibles. Voici une description des différentes fonctions de notre module:
- **compare_games**: Cette fonction nous permet de comparer deux **gameStruct** (deux états d'une partie). Elle utilise notamment la fonction **FArray.compare** qui permet de comparer les tableaux de *registres* et *colonnes*. La fonction **FArray.compare** utilise elle même **Stdlib.compare** (elle convertie d'abord les FArray en listes).

- **States**: Le module **States** est une implementation de l'interface **Set** où les éléments sont de type **Game.gameStruct** (état d'une partie) et la fonction de comparaison est **compare_games**.

- **set_of_list**: Permet de convertir une liste d'états en **States** (Set).

- **set_reachable**: Prend un **States** reachable (ensemble d'états atteignables), un **States** reached (ensemble d'états déjà atteints), et une liste de d'états. Elle renvoie l'ensemble reachable modifié en ajoutant les états de la liste qui n'ont pas déjà été atteints (pas dans **reached**) ou qui ne sont pas déjà dans les états atteignables (pas dans **reachable**).

- **add**: Prend en entrée un **état** de jeu de Solitaire (**Game.gameStruct**), une destination ("T" pour une **colonne vide**, "V" pour les **registres**, ou une carte correspondant à une colonne) et une liste d'états. Elle calcule tous les états de jeu atteignables en déplaçant une carte vers la destination spécifiée et les ajoute à la liste des états.

- **add_reachable**: Prend en entrée un **état** de jeu de Solitaire, un ensemble d'états atteignables (**reachable**) et un ensemble de d'états déjà atteints (**reached**). Elle calcule tous les états atteignables en un coup à partir de l'état donné et les ajoute à l'ensemble de parties atteignables, à moins qu'ils ne soient déjà présents dans l'ensemble **reached**. Pour ce faire, elle utilise la fonction **add**.

- **exhaustive**: Prend en entrée un **état** de jeu de Solitaire et appelle la fonction **search_sol** (avec **best_score=-1**) pour trouver une solution à cette partie. Elle renvoie l'enchainement des coups si une solution a été trouvé.

- **non_exhaustive**: Prend en entrée un **état** de jeu de Solitaire et appelle la fonction **search_sol** (avec **best_score=0**) pour trouver une solution à cette partie. Cette fois, **search_sol** va utiliser la fonction **heuristic** et mettre à jour le **best_score** pour trouver plus rapidement une solution.

Pour finir, la **search_sol** permet de trouver une solution à une partie de Solitaire (si il en existe une). Elle est appelée par deux autres fonctions: **exhaustive** et **non_exhaustive** (voir plus haut). C'est une fonction de recherche récursive qui prend un ensemble d'états **reached** et **reachable**, un **best_score** (le score de l'état avec le meilleur score) et une fonction **heuristic** qui prend en entrée un score, le meilleur score et renvoie un booléen indiquant si le score est suffisamment proche de ce meilleur score. Dans le cas d'une recherche **exhaustive**, le **best_score** vaut -1 et on ne regarde pas la fonction heuristic.

La fonction commence par vérifier si l'ensemble des **états atteignables** est vide, auquel cas elle renvoie None, indiquant qu'aucune solution n'a été trouvée. Sinon, elle récupère le premier **état atteignable** de reachable et le retire de l'ensemble. Elle normalise cet état et calcule son score. Si l'état a déjà été atteint ou si son score n'est pas suffisamment proche du meilleur score connu selon la fonction **heuristic** (uniquement si recherche **non_exhaustive**), elle appelle récursivement la fonction en supprimant l'état de **reachable**.

Sinon, si le score de l'état est égal à 52 (ce qui signifie que toutes les cartes ont été déplacées dans les dépôts), la fonction renvoie l'**historique** de cet état (l'enchainement des coups pour résoudre la partie).

Sinon, elle calcule tous les **états atteignables** en un coup à partir de l'**état actuel**, en utilisant la fonction **add_reachable** et appelle récursivement la fonction en lui passant ces nouveaux états atteignables. Le **best_score** est également mis à jour si besoin. 

## Organisation du travail
- Répartition des tâches entre les membres au cours du temps
- Brève chronologie de notre travail

## Misc
Remarques, suggestions, questions...
