(* Fonctions pour résoudre la version de FreeCell *)

type gameStruct


(*val initGame : int -> int -> gameStruct*)

val rec add : int list -> int list -> int:

(* Prend la liste de toutes les cartes puis crée
   un gameStruct avec les colonnes remplies *)
val initFreeCell : int list -> gameStruct
val initSeahaven : int list -> gameStruct
val initMidOil : int list -> gameStruct
val initBDozen : int list -> gameStruct