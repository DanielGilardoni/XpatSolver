(* Fonctions pour résoudre la version de FreeCell *)

type game = Freecell | Seahaven | Midnight | Baker
type gameStruct

val add : int list -> int list -> int -> (int list * int list)
val add_columns : int list FArray.t -> int list -> int list -> int -> (int list FArray.t * int list)
(* Prend la liste de toutes les cartes puis crée
   un gameStruct avec les colonnes remplies *)
val initGame : game -> int list -> gameStruct
val initGameAux : game -> int -> int -> int list -> int list -> gameStruct