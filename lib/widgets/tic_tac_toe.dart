import 'package:flutter/material.dart';

class TicTacToe extends StatefulWidget {
  const TicTacToe({super.key});

  @override
  State<TicTacToe> createState() => _TicTacToeState();
}

class _TicTacToeState extends State<TicTacToe> {
  // Border state to keep the track of moves
  final List<String> board = List.filled(9, "");
  //current players (x or o)
  String currentPlayer= "X";
  //variable to store the winner
  String winner = "";
  //flag to indicate a tie
  bool isTie = false;
  //function to handle a player's move
  player(int index){
    if(winner != '' || board[index] != ""){
      return;  //if the game is won or the cell is not empty do nothing
    }
    setState(() {
      board[index] = currentPlayer ; //set the current cell to the current player's symbol
      currentPlayer = currentPlayer == "X"
          ? "0"
          : "X";  //SWITCH TO THE one to the another player
      checkForWinner();
    },
    );
  }

  //function for check for a winner or a tie
  checkForWinner() {
    List<List<int>> lines = [
      [0,1,2],
      [3,4,5],
      [6,7,8],
      [0,3,6],
      [1,4,7],
      [2,5,8],
      [0,4,8],
      [2,4,6],
    ];
    //check each winning combination
    for(List<int> line in lines){
      String player1 = board[line[0]];
      String player2 = board[line[1]];
      String player3 = board[line[2]];
      if(player1 == "" || player2 == "" || player3 == ""){
        continue; //if any cell in the combination is empty, skip this combination

      }
      if(player1 == player2 && player2 == player3){
        setState(() {
          winner =
              player1; //if all cells in the comb are same, set the winner
        });
        return;
      }
    }
    // Check for a tie
    if(!board.contains("")){
      setState(() {
        isTie = true; //if the cells are empty and there's no winner its a tie
      });
    }
  }
  // fucntion to reset and play new game
  resetGame(){
    setState(() {
      board.fillRange(0, 9,''); // clear the board
      currentPlayer = 'X';
      winner = ''; // clear the winner
      isTie = false; //clear the tie flag
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: Colors.blue ,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border : Border.all(
                   color: currentPlayer == "X"
                       ?Colors.amber
                       :Colors.transparent,
                  ),
                  boxShadow: const [
                    BoxShadow(
                    color: Colors.black38,
                    blurRadius:3,
                  ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.person,
                    color: Colors.white,
                    size: 55,
                    ),
                    SizedBox(height:10),
                    Text("BOT 1",
                    style: TextStyle(
                        color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                    ),
                    ),
                    SizedBox(height:10),
                    Text("X",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                  ],
                ),
                ),
              ),
              SizedBox(width: size.width*0.08),
              Container(
                decoration:  BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border : Border.all(
                    color: currentPlayer == "0"
                        ?Colors.amber
                        :Colors.transparent,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius:3,
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.person,
                        color: Colors.white,
                        size: 55,
                      ),
                      SizedBox(height:10),
                      Text("BOT 2",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(height:10),
                      Text("0",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: size.height*0.04),
          //display the winner msg
          if(winner!= "")Row(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(winner,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
            ),
            const Text(" WON!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 35,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          ),
          // display tie msg
          if(isTie)
            const Text("It's a Tie!",
          style: TextStyle(
            color: Colors.tealAccent,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          ),
          //For game board
          Padding(
              padding: const EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: 9,
              padding: const EdgeInsets.all(10),
                shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10
              ),
              itemBuilder: (context, index){
              return GestureDetector(
                onTap: () {
                  player(index);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Center(
                    child: Text(board[index],
                    style: const TextStyle(
                      fontSize: 50,
                      color: Colors.white
                    ),
                    ),
                  ),
                ),
              );
              },
                ),
          ),
          //reset button
          if(winner!="" || isTie)
            ElevatedButton(onPressed: resetGame, 
                child: const Text("Play Again",
                style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),),
            ),
        ],
      ) ,
    );
  }
}
