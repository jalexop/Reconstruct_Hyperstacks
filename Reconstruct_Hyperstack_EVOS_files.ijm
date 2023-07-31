// @Integer(label="Number of Channels", value=3) ch
// @Integer(label="Field of Views (unmerged tile scans)", value=1) FoV
// @Integer(label="Time Points", value=1) TimePoints
// @File (label="Select a directory", style="directory") path
// @String(label="Output Folder Name", value="_outputFolder") OutFolder
sep=File.separator;
filelist = getFileList(path);
for (i = 0; i < lengthOf(filelist); i++) {
    if (endsWith(filelist[i], ".scanprotocol")) { 
        ScanProtocol_file=File.openAsString(path+sep+filelist[i]);
        setStepSizeFromScanProtocol=true;
    } 
}
if(setStepSizeFromScanProtocol){
	StepSize=substring(ScanProtocol_file, indexOf(ScanProtocol_file, "<d2p1:StepSize>"), indexOf(ScanProtocol_file, "</d2p1:StepSize>"));
	StepSize=replace(StepSize, "<d2p1:StepSize>", "");
	StepSize=parseFloat(StepSize);
}else{
	StepSize=1;
}


newFolder=File.getParent(path);
newFolder=newFolder+sep+OutFolder;
File.makeDirectory(newFolder);
setBatchMode(true);
for (i=0; i<FoV; i++)
{
	if (i<10){
		k="0"+i;
	}else{
		k=i;
	}
	File.openSequence(path, " filter=f"+k);
	getDimensions(width, height, channels, slices, frames);
	slices=slices/ch;
	run("Stack to Hyperstack...", "order=xyczt(default) channels="+ch+" slices="+slices+" frames="+TimePoints+" display=Color");
	img=getTitle();
	getPixelSize(unit, pixelWidth, pixelHeight);
	if(unit=="inch" || unit=="inches"){
		unit="um";
		pixelWidth=pixelWidth*25369.86992;
		pixelHeight=pixelHeight*25369.86992;
		setVoxelSize(pixelWidth, pixelHeight, StepSize, unit);
	}
	MetaData=getMetadata("Info");
	if(setStepSizeFromScanProtocol){
		MetaData=MetaData+"\n\nScan Protocol File\n\n"+ScanProtocol_file;
	}else{
		MetaData=MetaData+"\nHyperstack Reconstructed by a macro ()b\n";
	}
	setMetadata("Info", MetaData);
	saveAs("tif", newFolder+sep+img+"_f"+k);
	close();
}

setBatchMode(false);


/*
 * 
 */