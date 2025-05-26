local Tools = {}

function Tools.table_length(input_table)
  local count = 0
  for _ in pairs(input_table) do
    count = count + 1
  end
  return count
end

function Tools.has_items(input_table)
  return Tools.table_length(input_table) > 0
end

function Tools.is_table(obj)
  return type(obj) == "table"
end

function Tools.concat_tables(input_table_1, input_table_2, remove_duplicates)
  local result = {}
  for k, v in pairs(input_table_1) do
    result[k] = v
  end
  for k, v in pairs(input_table_2) do
    result[k] = v
  end
  if remove_duplicates then 
    result = Tools.remove_duplicates(result)
  end
  result.__name = input_table_1.__name
  return result
end

function Tools.print_table(input_table, table_name)
  print('Print Table')
  if Tools.is_table(input_table) then
    print("  Input Table: " .. (input_table.__name or "No Name Given"))
    for k, v in pairs(input_table) do
      if Tools.is_table(v) then
        local subtable = '  Subtable: ' .. (v.__name or 'no name')
        print(subtable)
      else
        if v ~= input_table.__name then
          print('  ' .. tostring(k) .. tostring(v))
        end
      end
    end
  else
    local is_table_name = (input_table == table_name)
    if is_table_name then
      print('This is a table name')
    end
    local input_type = tostring(type(input_table))
    local error_string = string.format([[
    -----------------------------------
    '%s' of type '%s' is not a table
    -----------------------------------]], 
    input_table, input_type)
    
    print(error_string)
  end
  print('End Print Table \n' )
end

function Tools.get_subtables(input_table)
  local result = {}
  for k, v in pairs(input_table) do
    if Tools.is_table(v) then 
      result[k] = v
    end
  end
  return result
end

function Tools.remove_duplicates(input_table)
  local seen = {}
  local result = {}
  for k, v in pairs(input_table) do
    if not seen[v] then
      result[k] = v
      seen[v] = true
    end
  end
  return result
end

function Tools.remove_item(input_to_remove, input_table)
  local result = {}
  for k, v in pairs(input_table) do
    if v ~= input_to_remove then 
      table.insert(result, v)
    end
  end
  return result
end

function Tools.print_all_tables(input_table)
  local subtable_list = input_table
  subtable_list .__name = 'Subtable List' 

  local subtable_start_count = Tools.table_length(subtable_list)
  local subtable_last_count = subtable_start_count

  local has_more_tables = true

  while has_more_tables do
    for table_name, subtable in pairs(subtable_list) do
      if Tools.is_table(subtable) then
        local loop_subtables = Tools.get_subtables(subtable)
        subtable_list = Tools.concat_tables(subtable_list, loop_subtables)
        local subtable_loop_count = Tools.table_length(subtable_list)
        if subtable_loop_count == subtable_last_count then
          has_more_tables = false
          print('found all tables: ' .. subtable_loop_count)
          break
        else
          subtable_last_count = subtable_loop_count
        end
      end
    end
  end

  for k, v in pairs(subtable_list) do
    Tools.print_table(v, subtable_list.__name)
  end
end
return Tools