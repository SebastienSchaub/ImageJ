
// Global variables
var OptimLum=0.8;// set the lum @80% of max intensity
var RefMod=newArray(3);
var RefCAxis=newArray(6);
var CorrInt=newArray(3);
var ScaleUnit="";
var ScalePxlImg=0;

macro "Starting"{
	run("Install...", "install=["+getDirectory("macros")+"MICA\\PlancheHisto.ijm]");
	run("Action Bar","/plugins/ActionBar/PlancheHisto.txt");// info : https://figshare.com/articles/dataset/Custom_toolbars_and_mini_applications_with_Action_Bar/3397603
//	run("Open [1]");
}

//=======================================================
macro "Open [1]"{
	open();
	if (bitDepth()==24) {
		run("RGB Stack");
		run("Make Composite", "display=Composite");
	}
	AddScaleBar();
}

//=======================================================
macro "Reset [2]"{
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		setMinAndMax(0,max);
	}	
}

//=======================================================
macro "Copy [3]"{
//	while (selectionType()==-1)	waitForUser("Draw Ref ROI");
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		if (selectionType()==-1) {
			RefMod[i-1]=GetMod();
		}
		else {
			getRawStatistics(nPixels, mean, min, max, std, histogram);
			RefMod[i-1]=mean;
		}
		getMinAndMax(RefCAxis[2*(i-1)], RefCAxis[2*(i-1)+1]);
	}	
}

//=======================================================
macro "WhiteBal [4]"{
	IsSelection=selectionType()!=-1;
	Stack.getDimensions(width, height, channels, slices, frames);

	if (IsSelection) run("Select None");
	for (ic=1;ic<=channels;ic++){
		Stack.setChannel(ic);
		
		if (IsSelection) {
			run("Restore Selection");
			getMinAndMax(mn, mx);
			getRawStatistics(nPixels, mean, min, max, std, histogram);
			RefMod[ic-1]=mean;
			run("Select None");
		}
		else {
//			RefMod[ic-1]=GetMod();
			getMinAndMax(mn, mx);
			RefMod[ic-1]=getValue("Mode");
		}
		CorrInt[ic-1]=RefMod[ic-1]/(mn+OptimLum*(mx-mn));
		RefCAxis[2*(ic-1)]=mn*CorrInt[ic-1];
		RefCAxis[2*(ic-1)+1]=mx*CorrInt[ic-1];
		setMinAndMax(RefCAxis[2*(ic-1)], RefCAxis[2*(ic-1)+1]);
	}	
	if (IsSelection) run("Restore Selection");
}

//=======================================================
macro "Paste [5]"{
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getMinAndMax(mn, mx);
		if (selectionType()==-1) TmpRefMod=GetMod();
		else {
			getRawStatistics(nPixels, mean, min, max, std, histogram);
			TmpRefMod=mean;
		}
		
		LumMod=(RefMod[i-1]-RefCAxis[2*(i-1)])/(RefCAxis[2*(i-1)+1]-RefCAxis[2*(i-1)]);
		k=TmpRefMod/(LumMod*(mx-mn)+mn);
		setMinAndMax(k*mn, k*mx);
	}	
}

//=======================================================
macro "Apply [6]"{
	IsSelection=selectionType()!=-1;
	Stack.getDimensions(width, height, channels, slices, frames);
	if (IsSelection) run("Select None");
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		setMinAndMax(RefCAxis[2*(i-1)], RefCAxis[2*(i-1)+1]);
	}	
	if (IsSelection) run("Restore Selection");
}

//=======================================================
macro "Scale [7]"{
	if (Overlay.hidden) Overlay.show;
	else Overlay.hide;
}

//=======================================================
macro "Export [8]"{
	IsSelection=selectionType()!=-1;
	ImgDir=getInfo("image.directory");
	ImgName=getInfo("image.filename");
	if (IsSelection) run("Select None");
	run("Duplicate...", "duplicate");
	run("RGB Color");
	run("Hide Overlay");
	corename=substring(ImgName,0,lastIndexOf(ImgName, "."));
	save(ImgDir+corename+"_WB.tif");
	close();
	if (IsSelection) run("Restore Selection");
}

//=======================================================
macro "Parameters [0]"{
	getPixelSize(ScaleUnit, ScalePxlImg, pixelHeight);
     	
  	myhelp = "<html>"
     +"Specific microscope from Microscopy Platform of Villefranche/Mer"
     +"<h2>Imager A2 : </h2>"
     +"<table border=2><tr><td>Obj</td><td>5x</td><td>10x</td><td>20x</td><td>40x</td><td>63x</td></tr>"
     +"<tr><td>&mu;m</td><td>0.930</td><td>0.465</td><td>0.232</td><td>0.116</td><td>0.74</td></tr>"
     +"</table>"
     +"<h2>Observer : </h2>"
     +"<table border=2><tr><td>Obj</td><td>5x</td><td>10x</td><td>20x</td><td>40x</td><td>63x</td></tr>"
     +"<tr><td>&mu;m</td><td>1.30</td><td>0.650</td><td>0.325</td><td>0.162</td><td>0.103</td></tr>"
     +"</table>"
     +"<h2>Axiovert 200M : </h2>"
     +"<table border=2><tr><td>Obj</td><td>2.5x</td><td>5x</td><td>10x</td><td>20x</td><td>40x</td><td>63x</td></tr>"
     +"<tr><td>&mu;m</td><td>2.6</td><td>1.30</td><td>0.650</td><td>0.325</td><td>0.162</td><td>0.103</td></tr>"
     +"</table>"   
     +"</html>";
	Dialog.create("PlancheHisto Parameters");
	Dialog.addNumber("Optim Lum [0..1]", OptimLum);
	Dialog.addMessage("Red  =[ "+round(RefCAxis[0])+".("+round(RefMod[0])+")."+round(RefCAxis[1])+" ]") 
	Dialog.addMessage("Green=[ "+round(RefCAxis[2])+".("+round(RefMod[1])+")."+round(RefCAxis[3])+" ]") 
	Dialog.addMessage("Blue =[ "+round(RefCAxis[4])+".("+round(RefMod[2])+")."+round(RefCAxis[5])+" ]") 
	Dialog.addMessage("=== SCALING ===",12,"#ff0000");
	Dialog.addNumber("Img PxlSze", ScalePxlImg);
	Dialog.addString("Unit", ScaleUnit, 8);
	Dialog.addHelp(myhelp);
	Dialog.show();
	OptimLum = Dialog.getNumber();
	ScalePxlImg = Dialog.getNumber();
	ScaleUnit = Dialog.getString();
	Stack.setXUnit(ScaleUnit);
	Stack.setYUnit(ScaleUnit);
	run("Properties...", "pixel_width="+ScalePxlImg+" pixel_height="+ScalePxlImg);
	AddScaleBar();
}

//--------------------------------------------------------
function GetMod(){
	nBins = 256;
	getHistogram(values, counts, nBins);
	i_max = 0;
	N_max = 0;
	for(i=1; i<nBins; i++){
	    if(counts[i]>N_max){
	        N_max = counts[i];
	        i_max = i;
	    }
    }
    return values[i_max];
}  

//--------------------------------------------------------
function AddScaleBar(){
	getPixelSize(ScaleUnit, ScalePxlImg, pixelHeight);
	W=getWidth();
	W2=ScalePxlImg*W/20;
	if (W2>1000) W2=Math.ceil(W2/1000)*1000;
	if ((W2<1000) & (W2>=100)) W2=Math.ceil(W2/100)*100;
	if ((W2<100) & (W2>=10)) W2=Math.ceil(W2/10)*10;
	if ((W2<10) & (W2>=1)) W2=Math.ceil(W2);
	if ((W2<1) & (W2>=0.1)) W2=Math.ceil(10*W2)/10;
	if ((W2<0.1) & (W2>=0.01)) W2=Math.ceil(100*W2)/100;
	if ((W2<0.01)) W2=Math.ceil(1000*W2)/1000;
	run("Remove Overlay");
	run("Scale Bar...", "width="+W2+" height=8 font="+Math.ceil(W/50)+" color=White background=Black location=[Lower Right] bold overlay");
}

/*=======================================================
// OLDER
//=======================================================
function GetRef(){
	while (selectionType()==-1)	waitForUser("Draw Ref ROI");
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		RefMod[i-1]=mean;
		getMinAndMax(RefCAxis[2*(i-1)], RefCAxis[2*(i-1)+1]);
	}
}

//=======================================================
function CopyRef(){
	while (selectionType()==-1)	waitForUser("Draw Ref ROI");
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getMinAndMax(mn, mx);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		LumMod=(RefMod[i-1]-RefCAxis[2*(i-1)])/(RefCAxis[2*(i-1)+1]-RefCAxis[2*(i-1)]);
		k=mean/(LumMod*(mx-mn)+mn);
		setMinAndMax(k*mn, k*mx);
	}
}


//=======================================================
function SetWB(){
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getMinAndMax(mn, mx);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		RefMod[i-1]=mean;
		CorrInt[i-1]=mean/(mn+OptimLum*(mx-mn));
		RefCAxis[2*(i-1)]=mn*CorrInt[i-1];
		RefCAxis[2*(i-1)+1]=mx*CorrInt[i-1];
		setMinAndMax(RefCAxis[2*(i-1)], RefCAxis[2*(i-1)+1]);
	}
}

/*=======================================================
//OLDER


//=======================================================
function SetWB(){
	setBatchMode("hide");
	TmpMod=GetMean();
	TmpCAxis=GetCAxis();	
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1;i<=channels;i++){
		mn=TmpCAxis[2*(i-1)];
		mx=TmpCAxis[2*(i-1)+1];
		
		CorrInt[i-1]=TmpMod[i-1]/(mn+OptimLum*(mx-mn));
		Stack.setChannel(i);
		setMinAndMax(TmpCAxis[2*(i-1)]*CorrInt[i-1], TmpCAxis[2*(i-1)+1]*CorrInt[i-1]);
		getMinAndMax(mn, mx);
		k=(TmpMod[i-1]-mn)/(mx-mn);
//		print(""+CorrInt[i-1]+">"+k+" ["+TmpCAxis[2*(i-1)]+","+TmpCAxis[2*(i-1)+1]+"] => ["+TmpCAxis[2*(i-1)]*CorrInt[i-1]+","+TmpCAxis[2*(i-1)+1]*CorrInt[i-1]+"]");
		print(""+CorrInt[i-1]+">"+k+" ["+TmpCAxis[2*(i-1)]+","+TmpCAxis[2*(i-1)+1]+"] => ["+mn+","+mx+"]");
	}
	setBatchMode("exit and display");
}
//=======================================================
function GetRef(){
	while (selectionType()==-1)	waitForUser("Draw Ref ROI");
	RefMod=GetMod();
	RefCAxis=GetCAxis();
}


//=======================================================
// Get Mean Gray per CH
function GetMean(){
	Stack.getDimensions(width, height, channels, slices, frames);
	MyMean=newArray(channels);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getRawStatistics(nPixels, mean, min, max, std, histogram);
		MyMean[i-1]=mean;
	}
	return MyMean;
}

//=======================================================
// Get Modal Gray per CH
function GetMod(){
	Stack.getDimensions(width, height, channels, slices, frames);
	MyMod=newArray(channels);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		MyMod[i-1]=SubGetMod();
	}
	return MyMod;

//--------------------------------------------------------
	function SubGetMod(){
		nBins = 256;
		getHistogram(values, counts, nBins);
		i_max = 0;
		N_max = 0;
		for(i=1; i<nBins; i++){
		    if(counts[i]>N_max){
		        N_max = counts[i];
		        i_max = i;
		    }
	    }
	    return values[i_max];
	}  	
}

//=======================================================
// Get CAxis per CH
function GetCAxis(){
	Stack.getDimensions(width, height, channels, slices, frames);
	CAxis=newArray(2*channels);
	for (i=1;i<=channels;i++){
		Stack.setChannel(i);
		getMinAndMax(CAxis[2*(i-1)], CAxis[2*(i-1)+1]);
	}
	return CAxis;
}
*/