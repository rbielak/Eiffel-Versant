-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PLIST_MANAGER

creation

	make

feature

	list: LINKED_LIST [PLIST[POBJECT]]

	batch_mode: BOOLEAN

	make is
		do
			!!list.make
		end -- make

	add (plist: PLIST [POBJECT]) is
		do
			if batch_mode then
				list.extend (plist)
			end
		end

	flush is
		do
			io.putstring ("Flushing ")
			io.putint (list.count)
			io.putstring (" plists in PLIST_MANAGER%N")
			list.wipe_out
		end

	wipe_out is
		do
			list.wipe_out
		end

	start_batch is
		do
			batch_mode := true
		end

	end_batch is
		do
			batch_mode := false
		end

end -- PLIST_MANAGER
