-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--

class NON_COMPARABLE_COUPLE [G, H] 

creation
	
	make
	
feature
	
	make (g: G; h: H) is
		do
			first := g
			second := h
		end
	
	first: G 
	
	second: H

end
