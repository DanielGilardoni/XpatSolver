

(* Attention aux registres. Ils peuvent contenir les mêmes cartes pas dans
   le meme ordre. Il faut les trier peut être avant ? *)
let compare_games (game1 : Game.gameStruct) (game2 : Game.gameStruct) : bool = 
  if FArray.compare game1.registers game2.registers then
    FArray.compare game1.columns game2.columns
  else
    false