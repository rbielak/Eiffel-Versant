-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class DBA_TRANSACTION

inherit
	
	DBA_ACTION
		redefine
			action
		end

feature

	action is
		local
			crashed: BOOLEAN
		do
			if not crashed then
				if sess.active and then not sess.in_transaction then
					sess.start_transaction
				end
				sub_action
			else
				error_report
				-- This runs if we crash
				if sess.in_transaction then
					sess.abort_transaction
				end
			end
		rescue
			if not crashed then
				crashed := True
				retry
			end
		end

end

