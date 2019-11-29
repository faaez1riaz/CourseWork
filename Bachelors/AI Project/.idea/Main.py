from Board import *
from Algorithm import *
import sys

print("Choose Difficulty:")
diff = input("1 for easy; 2 for medium; 3 for hard: ")
game_board = board(6, 6, int(diff))
game_board.print_board()
game_board.turn = True
winning_condition = False

while winning_condition == False:
    if game_board.turn == True:
        illegal = True
        while illegal:
            print("Enter x and y courdinates for the piece that you want to move:")
            from_x = input("y coordinate:")
            from_y = input("x coordinate:")
            print("Enter the x and y coordinates of where you want to move:")
            to_x = int(input("y coordinate:"))
            to_y = int(input("x coordinate:"))
            goti = game_board.c_board[int(from_x)][int(from_y)]
            print("completing move......")
            if game_board.check_legal_move(game_board.c_board[int(from_x)][int(from_y)], [to_x, to_y]) == False:
                print("Illegal move.....try again")
            else:
                game_board.complete_move(goti, [to_x, to_y])
                game_board.turn = False
                game_board.print_board()
                illegal = False
        if game_board.get_utility() > 600 or game_board.get_utility() < -600:
            winning_condition = True
            print("CONGRATULATIONS.............YOU WON THE GAME!")
            break
        # for i in range(game_board.width):
        #     for j in range(game_board.hieght):
        #         for x in range(i - 2, i + 2):
        #             for y in range(j - 2, j + 2):
        #                 if game_board.check_legal_move(game_board.c_board[i][j],[x, y]) and game_board.turn == True and game_board.c_board[i][j].type == human:
        #                     for child in game_board.get_children():
        #                         my_max = 1000
        #                         for child in game_board.get_children():
        #                             if child.get_utility() <= my_max:
        #                                 my_max = child.get_utility()
        #                         for child in game_board.get_children():
        #                             if child.get_utility() == my_max:
        #                                 from_x = i
        #                                 from_y = j
        #                                 to_x = x
        #                                 to_y = y
        #                                 goti = game_board.c_board[int(from_x)][int(from_y)]
        #                                 game_board.complete_move(goti, [to_x, to_y])
        #                                 print("completing move......")
        #                                 game_board.turn = False
        #                                 game_board.print_board()
        #                     if game_board.get_utility() > 600 or game_board.get_utility() < -600:
        #                         winning_condition = True
        #                         print("CONGRATULATIONS.............YOU WON THE GAME!")
        #                         break
        #                 if game_board.turn == False:
        #                     break


    elif game_board.turn == False:
        print("computing move for computer.......")
        move = alpha_beta_search()
        return_board = move.search(game_board)
        return_board.make_copy(game_board)
        game_board.print_board()
        game_board.turn = True
        print("Heuristic value:" + str(game_board.get_utility()))
        print("Maximum depth of tree: " + str(move.level) + "|" "Maximum number of nodes: " + str(move.no_of_nodes))
        print("Number of times pruning occurred in max value: " + str(move.max_pruning) + " | " "Number of times pruning occurred in min value: " + str(move.min_pruning))
        if game_board.get_utility() > 600 or game_board.get_utility() < -600:
            winning_condition = True
            print("SORRY..............THE COMPUTER WON THIS GAME!")
            break





#
# goti_x = 4 #input("Please enter x coordinate:")
# goti_y = 1 #input("Please enter y coordinate:")
# goti = game_board.c_board[int(goti_x)][int(goti_y)]
# game_board.complete_move(goti, [3,2])
# game_board.print_board()



# x = game_board.get_children();
# goti_x = 1 #input("Please enter x coordinate:")
# goti_y = 2 #input("Please enter y coordinate:")
# goti = game_board.c_board[int(goti_x)][int(goti_y)]
# game_board.complete_move(goti, [2,3])
# game_board.print_board()
# print("DRRRRRRRRRRRRRRR")
# x = board(6, 6)
# game_board.print_board()
# game_board.make_copy(x)
# print(game_board.turn)
# print(game_board.get_utility())
# for i in x:
#     for j in i.get_children():
#         print(j.turn)
#         j.print_board()



# ##
# goti_x = 3 #input("Please enter x coordinate:")
# goti_y = 2 #input("Please enter y coordinate:")
# goti = game_board.c_board[int(goti_x)][int(goti_y)]
# game_board.complete_move(goti, [2,3])
# game_board.print_board()
# print(game_board.get_utility())
#
#
# ##
# goti_x = 1 #input("Please enter x coordinate:")
# goti_y = 2 #input("Please enter y coordinate:")
# goti = game_board.c_board[int(goti_x)][int(goti_y)]
# game_board.complete_move(goti, [3,4])
# game_board.print_board()
# print(game_board.get_utility())