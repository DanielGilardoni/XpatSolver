(* Fonctions pour résoudre la version de FreeCell *)

type gameStruct

(* Prend la liste de toutes les cartes puis crée
   un gameStruct avec les colonnes remplies *)
val initFreeCell : int list -> gameStruct
val initSeahaven : int list -> gameStruct
val initMidOil : int list -> gameStruct
val initBDozen : int list -> gameStruct