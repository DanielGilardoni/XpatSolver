
  (* Fonction qui permet de comparer deux états. Renvoie 0 si ils sont égaux, sinon 1 ou -1 *)
  let compare_games (game1 : Game.gameStruct) (game2 : Game.gameStruct) : int = 
    let b = (FArray.compare game1.registers game2.registers) in
    if b = 0 then
      FArray.compare game1.columns game2.columns (* renvoit 0 si ils sont égaux. Sinon un nombre != 0 *)
    else
      b
  
  module States = Set.Make (struct type t = Game.gameStruct let compare = compare_games end)
  
  (* Permet de convertir une liste de gameStruct en States *)
  let set_of_list (games : Game.gameStruct list) =
    let set = States.empty in
    List.iter (fun x -> let set = States.add x set in ()) games;
    set
  
  (* Elle renvoie l'ensemble reachable modifié en ajoutant les états de la liste qui n'ont pas déjà été atteints
     ou qui ne sont pas déjà dans les états atteignables *)
  let rec set_reachable reachable reached (games : Game.gameStruct list) = 
    match games with 
    | [] -> reachable
    | game :: sub_games -> 
      (* Si l'etat à déjà été vu ou est déjà dans les etats atteignables, on passe au suivant sinon on l'ajoute aux etats atteignables *)
      if (States.mem game reached) || (States.mem game reachable) then set_reachable reachable reached sub_games 
      else let reachable = (States.add game reachable) in set_reachable reachable reached sub_games
  
  (* Test si on peut deplacer toutes les cartes sur location, et si oui ajoute cet état à to_add_list *)
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
  let add_reachable (game : Game.gameStruct) reachable reached =
    let to_add_list = 
      if (game.name = Baker) then 
        []
      else
        add game "T" []
    in

    let to_add_list = 
      if (game.name = Midnight) || (game.name = Baker) then 
        to_add_list
      else
        add game "V" to_add_list
    in

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
  
  let heuristic score best_score =
    (best_score - score) < 10

  
  (* Recherche une solution: exhaustive si best_score=-1, non exhaustive sinon *)
  let rec search_sol reachable reached best_score heuristic =
    if States.is_empty reachable then None (* Si recherche exhaustive, la partie est insoluble et exit 2 *)
    else let g = States.choose reachable in
    
    let reachable = States.remove g reachable in 

    let game = Game.normalisation_full g in
    let game_score = 
      if best_score >= 0 then
        Game.score game 
      else
        -1
    in
    if (States.mem game reached) || (best_score >= 0 && not (heuristic game_score best_score)) then
      let reachable = States.remove game reachable in
      search_sol reachable reached best_score heuristic
    else
      if Game.score game = 52 then
        Some (List.rev game.history) (* On renvoit l'enchainement des coups (une list de tuple: (départ, arrivée) avec arrivée qui vaut: "[0-51]", "T", "V") *)
      else
        let best_score = 
          if (best_score >= 0 && best_score < game_score) then
            game_score
          else 
            best_score
        in 
        let new_reachable = add_reachable game reachable reached in 
        search_sol new_reachable (States.add game reached) best_score heuristic
  
  let exhaustive game =
    let reachable = States.add game States.empty in
    let reached = States.empty in 
    search_sol reachable reached (-1) heuristic
    
  let non_exhaustive game =
    let reachable = States.add game States.empty in
    let reached = States.empty in
    search_sol reachable reached 0 heuristic
  
  let rec write_moves file moves = 
    match moves with 
    | [] -> close_out file;
    | move :: sub_moves -> 
      (Printf.fprintf file "%i %s\n" (fst move) (snd move)); 
      write_moves file sub_moves;