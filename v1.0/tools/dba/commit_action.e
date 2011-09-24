-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class COMMIT_ACTION

inherit

	DBA_ACTION

feature

	error_msg : STRING is "Cannot commit";
	
	sub_action is
		do
			if sess.in_transaction then
				sess.end_transaction
				io.putstring ("Committed....%N")
			else
				io.putstring ("Not in transaction...%N")
			end
		end

end -- class
