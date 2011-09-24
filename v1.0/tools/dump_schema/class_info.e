-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class CLASS_INFO

creation
	
	make

feature
	
	make (new_class : PCLASS) is
		require
			new_class /= Void and then new_class.exists
		do
			the_class := new_class;
		end;
	
	the_class : PCLASS;
	
	generated : BOOLEAN;
	
	mark_generated is
		require
			not generated
		do
			generated := True;
		ensure
			generated
		end;
	
	clear_generated_flag is
		do
			generated := False;
		ensure
			not generated
		end;

invariant

end -- CLASS_INFO
