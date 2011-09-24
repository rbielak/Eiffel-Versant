-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
indexing

	description: "PVIEWER - partially retrieve or store a POBJECT"
	
class PVIEWER

inherit

	DB_GLOBAL_INFO

	DB_INTERNAL

creation

	make

feature -- creation

	make (new_class_name: STRING; attribute_names: ARRAY [STRING]) is
		require
			class_not_void: new_class_name /= Void
			attribute_names_not_void: attribute_names /= Void
			attribute_names_valid: attribute_names.count > 0
		do
			class_name := new_class_name.twin
			view_attributes := attribute_names
		ensure
			class_name.is_equal (new_class_name)
		end

feature -- names

	class_name: STRING
			-- name of the class on which this view applies

	view_attributes: ARRAY [STRING]
			-- attributes in this view

feature -- view routines

	retrieve_view_by_pobject_id (pobject_id: INTEGER): ARRAY [ANY] is
			-- retrieve array of attributes of the specified object
		require
			pobject_id_valid: pobject_id /= 0
		do
			except.raise ("Not implemented")
		end

	retrieve_view (object: POBJECT): ARRAY [ANY] is
		require
			object_not_void: object /= Void
		do
			except.raise ("Not implemented")
		end

	store_difference_view (object: POBJECT) is
			-- store difference on current object and the view attributes
		require
			object_not_void: object /= Void
		local
			context: DB_OPERATION_CONTEXT
			pattr: OBJECT_PATTRIBUTE
			obj, it: POBJECT
			found_mismatch, reset_root_id, reset_db: BOOLEAN
			i: INTEGER
		do
			!!context.make_for_store_difference
			db_interface.operation_context_stack.put (context)
			db_interface.version_mismatch_handler.prepare
			db_interface.reset_mismatch_list
			if db_interface.current_root_id = 0 then
				reset_root_id := True
				db_interface.set_current_root_id (object.pobject_root_id)
			end
			if (object.pobject_id /= 0) and then object.database /= Void then
				db_interface.set_current_database (object.database)
				reset_db := True
			end
			if object.pobject_class = Void then
				object.reset_pobject_class
			end
			pclass := object.pobject_class
			-- mark the top object in progress, so we don't traverse it
			object.mark_in_progress (context)
			-- find all different objects
			from i := 1
			until i > view_attributes.count
			loop
				pattr ?= pclass.attributes.item (view_attributes @ i)
				-- if it's a reference to an object we can traverse
				if pattr /= Void then
					obj := pattr.value (object)
					if obj /= Void then
						obj.check_diff_obj (True, context)
					end
				end
				i := i + 1
			end
			-- at this point the "context" holds all the different 
			-- objects. 
			context.mark_objects_not_in_progress
			-- now check the top object
			if (object.pobject_id /= 0) and object.write_allowed then
				-- Write lock object, if we can write it
				db_interface.lock_object (object.pobject_id, db_interface.db_write_lock)
				-- Version check must be done after locking,
				-- which refreshes the Versant cache
				if (object.pobject_version /= object.cache_version) then
					if not db_interface.version_mismatch_handler.handle (object) then
						-- Add the object to a global mismatch list
						found_mismatch := True
						db_interface.mismatch_list.extend (object)
					end
				end
			end

			if not context.diff_stack.empty then
				-- lock and check version
				from context.diff_stack.start
				until context.diff_stack.off
				loop
					it := context.diff_stack.iterated_item
					context.diff_stack.forth
					if (it.pobject_id /= 0) and then it.write_allowed then
						-- Write lock object, if we can write it
						db_interface.lock_object (it.pobject_id, db_interface.db_write_lock)
						-- Versin check must be done after locking,
						-- which refreshes the Versant cache
						if (it.pobject_version /= it.cache_version) then
							if not db_interface.version_mismatch_handler.handle (it) then
								-- Add the object to a global mismatch list
								found_mismatch := True
								db_interface.mismatch_list.extend (it)
							end
						end
					end
				end -- loop
				if found_mismatch then
					-- Mistmatches found raise and exception
					except.raise ("Version mismatch")
				end
				-- now store everything
				from
				until context.diff_stack.empty
				loop
					check
						is_persistent: context.diff_stack.item.pobject_id /= 0
					end
					if context.diff_stack.item.write_allowed then
						context.diff_stack.item.store_shallow_obj (context)
					else
						io.putstring ("WARNING: skiping past a read_only object. Type: ")
						io.putstring (context.diff_stack.item.generator)
						if context.diff_stack.item.pobject_id /= 0 then
							io.putstring ("  LOID=")
							io.putstring (context.diff_stack.item.external_object_id)
						end
						io.putstring (" stamp: ")
						io.putint (context.diff_stack.item.rights_stamp)
						io.new_line
					end
					context.diff_stack.remove
				end;
			end
			-- store top object
			object.store_shallow_obj (context)
			context.mark_objects_not_in_progress 
			-- Commit to save data and release locks
			if db_interface.transaction_level = 0 then
				db_interface.commit
			end;
			if reset_root_id then
				db_interface.unset_current_root_id
			end
			if reset_db then
				db_interface.unset_current_database
			end
			db_interface.operation_context_stack.remove
		ensure
			not object.db_operation_in_progress
		end


feature {NONE} -- implementation

	pclass: PCLASS
			-- PCLASS for this object type



end

