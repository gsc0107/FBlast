import mx.controls.Alert;
import mx.controls.CheckBox;
import mx.rpc.events.FaultEvent;

[Bindable]
private var webServiceString:String="";
[Bindable]
private var datasetString:String="";
[Bindable]
private var selectedProgram:String="";
[Bindable]
private var resultXMLLink:String="";


import mx.events.IndexChangedEvent;
import mx.rpc.events.ResultEvent;
import mx.controls.Alert;
import mx.collections.ArrayCollection ;
import com.adobe.serialization.json.JSON;
import mx.utils.StringUtil;
import flash.net.URLRequest;
import flash.net.URLLoader;
import mx.collections.XMLListCollection;
import mx.collections.HierarchicalData;
import mx.events.CloseEvent;

[Bindable]
public var nucleotide_checkBoxArrayCol:ArrayCollection=new ArrayCollection() ;
[Bindable]
public var peptide_checkBoxArrayCol:ArrayCollection=new ArrayCollection() ;
[Bindable]
private var programArrayCol:ArrayCollection=new ArrayCollection() ;
public var checkboxArr:Array ;


/**called automatically when app is first run**/
private function initVars():void {
	httpService.send()
	checkboxArr = new Array();
}
/**Called automatically when the result is returned by the mthod getInitialconfig **/
public function handlegetinitialconfigResults(event:ResultEvent):void {
	var exprData:Object = JSON.decode(String(event.result));
	if(exprData.serviceurl[0].toString()!="" ){
		webServiceString=exprData.serviceurl[0].toString();
	}else{
		Alert.show("Please check your JSON file make sure for serviceurl.","Error JSON configuration");
	}
	
	if(exprData.datasets_nucleotide==null){
		Alert.show("Please check the configuration file for nucleotide datasets subsection.","Error JSON configuration unavailable");
	}else{		
		for(var i:int=0;i<exprData.datasets_nucleotide.length;i++){
			nucleotide_checkBoxArrayCol.addItem({label:exprData.datasets_nucleotide[i].label.toString(),path:exprData.datasets_nucleotide[i].path.toString()});
		}
	}
	
	
	if(exprData.datasets_peptide==null){
		Alert.show("Please check the configuration file for protein dataset subsection.","Error JSON configuration unavailable");
	}else{		
		for(var k:int=0;k<exprData.datasets_peptide.length;k++){
			peptide_checkBoxArrayCol.addItem({label:exprData.datasets_peptide[k].label.toString(),path:exprData.datasets_peptide[k].path.toString()});
		}
	}
	
	
	
	if(exprData.programs==null){
		Alert.show("Please check the configuration file for programs subsection.","Error JSON configuration unavailable");
	}else{		
		for(var j:int=0;j<exprData.programs.length;j++){
			programArrayCol.addItem({name:exprData.programs[j].name.toString(),program:exprData.programs[j].program.toString()});
		}
	}
	
} 

/**
 * Handle failed HTTPService component requests. */
private function handlegetInitialconfigFault(event:FaultEvent):Boolean {
	Alert.show("Please check the input format!!");
	return true;
}

/**If the data value passed to this function is in the array return true so that the check box is checked, otherwise return false so the check box is not checked **/
public function getChecked(data:int):Boolean {
	
	var isChecked:Boolean = false ;
	var pos:int = checkboxArr.indexOf( data ) ;
	if ( pos >= 0 ) {
		isChecked = true ;
	}	return isChecked;
	
}


/**Called when the user clicks on a check box The function receives an Object that includes a value for a data field (data is one of the column names in the query
 results used to create the checkboxArrCol above **/
public function updateAudience(genObj:Object):void {
	var pos:int = checkboxArr.indexOf(genObj.path) ;
	if ( pos >= 0 ) {
		checkboxArr.splice( pos,1);
	} else {
		checkboxArr.push( genObj.path ) ;
	}
	
	datasetString=checkboxArr.toString();
	datasetString = StringUtil.trimArrayElements(datasetString,",");
	//datasetString=StringUtil.trimArrayElements(datasetString);
	//Alert.show("You have selected check boxes with data values of: " + checkboxArr.toString() );
}

/**Happen when click the Blastbuttn**/
private function BlastClick(str:String):void{
	httpBlastService.url=webServiceString;
	var params:Object = new Object(); 
	selectedProgram=programDropDown.selectedItem.program.toString();
	//params.datasetString="/data/blast/ptrichocarpa_156/Ptrichocarpa_v156_transcript";
	
	/*var  str:String = " "; 
	for (var i:int = 0; i < checkboxArr.length; i++) {
	str =str+checkboxArr[i]+' ';
	} 
	*/
	//datasetString=datasetString.replace(","," ");
	params.datasetString=datasetString;//"data/blast/ptrichocarpa_156/Ptrichocarpa_v156_assebly_unmasked /data/blast/ptrichocarpa_156/Ptrichocarpa_v156_assebly_masked";
	//blastTxtinput.text=datasetString;
	params.selectedProgram=selectedProgram;
	params.blastSeq=blastTxtinput.text
	httpBlastService.send(params); 
	progbar.visible=true;
	//Alert.show(datasetString);
	//Alert.show(params.datasetString,'cor');
}
private function programDropDownChange():void{
	checkboxArr=new Array();
}

private function navigatetoXML():void{
	navigateToURL(new URLRequest('http://'+resultXMLLink), "_blank")
	
}
[Bindable]
private var xmlMain:XML=new XML(); 
[Bindable]
private var xmlList:XMLList=new XMLList(); 
[Bindable]
private var xmlListCollection:XMLListCollection=new XMLListCollection();  
[Bindable]
private var resultArray:Array=new Array();
[Bindable]
private var provider:ArrayCollection= new ArrayCollection();;

[Bindable] private var xlc:XMLListCollection;

/*
public function httpBlastServiceResults2(event:ResultEvent):void {
var exprData:Object = JSON.decode(String(event.result));
resultXMLLink=exprData.outpath.toString();


var myXML:XML = new XML();
var XML_URL:String = 'http://'+resultXMLLink;
var myXMLURL:URLRequest = new URLRequest(XML_URL);
var myLoader:URLLoader = new URLLoader(myXMLURL);
myLoader.addEventListener("complete", xmlLoaded);

function xmlLoaded(event:Event):void
{
myXML = XML(myLoader.data);
xmlListCollection= new XMLListCollection(myXML.BlastOutput_iterations);
xmlMain=myXML;

}	
provider=new ArrayCollection(xmlListCollection.toArray());
treeAdg.dataProvider =new HierarchicalData(provider);
}*/



/**Called automatically when the result is returned by the mthod getInitialconfig **/
public function httpBlastServiceResults(event:ResultEvent):void {
	provider=new ArrayCollection();
	//treeAdg.dataProvider=null;
	//gc.source=new ArrayCollection();
	xmlListCollection=new XMLListCollection();  
	var exprData:Object = JSON.decode(String(event.result));
	resultXMLLink=exprData.outpath.toString();
	
	var myXML:XML = new XML();
	var XML_URL:String = 'http://'+resultXMLLink;
	//	var XML_URL:String ="http://v11.popgenie.org/FBlastService/tmp/9541.fasta.xml"
	var myXMLURL:URLRequest = new URLRequest(XML_URL);
	var myLoader:URLLoader = new URLLoader(myXMLURL);
	
	
	//myLoader.addEventListener(Event.COMPLETE, xmlLoaded); 
	
	myLoader.addEventListener("complete", xmlLoaded);
	
	function xmlLoaded(event:Event):void
	{
		myXML = XML(myLoader.data);
		/*	myXML.BlastOutput.BlastOutput_program
		myXML.BlastOutput.BlastOutput_version
		myXML.BlastOutput.BlastOutput_reference
		myXML.BlastOutput.BlastOutput_db
		myXML.BlastOutput.BlastOutput_db.BlastOutput_query-ID
		BlastOutput_query-def
		BlastOutput_query-len*/
		//	BlastOutput= new XMLListCollection();
		//BlastOutput.source=myXML.BlastOutput.BlastOutput_iterations.Iteration_hits.Hit;
		xmlMain=myXML;
		//xlc = new XMLListCollection(XMLList(myXML)..BlastOutput);
		//	xmlListCollection= new XMLListCollection(myXML.BlastOutput_iterations.Iteration.Iteration_hits.Hit); //Iteration.Iteration_hits.Hit.Hit.Hit_hsps.Hsp
		
		xmlListCollection= new XMLListCollection(myXML.BlastOutput_iterations.Iteration);	
		
		for(var a:int=0; a< xmlListCollection.length;a++){
			//	Alert.show(xmlListCollection[a]["Iteration_query-def"].toString());//POPTR_0020s00420.1
			for(var b:int=0; b< xmlListCollection[a].Iteration_hits.Hit.length();b++){
				//	Alert.show( xmlListCollection[a].Iteration_hits.Hit[b].Hit_def.toString());
				
				for(var c:int=0; c < xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp.length();c++){
					//Alert.show(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_evalue.toString());
					provider.addItem({Iteration_query:xmlListCollection[a]["Iteration_query-def"],
						Hit_def:xmlListCollection[a].Iteration_hits.Hit[b].Hit_def+'->'+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_bit-score"],
						Hsp_evalue:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_evalue,
						Hsp_qseq:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_qseq,
						Hsp_hseq:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_hseq,
						Hsp_midline:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_midline,
						Hsp_hseqAll:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_hseq+'\n'+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_midline+'\n'+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_qseq,
						Hsp_bitscore:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_bit-score"]});		
					
				}
				
				
			}
			
		}
		progbar.visible=false;
		resultsTitleWIndow.visible=true;
		gc.refresh();
		//resultsTitleWIndow.addEventListener(CloseEvent.CLOSE,resultsTitleWIndow.visible=false);
		//treeAdg.dataProvider=provider;
		/*	Alert.show('Output Param: '+myXML.BlastOutput_param.toString());
		Alert.show('Iterations: '+myXML.BlastOutput_iterations.toString());
		Alert.show('DB: '+myXML.BlastOutput_db.toString());*/
		//	for each (var myXML:XML in xmlListCollection)
		//{
		//	Alert.show(myXML.BlastOutput_iterations.Iteration.Iteration_hits.Hit.Hit_hsps.toString());
		//}
		
		/*input.childrenField = "Iteration_query-def" ;
		pppp.dataProvider = new HierarchicalData(xmlListCollection);*/
		var expData:Object= new Object();
		
		//	provider=new ArrayCollection(xmlListCollection.toArray());
		
		/*	for(var w:int=0;w<xmlListCollection.length;w++){
		for(var j:int=0;j<xmlListCollection[w].Hit_hsps.Hsp.length();j++){
		provider.addItem({label:xmlListCollection[w].Hit_def,Hsp_num:xmlListCollection[w].Hit_hsps.Hsp[j].Hsp_num});
		}
		}*/
		//Alert.show(provider.toString());
		//for(var i:int=0;i<xmlListCollection.length;i++){
		//	Alert.show(xmlListCollection[i].toString());
		//}
		
		//	xmlList=myXML.BlastOutput_iterations.Iteration.Iteration_hits.Hit.Hit_hsps.Hsp as XMLList;
		//addDatatoArr();
		//xmlResults.text=myXML.toString();
	}
	//treeAdg.dataProvider =new HierarchicalData(provider);
}

private function addDatatoArr():void{
	xmlListCollection.source=xmlList;
	provider=new ArrayCollection(xmlListCollection.toArray());
	
	
	//	Alert.show(provider.toString());
	
	progbar.visible=false;
	
}
private function clickadg():void{
	trace(pppp.selectedItem.toString());
}