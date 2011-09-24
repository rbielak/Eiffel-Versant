-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- This class is used to produce a dump of group rights without
-- wildcards in the persistent root specification
--
class DB_RIGHTS_COLLECTION

inherit

	SHARED_CONNECTION

creation

	make

feature


	make is
		local
			db_names: ARRAY [STRING]
			i: INTEGER
			entry: DB_ROOT_ENTRY
			db: DATABASE
		do
			db_names := session.database_names
			-- first get the databases
			!!databases.make
			from
				i := 1
			until
				i > db_names.count
			loop
				databases.extend (session.find_database (db_names @ i))
				i := i + 1
			end
			-- for each database get the list of persistent roots
			!!expanded_root_lists.make
			from
				databases.start
			until 
				databases.off
			loop
				db := databases.item
				!!entry.make (db)
				expanded_root_lists.extend (entry)
				databases.forth
			end
		end

	
	databases: LINKED_LIST [DATABASE]
			-- databases connected

	expanded_root_lists : LINKED_LIST [DB_ROOT_ENTRY]
			-- for each database a list of roots and corresponding 
			-- rights

	last_group: USER_GROUP

	set_rights_for_group (group: USER_GROUP) is
		require
			group /= Void
		local
			db_rights: DATABASE_RIGHTS
		do
			last_group := group
			from
				databases.start
				expanded_root_lists.start
			until
				databases.off
			loop
				db_rights := group.group_rights_set.rights_for_database (databases.item.name_without_server)
				expanded_root_lists.item.set_root_rights (db_rights)
				databases.forth
				expanded_root_lists.forth
			end
		ensure
			last_group = group
		end

end
