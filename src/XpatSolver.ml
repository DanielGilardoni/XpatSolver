
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

let treat_game conf =
  let permut = XpatRandom.shuffle conf.seed in
  Printf.printf "Voici juste la permutation de graine %d:\n" conf.seed;
  List.iter (fun n -> print_int n; print_string " ") permut;
  print_newline ();
  List.iter (fun n -> Printf.printf "%s " (Card.to_string (Card.of_num n))) permut;
  print_newline ();
  let game = Game.initGame conf.game permut in 
  (* disp game; *)
  match conf.mode with 
  | Search s -> failwith "ToDo"
  | Check f ->
    let file = open_in f in
    let read_aux () =
      try Some (input_line file) with End_of_file -> None in
    let rec treat_game_aux game file nb_move = 
      try
        match (read_aux ()) with 
        | None ->
          let game = normalisation_full game in
          close_in file;
          if is_won game then 
            (Printf.printf "SUCCES"; exit 0)
          else
            (Printf.printf "ECHEC %d" nb_move; exit 1)
        | Some line -> 
          let mots = String.split_on_char ' ' line in
          let card1 = (int_of_string (List.hd mots)) in
          let mot2 = List.nth mots 1 in
          (* try
            Printf.printf "\n%s,%s %i\n" (Card.to_string (Card.of_num card1)) (Card.to_string (Card.of_num (int_of_string mot2))) nb_move;
            with _ ->
              (* Printf.printf "\n%s,%s\n" (Card.to_string (Card.of_num card1)) mot2; *)
          Printf.printf "%d\n" nb_move;
          disp game; *)
          let new_game1 = normalisation_full game in
          (* Printf.printf "\n" *)
          (* disp new_game1; *)
          (* begin *)
          (* Printf.printf "%b\n" (rules new_game1 card1 mot2); *)
          match (rules new_game1 card1 mot2) with
          | false -> Printf.printf "ECHEC %d" nb_move; exit 1
          | true -> 
            let new_game2 = remove new_game1 card1 in 
            let new_game3 = move new_game2 card1 mot2 in
            (* Printf.printf "\nDebut move\n";
            disp new_game3; *)
            (* Pour vérifier si l'historique *)
            (* disp_history new_game3;
            print_newline ();
            print_newline (); *)
            treat_game_aux new_game3 file (nb_move + 1)
      with _ -> (Printf.printf "ECHEC %d" nb_move; exit 1)
        (* end *)
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