
module States : (Set.S with type elt = Game.gameStruct)

val compare_games : Game.gameStruct -> Game.gameStruct -> int
val set_reachable : States.t -> States.t -> Game.gameStruct list -> States.t 
val add : Game.gameStruct -> string -> Game.gameStruct list -> Game.gameStruct list
val add_reachable : Game.gameStruct -> States.t -> States.t -> States.t
val search_sol : States.t -> States.t -> int -> (int -> int -> bool) -> (int * string) list option

val non_exhaustive : Game.gameStruct -> (int * string) list option

val write_moves : out_channel -> (int * string) list -> unit