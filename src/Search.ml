
(* Attention aux registres. Ils peuvent contenir les mêmes cartes pas dans
   le meme ordre. Il faut les trier peut être avant ? *)
let compare_games (game1 : Game.gameStruct) (game2 : Game.gameStruct) : int = 
  if (FArray.compare game1.registers game2.registers) = 0 then
    FArray.compare game1.columns game2.columns (* renvoit 0 si ils sont égaux. Sinon un nombre != 0 *)
  else
    1 (* différent *)

module States = Set.Make (struct type t = Game.gameStruct let compare = compare_games end)

(* Permet de convertir une liste de gameStruct en States *)
let set_of_list (games : Game.gameStruct list) =
  let set = States.empty in
  List.iter (fun x -> let set = States.add x set in ()) games;
  set

let rec set_reachable reachable reached (games : Game.gameStruct list) = 
  match games with 
  | [] -> reachable
  | game :: sub_games -> 
    (* Si l'etat à déjà été vu ou est déjà dans les etats atteignables, on passe au suivant sinon on l'ajoute aux etats atteignables *)
    if (States.mem game reached) || (States.mem game reachable) then set_reachable reachable reached sub_games 
    else let reachable = (States.add game reachable) in set_reachable reachable reached sub_games

(* On renvoie to_add_list qui contient tous les états atteignables depuis game, en deplaçant une carte dans un registre vide *)
(* let add_in_regs game = 
  let rec add_in_regs_aux index to_add_list = 
    if index >= FArray.length game.columns then 
      to_add_list
    else
      let col = get game.columns index in
      if List.length col = 0 then
        add_in_regs_aux (index+1) to_add_list
      else 
        try let new_regs = add_to_reg game.registers (List.hd col)  (* Il manque de remove la carte *)
            in let new_game = {name = game.name; registers = new_regs; columns = game.columns; depots = game.depots}
            in add_in_regs_aux (index + 1) (new_game :: to_add_list)
        with _ -> add_in_regs_aux (index + 1) to_add_list
  in add_in_regs_aux 0 [] *)

(* On ajoute à to_add_list tous les états atteignables depuis game en deplaçant une carte dans une colonne vide 
   depuis un registre non vide*)
(* let add_in_empty_cols_from_regs game to_add_list = 
  let rec add_aux index to_add_list =
    if index >= FArray.length game.registers then to_add_list
    else let card_opt = get game.registers index in 
    match card_opt with
    | None -> add_aux (index + 1) to_add_list
    | Some card -> 
      try let new_cols = add_to_col game.columns card 99
              in let new_regs = remove (* Mais il faudrait remove avant, sauf qu'on sait pas si add va marcher vu qu'on fait un try*)
              in let new_game = {name = game.name; registers = game.registers; columns = new_cols; depots = game.depots}
              in add_aux (index + 1) (new_game :: to_add_list)
          with _ -> add_aux (index + 1) to_add_list
  in add_aux 0 to_add_list *)



(* On "ajoute" (en realité c'est une nouvelle liste) à to_add_list tout les états atteignables depuis game 
   en deplaçant une carte dans une colonne vide (depuis une autre colonne contenant au moins 2 cartes 
   ou depuis un registre non vide (cas géré par add_in_empty_cols_from_regs) )  *)
(* let add_in_empty_cols game to_add_list =
  match game.name with
  | Baker -> to_add_list
  | Midnight -> to_add_list
  | _ -> 
    if empty_col game.columns = None then to_add_list  (* Si on fait ça quel interet de faire try with ?*)
    else let rec add_in_empty_cols_aux index to_add_list = 
      if index >= FArray.length game.columns then 
        add_in_empty_cols_from_regs game  (* Faut ajouter les cartes des registres *)
      else 
        let col = get game.columns index in
        if List.length col < 2 then
          add_in_empty_cols_aux (index+1) to_add_list
        else 
          try let new_cols = add_to_col game.columns (List.hd col) 
              in let new_game = {name = game.name; registers = game.registers; columns = new_cols; depots = game.depots}
              in add_in_empty_cols_aux (index + 1) (new_game :: to_add_list)
          with _ -> add_in_empty_cols_aux (index + 1) to_add_list
    in add_in_empty_cols_aux 0 to_add_list *)










(* Test si on peut deplacer toutes les cartes sur location, et si oui ajoute cet état à to_add_list
   C'est peut-être plus couteux mais c'est plus simple je crois que les fonctions au dessus *)
let add game location to_add_list = 
  let rec add_aux card1_num to_add_list = 
    if card1_num >= 52 then to_add_list
    else match (Game.rules game card1_num location) with
    | false -> add_aux (card1_num + 1) to_add_list
    | true -> 
      let new_game = Game.remove game card1_num in
      let new_game = Game.move new_game card1_num location in 
      add_aux (card1_num + 1) (new_game :: to_add_list)
  in add_aux 0 to_add_list

(* Ajoute tous les états de partie atteignables en un coup depuis game à reachable, sauf si ils appartiennent à reached *)
let add_reachable game reachable reached =
  let to_add_list = add game "T" [] in
  let to_add_list = add game "V" to_add_list in
  (* On va faire une fonction qui calcule les cartes ajoutables à une colonne non vide en fct du type de jeu 
     Puis on ajoute dans une liste de tuple de la forme (carte_attendues carte_destination) pour chaque col non vide 
     Puis on fait match Game.rules game (fst tuple) (snd tuple); remove; move...
     Sinon plus couteux, mais on peut utiliser add avec comme location la carte au bout de chaque colonne non vide *)

  (* Pour l'instant, on fait la methode plus couteuse pour faire un premier test *)
  (* On convertit le tableau en liste de liste *)
  let columns = FArray.to_list game.columns in

  let rec check_cols_and_add cols to_add_list =
    match cols with (* On récupère la premiere colonne, puis la 2ème etc... *)
    | [] -> to_add_list
    | col :: sub_cols -> match col with (* On récupère la carte au bout de la colonne. Si colonne vide, on skip *)
                          | [] -> check_cols_and_add sub_cols to_add_list
                          | card :: _ -> let to_add_list = add game (string_of_int (Card.to_num card)) to_add_list in
                                        check_cols_and_add sub_cols to_add_list
  in let to_add_list = check_cols_and_add columns to_add_list
  in let reachable = set_reachable reachable reached to_add_list in reachable

(*
-possible ? -> si reg vide alors tt deb de col. Si col vide alors tt reg ou tt autre deb col de taille > 1.
              sinon voir cartes attendues pour chaque col et voir si accessible
-Game.rules (t cho) -> decouper etapes prec en 3 fct qu'on appel en fct de mode de jeu et en precisant mode si besoin
-remove 
-move 
-reached ?
-add  *)

(* Recherche exhaustive ou non ? *)
let rec search_sol reachable reached =
  if States.is_empty reachable then None (* Si exhaustive alors Insoluble et exit 2 *)
  else let g = States.choose reachable in
  let reachable = States.remove g reachable in
  (* Game.disp g; *)
  let game = Game.normalisation_full g in
  if States.mem game reached then
    let reachable = States.remove game reachable in 
    (* (if not (States.mem g reached) then 
    let reached = States.add g reached;) Supprimer g de reached n'est pas utile car si on l'ajoute alors si on retombe dessus 
    il sera supprimé de to_add_list avant d'entrer dans reachable, et si on ne le fait pas il sera peut-être ajouter à reachable 
    mais apres avoir été normalisée on passera à l'état suivant car g normalisé aura déjà été observé. 
    Verifier si on a déjà vu l'état normalisé est suiffisant*)
    search_sol reachable reached
  else
    if Game.is_won game then
      Some (List.rev game.history) (* On renvoit l'enchainement des coups (une list de tuple: (départ, arrivée) avec arrivée qui vaut: "[0-51]", "T", "V") *)
    else
      let new_reachable = add_reachable game reachable reached in search_sol new_reachable (States.add game reached)

let rec write_moves file moves = 
  match moves with 
  | [] -> close_out file;
  | move :: sub_moves -> 
    (Printf.fprintf file "%i %s\n" (fst move) (snd move)); 
    write_moves file sub_moves;