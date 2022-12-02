
type gameStruct = {
  registers : int list FArray.t;
  columns : int list FArray.t;
}

let rec add l cards i = 
  if i > 0 then 
    match cards with
    | [] -> (l, cards)
    | a :: subCards -> let newList = a :: l in add newList subCards (i-1)
  else
    (l, cards)

let rec add_column columns cards cardsPerCol incr =
  match cardsPerCol with
  | [] -> (columns, cards)
  | nbCard :: subCardsPerCol -> 
    let (col, subCards) = add [] cards nbCard in
    let newCol = set columns incr col in
      add_column newCol subCards subCardsPerCol (incr + 1)
(*
let initGame nbReg nbCol cards =
  let reg = FArray.make nbReg [] in
  let col = FArray.make nbCol [] in
*)