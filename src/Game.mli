(* Fonctions pour résoudre la version de FreeCell *)

type game = Freecell | Seahaven | Midnight | Baker

type gameStruct = {
  name : game;
  registers : Card.card option FArray.t;
  columns : Card.card list FArray.t;
  depots : Card.card list FArray.t;
  history : (int * string) list;
}

val add : Card.card list -> int list -> int -> (Card.card list * int list)
val add_column : Card.card list FArray.t -> int list -> int list -> int -> (Card.card list FArray.t * int list)
(* Prend la liste de toutes les cartes puis crée
   un gameStruct avec les colonnes remplies *)
val initGame : game -> int list -> gameStruct
val initGameAux : game -> int -> int list -> int list -> gameStruct

val remove : gameStruct -> int -> gameStruct
val move : gameStruct -> int -> string -> gameStruct
val rules : gameStruct -> int -> string -> bool
val normalisation : gameStruct-> gameStruct * bool
val normalisation_full : gameStruct -> gameStruct

val is_won : gameStruct -> bool
val disp : gameStruct -> unit
val disp_history : gameStruct -> unit