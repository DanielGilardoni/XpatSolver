
open XpatLib
open XpatLib.Game
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



(* TODO : La fonction suivante est à adapter et continuer *)

let treat_game conf =
  let permut = XpatRandom.shuffle conf.seed in
  Printf.printf "Voici juste la permutation de graine %d:\n" conf.seed;
  List.iter (fun n -> print_int n; print_string " ") permut;
  print_newline ();
  List.iter (fun n -> Printf.printf "%s " (Card.to_string (Card.of_num n))) permut;
  print_newline ();
  let game = Game.initGame conf.game permut in 
  (* affichage game; *)
  match conf.mode with 
  | Search s -> failwith "ToDo"
  | Check f ->
    let file = open_in f in
    let read_aux () =
      try Some (input_line file) with End_of_file -> None in
    let rec treat_game_aux game file nb_move = 
      match (read_aux ()) with 
      | None -> 
        close_in file;
        if is_won game then 
          (Printf.printf "SUCCESS"; exit 0)
        else
          Printf.printf "ECHEC %d" nb_move; exit 1
      | Some line -> 
        let mots = String.split_on_char ' ' line in
        let card1 = (int_of_string (List.hd mots)) in
        let mot2 = List.nth mots 1 in
        try
          Printf.printf "\n%s,%s %i\n" (Card.to_string (Card.of_num card1)) (Card.to_string (Card.of_num (int_of_string mot2))) nb_move;
          with _ ->
            Printf.printf "\n%s,%s\n" (Card.to_string (Card.of_num card1)) mot2;
        (* affichage game; *)
        let new_game1 = normalisation_full game in
        (* Printf.printf "\n" *)
        (* affichage new_game1; *)
        (* begin *)
        match (rules new_game1 card1 mot2) with
        | false -> Printf.printf "ECHEC %d" nb_move; exit 1
        | true -> 
          let new_game2 = remove new_game1 card1 in 
          let new_game3 = move new_game2 card1 mot2 in
          treat_game_aux new_game3 file (nb_move + 1)
        (* end *)
    in treat_game_aux game file 1

  (* 
  let line = try input_line file with End_of_file -> Printf.printf "SUCCESS"; exit 0
  in  
  let mots = String.split_on_char ' ' line in
  let card1 = int_of_string (List.nth mots 0) in
  let mot2 = List.nth mots 1 in
  let new_game1 = normalisation game in
  match (rules new_game1 card1 mot2) with
  | false -> Printf.printf "ECHEC %d" nb_move; exit 1
  | true -> 
    let new_game2 = remove new_game1 card1 in 
    let new_game3 = move new_game2 card1 mot2
     *)

(* Corriger, afficher SUCCESS, faire boucle sur normalisation...*)
(*
- Résoudre: ça lit un fichier -> liste de lignes -> pour chaque ligne split sur l'espace -> puis normalisation, rules, remove, move sur mot1 mot2
*)
(* Il faut mettre les rois en haut dans Seahaven *)

let main () =
  (* Arg.parse
    [("-check", String (fun filename -> config.mode <- Check filename),
        "<filename>:\tValidate a solution file");
     ("-search", String (fun filename -> config.mode <- Search filename),
        "<filename>:\tSearch a solution and write it to a solution file")]
    set_game_seed (* pour les arguments seuls, sans option devant *)
    "XpatSolver <game>.<number> : search solution for Xpat2 game <number>"; *)
  (* treat_game config *)
  (* let permut = XpatRandom.shuffle config.seed in
  Printf.printf "Voici juste la permutation de graine %d:\n" config.seed;
  List.iter (fun n -> print_int n; print_string " ") permut;
  print_newline ();
  List.iter (fun n -> Printf.printf "%s " (Card.to_string (Card.of_num n))) permut;
  print_newline ();
  let game = Game.initGame config.game permut;
  affichage game;
  exit 0 *)

let _ = if not !Sys.interactive then main () else ()