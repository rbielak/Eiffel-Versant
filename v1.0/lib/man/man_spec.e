-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
deferred class MAN_SPEC [T->MANAGEABLE]

inherit

	PERSISTENCY_ROOT [T]


	RLIST [T]
		undefine
			has, is_equal, copy
		redefine
			is_valid_element
		end

--	DB_ACCESS

feature

	is_valid_element (item: T): BOOLEAN is
		do
			Result := item /= Void
		end

	update (element : T) is
			-- Update element that's handled by this manager
		require
			has: has (element)
			is_available : available
			write_allowed: write_allowed
		deferred
		end -- update

	has (element: T): BOOLEAN is
			-- See if we have this object in this MAN's cache
		require else
			is_available : available
			read_allowed: read_allowed
		deferred
		end -- has

	remove_item (item: T) is
			-- From RLIST.
		require else
			is_available : available
			delete_allowed: delete_allowed
		deferred
		end -- remove_item

	
	i_th (i: INTEGER): T is
			-- i_th element in the set
		require else
			is_available : available
			read_allowed: read_allowed
		deferred
		end -- i_th

	count: INTEGER is
			-- Count of elements in this MAN's cache
		do
			if contents /= Void then
				Result := contents.count
			end
		end -- count

	remove_all is
			-- From RLIST.
		require else
			is_available : available
			delete_allowed: delete_allowed
		deferred
		end -- remove_all
	
	transfer_element (element : T; other_root : MAN_SPEC [T]) is
			-- Transfer an element from another MAN to thisn one
		require
			element_not_void: element /= Void
			element_there: (other_root /= Void) and (other_root.has (element))
		do
			debug ("man")
				io.putstring ("MAN_SPEC.transfer called%N")
			end
			db_interface.start_transaction
			-- First remove the element from the old root
			other_root.remove_item (element);
			-- Next mark the removed element with new root ID
			element.change_root (root_id);
			-- Insert into current root
			extend (element)
			db_interface.end_transaction
		ensure
			element_in_new_root: has (element)
		end


	dump is
		local
			i, total: INTEGER
		do
			from
				io.putstring ("Display the entire contents of ")
				io.putstring (root_name)
				io.new_line
				io.putstring ("Nbr total of element(s) = ")
				total := contents.count
				io.putint (total)
				io.new_line
				i := 1
			until
				i > total
			loop
				contents.i_th(i).dump
				i := i + 1
			end
			io.new_line
		end -- dump


end -- class MAN_SPEC
