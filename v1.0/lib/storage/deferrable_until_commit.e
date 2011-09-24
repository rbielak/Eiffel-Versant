-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Action to be done just before the commit
-- 
deferred class DEFERRABLE_UNTIL_COMMIT

inherit

	DB_GLOBAL_INFO

feature {DB_INTERNAL}

	prepare is
			-- This routines prepares the defferable for a delayed action
		do
			if not prepared then
				db_interface.add_deferrable (Current)
				prepared := True
			end
		end

	action_before_commit is
			-- This action will be performed just before the commit
		deferred
		end

	action_before_abort is
			-- This action will be performed just before the abort
		deferred
		end

feature {DB_INTERFACE_INFO}

	commit_action is
		do
			action_before_commit
			prepared := False
		rescue
			prepared := False
		end

	abort_action is
		do
			action_before_abort
			prepared := False
		end

feature {NONE}

	prepared: BOOLEAN

end
