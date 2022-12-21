

(* Attention aux registres. Ils peuvent contenir les mêmes cartes pas dans
   le meme ordre. Il faut les trier peut être avant ? *)
let compare_games (game1 : Game.gameStruct) (game2 : Game.gameStruct) : bool = 
  if FArray.compare game1.registers game2.registers then
    FArray.compare game1.columns game2.columns
  else
    false

(* définir le type state et la fonction compare_state auparavant *)
module States = Set.Make (struct type t = gameStruct let compare = compare_games end)

let add_in_regs game reachable reached = 
  let rec add_in_regs_aux index to_add_list = 
    if index >= FArray.length game.columns then 
      to_add_list
    else
      let col = get game.columns index in
      if List.length col < 2 then
        add_in_regs_aux (index+1) to_add_list
      else 
        try let new_regs = add_to_reg game.registers (List.hd col) 
            in let new_game = {name = game.name; registers = new_regs; columns = game.columns; depots = game.depots}
            in add_in_regs_aux (index + 1) (new_game :: to_add_list)
        with _ -> add_in_regs_aux (index + 1) to_add_list
  in add_in_regs_aux 0 []

(* Ajoute tous les états de partie atteignables en un coup depuis game à reachable, sauf si ils appartiennent à reached *)
(* let add_reachable game reachable reached =
-possible ? -> si reg vide alors tt deb de col. Si col vide alors tt reg ou tt autre deb col de taille > 1.
              sinon voir cartes attendues pour chaque col et voir si accessible
-rules (t cho) -> decouper etapes prec en 3 fct qu'on appel en fct de mode de jeu et en precisant mode si besoin
-remove 
-move 
-reached ?
-add  *)
NOOOOOOOOOOO xd
Vzzz bonne nuit xD Bisous bisous d'amour Dadou. Coeur sur 
C'est tchao
Bonne nuit
Bisous
Bebou
Je push comme ça ?

(* Recherche exhaustive ou non ? *)
let search_sol (reachable : States) (reached : States) =
  if States.is_empty reachable then (Printf.printf "Echec"; exit 1) (* Si exhaustive alors Insoluble et exit 2 *)
  else let g = States.choose reachable in
  let reachable = States.remove g reachable in
  let game = normalisation_full g in
  if States.mem game reached then
    let reachable = States.remove game reachable in search_sol reachable reached
  else
    let new_reachable = add_reachable game reachable reached in search_sol new_reachable (States.add game reached) 
