-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class END_ACTION

inherit
	
	DBA_ACTION

feature

		error_msg : STRING is "Can't end session."

		sub_action is
			-- finish a db session
		local
			commit : BOOLEAN
		do
			if sess.active then 
				if sess.in_transaction then
					io.putstring ("Commit last transaction? [y/n]")
					io.readchar
					io.readline
					if (io.lastchar = 'y') or (io.lastchar = 'Y') then
						sess.end_transaction
						io.putstring ("Changes saved..  disconnecting%N%N")
					else
						sess.abort_transaction
						io.putstring ("Session aborted --> no changes %
									  %were saved%N%N")
					end
				end
				sess.finish;
			end
		end

end --class

