
open FArray

type game = Freecell | Seahaven | Midnight | Baker

type gameStruct = {
  name : game;
  registers : Card.card option FArray.t;
  columns : Card.card list FArray.t;
  depots : Card.card list FArray.t;
}

(* On ajoute i cards dans la liste l *)
let rec add l cards i = 
  if i > 0 then 
    match cards with
    | [] -> (l, cards)
    | a :: subCards -> add ((Card.of_num a) :: l) subCards (i-1)
  else
    (l, cards)

(* cardsPerCol est une liste contenant dans l'ordre le nombre de cartes à ajouté dans chaque colonne 
   On ajoute donc nbCards dans chaque colonne (sous forme de liste) de columns *)
let rec add_column columns cards cardsPerCol incr =
  match cardsPerCol with
  | [] -> (columns, cards)
  | nbCard :: subCardsPerCol -> 
    let (col, subCards) = add [] cards nbCard in
    let newCol = set columns incr col in
      add_column newCol subCards subCardsPerCol (incr + 1)

let initGameAux gameType nbReg cards cardsPerCol =
  let registers = FArray.make nbReg None in
  let columns = FArray.make (List.length cardsPerCol) [] in
  let depots = FArray.make 4 [] in
  let (columns, cards) = add_column columns cards cardsPerCol 0 in
  let registers = 
    match cards with
    | c1 :: c2 :: cards -> let reg1 = set registers 0 (Some (Card.of_num c1)) in
                           let reg2 = set reg1 1 (Some (Card.of_num c2)) in reg2
    | _ -> registers
  in {name = gameType ; columns = columns ; registers = registers; depots = depots}

let initGame gameType cards =
  match gameType with
  | Freecell -> initGameAux Freecell 4 cards [7;6;7;6;7;6]
  | Seahaven -> initGameAux Seahaven 4 cards (List.init 10 (fun x -> 5)) 
  | Midnight -> initGameAux Midnight 0 cards ((List.init 17 (fun x -> 3)) @ [1])
  | Baker -> initGameAux Baker 0 cards (List.init 13 (fun x -> 4))
  (* | _ -> raise Not_found *)


(* Ecriture des fonctions pour la partie I/2, Peut qu'il faudra les mettres ailleurs plus tard *)

exception Empty_Stack

let push stack elt =
  match stack with
  | stack -> elt :: stack

let pop = function
  | [] -> raise Empty_Stack
  | a :: stack -> (a, stack)

let peek = function
  | [] -> None
  | a :: stack -> Some a

let empty = function
  | [] -> true
  | _ -> false

(* Recuperer l'index de la colonne qui contient cette carte *)
let get_col columns card_num =
  let col_list = FArray.to_list columns in
  let rec get_col_aux cols index =
    match cols with
    | [] -> None
    | col :: _ when card_num = 0 && (empty col) -> Some index
    | col :: sub_cols -> match (peek col) with
                         | Some card when (Card.to_num card) = card_num -> Some index
                         | _ -> get_col_aux sub_cols (index+1)
  in get_col_aux col_list 0

let empty_col columns = 
  get_col columns 0

(* Renvoie l'index de la carte dans les registres *)
let get_reg registers card_num =
  let reg_list = FArray.to_list registers in
  let rec get_reg_aux regs index =
    match regs with
    | [] -> None
    | card :: _ when card_num = 0 && card = None -> Some index
    | card :: sub_regs -> match card with
                          | Some card when (Card.to_num card) = card_num-> Some index
                          | _ -> get_reg_aux sub_regs (index+1)
  in get_reg_aux reg_list 0

(* Recuperer l'index du premier registre vide *)
let empty_reg registers =
  get_reg registers 0

exception No_Register
exception No_Column
exception No_Index

let remove_in_col cols card =
  let index = get_col cols card in
  match index with
  | None -> raise No_Index
  | Some i -> let col = get cols i in
              match col with
              | [] -> raise Empty_Stack
              | _ :: sl -> set cols i sl

let remove_in_reg regs card =
  let index = get_reg regs card in
  match index with 
  | None -> raise No_Index
  | Some i -> set regs i None

let add_to_reg registers card =
  let reg = empty_reg registers in 
  match reg with
  | None -> raise No_Register
  | Some index -> set registers index (Some (Card.of_num card))

(* Si card2 = 0, alors get_col renvoie l'index de la premiere colonne vide. *)
let add_to_col columns card card2 =
  let index = get_col columns card2 in
  match index with
  | None -> raise No_Column
  | Some i -> let col = get columns i in
              set columns i ((Card.of_num card) :: col)

(* Verifier si card_num2 vaut bien [1,51] AVANT *)
let move game card_num location =
  let card2 = int_of_string(location) in
  match location with 
  | "T" -> let reg = add_to_reg game.registers card_num 
           in {name = game.name; registers = reg; columns = game.columns; depots = game.depots}
                           
  | "V" -> let columns = add_to_col game.columns card_num 0
           in {name = game.name; registers = game.registers; columns = columns; depots = game.depots}
  
  | _ when card2 > 0 && card2 < 52 -> let columns = add_to_col game.columns card_num card2
           in {name = game.name; registers = game.registers; columns = columns; depots = game.depots}
    
  | _ -> raise Not_found

  (*
  
  - Fonction rules
  - Normalisation
  - Résoudre: ça lit un fichier -> liste de lignes -> pour chaque ligne split sur l'espace -> puis rules, remove, move sur mot1 mot2
  
  *)