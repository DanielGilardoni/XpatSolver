
type gameStruct = {
  registers : int list FArray.t;
  columns : int list FArray.t;
}

let rec add l cards i = 
  if i > 0 then
    match cards with
    | a :: subCards -> a :: l in
    add l subCards (i-1)
  else
    (l, cards)

let rec add_column col cards i =
  if i > 0 then
    let (v, sc) = add [] cards 7 in
    let newCol = set col i v in
      add_column newCol sc (i-1)
  else
    (col, cards)

let initGame nbReg nbCol cards =
  let reg = FArray.make nbReg [] in
  let col = FArray.make nbCol [] in

    in

  in let (col, cards) = add_column col cards nbCol
  in add_column reg cards nbReg
in {registers=reg; columns=col} 

let initFreeCell