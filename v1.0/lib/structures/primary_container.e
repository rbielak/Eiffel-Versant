-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class PRIMARY_CONTAINER

creation

	make

feature

	memory_items: HASH_TABLE [POBJECT, INTEGER]

	make is
		do
			!!memory_items.make (200)
		end

	memorize_item (litem: POBJECT) is
		do
			if litem /= Void and not memory_items.has (litem.object_id) then
				memory_items.put (litem, litem.object_id)
			end
		end

end
