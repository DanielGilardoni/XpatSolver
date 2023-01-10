
open XpatLib
open XpatLib.Game
open XpatLib.Search
open Format

type mode =
  | Check of string (* filename of a solution file to check *)
  | Search of string (* filename where to write the solution *)

type config = { mutable game : game; mutable seed: int; mutable mode: mode }
let config = { game = Freecell; seed = 1; mode = Search "" }

let getgame = function
  | "FreeCell"|"fc" -> Freecell
  | "Seahaven"|"st" -> Seahaven
  | "MidnightOil"|"mo" -> Midnight
  | "BakersDozen"|"bd" -> Baker
  | _ -> raise Not_found

let split_on_dot name =
  match String.split_on_char '.' name with
  | [string1;string2] -> (string1,string2)
  | _ -> raise Not_found

let set_game_seed name =
  try
    let (sname,snum) = split_on_dot name in
    config.game <- getgame sname;
    config.seed <- int_of_string snum
  with _ -> failwith ("Error: <game>.<number> expected, with <game> in "^
                      "FreeCell Seahaven MidnightOil BakersDozen")

let treat_game conf =
  let permut = XpatRandom.shuffle conf.seed in
  Printf.printf "Voici juste la permutation de graine %d:\n" conf.seed;
  List.iter (fun n -> print_int n; print_string " ") permut;
  print_newline ();
  List.iter (fun n -> Printf.printf "%s " (Card.to_string (Card.of_num n))) permut;
  print_newline ();

  (* On initialise la partie avec la bonne permutation correspondant à la conf.seed *)
  let game = Game.initGame conf.game permut in 

  (* On fait soit une recherche, soit une vérification d'un fichier *)
  match conf.mode with 
  (* On effectue une recherche exhaustive ou non_exhaustive *)
  | Search s -> 
    let file = open_out s in (* On ouvre le fichier dans lequel on va écrire la solution *)
    let sol = exhaustive game in (* Ici on peut appeler "non_exhaustive game" *)
    begin
    match sol with 
    (* Si il n'y a pas de solution: on affiche INSOLUBLE et code erreur 2.
       Pour non_exhaustive, il faut remplacer INSOLUBLE par ECHEC et exit 1 *)
    | None -> (close_out file; Printf.printf "INSOLUBLE"; exit 2)
    | Some moves ->
      (* Si il y a une solution, on écrit les mouvements dans le fichier file et on affiche SUCCES *)
      (write_moves file moves;
      Printf.printf "SUCCES"; exit 0)
    end

  (* On vérifie si  un fichier solution est correcte *)
  | Check f ->
    let file = open_in f in (* On ouvre le fichier *)
    (* Cette fonction lit une ligne du fichier file. Renvoie None si on est arrivé au bout *)
    let read_aux () =
      try Some (input_line file) with End_of_file -> None in
    (* Cette fonction permet d'executer tous les coups du fichier file.
       Elle s'appelle recursivement tant que la fin du fichier n'est pas atteint *)
    let rec treat_game_aux game file nb_move = 
      try
        (* On lit le prochain coup *)
        match (read_aux ()) with 
        (* Si on est au bout du fichier *)
        | None ->
          let game = normalisation_full game in (* On normalise la partie *)
          close_in file;
          if is_won game then (* Si la partie est gagné, on renvoit SUCCES *)
            (Printf.printf "SUCCES"; exit 0)
          else (* Sinon, la partie est perdu et le fichier n'est pas une solution *)
            (Printf.printf "ECHEC %d" nb_move; exit 1)
        
        (* On prend la prochaine ligne *)
        | Some line -> 
          (* On récupère la carte et l'endroit où on veut la placer *)
          let mots = String.split_on_char ' ' line in
          let card1 = (int_of_string (List.hd mots)) in
          let mot2 = List.nth mots 1 in
          
          (* On normalise la partie *)
          let new_game1 = normalisation_full game in
          
          (* On vérifie si le mouvement donné par le fichier est autorisé *)
          match (rules new_game1 card1 mot2) with
          (* Le mouvement est interdit *)
          | false -> Printf.printf "ECHEC %d" nb_move; exit 1
          (* Le mouvement est autorisé*)
          | true -> 
            (* On retire la carte et on la place sur sa nouvelle location *)
            let new_game2 = remove new_game1 card1 in 
            let new_game3 = move new_game2 card1 mot2 in

            (* On appelle recursivement treat_game pour effectuer le prochain coup *)
            treat_game_aux new_game3 file (nb_move + 1)
      with _ -> (Printf.printf "ECHEC %d" nb_move; exit 1)
    
    (* On appelle treat_game_aux pour vérifier le fichier solution *)
    in treat_game_aux game file 1

  

let main () =
   Arg.parse
    [("-check", String (fun filename -> config.mode <- Check filename),
        "<filename>:\tValidate a solution file");
     ("-search", String (fun filename -> config.mode <- Search filename),
        "<filename>:\tSearch a solution and write it to a solution file")]
    set_game_seed (* pour les arguments seuls, sans option devant *)
    "XpatSolver <game>.<number> : search solution for Xpat2 game <number>"; 
   treat_game config

let _ = if not !Sys.interactive then main () else ()