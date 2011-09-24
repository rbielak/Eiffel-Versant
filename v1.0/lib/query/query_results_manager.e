-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class QUERY_RESULTS_MANAGER

feature

	all_results: HASH_TABLE [PLIST[POBJECT], INTEGER] is
		once
			!!Result.make (100)
		end

	wipe_all_result is
		do
io.putstring ("Flushing ")
io.putint (all_results.count)
io.putstring (" plists in QUERY_RESULTS_MANAGER%N")
			all_results.clear_all
		end

end
