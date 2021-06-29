# MaPlanche-ImageJ

The program helps to adapt white balance between images to get homogeneous gallery. It uses the ActionBar from J.Mutterer 

For simplicity the program and icon images are incorporated in the directory of ImageJ. Unzip the file and copy them in the Fiji folder (no file will be overwritten).
Then run the program in [Home Directory]\macros\Seb\MaPlanche.ijm.

ShortCuts:
[1] : Open. Open an image, if necessary, convert in 3 composite channels
[2] : Reset. Reset each channel to max intensity
[3] : Copy. Copy the relative intensity of (modal/mean) in the range of min& max contrast. if no selection it get the modal gray, if selection it get the mean gray value
[4] : WhitBal. Get the white balance of the relative intensity of (modal/mean) to get each channel at 80% (OptimLum can be adapted) of white. if no selection it get the modal gray, if selection it get the mean gray value
[5] : Paste. Adapt min&max contrast to get the same relative intensity of (modal/mean) per channel
[6] : Apply. Apply the same transformation as necessary for WhitBal. Useful when a reference image is taken in same conditions.
[7] : Export. Save and RGB image in the same folder as original one withe the extension "WB.tif". The Scale bar is removed before saving.
[0] : Parameter. Let tune the OptimLum paramameter and to scale the image

for information contact sebastien.schaub@imev-mer.fr
for details about ActionBar, see:
https://imagejdocu.tudor.lu/doku.php?id=plugin:utilities:action_bar:start#installation
