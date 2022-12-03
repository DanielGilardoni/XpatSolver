
open FArray

type game = Freecell | Seahaven | Midnight | Baker

type gameStruct = {
  name : game;
  registers : int list FArray.t;
  columns : int list FArray.t;
  depots : int list FArray.t;
}

(* On ajoute i cards dans la liste l *)
let rec add l cards i = 
  if i > 0 then 
    match cards with
    | [] -> (l, cards)
    | a :: subCards -> let newList = a :: l in add newList subCards (i-1)
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

let initGameAux gameType nbReg nbCol cards cardsPerCol =
  let registers = FArray.make nbReg [] in
  let columns = FArray.make nbCol [] in
  let depots = FArray.make 4 [] in
  let (columns, cards) = add_column columns cards cardsPerCol 0 in
  let registers = 
    match cards with
    | c1 :: c2 :: cards -> let reg1 = set registers 0 c1 in let reg2 = set reg1 1 c2 in reg2
    | _ -> registers
  in {name = gameType ; columns = columns ; registers = registers; depots = depots}

let initGame gameType cards =
  match gameType with
  | Freecell -> initGameAux FreeCell 4 8 cards [7,6,7,6,7,6]
  | Seahaven -> initGameAux Seahaven 4 10 cards (List.init 10 (fun x -> 5)) 
  | Midnight -> initGameAux Midnight 0 18 cards ((List.init 17 (fun x -> 3)) @ [1])
  | BakersDozen -> initGameAux BakersDozen 0 13 cards (List.init 13 (fun x -> 4))
  | _ -> raise Not_found
