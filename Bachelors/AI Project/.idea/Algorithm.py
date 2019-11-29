from Board import *
from time import *
import sys

infinity = 100000
max_time = 15

class alpha_beta_search:
    start_time = time()
    def __init__(self):
        self.start_time = time()
        self.v_value = infinity
        self.level = 0
        self.no_of_nodes = 1
        self.min_pruning = 0
        self.max_pruning = 0

    def search(self, state):
        # print("Entering heursitic search.........")
        self.v_value = self.max_value(state, -infinity, infinity, 0)
        # print("SELF.V_VALUE" + str(self.v_value))
        for child in state.get_children():
            if child.get_utility() >= self.v_value:
                return child
            else:
                my_max = -1000
                for child in state.get_children():
                    if child.get_utility() >= my_max:
                        my_max = child.get_utility()
                for child in state.get_children():
                    if child.get_utility() == my_max:
                        return child
                print("Something got bad and the code crashed")

    def max_value(self, state, alpha, beta, level):
        self.no_of_nodes = self.no_of_nodes + 1
        # print("Entering max........." + str(state.get_utility()))
        if self.terminal_test(state, level):
            return state.get_utility()
        self.v_value = -infinity
        for i in state.get_children():
            self.v_value = max(self.v_value, self.min_value(i, alpha, beta, level + 1))
            if self.v_value >= beta:
                self.max_pruning = self.max_pruning + 1
                return self.v_value
            alpha = max(alpha, self.v_value)
        return self.v_value

    def min_value(self, state, alpha, beta, level):
        self.no_of_nodes = self.no_of_nodes + 1
        # print("Entering min........."  + str(state.get_utility()))
        if self.terminal_test(state, level):
            return state.get_utility()
        self.v_value = infinity
        for i in state.get_children():
            self.v_value = min(self.v_value, self.max_value(i, alpha, beta, level + 1))
            if self.v_value <= alpha:
                self.min_pruning = self.min_pruning + 1
                return self.v_value
            beta = min(beta, self.v_value)
        return self.v_value


    def terminal_test(self, state, level):
        if self.level < level:
            self.level = self.level + 1
        if time() - self.start_time > max_time:
            return True
        else:
            if state.get_utility() > 600:
                return True
            elif state.get_utility() < -600:
                return True
            else:
                return False


