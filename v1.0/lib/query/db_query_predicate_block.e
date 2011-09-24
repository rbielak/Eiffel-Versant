-- Copyright (C) 1999 CAL FP Bank
-- Licensed under Eiffel Forum Freeware License, version 1;
-- (see forum.txt)
--
--
-- Predicate block for building query predicate trees
--

class DB_QUERY_PREDICATE_BLOCK
	
inherit
	
	DB_CONSTANTS
	VERSANT_EXTERNALS
	MEMORY
		redefine
			dispose
		end

creation
	
	make_as_and,
	make_as_or,
	make_as_not

feature
	
	operation: INTEGER
			-- which operation "and", "or" or "not"
	
	other_blocks: LIST [DB_QUERY_PREDICATE_BLOCK]
			-- other predicate blocks
	
	add_predicate_block (new_block: like Current) is
		require
			valid_block: new_block /= Void
		do
			if other_blocks = Void then
				!LINKED_LIST[DB_QUERY_PREDICATE_BLOCK]!other_blocks.make
			end
			other_blocks.extend (new_block)
		ensure
			added: other_blocks.has (new_block)
		end

	terms: LIST [DB_QUERY_PREDICATE [ANY]]
			-- term predicates that descibes tests on
			-- atrributes of queried objects
	
	add_predicate_term (new_term : DB_QUERY_PREDICATE [ANY]) is
		require
			valid_term: new_term /= Void
		do
			if terms = Void then
				!LINKED_LIST [DB_QUERY_PREDICATE [ANY]]!terms.make
			end
			terms.extend (new_term)
			if new_term.is_special then
				has_special_terms := True
			end
		ensure
			added: terms.has (new_term)
		end
	
	has_special_terms: BOOLEAN
			-- True if there are special terms present
			
	
	has_special_predicates : BOOLEAN is
			-- Does the expression tree starting at this
			-- point contain special predicates?
		do
			if has_special_terms then
				Result := True
			elseif other_blocks /= Void then
				from other_blocks.start
				until (other_blocks.off or Result)
				loop
					Result := other_blocks.item.has_special_predicates
					other_blocks.forth
				end
			end
		end

feature {VERSANT_DB_CLASS_QUERY, DB_PATH_QUERY, DB_QUERY_PREDICATE_BLOCK, INTERNAL_QUERY, CLASS_SELECT_QUERY}

	to_pointer: POINTER is
			-- Make the block into a C structure. Note that this code presumes that the predicate
			-- block structure is a tree and has not cycles in it.
		local
			pb_vstr: POINTER
			pt_vstr: POINTER
		do
			if pred_block_ptr /= default_pointer then
				-- Free the memory and vstrs
				c_free_pred_block (pred_block_ptr)
			end
			-- make vstr for predicate_blocks
			if other_blocks /= Void then
				from other_blocks.start
				until other_blocks.off
				loop
					pb_vstr := c_build_pred_block_vstr (pb_vstr, 
									    other_blocks.item.to_pointer)
					other_blocks.forth
				end
			end
			if terms /= Void then
				from terms.start
				until terms.off
				loop
					pt_vstr := c_build_whole_pred_vstr (pt_vstr, terms.item.to_pointer)
					terms.forth
				end
			end
			if (pb_vstr /= default_pointer) or (pt_vstr /= default_pointer) then
				pred_block_ptr := c_make_pred_block (operation, pb_vstr, pt_vstr)
			end
			Result := pred_block_ptr
		end
	
	set_operation (op: INTEGER) is
		require
			(op = db_o_and) or (op = db_o_or) or (op = db_o_not)
		do
			operation := op
		end
	
	evaluate_block (in_vstr: VSTR): VSTR is
			-- apply the predicates to the objects in the
			-- vstr and return vstr of one's that match
		local
			term_result_vstr, block_result_vstr: VSTR
			term_result_valid, block_result_valid: BOOLEAN
			size: INTEGER
		do
			-- if the input is empty, so is the result
			if in_vstr /= Void and then in_vstr.exists then
				size := in_vstr.integer_count
				-- apply pred_terms to the objects
				if (terms /= Void) and then (terms.count > 0) then
					term_result_vstr := eval_pred_terms (in_vstr, size)
					term_result_valid := True
				end
				if (other_blocks /= Void) and then (other_blocks.count > 0) then
					block_result_vstr := eval_other_blocks (in_vstr)
					block_result_valid := True
				end
				-- Combine the results
				if term_result_valid and block_result_valid then
					Result := term_result_vstr
					if operation = db_o_or then
						Result.union_with (block_result_vstr)
						block_result_vstr.dispose_area
					else
						Result.intersect_with (block_result_vstr)
						block_result_vstr.dispose_area
					end
				elseif term_result_valid then
					Result := term_result_vstr
				elseif block_result_valid then
					Result := block_result_vstr
				else
					!!Result.make (default_pointer)
				end
			end
		end
	
	eval_other_blocks (in_vstr: VSTR): VSTR is
		local
			one_result: VSTR
		do
			from other_blocks.start
			until other_blocks.off
			loop
				one_result := other_blocks.item.evaluate_block (in_vstr)
				-- combine with the result so far
				if operation = db_o_or then
					-- Union for OR
					if Result = Void then
						Result := one_result
					else
						Result.union_with (one_result)
						one_result.dispose_area
					end
				elseif operation = db_o_and then
					-- Intersection for AND
					if Result = Void then
						Result := one_result
						one_result.intersect_with (in_vstr)
					else
						Result.intersect_with (one_result)
						one_result.dispose_area
					end
				elseif operation = db_o_not then
					-- Complement for NOT
					if Result = Void then
						Result := one_result
						one_result.difference_with (in_vstr)
					else
						Result.difference_with (one_result)
						one_result.dispose_area
					end
				end
				other_blocks.forth
			end
			if Result = Void then
				!!Result.make (default_pointer)
			end
		end

	eval_pred_terms (in_vstr: VSTR; count: INTEGER): VSTR is
			-- Apply all the predicates in this block to
			-- the vstr of object IDs
		local
			i: INTEGER
			object_id: INTEGER
		do
			!!Result.make (default_pointer)
			from i := 1
			until (i > count) 
			loop
				object_id := in_vstr.i_th_integer (i)
				if predicates_true (object_id) then
					Result.extend_integer (object_id)
				end
				i := i + 1
			end
		end
	
	predicates_true (object_id: INTEGER) : BOOLEAN is
			-- Check if predicates are true for a give object_id
		local
			done: BOOLEAN
		do
			-- To make empty predicate evaluate to True for AND and to False for OR
			Result := (operation = db_o_and) 
			from terms.start
			until terms.off or done
			loop
				if operation = db_o_and then -- AND
					Result := Result and terms.item.is_true (object_id)
				        -- Short circuit the evaluation
				        if not Result then
						done := True
					end
				elseif operation = db_o_or then -- OR
					Result := Result or terms.item.is_true (object_id)
				        -- Short circuit the evaluation
				        if Result then
						done := True
					end
				else -- NOT
					-- Only one term for NOT
					Result := not terms.item.is_true (object_id)
					done := True
				end
				terms.forth
			end
		end


feature {NONE}

	pred_block_ptr: POINTER
			-- C structure representing this block

feature

	make_as_and is
		do
			operation := db_o_and
		end
	
	make_as_or is
		do
			operation := db_o_or
		end
	
	make_as_not is
		do
			operation := db_o_not
		end
	
	dispose is
		do
			if pred_block_ptr /= default_pointer then
				c_free_pred_block (pred_block_ptr)
				pred_block_ptr := default_pointer
			end
		end

end -- DB_QUERY_PREDICATE_BLOCK
