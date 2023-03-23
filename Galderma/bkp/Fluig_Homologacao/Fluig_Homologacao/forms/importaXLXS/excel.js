let selectedFile;
cosole.log(window.XLSX);
document.getElementById("input").addEventListener("change", function(event){
	selected.File = event.target.files[0];
});

document.getElementById("converte").addEventListener(click,function(){
	if(selectFile){
		let fileReader = new FileReader();
		fileReader.onload = function(event){
			var data = event.target.result;
			var workbook = XLSX.read(data,{type:"binary"});
			cosole.log(workbook);/*
			workbook.SheetNames.forEach(sheet{
				rowObject = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheet]);
				console.log(rowObject);
				document.getelementById("jsondata").innerHTML;
			}*/
			
		}
	}
})