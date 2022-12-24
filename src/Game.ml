
open FArray

type game = Freecell | Seahaven | Midnight | Baker

type gameStruct = {
  name : game;
  registers : Card.card option FArray.t;
  columns : Card.card list FArray.t;
  depots : Card.card list FArray.t;
  history : (int * string) list;
}

let rank card =
  fst card

let suit card =
  snd card


let kings_on_back columns =
  FArray.map (fun col -> 
    let kings = (List.filter (fun elt -> (rank elt) = 13) col) in 
    let no_kings = (List.filter (fun elt -> (rank elt) != 13) col) in
    no_kings @ kings) columns

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
  let history = [] in (* historique vide au début d'une partie *)
  let (columns, cards) = add_column columns cards cardsPerCol 0 in
  let registers = 
    match cards with
    | c1 :: c2 :: cards -> let reg1 = set registers 0 (Some (Card.of_num c1)) in
                           let reg2 = set reg1 1 (Some (Card.of_num c2)) in reg2
    | _ -> registers
  in {name = gameType ; columns = columns ; registers = registers; depots = depots; history = history}

let initGame gameType cards =
  match gameType with
  | Freecell -> initGameAux Freecell 4 cards [7;6;7;6;7;6;7;6]
  | Seahaven -> initGameAux Seahaven 4 cards (List.init 10 (fun x -> 5)) 
  | Midnight -> initGameAux Midnight 1 cards ((List.init 17 (fun x -> 3)) @ [1])
  | Baker -> let game = initGameAux Baker 1 cards (List.init 13 (fun x -> 4)) in
    {name = gameType ; columns = (kings_on_back game.columns) ; registers = game.registers; depots = game.depots; history = game.history} (* On met les rois au fond dans chaque colonne *)

let disp_history game =
  List.iter (fun (a, b) -> Printf.printf "(%d, %s), " a b) game.history

let rec disp_regs registers =
  match registers with 
  | [] -> ()
  | None :: sub -> disp_regs sub
  | Some card :: sub ->
    Printf.printf "%s ;%!" (Card.to_string card);
    disp_regs sub

let rec disp_list list =
  match list with 
  | [] -> ()
  | card :: sub_list ->
    Printf.printf "%s ;%!" (Card.to_string card);
    disp_list sub_list

let rec disp_list_list col_or_depots = 
  match col_or_depots with
  | [] -> ()
  | col :: sub -> Printf.printf "\n | "; disp_list col; disp_list_list sub 

let disp game = 
  Printf.printf "DEBUT AFFICHAGE GAME\n\n";
  let registers_list = FArray.to_list game.registers in
  let columns_list = FArray.to_list game.columns in 
  let depots_list = FArray.to_list game.depots in
  Printf.printf "Registers : \n";
  disp_regs registers_list;
  Printf.printf "\n\nColumns : \n";
  disp_list_list columns_list;
  Printf.printf "\n\nDepots : \n";
  disp_list_list depots_list;
  Printf.printf "\n\nHistory :\n";
  disp_history game

(* Ecriture des fonctions pour la partie I/2, Peut qu'il faudra les mettres ailleurs plus tard *)

exception Empty_Stack
exception No_Register
exception No_Column
exception No_Index

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
    | col :: _ when card_num = 99 && (empty col) -> Some index
    | col :: sub_cols -> match (peek col) with
                         | Some card when (Card.to_num card) = card_num -> Some index
                         | _ -> get_col_aux sub_cols (index+1)
  in get_col_aux col_list 0

let empty_col columns = 
  get_col columns 99

(* Renvoie l'index de la carte dans les registres *)
let get_reg registers card_num =
  let reg_list = FArray.to_list registers in
  let rec get_reg_aux regs index =
    match regs with
    | [] -> None
    | card :: _ when card_num = 99 && card = None -> Some index
    | card :: sub_regs -> match card with
                          | Some card when (Card.to_num card) = card_num-> Some index
                          | _ -> get_reg_aux sub_regs (index+1)
  in get_reg_aux reg_list 0

(* Recuperer l'index du premier registre vide *)
let empty_reg registers =
  get_reg registers 99

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

let remove game card = 
  try let reg = remove_in_reg game.registers card in
    {name = game.name; registers = reg; columns = game.columns; depots = game.depots; history = game.history}
  with No_Index -> let col = remove_in_col game.columns card in
    {name = game.name; registers = game.registers; columns = col; depots = game.depots; history = game.history}

let compare_cards_opt card1 card2 = 
  match card1 with 
  | None -> -1
  | Some c1 -> match card2 with
               | None -> 1
               | Some c2 -> if (Card.to_num c1) < (Card.to_num c2) then -1 else 1

let add_to_reg registers card =
  if (FArray.length registers) = 1 then 
    raise No_Register;
  let reg = empty_reg registers in 
  match reg with
  | None -> raise No_Index
  | Some index -> let new_registers = (set registers index (Some (Card.of_num card))) in
                  let reg_list = FArray.to_list new_registers in
                  let sort_regs = List.sort compare_cards_opt reg_list in
                  FArray.of_list sort_regs

(* Si card2 = 99, alors get_col renvoie l'index de la premiere colonne vide. *)
let add_to_col columns card card2 =
  let index = get_col columns card2 in
  match index with
  | None -> raise No_Column
  | Some i -> let col = get columns i in
              set columns i ((Card.of_num card) :: col)

(* Verifier si card_num2 vaut bien [1,51] AVANT *)
let move game card_num location =
  let card2 = try int_of_string(location) with _ -> 99 in
  (* On ajoute le dernier coup dans l'historique *)
  let new_history = (card_num, location) :: game.history in
  match location with 
  | "T" -> let reg = add_to_reg game.registers card_num
           in {name = game.name; registers = reg; columns = game.columns; depots = game.depots; history = new_history}
                           
  | "V" -> let columns = add_to_col game.columns card_num 99
           in {name = game.name; registers = game.registers; columns = columns; depots = game.depots; history = new_history}
  
  | _ when card2 >= 0 && card2 < 52 -> let columns = add_to_col game.columns card_num card2
           in {name = game.name; registers = game.registers; columns = columns; depots = game.depots; history = new_history}
    
  | _ -> raise Not_found

let rules game card_num location =
  if (get_col game.columns card_num) = None && (get_reg game.registers card_num) = None then false
  else
    let card2_num = 
      try int_of_string(location) with _ -> 99 in
    match location with 
    | "T" ->
      begin
        match game.name with
        | Midnight -> false
        | Baker -> false
        | _ -> (empty_reg game.registers) != None
      end
    | "V" ->
      begin
        match game.name with
        | Freecell -> (empty_col game.columns) != None
        | Seahaven -> let card1 = (Card.of_num card_num) in 
                      if not (rank card1 = 13) then false
                      else (empty_col game.columns) != None
        | _ -> false (* car colonne vide ne sont pas remplissables dans les autres modes *)
      end 
    | _ when card2_num >= 0 && card2_num < 52 -> 
      if (get_col game.columns card2_num) = None then false (* Si l'emplacement n'existe pas, si il n'y a pas de colonne avec card2 au bout *)
      else
          let card2 = Card.of_num card2_num in
          let card1 = Card.of_num card_num in 
      if not ((rank card2) = (rank card1) + 1) then false (* Si card1 n'est pas immediatement inferieure *)
      else 
        let suit1 = Card.num_of_suit (suit card1) in
        let suit2 = Card.num_of_suit (suit card2) in
        begin
          match game.name with
          | Freecell -> not ((suit1 < 2 && suit2 < 2) || (suit1 > 1 && suit2 > 1)) (* Si couleur alternée *)
          | Seahaven -> suit1 = suit2 (* Si même type*)
          | Midnight -> suit1 = suit2 (* Si même type*)
          | Baker -> true (* si on arrive ici c'est bon pas de condition sur les types dans ce mode *)
        end

    | _ -> false

let wanted_depot_cards depots = 
  let depots_list = FArray.to_list depots in
  let rec wanted_aux l1 l2 suit_num =
    match l1 with
    | [] -> l2
    | depot :: sl -> let card = match (peek depot) with
           | None -> Some (1, Card.suit_of_num suit_num)
           | Some card when rank card <= 13-> Some ((rank card + 1), suit card)
           | _ -> None
           in wanted_aux sl (card :: l2) (suit_num + 1)
    in wanted_aux depots_list [] 0

let add_to_depots depots card index =
  let depot = get depots index in
  set depots index (card :: depot)

let disp_card_num card = 
  Printf.printf "Normalise: %s\n" (Card.to_string card)

let normalisation game =
  let wanted_cards = wanted_depot_cards game.depots in
  let rec normalisation_aux game cards is_normalise =
    match cards with
    | [] -> (game, is_normalise)
    | card_opt :: sub_cards -> 
      match card_opt with 
      | None -> normalisation_aux game sub_cards is_normalise
      | Some card ->
      try
        let game_temp = remove game (Card.to_num card) in
        (* Printf.printf "after remove"; *)
        (* disp game_temp; *)
         (* ça modifie pas is_normalise on crée une nouvelle variable à chaque fois *)
        let new_depots = add_to_depots game_temp.depots card (Card.num_of_suit (suit card)) in 
        let new_game = {name = game.name; registers = game_temp.registers; columns = game_temp.columns; depots = new_depots; history = game.history} in
        normalisation_aux new_game sub_cards false
      with _ -> normalisation_aux game sub_cards is_normalise
    in normalisation_aux game wanted_cards true

let rec normalisation_full game = 
  (* Printf.printf "\n y \n"; *)
  let normalise = normalisation game in
  if snd normalise then fst normalise else normalisation_full (fst normalise)

let is_depot_complete depot suit_num = 
  let rec is_depot_complete_aux sub_depot index =
    begin
    match sub_depot with
    | [] when index = 13 -> true
    | [] -> false
    | card :: sub_depot -> 
      if not ((rank card) = (13 - index)) then
        false
      else
        let suit_card = suit card in
        if (Card.num_of_suit suit_card) = suit_num then is_depot_complete_aux sub_depot (index + 1)
        else false
    end
  in is_depot_complete_aux depot 0
      
let are_depots_complete depots = 
  let rec are_depots_complete_aux index =
    if index = 4 then true else 
      let depot_i = get depots index in
      if (is_depot_complete depot_i index) then are_depots_complete_aux (index+1) else false
  in are_depots_complete_aux 0

let is_empty_reg reg =
  match reg with
  | [] -> true
  | reg -> (List.filter (fun x -> x != None) reg) = []

let rec is_empty columns =
  match columns with 
  | [] -> true
  | reg_o_col :: sub -> if empty reg_o_col then is_empty sub else false

let is_won game = 
  let registers_list = FArray.to_list game.registers in
  if not (is_empty_reg registers_list) then
    false
  else
    let columns_list = FArray.to_list game.columns in 
    if not (is_empty columns_list) then
        false
    else
      are_depots_complete game.depots



