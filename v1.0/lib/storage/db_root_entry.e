-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
class DB_ROOT_ENTRY

inherit

	DB_INTERNAL

creation

	make

feature

	make (db: DATABASE) is
		local
			i: INTEGER
		do
			!!root_names.make
			from
				i := 1
			until
				i > db.database_root.roots.count
			loop
				root_names.extend (db.database_root.roots.i_th (i).root_name)
				i := i + 1
			end
			database := db
		end

	database: DATABASE

	root_names: SORTED_TWO_WAY_LIST [STRING]

	rights: LINKED_LIST [ROOT_RIGHTS]

	set_root_rights (db_rights: DATABASE_RIGHTS) is
		require
			db_rights /= Void
		local
			rrights: ROOT_RIGHTS
		do
			!!rights.make
			from 
				root_names.start
			until
				root_names.off
			loop
				rrights := db_rights.rights.get_root_rights (root_names.item)
				rights.extend (rrights)
				root_names.forth
			end
		ensure
			rights.count = root_names.count
		end

end

	
