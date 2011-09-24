-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- A handler for developer exceptions
--

class VERSION_MISMATCH_EXCEPTION_HANDLER

inherit
	
	EIF_DEVELOPER_EXCEPTION_HANDLER
	SHARED_CONNECTION


feature
	
	handle (ex_name: STRING): BOOLEAN is
		do
			-- Onlu handle version mismatch exceptions
			if ex_name.is_equal ("Version mismatch") then
				io.putstring ("Version mismatch exception!!!%N")
				if session.version_mismatch_list.count > 0 then
					-- create a double list of mismatched objects and
					-- display them 
					!!list_pair.make ("Version mismatches")
					from 
						session.version_mismatch_list.start
					until
						session.version_mismatch_list.off
					loop
						list_pair.add_object (session.version_mismatch_list.item)
						session.version_mismatch_list.forth
					end
					shell.ask_question ("Store failed! Version Mismatch.%NDisplay %
                                        %objects and continue?", "Yes", "Abort") 
					if shell.question_answer then
						-- Display the object and return True, since
						-- exception was handled
						shell.show_object (list_pair)
						Result := True
					end
				end
			end
		end
	
	list_pair: LIST_PAIR

end -- VERSION_MISMATCH_EXCEPTION_HANDLER
