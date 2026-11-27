//%attributes = {"invisible":true}
// Headless verification of the demo logic: dump getIndexes() for every table,
// create and delete indexes, and write a JSON report.
// Usage (tool4d): --startup-method test_indexes --user-param report.json
// A relative output path resolves against the database folder.

ON ERR CALL("dump_on_err"; ek local)

LOG EVENT(Into system standard outputs; "test_indexes t01 entry")

var $userParam : Text
var $paramStatus : Integer
  // Get database parameter is a function: the compiler rejects the bare
  // procedure form with "This function has been called as a procedure"
$paramStatus:=Get database parameter(User param value; $userParam)

var $report : Object
$report:=New object
$report.version:=Application version

var $out : 4D.File
If (Position("/"; $userParam)=1)
	$out:=File($userParam)
Else 
	$out:=Folder(fk database folder).file($userParam)
End if 
$out.parent.create()

var $tables : Collection
$tables:=New collection

var $lastTable; $i : Integer
$lastTable:=Last table number

For ($i; 1; $lastTable)
	$tables.push(Table name($i))
End for 

$report.tables:=New object

var $name : Text
For each ($name; $tables)
	$report.tables[$name]:=ds[$name].getIndexes()
	$out.setText(JSON Stringify($report; *))  // checkpoint
End for each 

LOG EVENT(Into system standard outputs; "test_indexes t02 dumps done")

// round trip: create a named B-tree on Persons.firstName through the same
// single-statement formula pattern the demo form uses (CREATE INDEX requires
// a syntactic table reference; the table is only known at runtime)
var $before; $after : Collection
$before:=ds.Persons.getIndexes()

ARRAY POINTER(<>idxFields; 1)
<>idxFields{1}:=Field(2; 2)

EXECUTE FORMULA("CREATE INDEX([Persons]; <>idxFields; 1; \"test_firstName_btree\")")

$after:=ds.Persons.getIndexes()

var $found : Boolean
var $e : Object
For each ($e; $after)
	If ($e.name="test_firstName_btree")
		$found:=True
	End if 
End for each 

$report.createTest:=New object("before"; $before.length; "after"; $after.length; "found"; $found)

LOG EVENT(Into system standard outputs; "test_indexes t03 created")

// delete by name
DELETE INDEX("test_firstName_btree")
$report.afterDeleteByName:=ds.Persons.getIndexes().length

LOG EVENT(Into system standard outputs; "test_indexes t04 deleted by name")

// delete by field pointer (the overload used for unnamed indexes)
ARRAY POINTER(<>idxFields; 1)
<>idxFields{1}:=Field(2; 2)
EXECUTE FORMULA("CREATE INDEX([Persons]; <>idxFields; 1; \"test_firstName_btree\")")
DELETE INDEX(Field(2; 2))
$report.afterDeleteByPointer:=ds.Persons.getIndexes().length

LOG EVENT(Into system standard outputs; "test_indexes t05 deleted by pointer")

$out.setText(JSON Stringify($report; *))

LOG EVENT(Into system standard outputs; "test_indexes t06 done")

If (Application info.headless)
	LOG EVENT(Log info; "test_indexes done")
	QUIT 4D
End if 
