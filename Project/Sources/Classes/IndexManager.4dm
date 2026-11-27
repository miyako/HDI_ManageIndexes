// IndexManager -- formClass of the HDI2 demo form.
//
// Demonstrates programmatic index management around DataClass.getIndexes()
// (4D 21 R5): enumerate tables and fields with the classic Structure Access
// commands, report every index of the selected dataclass, create an index
// with CREATE INDEX, delete it with DELETE INDEX, and verify each operation
// by calling getIndexes() again.

Function onLoad()
	
	var $tables : Collection
	$tables:=This.listTables()
	
	Form.tableSelector:=New object
	Form.tableSelector.values:=$tables
	Form.tableSelector.index:=0
	Form.tableSelector.currentValue:=$tables[0]
	
	Form.typeSelector:=New object
	Form.typeSelector.values:=New collection("Default"; "B-tree"; "Cluster B-tree"; "Keywords"; "Vector cosine"; "Vector dot"; "Vector euclidean")
	Form.typeSelector.index:=0
	Form.typeSelector.currentValue:="Default"
	
	Form.unique:=False
	Form.indexName:=""
	Form.status:=""
	
	This.loadFields()
	This.refresh()
	

Function loadFields()
	
	Form.fieldSelector:=New object
	Form.fieldSelector.values:=This.listFields(This.selectedValue(Form.tableSelector))
	Form.fieldSelector.index:=0
	Form.fieldSelector.currentValue:=Form.fieldSelector.values[0]
	Form.indexName:=Form.fieldSelector.values[0]+"_idx"
	

Function refresh()
	
	var $tableName : Text
	$tableName:=This.selectedValue(Form.tableSelector)
	
	var $indexes : Collection
	$indexes:=ds[$tableName].getIndexes()
	
	Form.indexes:=New collection
	
	var $index : Object
	For each ($index; $indexes)
		  // unnamed indexes (primary key, keywords) have no name property
		Form.indexes.push(New object("name"; Choose($index.name=Null; "(unnamed)"; $index.name); "named"; $index.name#Null; "attributes"; $index.attributes; "typeLabel"; This.typeLabel($index.type); "kind"; $index.kind; "uniqueLabel"; Choose($index.uniqueKey; "yes"; ""); "automaticLabel"; Choose($index.automatic; "yes"; ""); "fieldsLabel"; This.attributesLabel($index.attributes); "UUID"; $index.UUID))
	End for each 
	
	Form.currentIndex:=Null
	Form.json:=JSON Stringify($indexes; *)
	Form.status:=String($indexes.length)+" index(es) on "+$tableName
	

Function createIndex()
	
	var $tableName; $fieldName : Text
	$tableName:=This.selectedValue(Form.tableSelector)
	$fieldName:=This.selectedValue(Form.fieldSelector)
	
	var $name : Text
	$name:=Form.indexName
	If ($name="")
		$name:=$fieldName+"_idx"
	End if 
	
	var $type : Integer
	$type:=This.typeCode(This.selectedValue(Form.typeSelector))
	
	Use (Storage)
		Storage.demoError:=Null
	End use
	ON ERR CALL("ErrorTrap"; ek local)
	
	  // CREATE INDEX requires a syntactic table reference (aTable : Table):
	  // Table($num) or a Pointer variable is rejected with "4D was expecting
	  // a table". The table is only known at runtime, so the call is built as
	  // a single-statement formula over an interprocess pointer array (see
	  // README, "Points of interest").
	ARRAY POINTER(<>idxFields; 1)
	<>idxFields{1}:=Field(This.tableNumber($tableName); This.fieldNumber($fieldName))
	
	var $code : Text
	$code:="CREATE INDEX(["+This.refLiteral($tableName)+"]; <>idxFields; "+String($type)+"; \""+This.nameLiteral($name)+"\")"
	
	EXECUTE FORMULA($code)
	
	ON ERR CALL(""; ek local)
	
	  // refresh first: it resets the status line, then report the outcome
	This.refresh()
	
	If (Storage.demoError#Null)
		Form.status:="CREATE INDEX failed: "+String(Storage.demoError.errorCode)+" "+Storage.demoError.message
	Else 
		  // CREATE INDEX is a silent no-op when the field already carries an
		  // equivalent index (no error, no index): verify the round trip
		var $created : Boolean
		For each ($row; Form.indexes)
			If ($row.name=$name)
				$created:=True
			End if 
		End for each 
		
		If ($created)
			Form.status:="CREATE INDEX "+$name+" (type "+String($type)+") -- done"
		Else 
			Form.status:="No new index: "+$fieldName+" already carries an equivalent index."
		End if 
		
	End if 
	

Function deleteIndex()
	
	var $selected : Object
	$selected:=Form.currentIndex
	
	If ($selected=Null)
		Form.status:="Select an index in the list first."
		return 
	End if 
	
	Use (Storage)
		Storage.demoError:=Null
	End use
	ON ERR CALL("ErrorTrap"; ek local)
	
	var $done : Text
	
	If ($selected.named)
		
		DELETE INDEX($selected.name)
		$done:="DELETE INDEX(\""+$selected.name+"\") -- done"
		
	Else 
		
		// unnamed index (primary key, keywords): DELETE INDEX accepts a field
		// pointer and removes every index built on that field
		var $fieldPtr : Pointer
		$fieldPtr:=This.fieldPointer($selected.attributes[0])
		
		If ($fieldPtr#Null)
			DELETE INDEX($fieldPtr)
			$done:="DELETE INDEX(field pointer) -- unnamed index removed"
		Else 
			$done:="Cannot resolve the field of this index."
		End if 
		
	End if 
	
	ON ERR CALL(""; ek local)
	
	  // refresh first: it resets the status line, then report the outcome
	This.refresh()
	
	If (Storage.demoError#Null)
		Form.status:="DELETE INDEX failed: "+String(Storage.demoError.errorCode)+" "+Storage.demoError.message
	Else 
		Form.status:=$done
	End if 
	
	

// private

Function tableNumber($tableName : Text) : Integer
	
	var $lastTable; $i : Integer
	$lastTable:=Last table number
	
	For ($i; 1; $lastTable)
		If (Table name($i)=$tableName)
			return $i
		End if 
	End for 
	
	return 0
	

Function listTables() : Collection
	
	var $names : Collection
	$names:=New collection
	
	var $lastTable; $i : Integer
	$lastTable:=Last table number
	
	For ($i; 1; $lastTable)
		$names.push(Table name($i))
	End for 
	
	return $names.sort()
	

Function listFields($tableName : Text) : Collection
	
	var $names : Collection
	$names:=New collection
	
	var $tableNum; $lastField; $i : Integer
	$tableNum:=This.tableNumber($tableName)
	$lastField:=Last field number($tableNum)
	
	For ($i; 1; $lastField)
		$names.push(Field name($tableNum; $i))
	End for 
	
	return $names.sort()
	

Function fieldNumber($fieldName : Text) : Integer
	
	var $tableNum; $lastField; $i : Integer
	$tableNum:=This.tableNumber(This.selectedValue(Form.tableSelector))
	$lastField:=Last field number($tableNum)
	
	For ($i; 1; $lastField)
		If (Field name($tableNum; $i)=$fieldName)
			return $i
		End if 
	End for 
	
	return 0
	

Function fieldPointer($fieldName : Text) : Pointer
	
	var $fieldNum : Integer
	$fieldNum:=This.fieldNumber($fieldName)
	
	If ($fieldNum=0)
		return Null
	End if 
	
	return Field(This.tableNumber(This.selectedValue(Form.tableSelector)); $fieldNum)
	

Function typeLabel($type : Integer) : Text
	
	Case of 
		: ($type=-1)
			return "keywords"
		: ($type=0)
			return "default"
		: ($type=1)
			return "B-tree"
		: ($type=3)
			return "cluster"
		: ($type=4)
			return "vector cosine"
		: ($type=5)
			return "vector dot"
		: ($type=6)
			return "vector euclidean"
		Else 
			return "type "+String($type)
	End case 
	

Function typeCode($label : Text) : Integer
	
	Case of 
		: ($label="Keywords")
			return -1
		: ($label="B-tree")
			return 1
		: ($label="Cluster B-tree")
			return 3
		: ($label="Vector cosine")
			return 4
		: ($label="Vector dot")
			return 5
		: ($label="Vector euclidean")
			return 6
		Else 
			return 0
	End case 
	

Function attributesLabel($attributes : Collection) : Text
	
	var $labels : Collection
	$labels:=New collection
	
	var $attr : Variant
	For each ($attr; $attributes)
		If (Value type($attr)=Is object)
			$labels.push($attr.name)
		Else 
			$labels.push(String($attr))
		End if 
	End for each 
	
	return $labels.join(", ")
	

Function selectedValue($selector : Object) -> $value : Text
	
	  // object-bound drop-down: index is the source of truth; currentValue is
	  // display text and can still hold the initial placeholder on some builds
	
	If ($selector=Null)
		$value:=""
	Else 
		
		If ($selector.index>=0)
			$value:=$selector.values[$selector.index]
		Else 
			$value:=$selector.currentValue
		End if 
		
	End if 
	

Function refLiteral($identifier : Text) : Text
	
	// table and field names come from the structure itself and are used
	// verbatim inside the executed formula
	
	return $identifier
	

Function nameLiteral($name : Text) : Text
	
	// the index name comes from the demo form: escape it for the formula
	
	return Replace string(Replace string($name; "\\"; "\\\\"); "\""; "\\\"")
	
