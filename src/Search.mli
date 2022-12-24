
module States : (Set.S with type elt = Game.gameStruct)

val compare_games : Game.gameStruct -> Game.gameStruct -> int
val search_sol : States.t -> States.t -> (int * string) list