-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class ARRAYED_H_TABLE [G, H->HASHABLE]

inherit

	HASH_TABLE[G, H]
		export {ANY}
			content, keys, deleted_marks,
			Found_constant, control
		end

creation

	make

feature

	existing_item: G is
			-- Fast item seeking after calling `has'.
		require
			found_item: control = Found_constant
		do
			Result := content.item (position)
		end -- existing_item

	array_representation: ARRAY [G] is
			-- Representation as a linear structure
		local
			i: INTEGER
		do 
			if count > 0 then
				!!Result.make (1, count)
				from
					start
					i := 1
				until
					off
				loop
					Result.put (item_for_iteration, i)
					i := i + 1
					forth
				end
			end
		ensure
			cursor_off: off
		end -- array_representation

--	old_array_representation: ARRAY [G] is
--		local
--			i, j, table_size: INTEGER
--			l_dead_key: H
--		do
--			!!Result.make (1, count)
--			from
--				table_size := content.upper
--				j := 1
--			until
--				i > table_size
--			loop
--				if keys.item (i) /= l_dead_key then
--					Result.put (content.item (i), j)
--					j := j + 1
--				end;
--				i := i + 1
--			end
--		end

feature {DB_INTERFACE_INFO}

	decrement_count is
		do
			count := count - 1
		end

end -- class ARRAYED_H_TABLE
