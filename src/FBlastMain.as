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
[Bindable]
private var blastSeqString:String="";

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
import flash.net.FileReference;
import flash.net.FileFilter;
import flash.events.Event;
import mx.formatters.NumberBaseRoundType;
import flashx.textLayout.formats.Float;
import mx.charts.PlotChart;
import mx.charts.series.PlotSeries;
import mx.charts.CategoryAxis;
import mx.charts.Legend;

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
	//Alert.show("You have selected check boxes with data values of: " + checkboxArr.toString() );
}

/**Happen when click the Blastbuttn**/
private function BlastClick(str:String):void{
	httpBlastService.url=webServiceString;
	var params:Object = new Object(); 
	selectedProgram=programDropDown.selectedItem.program.toString();
	
	params.datasetString=datasetString;//"data/blast/ptrichocarpa_156/Ptrichocarpa_v156_assebly_unmasked /data/blast/ptrichocarpa_156/Ptrichocarpa_v156_assebly_masked";
	
	params.selectedProgram=selectedProgram;
	blastSeqString=blastTxtinput.text;
	trace(blastSeqString);
	blastSeqString=blastSeqString.replace(/\s+/g, '\n');;
	trace('after'+blastSeqString);
	params.blastSeq=blastSeqString;
	blastTxtinput.text=blastSeqString;
	httpBlastService.send(params); 
	progbar.visible=true;
	//Alert.show(datasetString);
	//Alert.show(params.datasetString,'cor');
}
private function programDropDownChange():void{
	checkboxArr=new Array();
}

public function stripspaces(originalstring:String):String
{
	var original:Array=originalstring.split(" ");
	return(original.join("\n"));
}

private function navigatetoXML():void{
	navigateToURL(new URLRequest('http://'+resultXMLLink), "_blank")
	
}
[Bindable]
private var xmlListCollection:XMLListCollection=new XMLListCollection();  

[Bindable]
private var provider:ArrayCollection= new ArrayCollection();;


/**Called automatically when the result is returned by the mthod getInitialconfig **/
public function httpBlastServiceResults(event:ResultEvent):void {
	provider=new ArrayCollection();
	xmlListCollection=new XMLListCollection();  
	var exprData:Object = JSON.decode(String(event.result));
	resultXMLLink=exprData.outpath.toString();
	
	var myXML:XML = new XML();
	var XML_URL:String = 'http://'+resultXMLLink;
//var XML_URL:String ="http://v22.popgenie.org/FBlastService/tmp/12043.fasta.xml"
	var myXMLURL:URLRequest = new URLRequest(XML_URL);
	var myLoader:URLLoader = new URLLoader(myXMLURL);
	
	myLoader.addEventListener("complete", xmlLoaded);
	
	function xmlLoaded(event:Event):void
	{
		myXML = XML(myLoader.data);
		//xmlMain=myXML;
		xmlListCollection= new XMLListCollection(myXML.BlastOutput_iterations.Iteration);	
		
	//	numberFormatter.rounding = NumberBaseRoundType.NEAREST;
		
		for(var a:int=0; a< xmlListCollection.length;a++){
		//	Alert.show(xmlListCollection[a]["Iteration_query-def"].toString());//POPTR_0020s00420.1
			for(var b:int=0; b< xmlListCollection[a].Iteration_hits.Hit.length();b++){
			//	Alert.show( xmlListCollection[a].Iteration_hits.Hit[b].Hit_def.toString());
				
				for(var c:int=0; c < xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp.length();c++){
					//var testn:String=sprintf("%03d",4);
					
					//var numTmp:Number=Number(parseInt(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_query-from"])+(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-to"]-xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-from"]));
					
					provider.addItem({Iteration_query:xmlListCollection[a]["Iteration_query-def"],
						Hit_def:xmlListCollection[a].Iteration_hits.Hit[b].Hit_def,
						hit_id:xmlListCollection[a].Iteration_hits.Hit[b].Hit_accession,
						Hsp_evalue:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_evalue,
						Hsp_qseq:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_qseq,
					Hsp_hseq:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_hseq,
					Hsp_midline:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_midline,
//					Hsp_hseqAll:'Query:	'+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_query-from"])+'  '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_hseq+'  '+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_query-to"])+
//					'\n      	            '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_midline+'\nSubjct:	'+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-from"])+'  '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_qseq+'  '+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-"]),
					Hsp_hseqAll:'Query:	'+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_query-from"])+'  '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_hseq+'  '+sprintf("%010d",parseInt(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_query-from"])+(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-to"]-xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-from"]))+
					'\n      	            '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_midline+'\nSubjct:	'+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-from"])+'  '+xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_qseq+'  '+sprintf("%010d",xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_hit-to"]),

					Hsp_bitscore:xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_bit-score"],
					
					Identities:(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_identity*100/xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_align-len"]),
					Positive:(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_positive*100/xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_align-len"]),
					Gaps:(xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c].Hsp_gaps*100/xmlListCollection[a].Iteration_hits.Hit[b].Hit_hsps.Hsp[c]["Hsp_align-len"])
					
					
					});		
				
					
					
				}
				
			}
			
		}
		progbar.visible=false;
		if(provider.length>0){
			
		resultsTitleWIndow.visible=true;
		//gc.refresh();
		}else{
			Alert.show("Please check your input format, dont fortget to select at least one dataset plus select the correct program from dropdown list","Input Error");
		}
	}
	
}

private function addDatatoArr():void{
	//xmlListCollection.source=xmlList;
	provider=new ArrayCollection(xmlListCollection.toArray());
	progbar.visible=false;
	
}

private function clickadg():void{
	trace(pppp.selectedItem.toString());
}

/**Import fasta file into input text  area**/
private var fileReference:FileReference;
private var myFilter:FileFilter = new FileFilter("*","*.txt");


private function loadFile():void{ 
	fileReference = new FileReference();
	fileReference.browse([myFilter]);
	fileReference.addEventListener(Event.SELECT,selectFile);
	fileReference.addEventListener(Event.COMPLETE,loadText);
}

private function selectFile(e:Event):void{
	fileReference.load();
}

private function loadText(e:Event):void{
	var data:ByteArray = fileReference.data;
	blastTxtinput.text = data.readUTFBytes(data.bytesAvailable).replace(/\s+/g, '\n');;
	fileReference = null;
}

/**
 *  Create dynamic plot Chart
 */
[Bindable]
public var legendPlot:Legend= new Legend();
[Bindable]
public var myChartPlot:PlotChart=new PlotChart();
public function CreatePlotChart():void {
	
	var series2:PlotSeries;
	
	myChartPlot.showDataTips = true;
	myChartPlot.dataProvider = provider;
	//
	/* Define the category axis. */
	var hAxis:CategoryAxis = new CategoryAxis();
	hAxis.labelFunction=changename;
	hAxis.categoryField = "Hit_def" ;
	myChartPlot.horizontalAxis = hAxis;
	
	/* Add the series. */
	var mySeries:Array=myChartPlot.series;//=new Array();
	
	series2 = new PlotSeries();
	series2.dataProvider=provider;
	series2.xField="Hit_def";
	series2.yField="Hsp_evalue";
	series2.displayName = "test";
	//series2.itemRenderer=mx.charts.renderers.CircleItemRenderer;
	mySeries.push(series2);
	var bgi:RangeSelector=new RangeSelector();
	/*var bgi:GridLines = new GridLines();
	var s:SolidColorStroke = new SolidColorStroke(0xff00ff, 3);
	bgi.setStyle("horizontalStroke",s);
	var c:SolidColor = new SolidColor(0x990033, .2);
	bgi.setStyle("horizontalFill",c);
	var c2:SolidColor = new SolidColor(0x999933, .2);
	bgi.setStyle("horizontalAlternateFill",c2);*/
	myChartPlot.annotationElements = [bgi]
	
	//myChartPlot.annotationElements=[RangeSelector];
	myChartPlot.seriesFilters = [];
	
	myChartPlot.series = mySeries;
	myChartPlot.percentWidth=100;
	myChartPlot.percentHeight=100;
	//myChart1.height=80;
	/* Create a legend. */
	//legend1 = new Legend();
	legendPlot.dataProvider = myChartPlot;
	myChartPlot.styleName="linechart";
	/* Attach chart and legend to the display list. */
	p4.addElement(myChartPlot);
	p4.addElement(legendPlot);
	
}

/**
 * Chart change Label style.
 */

private function changename(item:Object, prevValue:Object, axis:CategoryAxis, categoryItem:Object):String {
	var pattern:RegExp = /_/gi;
	var str1:String=new String();
	str1=item.replace(pattern, " ");
	return str1;
	
}