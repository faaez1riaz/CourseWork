import copy

blank = '-'
comp = 'X'
human = 'H'
class board():
      class node():
        type =''
        curr_pos = []
        def __init__(self,node_type, position):
            self.type = copy.copy(node_type)
            self.curr_pos = copy.copy(position)
        def set_type(self, node_type):
            self.type = copy.copy(node_type)
        def set_pos(self, position):
            self.curr_pos = copy.copy(position)
        def subract_pos(self, position):
            x = position[0] - self.curr_pos[0]
            y = position[1] - self.curr_pos[1]
            return [x, y]

      def get_board(self):
          return self.c_board

      def __init__(self, row_len, col_len, d):
          self.c_board = []
          self.turn = None  # true for human, false for comp
          self.width = row_len
          self.hieght = col_len
          self.diff = d
          for i in range(row_len):
              self.c_board.append([])
              for j in range(col_len):
                  new_node = self.node(blank, [i, j])
                  self.c_board[i].append(new_node)
          self.set_pieces()

      def print_board(self):
          for i in range(self.width):
              if i == 0:
                  print('', end='   ')
                  for j in range(self.hieght):
                    print(j, end='  ')
              print('\n')
              print(i, end='  ')
              for j in range(self.hieght):
                  print(self.c_board[i][j].type, end='  ')
          print('\n____________________________\n')

      def set_pieces(self):
          for i in range(self.width):
              for j in range(self.hieght):
                  if i == 0:
                      if j % 2 > 0:
                          self.c_board[i][j].set_type(comp)
                  elif i == 1:
                      if j % 2 == 0:
                          self.c_board[i][j].set_type(comp)
                  elif i == self.hieght - 2:
                      if j % 2 > 0:
                          self.c_board[i][j].set_type(human)
                  elif i == self.hieght - 1:
                      if j % 2 == 0:
                          self.c_board[i][j].set_type(human)

      def get_moves(self, goti):
          x = copy.copy(goti.curr_pos[0])
          y = copy.copy(goti.curr_pos[1])
          list_of_moves = []
          if goti.type == human:
            list_of_moves.append([x - 1, y + 1])
            list_of_moves.append([x - 1, y - 1])
            list_of_moves.append([x - 2, y + 2])
            list_of_moves.append([x - 2, y - 2])
          elif goti.type == comp:
            list_of_moves.append([x + 1, y + 1])
            list_of_moves.append([x + 1, y - 1])
            list_of_moves.append([x + 2, y + 2])
            list_of_moves.append([x + 2, y - 2])
          else:
              print("")
          return list_of_moves

      def check_legal_move(self, goti, move_to):
          if move_to[0] >= self.width or move_to[1] >= self.hieght or move_to[0] < 0 or move_to[1] < 0:
              # print("Invalid Move: Outside the board")
              return False
          elif self.c_board[move_to[0]][move_to[1]].type != blank:
              # print("Invalid Move: destination already has a piece")
              return False
          elif goti.type != blank:
            if goti.type == comp:
                if goti.subract_pos(move_to) == [1, 1] or goti.subract_pos(move_to) == [1, -1]:
                    return True
                elif (goti.subract_pos(move_to) == [2, 2] or goti.subract_pos(move_to) == [2, -2]) and (self.c_board[int((goti.curr_pos[0] + move_to[0]) / 2)][int((goti.curr_pos[1] + move_to[1]) / 2)].type == human):
                    return True
                else:
                    # print("Invalid Move for comp")
                    return False
            elif goti.type == human:
                if goti.subract_pos(move_to) == [-1, 1] or goti.subract_pos(move_to) == [-1, -1]:
                    return True
                elif (goti.subract_pos(move_to) == [-2, 2] or goti.subract_pos(move_to) == [-2, -2]) and (self.c_board[int((goti.curr_pos[0] + move_to[0]) / 2)][int((goti.curr_pos[1] + move_to[1]) / 2)].type == comp):
                    return True
                else:
                    # print("Invalid Move for human")
                    return False
          else:
            print("")

      def check_capture(self, goti, move_to):
          if self.check_legal_move(goti, move_to):
            if goti.type == comp:
                if goti.subract_pos(move_to) == [2, 2] or goti.subract_pos(move_to) == [2, -2]:
                    return True
                else:
                    return False
            elif goti.type == human:
                if goti.subract_pos(move_to) == [-2, 2] or goti.subract_pos(move_to) == [-2, -2]:
                    return True
                else:
                    return False

      def get_utility(self):
          human_value = 1
          comp_value = 1
          dist_comp = 0
          dist_human = 0
          for i in self.get_board():
              for j in i:
                  if j.type == human:
                      human_value = human_value + 1
                      dist_human += j.curr_pos[1]
                  elif j.type == comp:
                      comp_value = comp_value + 1
                      dist_comp += j.curr_pos[1]
          if self.diff == 1:
              return (comp_value * 100 + dist_comp - human_value * 100)
          elif self.diff == 2:
              return (comp_value * 50 + dist_comp - human_value * 100)
          elif self.diff == 3:
              return (comp_value * 50 + dist_comp - human_value * 100 - dist_human)
          else:
              print("MAJOOOOOOOOOOOOOOOOOOOOOOOOOOOOOR TROUUUUUUUBLE")


      def complete_move(self, goti, move_to):
          if self.check_capture(goti, move_to):
              captured_goti = [int((copy.copy(goti.curr_pos[0])+ copy.copy(move_to[0]))/2), int((copy.copy(goti.curr_pos[1]) + copy.copy(move_to[1]))/2)]
              curr_type = copy.copy(self.c_board[goti.curr_pos[0]][goti.curr_pos[1]].type)
              self.c_board[goti.curr_pos[0]][goti.curr_pos[1]].type = blank
              self.c_board[move_to[0]][move_to[1]].type = copy.copy(curr_type)
              self.c_board[captured_goti[0]][captured_goti[1]].type = blank
          elif self.check_legal_move(goti, move_to):
              curr_type = copy.copy(self.c_board[goti.curr_pos[0]][goti.curr_pos[1]].type)
              curr_p = copy.copy(self.c_board[goti.curr_pos[0]][goti.curr_pos[1]].curr_pos)
              self.c_board[goti.curr_pos[0]][goti.curr_pos[1]].type = blank
              self.c_board[move_to[0]][move_to[1]].type = copy.copy(curr_type)
          else:
              print("")

      def make_copy(self, copied_board):
          # self.print_board()
          for i in range(self.width):
              for j in range(self.hieght):
                  copied_board.c_board[i][j].type = copy.copy(self.c_board[i][j].type)
          # copied_board.print_board()
          if(self.turn):
            copied_board.turn = True
          else:
            copied_board.turn = False
            copied_board.hieght = copy.copy(self.hieght)
            copied_board.width = copy.copy(self.width)


      def get_children(self):
          children = []
          for i in range(self.width):
              for j in range(self.hieght):
                # print(self.c_board[i][j].curr_pos, end='&')
                # print(self.c_board[i][j].type)
                # print(self.turn)
                if self.turn == True:
                    if self.c_board[i][j].type == human:
                        moves = self.get_moves(self.c_board[i][j])
                        for move in moves:
                            if self.check_legal_move(self.c_board[i][j], move):
                                # print("legal move..............................................")
                                child = board(6, 6, self.diff)
                                self.make_copy(child)
                                child.complete_move(self.c_board[i][j], move)
                                child.turn = not child.turn
                                # print(self.turn)
                                children.append(child)
                                # child.print_board()
                if self.turn == False:
                    if self.c_board[i][j].type == comp:
                        moves = self.get_moves(self.c_board[i][j])
                        for move in moves:
                            # print(self.c_board[i][j].curr_pos, end=',')
                            # print(move, end=',')
                            # print(self.c_board[i][j].type)
                            if self.check_legal_move(self.c_board[i][j], move):
                                # print("legal move")
                                child = board(6, 6, self.diff)
                                self.make_copy(child)
                                child.complete_move(self.c_board[i][j], move)
                                child.turn = not child.turn
                                # print(self.turn)
                                children.append(child)
                                # child.print_board()
          return children




