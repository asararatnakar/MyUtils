
if (process.argv.length < 3) {
    console.log("\nUSAGE: node ascii2text.js <ascii>\n");
    console.log("example: \n");
    console.log('node helloblockachain.js "99 111 110 115 10 110 115 117"\n');
    process.exit();
}

if (process.argv[2].length < 1 ){
   console.log("\nInvalid ASCII value, Exiting ... Retry ...\n");
   process.exit();
}
var str = process.argv[2];
var res = str.split(" ");
var result = '';

for (var i=0;i<res.length;i++) {
  var temp = String.fromCharCode(parseInt(res[i]));
  result += temp;
}
console.log("\nText now is : " +result+"\n");

