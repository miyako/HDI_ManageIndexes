//%attributes = {"invisible":true}
// Headless verification of the demo form wiring: instantiate the formClass
// the way DIALOG does, then drive the same functions the widgets call --
// drop-down selection (object binding), list box row selection
// (currentItemSource) and the Create/Refresh/Delete button actions -- and
// assert on Form state and on the live catalog via getIndexes().
//
// Run: tool4d --project Project/HDI_ManageIndexes.4DProject
//      --startup-method test_ui --skip-onstartup --data Project/Data/...
// Report: test_ui_report.json in the database folder.

ON ERR CALL("dump_on_err"; ek local)

var $report : Object
$report:=New object

var $dataFolder : 4D.Folder
$dataFolder:=Folder(fk database folder)

var $stage : Text
$stage:="start"
  // checkpoint: the report records how far the test got
$report.stage:=$stage
$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report))

FORM LOAD("HDI2")

	var $before : Integer
	
	  // On Load does not fire for FORM LOAD; the form method calls onLoad()
	Form.onLoad()
	  // a previous run that died between create and delete leaves its index
	  // behind, occupying the one unindexed field; clean up before searching
DELETE INDEX("ui_test_idx")
DELETE INDEX("code_idx")
Form.refresh()
	$stage:="loaded"
	$report.stage:=$stage
	$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report))
	
	  // -- object-bound drop-downs ------------------------------------------------
	$report.tableCount:=Form.tableSelector.values.length
	$report.typeCount:=Form.typeSelector.values.length
	$report.typeFirst:=Form.typeSelector.values[0]
	$report.fieldCount:=Form.fieldSelector.values.length
	$report.suggestedName:=Form.indexName
	$report.statusAfterLoad:=Form.status
	
	  // the drop-down writes .index back on user selection; dropTable's
	  // On Data Change handler then calls loadFields() + refresh()
	Form.tableSelector.index:=1
	Form.loadFields()
	Form.refresh()
	$report.afterTableSwitch:=New object
	$report.afterTableSwitch.status:=Form.status
	$report.afterTableSwitch.fieldCount:=Form.fieldSelector.values.length
	$report.afterTableSwitch.suggestedName:=Form.indexName
	$stage:="tableSwitch"
	$report.stage:=$stage
	$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report))
	
	  // -- create path (btnCreate -> createIndex) ---------------------------------
	  // CREATE INDEX silently ignores a field that already carries an
	  // equivalent index, so create on a table+field that has none
	var $free : Integer
	$free:=-1
	var $t : Integer
	var $f : Integer
	var $row : Object
	For ($t; 0; Form.tableSelector.values.length-1)
		Form.tableSelector.index:=$t
		Form.loadFields()
		Form.refresh()
		
		For ($f; 0; Form.fieldSelector.values.length-1)
			$free:=$f
			For each ($row; Form.indexes)
				If ($row.attributes.indexOf(Form.fieldSelector.values[$f])>=0)
					$free:=-1
				End if 
			End for each 
			If ($free>=0)
				$f:=Form.fieldSelector.values.length
			End if 
		End for 
		
		If ($free>=0)
			$t:=Form.tableSelector.values.length
		End if 
	End for 
	
	If ($free<0)
		  // every field is indexed (e.g. a leftover test index could not be
		  // deleted): report it instead of crashing on values[-1]
		$report.noFreeField:=True
		$report.ok:=False
		$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report; *))
		FORM UNLOAD
		LOG EVENT(Into system standard outputs; "test_ui: no unindexed field found")
		return
	End if 
	
	$report.freeFieldIndex:=$free
	$report.freeFieldName:=Form.fieldSelector.values[$free]
	$report.freeFieldTable:=Form.tableSelector.values[Form.tableSelector.index]
	$before:=Form.indexes.length
	
	Form.fieldSelector.index:=$free
	Form.indexName:="ui_test_idx"
	Form.typeSelector.index:=1
	Form.createIndex()
	$stage:="created"
	$report.stage:=$stage
	$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report))
	
	$report.afterCreate:=New object
	$report.afterCreate.status:=Form.status
	$report.afterCreate.rows:=Form.indexes.length
	$report.afterCreate.found:=False
	
	var $createdRow : Object
	For each ($row; Form.indexes)
		If ($row.name="ui_test_idx")
			$report.afterCreate.found:=True
			$createdRow:=$row
		End if 
	End for each 
	
	  // -- selection + delete path (list box currentItemSource -> btnDelete) -----
	  // what the list box writes on a row click:
	Form.currentIndex:=$createdRow
	Form.deleteIndex()
	
	$report.afterDelete:=New object
	$report.afterDelete.status:=Form.status
	$report.afterDelete.rows:=Form.indexes.length
	
	  // delete with no selection must not throw
	Form.currentIndex:=Null
	Form.deleteIndex()
	$report.deleteNoSelection:=Form.status
	
FORM UNLOAD

$report.ok:=($report.afterCreate.found=True) && ($report.afterCreate.rows=($before+1)) && ($report.afterDelete.rows=$before) && (Position("done"; $report.afterCreate.status)>0)

$dataFolder.file("test_ui_report.json").setText(JSON Stringify($report; *))
