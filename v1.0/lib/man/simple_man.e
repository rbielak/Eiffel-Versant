-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class SIMPLE_MAN [T->MANAGEABLE]

inherit

	MAN_SPEC [T]

feature 

	extend (element: T) is
			-- Add new element to the MAN. Abort if item
			-- with the same keys already there
		require else
			is_available : available
			add_allowed: add_allowed 
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			if not add_allowed then
				except.raise ("Not allowed to add to  MAN");
			end
			if element.pobject_root_id /=0 then
				if element.pobject_root_id /= root_id then
					io.putstring ("Trying into insert into the wrong root%N");
					io.putstring ("root_id=");  io.putint (root_id);
					io.new_line;
					io.putstring (element.tagged_out);
					io.new_line;
					except.raise ("Trying to put into wrong root");
				end
			end
			db_interface.set_current_manager (Current)
			contents.extend (element)
			publish (Void)
			db_interface.unset_current_manager
			debug ("man")
				timer.stop
				io.putstring ("SIMPLE_MAN(")
				io.putstring (root_name)
				io.putstring(").extend")
				timer.print_time
			end
		ensure then
			item_added: has (element)
		end

	append_array (items: ARRAY [T]) is
		require else
			is_available : available
			add_allowed: add_allowed 
		local
			timer: SIMPLE_TIMER
			i: INTEGER
		do
			debug ("man")
				!!timer
				timer.start
			end
			if not add_allowed then
				except.raise ("Not allowed to add to  MAN");
			end
			-- verify root_ids
			from i := items.lower
			until i > items.upper
			loop
				if (items @ i).pobject_root_id /=0 then
					if (items @ i).pobject_root_id /= root_id then
						io.putstring ("Trying into insert into the wrong root%N");
						io.putstring ("root_id=");  io.putint (root_id);
						io.new_line;
						io.putstring ((items @ i).tagged_out);
						io.new_line;
						except.raise ("Trying to put into wrong root");
					end
				end
				i := i + 1
			end
			db_interface.set_current_manager (Current)
			contents.append_array (items)
			publish (Void)
			db_interface.unset_current_manager
			debug ("man")
				timer.stop
				io.putstring ("SIMPLE_MAN(")
				io.putstring (root_name)
				io.putstring(").append_array")
				timer.print_time
			end
		end

	update (element : T) is
			-- Update element that's handled by this manager
		require else
			has: has (element)
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			db_interface.set_current_manager (Current)
			element.store_difference
			db_interface.unset_current_manager
			debug ("man")
				timer.stop
				io.putstring ("SIMPLE_MAN(")
				io.putstring (root_name)
				io.putstring(").update")
				timer.print_time
			end
		end -- update

	has (element: T): BOOLEAN is
			-- See if we have this object in this MAN's cache
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			-- If the thing is not presistent, then we
			-- can't have it
			if element.pobject_id /= 0 then
				Result := contents.has (element)
			end
			debug ("man")
				timer.stop
				io.putstring ("SIMPLE_MAN(")
				io.putstring (root_name)
				io.putstring(").has")
				timer.print_time
			end
		end -- has
	
	remove_item (item: T) is
			-- From RLIST.
			-- In MAN, it does not remove anything.
		do
			if item.pobject_id /= 0 then
				if delete_allowed and then contents.has (item) then
					contents.remove_item (item)
				end
			end
		end -- remove_item

	i_th (i: INTEGER): T is
			-- i_th element in the set
		local
			timer: SIMPLE_TIMER
		do
			debug ("man")
				!!timer
				timer.start
			end
			Result := contents.i_th (i)
			debug ("man")
				timer.stop
				io.putstring ("SIMPLE_MAN(")
				io.putstring (root_name)
				io.putstring(").i_th")
				timer.print_time
			end
		end -- i_th

	remove_all is
			-- From RLIST.
		do
			if delete_allowed then
				contents.remove_all
			end
		end -- remove_all

end -- class SIMPLE_MAN
